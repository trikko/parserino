module parserino.lexbor.core.diyfp;

// D port of lexbor (https://github.com/lexbor/lexbor), Apache-2.0.
// Original author: Alexander Borisov <borisov@lexbor.com>

public import core.stdc.math;
public import parserino.lexbor.core.base;

extern(C) @nogc nothrow:
__gshared:

// ---- diyfp.h ----
/*
 * Copyright (C) 2015-2019 NGINX, Inc.
 * Copyright (C) 2019-2025 F5, Inc.
 * Copyright (C) 2015-2021 Igor Sysoev
 * Copyright (C) 2017-2025 Dmitry Volyntsev
 * Copyright (C) 2019-2022 Alexander Borisov
 * Copyright (C) 2022-2025 Vadim Zhestikov
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 */

/*
 * Copyright (C) Alexander Borisov
 *
 * Based on nxt_diyfp.h from NGINX NJS project
 * An internal diy_fp implementation.
 * For details, see Loitsch, Florian. "Printing floating-point numbers quickly
 * and accurately with integers." ACM Sigplan Notices 45.6 (2010): 233-243.
 */
enum LEXBOR_DBL_SIGNIFICAND_SIZE = 52;
enum LEXBOR_DBL_EXPONENT_BIAS = (0x3FF + LEXBOR_DBL_SIGNIFICAND_SIZE);
enum LEXBOR_DBL_EXPONENT_MIN = (-LEXBOR_DBL_EXPONENT_BIAS);
enum LEXBOR_DBL_EXPONENT_MAX = (0x7FF - LEXBOR_DBL_EXPONENT_BIAS);
enum LEXBOR_DBL_EXPONENT_DENORMAL = (-LEXBOR_DBL_EXPONENT_BIAS + 1);

enum LEXBOR_DBL_SIGNIFICAND_MASK = (((uint64_t) (0x000FFFFF) << 32) + (0xFFFFFFFF));
enum LEXBOR_DBL_HIDDEN_BIT = (((uint64_t) (0x00100000) << 32) + (0x00000000));
enum LEXBOR_DBL_EXPONENT_MASK = (((uint64_t) (0x7FF00000) << 32) + (0x00000000));

enum LEXBOR_DIYFP_SIGNIFICAND_SIZE = 64;

enum LEXBOR_SIGNIFICAND_SIZE = 53;
enum LEXBOR_SIGNIFICAND_SHIFT = (LEXBOR_DIYFP_SIGNIFICAND_SIZE - LEXBOR_DBL_SIGNIFICAND_SIZE);

enum LEXBOR_DECIMAL_EXPONENT_OFF = 348;
enum LEXBOR_DECIMAL_EXPONENT_MIN = (-348);
enum LEXBOR_DECIMAL_EXPONENT_MAX = 340;
enum LEXBOR_DECIMAL_EXPONENT_DIST = 8;

struct lexbor_diyfp_t {
    ulong significand;
    int exp;
}



