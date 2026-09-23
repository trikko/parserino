module parserino.lexbor.core.swar;

// D port of lexbor (https://github.com/lexbor/lexbor), Apache-2.0.
// Original author: Alexander Borisov <borisov@lexbor.com>

public import parserino.lexbor.core.base;

extern(C) @nogc nothrow:
__gshared:

// ---- swar.h ----
/*
 * Copyright (C) 2024 Alexander Borisov
 *
 * Author: Niels Dossche <nielsdos@php.net>
 */
/* 
 * Based on techniques from https://graphics.stanford.edu/~seander/bithacks.html
 */
enum size_t LEXBOR_SWAR_ONES = (~(cast(size_t) 0) / 0xFF);

version (LittleEndian) enum LEXBOR_SWAR_IS_LITTLE_ENDIAN = true; else enum LEXBOR_SWAR_IS_LITTLE_ENDIAN = false;

/*
 * When handling hot loops that search for a set of characters,
 * this function can be used to quickly move the data pointer much
 * closer to the first occurrence of such a character.
 */
 const(lxb_char_t)* lexbor_swar_seek4(const(lxb_char_t)* data, const(lxb_char_t)* end, lxb_char_t c1, lxb_char_t c2, lxb_char_t c3, lxb_char_t c4)
{
    size_t bytes = void, matches = void, t1 = void, t2 = void, t3 = void, t4 = void;

    if (LEXBOR_SWAR_IS_LITTLE_ENDIAN) {
        while (data + size_t.sizeof <= end) {
            memcpy(&bytes, data, size_t.sizeof);

            t1 = bytes ^ (LEXBOR_SWAR_ONES * (c1));
            t2 = bytes ^ (LEXBOR_SWAR_ONES * (c2));
            t3 = bytes ^ (LEXBOR_SWAR_ONES * (c3));
            t4 = bytes ^ (LEXBOR_SWAR_ONES * (c4));
            matches = (((t1) - LEXBOR_SWAR_ONES) & ~(t1) & (LEXBOR_SWAR_ONES * (0x80))) | (((t2) - LEXBOR_SWAR_ONES) & ~(t2) & (LEXBOR_SWAR_ONES * (0x80)))
                      | (((t3) - LEXBOR_SWAR_ONES) & ~(t3) & (LEXBOR_SWAR_ONES * (0x80))) | (((t4) - LEXBOR_SWAR_ONES) & ~(t4) & (LEXBOR_SWAR_ONES * (0x80)));

            if (matches) {
                data += ((((matches - 1) & LEXBOR_SWAR_ONES) * LEXBOR_SWAR_ONES)
                        >> (size_t.sizeof * 8 - 8)) - 1;
                break;
            } else {
                data += size_t.sizeof;
            }
        }
    }

    return data;
}

 const(lxb_char_t)* lexbor_swar_seek3(const(lxb_char_t)* data, const(lxb_char_t)* end, lxb_char_t c1, lxb_char_t c2, lxb_char_t c3)
{
    size_t bytes = void, matches = void, t1 = void, t2 = void, t3 = void;

    if (LEXBOR_SWAR_IS_LITTLE_ENDIAN) {
        while (data + size_t.sizeof <= end) {
            memcpy(&bytes, data, size_t.sizeof);

            t1 = bytes ^ (LEXBOR_SWAR_ONES * (c1));
            t2 = bytes ^ (LEXBOR_SWAR_ONES * (c2));
            t3 = bytes ^ (LEXBOR_SWAR_ONES * (c3));
            matches = (((t1) - LEXBOR_SWAR_ONES) & ~(t1) & (LEXBOR_SWAR_ONES * (0x80))) | (((t2) - LEXBOR_SWAR_ONES) & ~(t2) & (LEXBOR_SWAR_ONES * (0x80)))
                       | (((t3) - LEXBOR_SWAR_ONES) & ~(t3) & (LEXBOR_SWAR_ONES * (0x80)));

            if (matches) {
                data += ((((matches - 1) & LEXBOR_SWAR_ONES) * LEXBOR_SWAR_ONES)
                         >> (size_t.sizeof * 8 - 8)) - 1;
                break;
            } else {
                data += size_t.sizeof;
            }
        }
    }

    return data;
}
