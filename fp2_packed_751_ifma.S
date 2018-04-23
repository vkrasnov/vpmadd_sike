#if defined(__APPLE__)
/* OS X's C ABI prefixes functions with underscore. */
#define C_ABI(x) _ ## x
#define HIDDEN .private_extern
#else
#define C_ABI(x) x
#define HIDDEN .hidden
#endif

#define ACC0 %zmm0
#define ACC1 %zmm1
#define ACC2 %zmm2
#define ACC3 %zmm3
#define ACC4 %zmm4
#define ACC5 %zmm5
#define ACC6 %zmm6
#define ACC7 %zmm7
#define ACC8 %zmm8
#define ACC9 %zmm9
#define ACC10 %zmm10
#define ACC11 %zmm11
#define ACC12 %zmm12
#define ACC13 %zmm13
#define ACC14 %zmm14
#define ACC15 %zmm15

#define A0 %zmm16
#define A1 %zmm17
#define A2 %zmm18
#define A3 %zmm19
#define A4 %zmm20
#define A5 %zmm21
#define A6 %zmm22
#define A7 %zmm23
#define A8 %zmm24
#define A9 %zmm25
#define A10 %zmm26
#define A11 %zmm27
#define A12 %zmm28
#define A13 %zmm29
#define A14 %zmm30

#define B %zmm31

#define rptr %rdi
#define aptr %rsi
#define bptr %rdx

#define r0ptr %rdi
#define a0ptr %rsi
#define b0ptr %rdx

#define r1ptr %rcx
#define a1ptr %r8
#define b1ptr %r9

#define hlp %rax

.p2align 6
.Lmask:
.Lpoly:
.quad 0x000fffffffffffff, 0x000fffffffffffff, 0x000fffffffffffff, 0x000fffffffffffff 
.quad 0x000fffffffffffff, 0x000fffffffffffff, 0x000fffffffffffff, 0x00049f878a8eeaff
.quad 0x0007cc76e3ec9685, 0x00076da959b1a13f, 0x00084e9867d6ebe8, 0x000b5045cb257480
.quad 0x000f97badc668562, 0x00041f71c0e12909, 0x00000000006fe5d5, 0

.LpolyX:
.quad 0x0fffffffffffff00, 0x0fffffffffffff00, 0x0fffffffffffff00, 0x0fffffffffffff00
.quad 0x0fffffffffffff00, 0x0fffffffffffff00, 0x0fffffffffffff00, 0x049f878a8eeaff00
.quad 0x07cc76e3ec968500, 0x076da959b1a13f00, 0x084e9867d6ebe800, 0x0b5045cb25748000
.quad 0x0f97badc66856200, 0x041f71c0e1290900, 0x000000006fe5d500, 0

.Lperm0:
.quad 0,1,0,1,2,3,2,3

.Lperm1:
.quad 4,5,5,4,6,7,7,6

// TODO: avoid transposing every call by keeping data vertical throughout

