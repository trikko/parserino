/++
 A bump allocator: many small allocations, freed all together.

 It also works at compile time (CTFE), where it falls back to the GC,
 so the same parsing code can run both at runtime and at compile time.
+/
module parserino.arena;

import core.memory : pureMalloc, pureFree;
import core.stdc.string : memcpy, memset;

version (D_BetterC)
{
    // Without druntime there is no GC: the compile-time features are not available.
    package T[] ctfeNew(T)(size_t n) @nogc nothrow pure { assert(0, "CTFE allocation needs druntime"); }
    package T* ctfeNewOne(T)() @nogc nothrow pure { assert(0, "CTFE allocation needs druntime"); }
}
else
{
    /// Allocate `n` zeroed `T`s with the GC. Only for CTFE.
    private T[] gcNew(T)(size_t n) nothrow pure { return new T[n]; }
    private T* gcNewOne(T)() nothrow pure { return new T; }

    /// Call `gcNew` from @nogc code: it is used only in `if (__ctfe)` branches.
    package T[] ctfeNew(T)(size_t n) @trusted @nogc nothrow pure
    {
        alias F = T[] function(size_t) @nogc nothrow pure;
        return (cast(F) &gcNew!T)(n);
    }

    package T* ctfeNewOne(T)() @trusted @nogc nothrow pure
    {
        alias F = T* function() @nogc nothrow pure;
        return (cast(F) &gcNewOne!T)();
    }
}

@nogc nothrow pure @safe:

/// Copy `n` items (memcpy, a loop in CTFE)
void copyItems(T)(T* dst, const(T)* src, size_t n) @system
{
    if (__ctfe) { foreach (i; 0 .. n) dst[i] = cast(T) src[i]; }
    else if (n) memcpy(dst, src, n * T.sizeof);
}

struct Arena
{
@nogc nothrow pure @safe:
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
        // A single object (not an array element) can initialize static data
        if (__ctfe) return ctfeNewOne!T();

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
            pureFree(head);
            head = next;
        }
    }

    ~this() { release(); }

    private:

    enum BlockSize = 4096;

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
        auto size = header + bytes > BlockSize ? header + bytes : BlockSize;
        auto b = cast(Block*) pureMalloc(size);
        if (b is null) return null;

        b.size = size;
        b.used = header + bytes;
        b.next = head;
        head = b;
        return cast(ubyte*) b + header;
    }
}

/++ A growable array for temporary data (malloc'd, GC in CTFE).
 + If memory runs out, the items are not added and `failed` becomes true (and stays true):
 + the owner checks it at the end of its work, as it checks the results of the `Arena`.
 +/
struct Buffer(T)
{
@nogc nothrow pure @safe:
    @disable this(this);

    pragma(inline, true)
    void put(T x) @trusted
    {
        if (length_ == data.length && !grow(length_ + 1)) return;
        data[length_++] = x;
    }

    /// Append many items at once
    pragma(inline, true)
    void put(scope const(T)[] xs) @trusted
    {
        if (xs.length == 0) return;
        if (length_ + xs.length > data.length && !grow(length_ + xs.length)) return;

        if (__ctfe) { foreach (i, x; xs) data[length_ + i] = cast(T) x; }
        else memcpy(data.ptr + length_, xs.ptr, xs.length * T.sizeof);
        length_ += xs.length;
    }

    static if (is(T == char))
    {
        /// Append `s` in ASCII lowercase
        pragma(inline, true)
        void putLower(scope const(char)[] s) @trusted
        {
            auto at = length_;
            put(s);
            if (length_ == at) return;
            foreach (ref c; data[at .. length_])
                if (c >= 'A' && c <= 'Z') c |= 0x20;
        }
    }

    // Forced inlining: these are in the hot loops of the parser
    pragma(inline, true) inout(T)[] opSlice() inout { return data[0 .. length_]; }
    pragma(inline, true) ref inout(T) opIndex(size_t i) inout { return data[i]; }
    pragma(inline, true) @property size_t length() const { return length_; }
    pragma(inline, true) @property bool empty() const { return length_ == 0; }
    pragma(inline, true) void clear() { length_ = 0; }

    /// Remove the last item
    pragma(inline, true) void removeLast() { assert(length_ > 0); length_--; }

    /// Keep only the first `n` items
    pragma(inline, true) void shrinkTo(size_t n) { assert(n <= length_); length_ = n; }

    ~this() @trusted { if (!__ctfe && data.ptr !is null) pureFree(data.ptr); }

    /// Memory ran out: some items were not added
    bool failed;

    private:

    T[] data;
    size_t length_;

    pragma(inline, false)
    bool grow(size_t needed) @trusted
    {
        if (failed) return false;

        auto n = data.length == 0 ? 8 : data.length * 2;
        if (n < needed) n = needed;

        T[] nd;
        if (__ctfe) nd = ctfeNew!T(n);
        else
        {
            auto p = cast(T*) pureMalloc(n * T.sizeof);
            if (p is null) { failed = true; return false; }
            nd = p[0 .. n];
        }

        copyItems(nd.ptr, data.ptr, length_);
        if (!__ctfe && data.ptr !is null) pureFree(data.ptr);
        data = nd;
        return true;
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
