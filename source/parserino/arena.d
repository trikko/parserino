/++
 A bump allocator: many small allocations, freed all together.

 It also works at compile time (CTFE), where it falls back to the GC,
 so the same parsing code can run both at runtime and at compile time.
+/
module parserino.arena;

import core.stdc.stdlib : malloc, free;
import core.stdc.string : memcpy, memset;

/// Allocate `n` zeroed `T`s with the GC. Only for CTFE.
private T[] gcNew(T)(size_t n) nothrow pure { return new T[n]; }

@nogc nothrow:

/// Call `gcNew` from @nogc code: it is used only in `if (__ctfe)` branches.
package T[] ctfeNew(T)(size_t n) @trusted
{
    alias F = T[] function(size_t) @nogc nothrow pure;
    return (cast(F) &gcNew!T)(n);
}

struct Arena
{
@nogc nothrow:
    @disable this(this);

    /// Allocate `n` zeroed `T`s. It returns `null` if out of memory.
    T[] alloc(T)(size_t n) @trusted
    {
        if (n == 0) return null;
        if (__ctfe) return ctfeNew!T(n);

        auto bytes = n * T.sizeof;
        auto p = allocBytes(bytes, T.alignof);
        if (p is null) return null;
        memset(p, 0, bytes);
        return (cast(T*) p)[0 .. n];
    }

    /// Allocate a single zeroed `T`.
    T* make(T)() @trusted
    {
        auto a = alloc!T(1);
        return a is null ? null : &a[0];
    }

    /// Copy an array into the arena.
    T[] dup(T)(scope const(T)[] src) @trusted
    {
        if (src.length == 0) return null;
        auto a = alloc!T(src.length);
        if (a is null) return null;
        if (__ctfe) { foreach (i, ref x; a) x = cast(T) src[i]; }
        else memcpy(a.ptr, src.ptr, src.length * T.sizeof);
        return a;
    }

    /// Free everything.
    void release() @trusted
    {
        if (__ctfe) { head = null; return; }

        while (head !is null)
        {
            auto next = head.next;
            free(head);
            head = next;
        }
    }

    ~this() { release(); }

    private:

    enum blockSize = 4096;

    static struct Block
    {
        Block* next;
        size_t used;
        size_t size;
    }

    Block* head;

    void* allocBytes(size_t bytes, size_t alignment) @trusted
    {
        if (head !is null)
        {
            auto start = (head.used + alignment - 1) & ~(alignment - 1);
            if (start + bytes <= head.size)
            {
                head.used = start + bytes;
                return cast(ubyte*) head + start;
            }
        }

        auto header = (Block.sizeof + 15) & ~15;
        auto size = header + bytes > blockSize ? header + bytes : blockSize;
        auto b = cast(Block*) malloc(size);
        if (b is null) return null;

        b.size = size;
        b.used = header + bytes;
        b.next = head;
        head = b;
        return cast(ubyte*) b + header;
    }
}

/// A growable array for temporary data (malloc'd, GC in CTFE).
struct Buffer(T)
{
@nogc nothrow:
    @disable this(this);

    void put(T x) @trusted
    {
        if (length == data.length) grow();
        data[length++] = x;
    }

    inout(T)[] opSlice() inout { return data[0 .. length]; }
    ref inout(T) opIndex(size_t i) inout { return data[i]; }
    @property bool empty() const { return length == 0; }
    void clear() { length = 0; }

    ~this() @trusted { if (!__ctfe && data.ptr !is null) free(data.ptr); }

    size_t length;

    private:
    T[] data;

    void grow() @trusted
    {
        auto n = data.length == 0 ? 8 : data.length * 2;
        T[] nd;
        if (__ctfe) nd = ctfeNew!T(n);
        else
        {
            auto p = cast(T*) malloc(n * T.sizeof);
            if (p is null) assert(0, "Out of memory");
            nd = p[0 .. n];
        }

        foreach (i; 0 .. length) nd[i] = data[i];
        if (!__ctfe && data.ptr !is null) free(data.ptr);
        data = nd;
    }
}

unittest
{
    static int ct()
    {
        Arena a;
        auto x = a.alloc!int(3);
        x[1] = 5;
        Buffer!int b;
        foreach (i; 0 .. 20) b.put(i);
        return x[1] * 10000 + b[19] * 100 + cast(int) b.length;
    }

    static assert(ct() == 51920);
    assert(ct() == 51920);
}