// Performs 8 field multiplications in parallel
.globl C_ABI(fp2_mul_ifma_x2)
C_ABI(fp2_mul_ifma_x2):

    push %rbp
    mov %rsp, %rbp
    sub $960, %rsp
    and $-64, %rsp

    mov $0x7f, %rax
    kmovq %rax, %k5

    // Load a0[0]
    vmovdqu64 0*64(a0ptr), %zmm0
    vmovdqu64 1*64(a0ptr), %zmm1{%k5}{z}
    lea 15*8(a0ptr), a0ptr
    // Load a0[1]
    vmovdqu64 0*64(a0ptr), %zmm2
    vmovdqu64 1*64(a0ptr), %zmm3{%k5}{z}
    // Load b0[0]
    vmovdqu64 0*64(b0ptr), %zmm4
    vmovdqu64 1*64(b0ptr), %zmm5{%k5}{z}
    lea 15*8(b0ptr), b0ptr
    // Load b0[1]
    vmovdqu64 0*64(b0ptr), %zmm6
    vmovdqu64 1*64(b0ptr), %zmm7{%k5}{z}
    // Load a1[0]
    vmovdqu64 0*64(a1ptr), %zmm8
    vmovdqu64 1*64(a1ptr), %zmm9{%k5}{z}
    lea 15*8(a1ptr), a1ptr
    // Load a1[1]
    vmovdqu64 0*64(a1ptr), %zmm10
    vmovdqu64 1*64(a1ptr), %zmm11{%k5}{z}
    // Load b1[0]
    vmovdqu64 0*64(b1ptr), %zmm12
    vmovdqu64 1*64(b1ptr), %zmm13{%k5}{z}
    lea 15*8(b1ptr), b1ptr
    // Load b1[1]
    vmovdqu64 0*64(b1ptr), %zmm14
    vmovdqu64 1*64(b1ptr), %zmm15{%k5}{z}
    // Transpose
    vpunpcklqdq %zmm2, %zmm0, %zmm16 // 0 0 2 2 4 4 6 6
    vpunpckhqdq %zmm2, %zmm0, %zmm17 // 1 1 3 3 5 5 7 7
    vpunpcklqdq %zmm6, %zmm4, %zmm18 // 0 0 2 2 4 4 6 6
    vpunpckhqdq %zmm6, %zmm4, %zmm19 // 1 1 3 3 5 5 7 7
    vpunpcklqdq %zmm10, %zmm8, %zmm20 // 0 0 2 2 4 4 6 6
    vpunpckhqdq %zmm10, %zmm8, %zmm21 // 1 1 3 3 5 5 7 7
    vpunpcklqdq %zmm14, %zmm12, %zmm22 // 0 0 2 2 4 4 6 6
    vpunpckhqdq %zmm14, %zmm12, %zmm23 // 1 1 3 3 5 5 7 7
    
    vpunpcklqdq %zmm3, %zmm1, %zmm24 // 8 8 10 10 12 12 14 14
    vpunpckhqdq %zmm3, %zmm1, %zmm25 // 9 9 11 11 13 13 15 15
    vpunpcklqdq %zmm7, %zmm5, %zmm26 // 8 8 10 10 12 12 14 14
    vpunpckhqdq %zmm7, %zmm5, %zmm27 // 9 9 11 11 13 13 15 15
    vpunpcklqdq %zmm11, %zmm9, %zmm28 // 8 8 10 10 12 12 14 14
    vpunpckhqdq %zmm11, %zmm9, %zmm29 // 9 9 11 11 13 13 15 15
    vpunpcklqdq %zmm15, %zmm13, %zmm30 // 8 8 10 10 12 12 14 14
    vpunpckhqdq %zmm15, %zmm13, %zmm31 // 9 9 11 11 13 13 15 15

    vshufi64x2 $0x44, %zmm20, %zmm16, %zmm0 // 0 0 2 2 0 0 2 2
    vshufi64x2 $0x44, %zmm22, %zmm18, %zmm1 // 0 0 2 2 0 0 2 2
    vshufi64x2 $0xee, %zmm20, %zmm16, %zmm2 // 4 4 6 6 4 4 6 6
    vshufi64x2 $0xee, %zmm22, %zmm18, %zmm3 // 4 4 6 6 4 4 6 6

    vshufi64x2 $0x44, %zmm21, %zmm17, %zmm4 // 1 1 3 3 1 1 3 3
    vshufi64x2 $0x44, %zmm23, %zmm19, %zmm5 // 1 1 3 3 1 1 3 3
    vshufi64x2 $0xee, %zmm21, %zmm17, %zmm6 // 5 5 7 7 5 5 7 7
    vshufi64x2 $0xee, %zmm23, %zmm19, %zmm7 // 5 5 7 7 5 5 7 7

    vshufi64x2 $0x44, %zmm28, %zmm24, %zmm8 // 8 8 10 10 8 8 10 10
    vshufi64x2 $0x44, %zmm30, %zmm26, %zmm9 // 8 8 10 10 8 8 10 10
    vshufi64x2 $0xee, %zmm28, %zmm24, %zmm10 // 12 12 14 14 12 12 14 14
    vshufi64x2 $0xee, %zmm30, %zmm26, %zmm11 // 12 12 14 14 12 12 14 14

    vshufi64x2 $0x44, %zmm29, %zmm25, %zmm12 // 9 9 11 11 9 9 11 11
    vshufi64x2 $0x44, %zmm31, %zmm27, %zmm13 // 9 9 11 11 9 9 11 11
    vshufi64x2 $0xee, %zmm29, %zmm25, %zmm14 // 13 13 15 15 13 13 15 15
    vshufi64x2 $0xee, %zmm31, %zmm27, %zmm15 // 13 13 15 15 13 13 15 15

    vshufi64x2 $0x88, %zmm1, %zmm0, %zmm16 //0
    vshufi64x2 $0x88, %zmm5, %zmm4, %zmm17 //1
    vshufi64x2 $0xdd, %zmm1, %zmm0, %zmm18 //
    vshufi64x2 $0xdd, %zmm5, %zmm4, %zmm19
    vshufi64x2 $0x88, %zmm3, %zmm2, %zmm20
    vshufi64x2 $0x88, %zmm7, %zmm6, %zmm21
    vshufi64x2 $0xdd, %zmm3, %zmm2, %zmm22
    vshufi64x2 $0xdd, %zmm7, %zmm6, %zmm23
    vshufi64x2 $0x88, %zmm9, %zmm8, %zmm24
    vshufi64x2 $0x88, %zmm13, %zmm12, %zmm25
    vshufi64x2 $0xdd, %zmm9, %zmm8, %zmm26
    vshufi64x2 $0xdd, %zmm13, %zmm12, %zmm27
    vshufi64x2 $0x88, %zmm11, %zmm10, %zmm28
    vshufi64x2 $0x88, %zmm15, %zmm14, %zmm29
    vshufi64x2 $0xdd, %zmm11, %zmm10, %zmm30

    vmovdqa64 .Lperm0(%rip), %zmm31
    vpermq %zmm16, %zmm31, %zmm0
    vpermq %zmm17, %zmm31, %zmm1
    vpermq %zmm18, %zmm31, %zmm2
    vpermq %zmm19, %zmm31, %zmm3
    vpermq %zmm20, %zmm31, %zmm4
    vpermq %zmm21, %zmm31, %zmm5
    vpermq %zmm22, %zmm31, %zmm6
    vpermq %zmm23, %zmm31, %zmm7
    vpermq %zmm24, %zmm31, %zmm8
    vpermq %zmm25, %zmm31, %zmm9
    vpermq %zmm26, %zmm31, %zmm10
    vpermq %zmm27, %zmm31, %zmm11
    vpermq %zmm28, %zmm31, %zmm12
    vpermq %zmm29, %zmm31, %zmm13
    vpermq %zmm30, %zmm31, %zmm14

    .irp r,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14
    vmovdqu64 %zmm\r, \r*64(%rsp)
    .endr

    vmovdqa64 .Lperm1(%rip), %zmm31
    vpermq %zmm16, %zmm31, A0
    vpermq %zmm17, %zmm31, A1
    vpermq %zmm18, %zmm31, A2
    vpermq %zmm19, %zmm31, A3
    vpermq %zmm20, %zmm31, A4
    vpermq %zmm21, %zmm31, A5
    vpermq %zmm22, %zmm31, A6
    vpermq %zmm23, %zmm31, A7
    vpermq %zmm24, %zmm31, A8
    vpermq %zmm25, %zmm31, A9
    vpermq %zmm26, %zmm31, A10
    vpermq %zmm27, %zmm31, A11
    vpermq %zmm28, %zmm31, A12
    vpermq %zmm29, %zmm31, A13
    vpermq %zmm30, %zmm31, A14

    lea (%rsp), bptr
    call do_mul_x2

    // After parallel multiplication the layout is:
    // A0[0] * B0[0], A0[1] * B0[1], A0[0] * B0[1], A0[1] * B0[0], A1[0] * B1[0], A1[1] * B1[1], A1[0] * B1[1], A1[1] * B1[0]
    // We need to compute:
    // A0[0] * B0[0] - A0[1] * B0[1],  A0[0] * B0[1] + A0[1] * B0[0], A1[0] * B1[0] - A0[1] * B1[1],  A1[0] * B1[1] + A1[1] * B1[0]
    vpsrldq $8, ACC0, A0
    vpsrldq $8, ACC1, A1
    vpsrldq $8, ACC2, A2
    vpsrldq $8, ACC3, A3
    vpsrldq $8, ACC4, A4
    vpsrldq $8, ACC5, A5
    vpsrldq $8, ACC6, A6
    vpsrldq $8, ACC7, A7
    vpsrldq $8, ACC8, A8
    vpsrldq $8, ACC9, A9
    vpsrldq $8, ACC10, A10
    vpsrldq $8, ACC11, A11
    vpsrldq $8, ACC12, A12
    vpsrldq $8, ACC13, A13
    vpsrldq $8, ACC14, A14

    mov $0x44, hlp
    kmovq hlp, %k7

    vpaddq A0, ACC0, ACC0{%k7}
    vpaddq A1, ACC1, ACC1{%k7}
    vpaddq A2, ACC2, ACC2{%k7}
    vpaddq A3, ACC3, ACC3{%k7}
    vpaddq A4, ACC4, ACC4{%k7}
    vpaddq A5, ACC5, ACC5{%k7}
    vpaddq A6, ACC6, ACC6{%k7}
    vpaddq A7, ACC7, ACC7{%k7}
    vpaddq A8, ACC8, ACC8{%k7}
    vpaddq A9, ACC9, ACC9{%k7}
    vpaddq A10, ACC10, ACC10{%k7}
    vpaddq A11, ACC11, ACC11{%k7}
    vpaddq A12, ACC12, ACC12{%k7}
    vpaddq A13, ACC13, ACC13{%k7}
    vpaddq A14, ACC14, ACC14{%k7}

    mov $0x11, hlp
    kmovq hlp, %k7

    vpaddq 0*8+.LpolyX(%rip){1to8}, ACC0, ACC0{%k7}
    vpaddq 1*8+.LpolyX(%rip){1to8}, ACC1, ACC1{%k7}
    vpaddq 2*8+.LpolyX(%rip){1to8}, ACC2, ACC2{%k7}
    vpaddq 3*8+.LpolyX(%rip){1to8}, ACC3, ACC3{%k7}
    vpaddq 4*8+.LpolyX(%rip){1to8}, ACC4, ACC4{%k7}
    vpaddq 5*8+.LpolyX(%rip){1to8}, ACC5, ACC5{%k7}
    vpaddq 6*8+.LpolyX(%rip){1to8}, ACC6, ACC6{%k7}
    vpaddq 7*8+.LpolyX(%rip){1to8}, ACC7, ACC7{%k7}
    vpaddq 8*8+.LpolyX(%rip){1to8}, ACC8, ACC8{%k7}
    vpaddq 9*8+.LpolyX(%rip){1to8}, ACC9, ACC9{%k7}
    vpaddq 10*8+.LpolyX(%rip){1to8}, ACC10, ACC10{%k7}
    vpaddq 11*8+.LpolyX(%rip){1to8}, ACC11, ACC11{%k7}
    vpaddq 12*8+.LpolyX(%rip){1to8}, ACC12, ACC12{%k7}
    vpaddq 13*8+.LpolyX(%rip){1to8}, ACC13, ACC13{%k7}
    vpaddq 14*8+.LpolyX(%rip){1to8}, ACC14, ACC14{%k7}

    vpsubq A0, ACC0, ACC0{%k7}
    vpsubq A1, ACC1, ACC1{%k7}
    vpsubq A2, ACC2, ACC2{%k7}
    vpsubq A3, ACC3, ACC3{%k7}
    vpsubq A4, ACC4, ACC4{%k7}
    vpsubq A5, ACC5, ACC5{%k7}
    vpsubq A6, ACC6, ACC6{%k7}
    vpsubq A7, ACC7, ACC7{%k7}
    vpsubq A8, ACC8, ACC8{%k7}
    vpsubq A9, ACC9, ACC9{%k7}
    vpsubq A10, ACC10, ACC10{%k7}
    vpsubq A11, ACC11, ACC11{%k7}
    vpsubq A12, ACC12, ACC12{%k7}
    vpsubq A13, ACC13, ACC13{%k7}
    vpsubq A14, ACC14, ACC14{%k7}
    vpsrlq $52, ACC0, B
    vpaddq B, ACC1, ACC1
    vpandq .Lpoly(%rip){1to8}, ACC0, ACC0

    vpsrlq $52, ACC1, B
    vpaddq B, ACC2, ACC2
    vpandq .Lpoly(%rip){1to8}, ACC1, ACC1

    vpsrlq $52, ACC2, B
    vpaddq B, ACC3, ACC3
    vpandq .Lpoly(%rip){1to8}, ACC2, ACC2

    vpsrlq $52, ACC3, B
    vpaddq B, ACC4, ACC4
    vpandq .Lpoly(%rip){1to8}, ACC3, ACC3

    vpsrlq $52, ACC4, B
    vpaddq B, ACC5, ACC5
    vpandq .Lpoly(%rip){1to8}, ACC4, ACC4

    vpsrlq $52, ACC5, B
    vpaddq B, ACC6, ACC6
    vpandq .Lpoly(%rip){1to8}, ACC5, ACC5

    vpsrlq $52, ACC6, B
    vpaddq B, ACC7, ACC7
    vpandq .Lpoly(%rip){1to8}, ACC6, ACC6

    vpsrlq $52, ACC7, B
    vpaddq B, ACC8, ACC8
    vpandq .Lpoly(%rip){1to8}, ACC7, ACC7

    vpsrlq $52, ACC8, B
    vpaddq B, ACC9, ACC9
    vpandq .Lpoly(%rip){1to8}, ACC8, ACC8

    vpsrlq $52, ACC9, B
    vpaddq B, ACC10, ACC10
    vpandq .Lpoly(%rip){1to8}, ACC9, ACC9

    vpsrlq $52, ACC10, B
    vpaddq B, ACC11, ACC11
    vpandq .Lpoly(%rip){1to8}, ACC10, ACC10

    vpsrlq $52, ACC11, B
    vpaddq B, ACC12, ACC12
    vpandq .Lpoly(%rip){1to8}, ACC11, ACC11

    vpsrlq $52, ACC12, B
    vpaddq B, ACC13, ACC13
    vpandq .Lpoly(%rip){1to8}, ACC12, ACC12

    vpsrlq $52, ACC13, B
    vpaddq B, ACC14, ACC14
    vpandq .Lpoly(%rip){1to8}, ACC13, ACC13

    vpandq .Lpoly(%rip){1to8}, ACC14, ACC14

    // Transpose to horizontal
    vpunpcklqdq ACC1, ACC0, ACC0
    vpunpcklqdq ACC3, ACC2, ACC1
    vpunpcklqdq ACC5, ACC4, ACC2
    vpunpcklqdq ACC7, ACC6, ACC3
    vpunpcklqdq ACC9, ACC8, ACC4
    vpunpcklqdq ACC11, ACC10, ACC5
    vpunpcklqdq ACC13, ACC12, ACC6
    vmovdqa64 ACC14, ACC7

    vshufi64x2 $0x44, ACC1, ACC0, A0
    vshufi64x2 $0x44, ACC3, ACC2, A1
    vshufi64x2 $0x44, ACC5, ACC4, A2
    vshufi64x2 $0x44, ACC7, ACC6, A3

    vshufi64x2 $0xee, ACC1, ACC0, A4
    vshufi64x2 $0xee, ACC3, ACC2, A5
    vshufi64x2 $0xee, ACC5, ACC4, A6
    vshufi64x2 $0xee, ACC7, ACC6, A7

    vshufi64x2 $0x88, A1, A0, ACC0
    vshufi64x2 $0x88, A3, A2, ACC1
    vshufi64x2 $0xdd, A1, A0, ACC2
    vshufi64x2 $0xdd, A3, A2, ACC3

    vshufi64x2 $0x88, A5, A4, ACC4
    vshufi64x2 $0x88, A7, A6, ACC5
    vshufi64x2 $0xdd, A5, A4, ACC6
    vshufi64x2 $0xdd, A7, A6, ACC7

    vmovdqu64 ACC0, 0*64(r0ptr)
    vmovdqu64 ACC1, 1*64(r0ptr){%k5}
    lea 15*8(r0ptr), r0ptr
    vmovdqu64 ACC2, 0*64(r0ptr)
    vmovdqu64 ACC3, 1*64(r0ptr){%k5}

    vmovdqu64 ACC4, 0*64(r1ptr)
    vmovdqu64 ACC5, 1*64(r1ptr){%k5}
    lea 15*8(r1ptr), r1ptr
    vmovdqu64 ACC6, 0*64(r1ptr)
    vmovdqu64 ACC7, 1*64(r1ptr){%k5}

    mov %rbp, %rsp
    pop %rbp