/*
 * Inline functions
 */

 ulong lexbor_diyfp_leading_zeros64(ulong x)
{
    ulong n = void;

    if (x == 0) {
        return 64;
    }

    n = 0;

    while ((x & 0x8000000000000000) == 0) {
        n++;
        x <<= 1;
    }

    return n;
}

 lexbor_diyfp_t lexbor_diyfp_from_d2(double d)
{
    int biased_exp = void;
    ulong significand = void;
    lexbor_diyfp_t r = void;

    union _U {
        double d = void;
        ulong u64 = void;
    }_U u = void;

    u.d = d;

    biased_exp = (u.u64 & LEXBOR_DBL_EXPONENT_MASK)
                 >> LEXBOR_DBL_SIGNIFICAND_SIZE;
    significand = u.u64 & LEXBOR_DBL_SIGNIFICAND_MASK;

    if (biased_exp != 0) {
        r.significand = significand + LEXBOR_DBL_HIDDEN_BIT;
        r.exp = biased_exp - LEXBOR_DBL_EXPONENT_BIAS;
    }
    else {
        r.significand = significand;
        r.exp = LEXBOR_DBL_EXPONENT_MIN + 1;
    }

    return r;
}

 double lexbor_diyfp_2d(lexbor_diyfp_t v)
{
    int exp = void;
    ulong significand = void, biased_exp = void;

    union _U {
        double d = void;
        ulong u64 = void;
    }_U u = void;

    exp = v.exp;
    significand = v.significand;

    while (significand > LEXBOR_DBL_HIDDEN_BIT + LEXBOR_DBL_SIGNIFICAND_MASK) {
        significand >>= 1;
        exp++;
    }

    if (exp >= LEXBOR_DBL_EXPONENT_MAX) {
        return INFINITY;
    }

    if (exp < LEXBOR_DBL_EXPONENT_DENORMAL) {
        return 0.0;
    }

    while (exp > LEXBOR_DBL_EXPONENT_DENORMAL
           && (significand & LEXBOR_DBL_HIDDEN_BIT) == 0)
    {
        significand <<= 1;
        exp--;
    }

    if (exp == LEXBOR_DBL_EXPONENT_DENORMAL
        && (significand & LEXBOR_DBL_HIDDEN_BIT) == 0)
    {
        biased_exp = 0;

    } else {
        biased_exp = cast(ulong) (exp + LEXBOR_DBL_EXPONENT_BIAS);
    }

    u.u64 = (significand & LEXBOR_DBL_SIGNIFICAND_MASK)
            | (biased_exp << LEXBOR_DBL_SIGNIFICAND_SIZE);

    return u.d;
}

 lexbor_diyfp_t lexbor_diyfp_shift_left(lexbor_diyfp_t v, uint shift)
{
    return lexbor_diyfp_t ( significand: (v.significand << shift), exp: cast(int) (v.exp - shift) );
}

 lexbor_diyfp_t lexbor_diyfp_shift_right(lexbor_diyfp_t v, uint shift)
{
    return lexbor_diyfp_t ( significand: (v.significand >> shift), exp: cast(int) (v.exp + shift) );
}

 lexbor_diyfp_t lexbor_diyfp_sub(lexbor_diyfp_t lhs, lexbor_diyfp_t rhs)
{
    return lexbor_diyfp_t ( significand: (lhs.significand - rhs.significand), exp: cast(int) (lhs.exp) );
}

 lexbor_diyfp_t lexbor_diyfp_mul(lexbor_diyfp_t lhs, lexbor_diyfp_t rhs)
{
    ulong a = void, b = void, c = void, d = void, ac = void, bc = void, ad = void, bd = void, tmp = void;

    a = lhs.significand >> 32;
    b = lhs.significand & 0xffffffff;
    c = rhs.significand >> 32;
    d = rhs.significand & 0xffffffff;

    ac = a * c;
    bc = b * c;
    ad = a * d;
    bd = b * d;

    tmp = (bd >> 32) + (ad & 0xffffffff) + (bc & 0xffffffff);

    /* mult_round. */

    tmp += 1U << 31;

    return lexbor_diyfp_t ( significand: (ac + (ad >> 32) + (bc >> 32) + (tmp >> 32)), exp: cast(int) (lhs.exp + rhs.exp + 64) )
                                               ;

}

 lexbor_diyfp_t lexbor_diyfp_normalize(lexbor_diyfp_t v)
{
    return lexbor_diyfp_shift_left(v,
                        cast(uint) lexbor_diyfp_leading_zeros64(v.significand));
}

// ---- diyfp.c ----
/*
 * Copyright (C) 2015-2019 NGINX, Inc.
 * Copyright (C) 2019-2025 F5, Inc.
 * Copyright (C) 2015-2021 Igor Sysoev
 * Copyright (C) 2017-2025 Dmitry Volyntsev
 * Copyright (C) 2019-2022 Alexander Borisov
 * Copyright (C) 2022-2025 Vadim Zhestikov
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 */

