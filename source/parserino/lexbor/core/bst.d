module parserino.lexbor.core.bst;

// D port of lexbor (https://github.com/lexbor/lexbor), Apache-2.0.
// Original author: Alexander Borisov <borisov@lexbor.com>

public import core.stdc.string;
public import parserino.lexbor.core.base;
public import parserino.lexbor.core.dobject;
import parserino.lexbor.core.conv;

extern(C) @nogc nothrow:
__gshared:

// ---- bst.h ----
/*
 * Copyright (C) 2018 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */
alias lexbor_bst_entry_t = lexbor_bst_entry;
alias lexbor_bst_t = lexbor_bst;

alias lexbor_bst_entry_f = bool function(lexbor_bst_t* bst, lexbor_bst_entry_t* entry, void* ctx);

struct lexbor_bst_entry {
    void* value;

    lexbor_bst_entry_t* right;
    lexbor_bst_entry_t* left;
    lexbor_bst_entry_t* next;
    lexbor_bst_entry_t* parent;

    size_t size;
}

struct lexbor_bst {
    lexbor_dobject_t* dobject;
    lexbor_bst_entry_t* root;

    size_t tree_length;
}















// ---- bst.c ----
/*
 * Copyright (C) 2018 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */

lexbor_bst_t* lexbor_bst_create()
{
    return cast(lexbor_bst*) lexbor_calloc(1, lexbor_bst_t.sizeof);
}

lxb_status_t lexbor_bst_init(lexbor_bst_t* bst, size_t size)
{
    lxb_status_t status = void;

    if (bst == null) {
        return LXB_STATUS_ERROR_OBJECT_IS_NULL;
    }

    if (size == 0) {
        return LXB_STATUS_ERROR_WRONG_ARGS;
    }

    bst.dobject = lexbor_dobject_create();
    status = lexbor_dobject_init(bst.dobject, size,
                                 lexbor_bst_entry_t.sizeof);
    if (status != LXB_STATUS_OK) {
        return status;
    }

    bst.root = null;
    bst.tree_length = 0;

    return LXB_STATUS_OK;
}

void lexbor_bst_clean(lexbor_bst_t* bst)
{
    if (bst != null) {
        lexbor_dobject_clean(bst.dobject);

        bst.root = null;
        bst.tree_length = 0;
    }
}

lexbor_bst_t* lexbor_bst_destroy(lexbor_bst_t* bst, bool self_destroy)
{
    if (bst == null) {
        return null;
    }

    bst.dobject = lexbor_dobject_destroy(bst.dobject, true);

    if (self_destroy) {
        return cast(lexbor_bst*) lexbor_free(bst);
    }

    return bst;
}

lexbor_bst_entry_t* lexbor_bst_entry_make(lexbor_bst_t* bst, size_t size)
{
    lexbor_bst_entry_t* new_entry = cast(lexbor_bst_entry*) lexbor_dobject_calloc(bst.dobject);
    if (new_entry == null) {
        return null;
    }

    new_entry.size = size;

    bst.tree_length++;

    return new_entry;
}

lexbor_bst_entry_t* lexbor_bst_insert(lexbor_bst_t* bst, lexbor_bst_entry_t** scope_, size_t size, void* value)
{
    lexbor_bst_entry_t* new_entry = void, entry = void;

    new_entry = cast(lexbor_bst_entry*) lexbor_dobject_calloc(bst.dobject);
    if (new_entry == null) {
        return null;
    }

    new_entry.size = size;
    new_entry.value = value;

    bst.tree_length++;

    if (*scope_ == null) {
        *scope_ = new_entry;
        return new_entry;
    }

    entry = *scope_;

    while (entry != null) {
        if (size == entry.size) {
            if (entry.next) {
                new_entry.next = entry.next;
            }

            entry.next = new_entry;
            new_entry.parent = entry.parent;

            return new_entry;
        }
        else if (size > entry.size) {
            if (entry.right == null) {
                entry.right = new_entry;
                new_entry.parent = entry;

                return new_entry;
            }

            entry = entry.right;
        }
        else {
            if (entry.left == null) {
                entry.left = new_entry;
                new_entry.parent = entry;

                return new_entry;
            }

            entry = entry.left;
        }
    }

    return null;
}