ret

// Performs 8 field multiplications in parallel
.globl C_ABI(amm_751_ifma_x2)
C_ABI(amm_751_ifma_x2):

    vmovdqu64 0*64(aptr), A0
    vmovdqu64 1*64(aptr), A1
    vmovdqu64 2*64(aptr), A2
    vmovdqu64 3*64(aptr), A3
    vmovdqu64 4*64(aptr), A4
    vmovdqu64 5*64(aptr), A5
    vmovdqu64 6*64(aptr), A6
    vmovdqu64 7*64(aptr), A7
    vmovdqu64 8*64(aptr), A8
    vmovdqu64 9*64(aptr), A9
    vmovdqu64 10*64(aptr), A10
    vmovdqu64 11*64(aptr), A11
    vmovdqu64 12*64(aptr), A12
    vmovdqu64 13*64(aptr), A13
    vmovdqu64 14*64(aptr), A14
do_mul_x2:
    vpxorq ACC0, ACC0, ACC0
    vpxorq ACC1, ACC1, ACC1
    vpxorq ACC2, ACC2, ACC2
    vpxorq ACC3, ACC3, ACC3
    vpxorq ACC4, ACC4, ACC4
    vpxorq ACC5, ACC5, ACC5
    vpxorq ACC6, ACC6, ACC6
    vpxorq ACC7, ACC7, ACC7
    vpxorq ACC8, ACC8, ACC8
    vpxorq ACC9, ACC9, ACC9
    vpxorq ACC10, ACC10, ACC10    
    vpxorq ACC11, ACC11, ACC11
    vpxorq ACC12, ACC12, ACC12
    vpxorq ACC13, ACC13, ACC13
    vpxorq ACC14, ACC14, ACC14
    vpxorq ACC15, ACC15, ACC15

    mov $15, hlp