/*
 * Copyright (C) Alexander Borisov
 *
 * Based on nxt_diyfp.h from NGINX NJS project
 * An internal diy_fp implementation.
 * For details, see Loitsch, Florian. "Printing floating-point numbers quickly
 * and accurately with integers." ACM Sigplan Notices 45.6 (2010): 233-243.
 */

struct lexbor_diyfp_cpe_t {
  ulong significand;
  short bin_exp;
  short dec_exp;
}

private const(lexbor_diyfp_cpe_t)[88] lexbor_cached_powers = [
  { ((cast(ulong) (0xfa8fd5a0) << 32) + (0x081c0288)), -1220, -348 },
  { ((cast(ulong) (0xbaaee17f) << 32) + (0xa23ebf76)), -1193, -340 },
  { ((cast(ulong) (0x8b16fb20) << 32) + (0x3055ac76)), -1166, -332 },
  { ((cast(ulong) (0xcf42894a) << 32) + (0x5dce35ea)), -1140, -324 },
  { ((cast(ulong) (0x9a6bb0aa) << 32) + (0x55653b2d)), -1113, -316 },
  { ((cast(ulong) (0xe61acf03) << 32) + (0x3d1a45df)), -1087, -308 },
  { ((cast(ulong) (0xab70fe17) << 32) + (0xc79ac6ca)), -1060, -300 },
  { ((cast(ulong) (0xff77b1fc) << 32) + (0xbebcdc4f)), -1034, -292 },
  { ((cast(ulong) (0xbe5691ef) << 32) + (0x416bd60c)), -1007, -284 },
  { ((cast(ulong) (0x8dd01fad) << 32) + (0x907ffc3c)), -980, -276 },
  { ((cast(ulong) (0xd3515c28) << 32) + (0x31559a83)), -954, -268 },
  { ((cast(ulong) (0x9d71ac8f) << 32) + (0xada6c9b5)), -927, -260 },
  { ((cast(ulong) (0xea9c2277) << 32) + (0x23ee8bcb)), -901, -252 },
  { ((cast(ulong) (0xaecc4991) << 32) + (0x4078536d)), -874, -244 },
  { ((cast(ulong) (0x823c1279) << 32) + (0x5db6ce57)), -847, -236 },
  { ((cast(ulong) (0xc2109436) << 32) + (0x4dfb5637)), -821, -228 },
  { ((cast(ulong) (0x9096ea6f) << 32) + (0x3848984f)), -794, -220 },
  { ((cast(ulong) (0xd77485cb) << 32) + (0x25823ac7)), -768, -212 },
  { ((cast(ulong) (0xa086cfcd) << 32) + (0x97bf97f4)), -741, -204 },
  { ((cast(ulong) (0xef340a98) << 32) + (0x172aace5)), -715, -196 },
  { ((cast(ulong) (0xb23867fb) << 32) + (0x2a35b28e)), -688, -188 },
  { ((cast(ulong) (0x84c8d4df) << 32) + (0xd2c63f3b)), -661, -180 },
  { ((cast(ulong) (0xc5dd4427) << 32) + (0x1ad3cdba)), -635, -172 },
  { ((cast(ulong) (0x936b9fce) << 32) + (0xbb25c996)), -608, -164 },
  { ((cast(ulong) (0xdbac6c24) << 32) + (0x7d62a584)), -582, -156 },
  { ((cast(ulong) (0xa3ab6658) << 32) + (0x0d5fdaf6)), -555, -148 },
  { ((cast(ulong) (0xf3e2f893) << 32) + (0xdec3f126)), -529, -140 },
  { ((cast(ulong) (0xb5b5ada8) << 32) + (0xaaff80b8)), -502, -132 },
  { ((cast(ulong) (0x87625f05) << 32) + (0x6c7c4a8b)), -475, -124 },
  { ((cast(ulong) (0xc9bcff60) << 32) + (0x34c13053)), -449, -116 },
  { ((cast(ulong) (0x964e858c) << 32) + (0x91ba2655)), -422, -108 },
  { ((cast(ulong) (0xdff97724) << 32) + (0x70297ebd)), -396, -100 },
  { ((cast(ulong) (0xa6dfbd9f) << 32) + (0xb8e5b88f)), -369, -92 },
  { ((cast(ulong) (0xf8a95fcf) << 32) + (0x88747d94)), -343, -84 },
  { ((cast(ulong) (0xb9447093) << 32) + (0x8fa89bcf)), -316, -76 },
  { ((cast(ulong) (0x8a08f0f8) << 32) + (0xbf0f156b)), -289, -68 },
  { ((cast(ulong) (0xcdb02555) << 32) + (0x653131b6)), -263, -60 },
  { ((cast(ulong) (0x993fe2c6) << 32) + (0xd07b7fac)), -236, -52 },
  { ((cast(ulong) (0xe45c10c4) << 32) + (0x2a2b3b06)), -210, -44 },
  { ((cast(ulong) (0xaa242499) << 32) + (0x697392d3)), -183, -36 },
  { ((cast(ulong) (0xfd87b5f2) << 32) + (0x8300ca0e)), -157, -28 },
  { ((cast(ulong) (0xbce50864) << 32) + (0x92111aeb)), -130, -20 },
  { ((cast(ulong) (0x8cbccc09) << 32) + (0x6f5088cc)), -103, -12 },
  { ((cast(ulong) (0xd1b71758) << 32) + (0xe219652c)), -77, -4 },
  { ((cast(ulong) (0x9c400000) << 32) + (0x00000000)), -50, 4 },
  { ((cast(ulong) (0xe8d4a510) << 32) + (0x00000000)), -24, 12 },
  { ((cast(ulong) (0xad78ebc5) << 32) + (0xac620000)), 3, 20 },
  { ((cast(ulong) (0x813f3978) << 32) + (0xf8940984)), 30, 28 },
  { ((cast(ulong) (0xc097ce7b) << 32) + (0xc90715b3)), 56, 36 },
  { ((cast(ulong) (0x8f7e32ce) << 32) + (0x7bea5c70)), 83, 44 },
  { ((cast(ulong) (0xd5d238a4) << 32) + (0xabe98068)), 109, 52 },
  { ((cast(ulong) (0x9f4f2726) << 32) + (0x179a2245)), 136, 60 },
  { ((cast(ulong) (0xed63a231) << 32) + (0xd4c4fb27)), 162, 68 },
  { ((cast(ulong) (0xb0de6538) << 32) + (0x8cc8ada8)), 189, 76 },
  { ((cast(ulong) (0x83c7088e) << 32) + (0x1aab65db)), 216, 84 },
  { ((cast(ulong) (0xc45d1df9) << 32) + (0x42711d9a)), 242, 92 },
  { ((cast(ulong) (0x924d692c) << 32) + (0xa61be758)), 269, 100 },
  { ((cast(ulong) (0xda01ee64) << 32) + (0x1a708dea)), 295, 108 },
  { ((cast(ulong) (0xa26da399) << 32) + (0x9aef774a)), 322, 116 },
  { ((cast(ulong) (0xf209787b) << 32) + (0xb47d6b85)), 348, 124 },
  { ((cast(ulong) (0xb454e4a1) << 32) + (0x79dd1877)), 375, 132 },
  { ((cast(ulong) (0x865b8692) << 32) + (0x5b9bc5c2)), 402, 140 },
  { ((cast(ulong) (0xc83553c5) << 32) + (0xc8965d3d)), 428, 148 },
  { ((cast(ulong) (0x952ab45c) << 32) + (0xfa97a0b3)), 455, 156 },
  { ((cast(ulong) (0xde469fbd) << 32) + (0x99a05fe3)), 481, 164 },
  { ((cast(ulong) (0xa59bc234) << 32) + (0xdb398c25)), 508, 172 },
  { ((cast(ulong) (0xf6c69a72) << 32) + (0xa3989f5c)), 534, 180 },
  { ((cast(ulong) (0xb7dcbf53) << 32) + (0x54e9bece)), 561, 188 },
  { ((cast(ulong) (0x88fcf317) << 32) + (0xf22241e2)), 588, 196 },
  { ((cast(ulong) (0xcc20ce9b) << 32) + (0xd35c78a5)), 614, 204 },
  { ((cast(ulong) (0x98165af3) << 32) + (0x7b2153df)), 641, 212 },
  { ((cast(ulong) (0xe2a0b5dc) << 32) + (0x971f303a)), 667, 220 },
  { ((cast(ulong) (0xa8d9d153) << 32) + (0x5ce3b396)), 694, 228 },
  { ((cast(ulong) (0xfb9b7cd9) << 32) + (0xa4a7443c)), 720, 236 },
  { ((cast(ulong) (0xbb764c4c) << 32) + (0xa7a44410)), 747, 244 },
  { ((cast(ulong) (0x8bab8eef) << 32) + (0xb6409c1a)), 774, 252 },
  { ((cast(ulong) (0xd01fef10) << 32) + (0xa657842c)), 800, 260 },
  { ((cast(ulong) (0x9b10a4e5) << 32) + (0xe9913129)), 827, 268 },
  { ((cast(ulong) (0xe7109bfb) << 32) + (0xa19c0c9d)), 853, 276 },
  { ((cast(ulong) (0xac2820d9) << 32) + (0x623bf429)), 880, 284 },
  { ((cast(ulong) (0x80444b5e) << 32) + (0x7aa7cf85)), 907, 292 },
  { ((cast(ulong) (0xbf21e440) << 32) + (0x03acdd2d)), 933, 300 },
  { ((cast(ulong) (0x8e679c2f) << 32) + (0x5e44ff8f)), 960, 308 },
  { ((cast(ulong) (0xd433179d) << 32) + (0x9c8cb841)), 986, 316 },
  { ((cast(ulong) (0x9e19db92) << 32) + (0xb4e31ba9)), 1013, 324 },
  { ((cast(ulong) (0xeb96bf6e) << 32) + (0xbadf77d9)), 1039, 332 },
  { ((cast(ulong) (0xaf87023b) << 32) + (0x9bf0ee6b)), 1066, 340 },
];