lexbor_bst_entry_t* lexbor_bst_insert_not_exists(lexbor_bst_t* bst, lexbor_bst_entry_t** scope_, size_t size)
{
    lexbor_bst_entry_t* entry = void;

    if (*scope_ == null) {
        *scope_ = lexbor_bst_entry_make(bst, size);

        return *scope_;
    }

    entry = *scope_;

    while (entry != null) {
        if (size == entry.size) {
            return entry;
        }
        else if (size > entry.size) {
            if (entry.right == null) {
                entry.right = lexbor_bst_entry_make(bst, size);
                entry.right.parent = entry;

                return entry.right;
            }

            entry = entry.right;
        }
        else {
            if (entry.left == null) {
                entry.left = lexbor_bst_entry_make(bst, size);
                entry.left.parent = entry;

                return entry.left;
            }

            entry = entry.left;
        }
    }

    return null;
}

lexbor_bst_entry_t* lexbor_bst_search(lexbor_bst_t* bst, lexbor_bst_entry_t* scope_, size_t size)
{
    while (scope_ != null) {
        if (scope_.size == size) {
            return scope_;
        }
        else if (size > scope_.size) {
            scope_ = scope_.right;
        }
        else {
            scope_ = scope_.left;
        }
    }

    return null;
}

lexbor_bst_entry_t* lexbor_bst_search_close(lexbor_bst_t* bst, lexbor_bst_entry_t* scope_, size_t size)
{
    lexbor_bst_entry_t* max = null;

    while (scope_ != null) {
        if (scope_.size == size) {
            return scope_;
        }
        else if (size > scope_.size) {
            scope_ = scope_.right;
        }
        else {
            max = scope_;
            scope_ = scope_.left;
        }
    }

    return max;
}

void* lexbor_bst_remove(lexbor_bst_t* bst, lexbor_bst_entry_t** scope_, size_t size)
{
    lexbor_bst_entry_t* entry = *scope_;

    while (entry != null) {
        if (entry.size == size) {
            return lexbor_bst_remove_by_pointer(bst, entry, scope_);
        }
        else if (size > entry.size) {
            entry = entry.right;
        }
        else {
            entry = entry.left;
        }
    }

    return null;
}

void* lexbor_bst_remove_close(lexbor_bst_t* bst, lexbor_bst_entry_t** scope_, size_t size, size_t* found_size)
{
    lexbor_bst_entry_t* entry = *scope_;
    lexbor_bst_entry_t* max = null;

    while (entry != null) {
        if (entry.size == size) {
            if (found_size) {
                *found_size = entry.size;
            }

            return lexbor_bst_remove_by_pointer(bst, entry, scope_);
        }
        else if (size > entry.size) {
            entry = entry.right;
        }
        else {
            max = entry;
            entry = entry.left;
        }
    }

    if (max != null) {
        if (found_size != null) {
            *found_size = max.size;
        }

        return lexbor_bst_remove_by_pointer(bst, max, scope_);
    }

    if (found_size != null) {
        *found_size = 0;
    }

    return null;
}