1:
        vmovdqu64 (bptr), B
        lea 1*64(bptr), bptr
    
        vpmadd52luq A0, B, ACC0
        vpmadd52luq A1, B, ACC1
        vpmadd52luq A2, B, ACC2
        vpmadd52luq A3, B, ACC3
        vpmadd52luq A4, B, ACC4
        vpmadd52luq A5, B, ACC5
        vpmadd52luq A6, B, ACC6
        vpmadd52luq A7, B, ACC7
        vpmadd52luq A8, B, ACC8
        vpmadd52luq A9, B, ACC9
        vpmadd52luq A10, B, ACC10
        vpmadd52luq A11, B, ACC11
        vpmadd52luq A12, B, ACC12
        vpmadd52luq A13, B, ACC13
        vpmadd52luq A14, B, ACC14

        vpmadd52huq A0, B, ACC1
        vpmadd52huq A1, B, ACC2
        vpmadd52huq A2, B, ACC3
        vpmadd52huq A3, B, ACC4
        vpmadd52huq A4, B, ACC5
        vpmadd52huq A5, B, ACC6
        vpmadd52huq A6, B, ACC7
        vpmadd52huq A7, B, ACC8
        vpmadd52huq A8, B, ACC9
        vpmadd52huq A9, B, ACC10
        vpmadd52huq A10, B, ACC11
        vpmadd52huq A11, B, ACC12
        vpmadd52huq A12, B, ACC13
        vpmadd52huq A13, B, ACC14
        vpmadd52huq A14, B, ACC15

        vmovdqa64 ACC0, B

        vpmadd52luq 0*8 + .Lpoly(%rip){1to8}, B, ACC0
        vpsrlq $52, ACC0, ACC0
        vpmadd52luq 1*8 + .Lpoly(%rip){1to8}, B, ACC1
        vpaddq ACC1, ACC0, ACC0
        vpmadd52luq 2*8 + .Lpoly(%rip){1to8}, B, ACC2
        vmovdqa64 ACC2, ACC1
        vpmadd52luq 3*8 + .Lpoly(%rip){1to8}, B, ACC3
        vmovdqa64 ACC3, ACC2
        vpmadd52luq 4*8 + .Lpoly(%rip){1to8}, B, ACC4
        vmovdqa64 ACC4, ACC3
        vpmadd52luq 5*8 + .Lpoly(%rip){1to8}, B, ACC5
        vmovdqa64 ACC5, ACC4
        vpmadd52luq 6*8 + .Lpoly(%rip){1to8}, B, ACC6
        vmovdqa64 ACC6, ACC5
        vpmadd52luq 7*8 + .Lpoly(%rip){1to8}, B, ACC7
        vmovdqa64 ACC7, ACC6
        vpmadd52luq 8*8 + .Lpoly(%rip){1to8}, B, ACC8
        vmovdqa64 ACC8, ACC7
        vpmadd52luq 9*8 + .Lpoly(%rip){1to8}, B, ACC9
        vmovdqa64 ACC9, ACC8
        vpmadd52luq 10*8 + .Lpoly(%rip){1to8}, B, ACC10
        vmovdqa64 ACC10, ACC9
        vpmadd52luq 11*8 + .Lpoly(%rip){1to8}, B, ACC11
        vmovdqa64 ACC11, ACC10
        vpmadd52luq 12*8 + .Lpoly(%rip){1to8}, B, ACC12
        vmovdqa64 ACC12, ACC11
        vpmadd52luq 13*8 + .Lpoly(%rip){1to8}, B, ACC13
        vmovdqa64 ACC13, ACC12
        vpmadd52luq 14*8 + .Lpoly(%rip){1to8}, B, ACC14
        vmovdqa64 ACC14, ACC13
        vmovdqa64 ACC15, ACC14
        vpxorq ACC15, ACC15, ACC15

        vpmadd52huq 0*8 + .Lpoly(%rip){1to8}, B, ACC0
        vpmadd52huq 1*8 + .Lpoly(%rip){1to8}, B, ACC1
        vpmadd52huq 2*8 + .Lpoly(%rip){1to8}, B, ACC2
        vpmadd52huq 3*8 + .Lpoly(%rip){1to8}, B, ACC3
        vpmadd52huq 4*8 + .Lpoly(%rip){1to8}, B, ACC4
        vpmadd52huq 5*8 + .Lpoly(%rip){1to8}, B, ACC5
        vpmadd52huq 6*8 + .Lpoly(%rip){1to8}, B, ACC6
        vpmadd52huq 7*8 + .Lpoly(%rip){1to8}, B, ACC7
        vpmadd52huq 8*8 + .Lpoly(%rip){1to8}, B, ACC8
        vpmadd52huq 9*8 + .Lpoly(%rip){1to8}, B, ACC9
        vpmadd52huq 10*8 + .Lpoly(%rip){1to8}, B, ACC10
        vpmadd52huq 11*8 + .Lpoly(%rip){1to8}, B, ACC11
        vpmadd52huq 12*8 + .Lpoly(%rip){1to8}, B, ACC12
        vpmadd52huq 13*8 + .Lpoly(%rip){1to8}, B, ACC13
        vpmadd52huq 14*8 + .Lpoly(%rip){1to8}, B, ACC14

        dec hlp
    jnz 1b

    ret