enum LEXBOR_DIYFP_D_1_LOG2_10 = 0.30102999566398114 /* 1 / log2(10). */;

lexbor_diyfp_t lexbor_cached_power_dec(int exp, int* dec_exp)
{
    uint index = void;
    const(lexbor_diyfp_cpe_t)* cp = void;

    index = (exp + LEXBOR_DECIMAL_EXPONENT_OFF) / LEXBOR_DECIMAL_EXPONENT_DIST;
    cp = &lexbor_cached_powers[index];

    *dec_exp = cp.dec_exp;

    return lexbor_diyfp_t ( significand: (cp.significand), exp: cast(int) (cp.bin_exp) );
}

lexbor_diyfp_t lexbor_cached_power_bin(int exp, int* dec_exp)
{
    int k = void;
    uint index = void;
    const(lexbor_diyfp_cpe_t)* cp = void;

    k = cast(int) ceil((-61 - exp) * LEXBOR_DIYFP_D_1_LOG2_10)
        + LEXBOR_DECIMAL_EXPONENT_OFF - 1;

    index = cast(uint) (k >> 3) + 1;

    cp = &lexbor_cached_powers[index];

    *dec_exp = -(LEXBOR_DECIMAL_EXPONENT_MIN + cast(int) (index << 3));

    return lexbor_diyfp_t ( significand: (cp.significand), exp: cast(int) (cp.bin_exp) );
}