void* lexbor_bst_remove_by_pointer(lexbor_bst_t* bst, lexbor_bst_entry_t* entry, lexbor_bst_entry_t** root)
{
    void* value = void;
    lexbor_bst_entry_t* next = void, right = void, left = void;

    bst.tree_length--;

    if (entry.next != null) {
        next = entry.next;
        entry.next = entry.next.next;

        value = next.value;

        lexbor_dobject_free(bst.dobject, next);

        return value;
    }

    value = entry.value;

    if (entry.left == null && entry.right == null) {
        if (entry.parent != null) {
            if (entry.parent.left == entry) entry.parent.left = null;
            if (entry.parent.right == entry) entry.parent.right = null;
        }
        else {
            *root = null;
        }

        lexbor_dobject_free(bst.dobject, entry);
    }
    else if (entry.left == null) {
        if (entry.parent == null) {
            entry.right.parent = null;

            *root = entry.right;

            lexbor_dobject_free(bst.dobject, entry);

            entry = *root;
        }
        else {
            right = entry.right;
            right.parent = entry.parent;

            memcpy(entry, right, lexbor_bst_entry_t.sizeof);

            lexbor_dobject_free(bst.dobject, right);
        }

        if (entry.right != null) {
            entry.right.parent = entry;
        }

        if (entry.left != null) {
            entry.left.parent = entry;
        }
    }
    else if (entry.right == null) {
        if (entry.parent == null) {
            entry.left.parent = null;

            *root = entry.left;

            lexbor_dobject_free(bst.dobject, entry);

            entry = *root;
        }
        else {
            left = entry.left;
            left.parent = entry.parent;

            memcpy(entry, left, lexbor_bst_entry_t.sizeof);

            lexbor_dobject_free(bst.dobject, left);
        }

        if (entry.right != null) {
            entry.right.parent = entry;
        }

        if (entry.left != null) {
            entry.left.parent = entry;
        }
    }
    else {
        left = entry.right;

        while (left.left != null) {
            left = left.left;
        }

        /* Swap */
        entry.size = left.size;
        entry.next = left.next;
        entry.value = left.value;

        /* Change parrent */
        if (entry.right == left) {
            entry.right = left.right;

            if (entry.right != null) {
                left.right.parent = entry;
            }
        }
        else {
            left.parent.left = left.right;

            if (left.right != null) {
                left.right.parent = left.parent;
            }
        }

        lexbor_dobject_free(bst.dobject, left);
    }

    return value;
}

void lexbor_bst_serialize(lexbor_bst_t* bst, lexbor_callback_f callback, void* ctx)
{
    lexbor_bst_serialize_entry(bst.root, callback, ctx, 0);
}

void lexbor_bst_serialize_entry(lexbor_bst_entry_t* entry, lexbor_callback_f callback, void* ctx, size_t tabs)
{
    size_t len = void;
    lxb_char_t[1024] buff = void;

    if (entry == null) {
        return;
    }

    /* Left */
    for (size_t i = 0; i < tabs; i++) {
        callback(cast(lxb_char_t*) "\t", 1, ctx);
    }
    callback(cast(lxb_char_t*) "<left ", 6, ctx);

    if (entry.left) {
        len = lexbor_conv_int64_to_data(cast(long) entry.left.size,
                                        buff.ptr, buff.sizeof);
        callback(buff.ptr, len, ctx);

        callback(cast(lxb_char_t*) ">\n", 2, ctx);
        lexbor_bst_serialize_entry(entry.left, callback, ctx, (tabs + 1));

        for (size_t i = 0; i < tabs; i++) {
            callback(cast(lxb_char_t*) "\t", 1, ctx);
        }
    }
    else {
        callback(cast(lxb_char_t*) "NULL>", 5, ctx);
    }

    callback(cast(lxb_char_t*) "</left>\n", 8, ctx);

    /* Right */
    for (size_t i = 0; i < tabs; i++) {
        callback(cast(lxb_char_t*) "\t", 1, ctx);
    }
    callback(cast(lxb_char_t*) "<right ", 7, ctx);

    if (entry.right) {
        len = lexbor_conv_int64_to_data(cast(long) entry.right.size,
                                        buff.ptr, buff.sizeof);
        callback(buff.ptr, len, ctx);

        callback(cast(lxb_char_t*) ">\n", 2, ctx);
        lexbor_bst_serialize_entry(entry.right, callback, ctx, (tabs + 1));

        for (size_t i = 0; i < tabs; i++) {
            callback(cast(lxb_char_t*) "\t", 1, ctx);
        }
    }
    else {
        callback(cast(lxb_char_t*) "NULL>", 5, ctx);
    }

    callback(cast(lxb_char_t*) "</right>\n", 9, ctx);
}
