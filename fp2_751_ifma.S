
#if defined(__APPLE__)
/* OS X's C ABI prefixes functions with underscore. */
#define C_ABI(x) _ ## x
#define HIDDEN .private_extern
#else
#define C_ABI(x) x
#define HIDDEN .hidden
#endif

.p2align 6
.LpermMask0:
.word 0,1,2,3,   3,4,5,6,   6,7,8,9,    9,10,11,12,    13,14,15,16,   16,17,18,19,   19,20,21,22,    22,23,24,25
.LshiftMask0:
.quad 0,4,8,12,0,4,8,12
.LandMask:
.quad 0xfffffffffffff

.p2align 6
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

#define felemR %rdi
#define felemA %rsi
#define felemB %rdx

#define itr %r10

#define M0 %zmm0
#define M1 %zmm1
#define ZERO %zmm2
#define AND_MASK %zmm3

#define A0a %zmm4
#define A0b %zmm5

#define A1a %zmm6
#define A1b %zmm7

#define ACC0a %zmm8
#define ACC0b %zmm9
#define ACC1a %zmm10
#define ACC1b %zmm11
#define ACC2a %zmm12
#define ACC2b %zmm13
#define ACC3a %zmm14
#define ACC3b %zmm15

#define B0curr %zmm16
#define B0prev %zmm17
#define B1curr %zmm18
#define B1prev %zmm19

#define Y0curr %zmm20
#define Y0prev %zmm21
#define Y1curr %zmm22
#define Y1prev %zmm23
#define Y2curr %zmm24
#define Y2prev %zmm25
#define Y3curr %zmm26
#define Y3prev %zmm27

#define T0 %zmm28
#define T1 %zmm29
#define T2 %zmm30
#define T3 %zmm31

###############################################################################
.globl C_ABI(fp2_mul_ifma)
.p2align 6
C_ABI(fp2_mul_ifma):

    mov $1, %eax
    kmovw %eax, %k1
    mov $0x7f, %eax
    kmovw %eax, %k5

    vpbroadcastq .LandMask(%rip), AND_MASK
    vpxorq ZERO, ZERO, ZERO

    vmovdqu64 64*0(felemA), A0a
    vmovdqu64 64*1(felemA), A0b{%k5}{z}
    vmovdqu64 15*8 + 64*0(felemA), A1a
    vmovdqu64 15*8 + 64*1(felemA), A1b{%k5}{z}

    # Load the modulus
    vmovdqa64 64*0 + .Lpoly(%rip), M0
    vmovdqa64 64*1 + .Lpoly(%rip), M1

    # Prepare the accumulators
    vpxorq ACC0a, ACC0a, ACC0a
    vpxorq ACC0b, ACC0b, ACC0b
    vpxorq ACC1a, ACC1a, ACC1a
    vpxorq ACC1b, ACC1b, ACC1b
    vpxorq ACC2a, ACC2a, ACC2a
    vpxorq ACC2b, ACC2b, ACC2b
    vpxorq ACC3a, ACC3a, ACC3a
    vpxorq ACC3b, ACC3b, ACC3b
    vpxorq T0, T0, T0
    vpxorq T1, T1, T1
    vpxorq T2, T2, T2
    vpxorq T3, T3, T3

    # First iteration
    vpbroadcastq (felemB), B0curr
    vpbroadcastq 15*8(felemB), B1curr
    lea 8(felemB), felemB

    vpmadd52luq B0curr, A0a, ACC0a
    vpmadd52luq B0curr, A0b, ACC0b
    vpmadd52luq B1curr, A1a, ACC1a
    vpmadd52luq B1curr, A1b, ACC1b
    vpmadd52luq B0curr, A1a, ACC2a
    vpmadd52luq B0curr, A1b, ACC2b
    vpmadd52luq B1curr, A0a, ACC3a
    vpmadd52luq B1curr, A0b, ACC3b

    vpermq ACC0a, ZERO, Y0curr
    vpermq ACC1a, ZERO, Y1curr
    vpermq ACC2a, ZERO, Y2curr
    vpermq ACC3a, ZERO, Y3curr

    vpmadd52luq Y0curr, M0, ACC0a
    vpmadd52luq Y0curr, M1, ACC0b
    vpmadd52luq Y1curr, M0, ACC1a
    vpmadd52luq Y1curr, M1, ACC1b
    vpmadd52luq Y2curr, M0, ACC2a
    vpmadd52luq Y2curr, M1, ACC2b
    vpmadd52luq Y3curr, M0, ACC3a
    vpmadd52luq Y3curr, M1, ACC3b

    vpsrlq $52, ACC0a, T0{%k1}{z}
    vpsrlq $52, ACC1a, T1{%k1}{z}
    vpsrlq $52, ACC2a, T2{%k1}{z}
    vpsrlq $52, ACC3a, T3{%k1}{z}

    mov $14, itr

1:
        # Shift the ACC in zmms right by a word
        valignq $1, ACC0a, ACC0b, ACC0a
        valignq $1, ACC0b, ZERO, ACC0b
        valignq $1, ACC1a, ACC1b, ACC1a
        valignq $1, ACC1b, ZERO, ACC1b
        valignq $1, ACC2a, ACC2b, ACC2a
        valignq $1, ACC2b, ZERO, ACC2b
        valignq $1, ACC3a, ACC3b, ACC3a
        valignq $1, ACC3b, ZERO, ACC3b

        vmovdqa64 B0curr, B0prev
        vmovdqa64 B1curr, B1prev
        vmovdqa64 Y0curr, Y0prev
        vmovdqa64 Y1curr, Y1prev
        vmovdqa64 Y2curr, Y2prev
        vmovdqa64 Y3curr, Y3prev

        vpbroadcastq (felemB), B0curr
        vpbroadcastq 15*8(felemB), B1curr
        lea 8(felemB), felemB

        # High multiplications
        vpmadd52huq B0prev, A0a, ACC0a # ACC0 = A0 * B0
        vpmadd52huq B0prev, A0b, ACC0b
        vpmadd52huq B1prev, A1a, ACC1a # ACC1 = A1 * B1
        vpmadd52huq B1prev, A1b, ACC1b
        vpmadd52huq B0prev, A1a, ACC2a # ACC2 = A1 * B0
        vpmadd52huq B0prev, A1b, ACC2b
        vpmadd52huq B1prev, A0a, ACC3a # ACC3 = A0 * B1
        vpmadd52huq B1prev, A0b, ACC3b

        vpmadd52huq Y0prev, M0, ACC0a
        vpmadd52huq Y0prev, M1, ACC0b
        vpmadd52huq Y1prev, M0, ACC1a
        vpmadd52huq Y1prev, M1, ACC1b
        vpmadd52huq Y2prev, M0, ACC2a
        vpmadd52huq Y2prev, M1, ACC2b
        vpmadd52huq Y3prev, M0, ACC3a
        vpmadd52huq Y3prev, M1, ACC3b
        # Low multiplications
        vpmadd52luq B0curr, A0a, ACC0a
        vpmadd52luq B0curr, A0b, ACC0b
        vpmadd52luq B1curr, A1a, ACC1a
        vpmadd52luq B1curr, A1b, ACC1b
        vpmadd52luq B0curr, A1a, ACC2a
        vpmadd52luq B0curr, A1b, ACC2b
        vpmadd52luq B1curr, A0a, ACC3a
        vpmadd52luq B1curr, A0b, ACC3b

        vpaddq T0, ACC0a, ACC0a
        vpaddq T1, ACC1a, ACC1a
        vpaddq T2, ACC2a, ACC2a
        vpaddq T3, ACC3a, ACC3a
        vpermq ACC0a, ZERO, Y0curr
        vpermq ACC1a, ZERO, Y1curr
        vpermq ACC2a, ZERO, Y2curr
        vpermq ACC3a, ZERO, Y3curr

        vpmadd52luq Y0curr, M0, ACC0a
        vpmadd52luq Y0curr, M1, ACC0b
        vpmadd52luq Y1curr, M0, ACC1a
        vpmadd52luq Y1curr, M1, ACC1b
        vpmadd52luq Y2curr, M0, ACC2a
        vpmadd52luq Y2curr, M1, ACC2b
        vpmadd52luq Y3curr, M0, ACC3a
        vpmadd52luq Y3curr, M1, ACC3b

        vpsrlq $52, ACC0a, T0{%k1}{z}
        vpsrlq $52, ACC1a, T1{%k1}{z}
        vpsrlq $52, ACC2a, T2{%k1}{z}
        vpsrlq $52, ACC3a, T3{%k1}{z}

        dec itr
    jne 1b
    valignq $1, ACC0a, ACC0b, ACC0a
    valignq $1, ACC0b, ZERO, ACC0b
    valignq $1, ACC1a, ACC1b, ACC1a
    valignq $1, ACC1b, ZERO, ACC1b
    valignq $1, ACC2a, ACC2b, ACC2a
    valignq $1, ACC2b, ZERO, ACC2b
    valignq $1, ACC3a, ACC3b, ACC3a
    valignq $1, ACC3b, ZERO, ACC3b
    vpaddq T0, ACC0a, ACC0a
    vpaddq T1, ACC1a, ACC1a
    vpaddq T2, ACC2a, ACC2a
    vpaddq T3, ACC3a, ACC3a

    # The last high multiplications
    vpmadd52huq B0curr, A0a, ACC0a
    vpmadd52huq B0curr, A0b, ACC0b
    vpmadd52huq B1curr, A1a, ACC1a
    vpmadd52huq B1curr, A1b, ACC1b
    vpmadd52huq B0curr, A1a, ACC2a
    vpmadd52huq B0curr, A1b, ACC2b
    vpmadd52huq B1curr, A0a, ACC3a
    vpmadd52huq B1curr, A0b, ACC3b

    vpmadd52huq Y0curr, M0, ACC0a
    vpmadd52huq Y0curr, M1, ACC0b
    vpmadd52huq Y1curr, M0, ACC1a
    vpmadd52huq Y1curr, M1, ACC1b
    vpmadd52huq Y2curr, M0, ACC2a
    vpmadd52huq Y2curr, M1, ACC2b
    vpmadd52huq Y3curr, M0, ACC3a
    vpmadd52huq Y3curr, M1, ACC3b

    # C0 = A0*B0 - A1*B1
    # C1 = A0*B1 + A1*B0
    vpaddq  64*0 + .LpolyX(%rip), ACC0a, ACC0a
    vpaddq  64*1 + .LpolyX(%rip), ACC0b, ACC0b

    vpaddq  ACC3a, ACC2a, ACC2a
    vpaddq  ACC3b, ACC2b, ACC2b

    vpsubq  ACC1a, ACC0a, ACC0a
    vpsubq  ACC1b, ACC0b, ACC0b
    # Now 'normalize' the acc to 52 bit words
    vpsrlq  $52, ACC0a, A0a
    vpsrlq  $52, ACC0b, A0b

    vpsrlq  $52, ACC2a, A1a
    vpsrlq  $52, ACC2b, A1b

    vpandq  AND_MASK, ACC0a, ACC0a
    vpandq  AND_MASK, ACC0b, ACC0b
    vpandq  AND_MASK, ACC2a, ACC2a
    vpandq  AND_MASK, ACC2b, ACC2b

    valignq $7, A0a, A0b, A0b
    valignq $7, ZERO, A0a, A0a
    valignq $7, A1a, A1b, A1b
    valignq $7, ZERO, A1a, A1a

    vpaddq  A0a, ACC0a, ACC0a
    vpaddq  A0b, ACC0b, ACC0b
    vpaddq  A1a, ACC2a, ACC2a
    vpaddq  A1b, ACC2b, ACC2b

    vpcmpuq $1, A0a, ACC0a, %k1
    vpcmpuq $1, A0b, ACC0b, %k2
    vpcmpuq $0, AND_MASK, ACC0a, %k3
    vpcmpuq $0, AND_MASK, ACC0b, %k4

    kmovb %k1, %eax
    kmovb %k2, %ecx
    kmovb %k3, %r8d
    kmovb %k4, %r9d

    add %al, %al
    adc %cl, %cl

    add %r8b, %al
    adc %r9b, %cl

    xor %r8b, %al
    xor %r9b, %cl

    kmovb %eax, %k1
    kmovb %ecx, %k2

    vpsubq AND_MASK, ACC0a, ACC0a{%k1}
    vpsubq AND_MASK, ACC0b, ACC0b{%k2}
    vpandq AND_MASK, ACC0a, ACC0a
    vpandq AND_MASK, ACC0b, ACC0b

    vpcmpuq $1, A1a, ACC2a, %k1
    vpcmpuq $1, A1b, ACC2b, %k2
    vpcmpuq $0, AND_MASK, ACC2a, %k3
    vpcmpuq $0, AND_MASK, ACC2b, %k4

    kmovb %k1, %eax
    kmovb %k2, %ecx
    kmovb %k3, %r8d
    kmovb %k4, %r9d

    add %al, %al
    adc %cl, %cl
    add %r8b, %al
    adc %r9b, %cl
    xor %r8b, %al
    xor %r9b, %cl
    kmovb %eax, %k1
    kmovb %ecx, %k2

    vpsubq AND_MASK, ACC2a, ACC2a{%k1}
    vpsubq AND_MASK, ACC2b, ACC2b{%k2}
    vpandq AND_MASK, ACC2a, ACC2a
    vpandq AND_MASK, ACC2b, ACC2b

    mov $0x7f, %eax
    kmovw %eax, %k1

    vmovdqu64 ACC0a, 64*0(felemR)
    vmovdqu64 ACC0b, 64*1(felemR){%k5}
    vmovdqu64 ACC2a, 15*8 + 64*0(felemR)
    vmovdqu64 ACC2b, 15*8 + 64*1(felemR){%k5}
    ret

###############################################################################

#define ST0 ACC3a
#define ST1 ACC3b
#define ST2 Y3curr

.globl C_ABI(fp2_sqr_ifma)
.p2align 6
C_ABI(fp2_sqr_ifma):

    mov $1, %eax
    kmovw %eax, %k1
    mov $0x7f, %eax
    kmovw %eax, %k2

    vpbroadcastq .LandMask(%rip), AND_MASK
    vpxorq ZERO, ZERO, ZERO

    vmovdqu64 64*0(felemA), A0a
    vmovdqu64 64*1(felemA), A0b{%k2}{z}
    vmovdqu64 15*8 + 64*0(felemA), A1a
    vmovdqu64 15*8 + 64*1(felemA), A1b{%k2}{z}

    # Load the modulus
    vmovdqa64 64*0 + .Lpoly(%rip), M0
    vmovdqa64 64*1 + .Lpoly(%rip), M1

    # Prepare the accumulators
    vpxorq ACC0a, ACC0a, ACC0a
    vpxorq ACC0b, ACC0b, ACC0b
    vpxorq ACC1a, ACC1a, ACC1a
    vpxorq ACC1b, ACC1b, ACC1b
    vpxorq ACC2a, ACC2a, ACC2a
    vpxorq ACC2b, ACC2b, ACC2b
    vpxorq T0, T0, T0
    vpxorq T1, T1, T1
    vpxorq T2, T2, T2

    # First iteration
    vpbroadcastq (felemA), B0curr
    vpbroadcastq 15*8(felemA), B1curr
    lea 8(felemA), felemA

    vpmadd52luq B0curr, A0a, ACC0a
    vpmadd52luq B0curr, A0b, ACC0b
    vpmadd52luq B1curr, A1a, ACC1a
    vpmadd52luq B1curr, A1b, ACC1b
    vpmadd52luq B0curr, A1a, ACC2a
    vpmadd52luq B0curr, A1b, ACC2b

    vpermq ACC0a, ZERO, Y0curr
    vpermq ACC1a, ZERO, Y1curr
    vpermq ACC2a, ZERO, Y2curr

    vpmadd52luq Y0curr, M0, ACC0a
    vpmadd52luq Y0curr, M1, ACC0b
    vpmadd52luq Y1curr, M0, ACC1a
    vpmadd52luq Y1curr, M1, ACC1b
    vpmadd52luq Y2curr, M0, ACC2a
    vpmadd52luq Y2curr, M1, ACC2b

    vpsrlq $52, ACC0a, T0{%k1}{z}
    vpsrlq $52, ACC1a, T1{%k1}{z}
    vpsrlq $52, ACC2a, T2{%k1}{z}

    mov $14, itr

1:
        # Shift the ACC in zmms right by a word
        valignq $1, ACC0a, ACC0b, ACC0a
        valignq $1, ACC0b, ZERO, ACC0b
        valignq $1, ACC1a, ACC1b, ACC1a
        valignq $1, ACC1b, ZERO, ACC1b
        valignq $1, ACC2a, ACC2b, ACC2a
        valignq $1, ACC2b, ZERO, ACC2b

        vpxorq ST0, ST0, ST0
        vpxorq ST1, ST1, ST1
        vpxorq ST2, ST2, ST2

        vmovdqa64 B0curr, B0prev
        vmovdqa64 B1curr, B1prev
        vmovdqa64 Y0curr, Y0prev
        vmovdqa64 Y1curr, Y1prev
        vmovdqa64 Y2curr, Y2prev

        vpbroadcastq (felemA), B0curr
        vpbroadcastq 15*8(felemA), B1curr
        lea 8(felemA), felemA

        # High multiplications
        vpmadd52huq B0prev, A0a, ACC0a # ACC0 = A0 * B0
        vpmadd52huq B1prev, A1a, ACC1a # ACC1 = A1 * B1
        vpmadd52huq B0prev, A1a, ACC2a # ACC2 = A1 * B0
        vpmadd52huq B0prev, A0b, ACC0b
        vpmadd52huq B1prev, A1b, ACC1b
        vpmadd52huq B0prev, A1b, ACC2b
        # We really want to have 8 independent vpmadd instructions in the pipe
        vpmadd52huq Y0prev, M0, T0
        vpmadd52huq Y1prev, M0, T1
        vpmadd52huq Y2prev, M0, T2

        vpmadd52huq Y0prev, M1, ACC0b
        vpmadd52huq Y1prev, M1, ACC1b
        vpmadd52huq Y2prev, M1, ACC2b
        # Low multiplications
        vpmadd52luq B0curr, A0a, ACC0a
        vpmadd52luq B1curr, A1a, ACC1a
        vpmadd52luq B0curr, A1a, ACC2a
 
        vpmadd52luq B0curr, A0b, ST0
        vpmadd52luq B1curr, A1b, ST1
        vpmadd52luq B0curr, A1b, ST2

        vpaddq T0, ACC0a, ACC0a
        vpaddq T1, ACC1a, ACC1a
        vpaddq T2, ACC2a, ACC2a
        vpermq ACC0a, ZERO, Y0curr
        vpermq ACC1a, ZERO, Y1curr
        vpermq ACC2a, ZERO, Y2curr
        vpaddq ST0, ACC0b, ACC0b
        vpaddq ST1, ACC1b, ACC1b
        vpaddq ST2, ACC2b, ACC2b

        vpmadd52luq Y0curr, M0, ACC0a
        vpmadd52luq Y0curr, M1, ACC0b
        vpmadd52luq Y1curr, M0, ACC1a
        vpmadd52luq Y1curr, M1, ACC1b
        vpmadd52luq Y2curr, M0, ACC2a
        vpmadd52luq Y2curr, M1, ACC2b

        vpsrlq $52, ACC0a, T0{%k1}{z}
        vpsrlq $52, ACC1a, T1{%k1}{z}
        vpsrlq $52, ACC2a, T2{%k1}{z}

        dec itr
    jne 1b
    valignq $1, ACC0a, ACC0b, ACC0a
    valignq $1, ACC0b, ZERO, ACC0b
    valignq $1, ACC1a, ACC1b, ACC1a
    valignq $1, ACC1b, ZERO, ACC1b
    valignq $1, ACC2a, ACC2b, ACC2a
    valignq $1, ACC2b, ZERO, ACC2b
    vpaddq T0, ACC0a, ACC0a
    vpaddq T1, ACC1a, ACC1a
    vpaddq T2, ACC2a, ACC2a

    # The last high multiplications
    vpmadd52huq B0curr, A0a, ACC0a
    vpmadd52huq B0curr, A0b, ACC0b
    vpmadd52huq B1curr, A1a, ACC1a
    vpmadd52huq B1curr, A1b, ACC1b
    vpmadd52huq B0curr, A1a, ACC2a
    vpmadd52huq B0curr, A1b, ACC2b

    vpmadd52huq Y0curr, M0, ACC0a
    vpmadd52huq Y0curr, M1, ACC0b
    vpmadd52huq Y1curr, M0, ACC1a
    vpmadd52huq Y1curr, M1, ACC1b
    vpmadd52huq Y2curr, M0, ACC2a
    vpmadd52huq Y2curr, M1, ACC2b

    # C0 = A0*B0 - A1*B1
    # C1 = A0*B1 + A1*B0
    vpaddq  64*0 + .LpolyX(%rip), ACC0a, ACC0a
    vpaddq  64*1 + .LpolyX(%rip), ACC0b, ACC0b

    vpaddq  ACC2a, ACC2a, ACC2a
    vpaddq  ACC2b, ACC2b, ACC2b

    vpsubq  ACC1a, ACC0a, ACC0a
    vpsubq  ACC1b, ACC0b, ACC0b

    # Now 'normalize' the acc to 52 bit words
    vpsrlq  $52, ACC0a, A0a
    vpsrlq  $52, ACC0b, A0b
    vpsrlq  $52, ACC2a, A1a
    vpsrlq  $52, ACC2b, A1b

    vpandq  AND_MASK, ACC0a, ACC0a
    vpandq  AND_MASK, ACC0b, ACC0b
    vpandq  AND_MASK, ACC2a, ACC2a
    vpandq  AND_MASK, ACC2b, ACC2b

    valignq $7, A0a, A0b, A0b
    valignq $7, ZERO, A0a, A0a
    valignq $7, A1a, A1b, A1b
    valignq $7, ZERO, A1a, A1a

    vpaddq  A0a, ACC0a, ACC0a
    vpaddq  A0b, ACC0b, ACC0b
    vpaddq  A1a, ACC2a, ACC2a
    vpaddq  A1b, ACC2b, ACC2b

    vpcmpuq $1, A0a, ACC0a, %k1
    vpcmpuq $1, A0b, ACC0b, %k2
    vpcmpuq $0, AND_MASK, ACC0a, %k3
    vpcmpuq $0, AND_MASK, ACC0b, %k4

    kmovb %k1, %eax
    kmovb %k2, %ecx
    kmovb %k3, %r8d
    kmovb %k4, %r9d

    add %al, %al
    adc %cl, %cl
    add %r8b, %al
    adc %r9b, %cl
    xor %r8b, %al
    xor %r9b, %cl
    kmovb %eax, %k1
    kmovb %ecx, %k2

    vpsubq AND_MASK, ACC0a, ACC0a{%k1}
    vpsubq AND_MASK, ACC0b, ACC0b{%k2}
    vpandq AND_MASK, ACC0a, ACC0a
    vpandq AND_MASK, ACC0b, ACC0b

    vpcmpuq $1, A1a, ACC2a, %k1
    vpcmpuq $1, A1b, ACC2b, %k2
    vpcmpuq $0, AND_MASK, ACC2a, %k3
    vpcmpuq $0, AND_MASK, ACC2b, %k4

    kmovb %k1, %eax
    kmovb %k2, %ecx
    kmovb %k3, %r8d
    kmovb %k4, %r9d

    add %al, %al
    adc %cl, %cl
    add %r8b, %al
    adc %r9b, %cl
    xor %r8b, %al
    xor %r9b, %cl
    kmovb %eax, %k1
    kmovb %ecx, %k2

    vpsubq AND_MASK, ACC2a, ACC2a{%k1}
    vpsubq AND_MASK, ACC2b, ACC2b{%k2}
    vpandq AND_MASK, ACC2a, ACC2a
    vpandq AND_MASK, ACC2b, ACC2b

    mov $0x7f, %eax
    kmovw %eax, %k1

    vmovdqu64 ACC0a, 64*0(felemR)
    vmovdqu64 ACC0b, 64*1(felemR){%k1}
    vmovdqu64 ACC2a, 15*8 + 64*0(felemR)
    vmovdqu64 ACC2b, 15*8 + 64*1(felemR){%k1}
    ret

###############################################################################
.globl C_ABI(fp2_sub)
.p2align 6
C_ABI(fp2_sub):

    mov $1, %eax
    kmovw %eax, %k1
    mov $0x7f, %eax
    kmovw %eax, %k2
    
    vmovdqu64 64*0(felemA), ACC0a
    vmovdqu64 64*1(felemA), ACC0b{%k2}{z}
    vmovdqu64 15*8 + 64*0(felemA), ACC1a
    vmovdqu64 15*8 + 64*1(felemA), ACC1b{%k2}{z}

    vmovdqu64 64*0(felemB), ACC2a
    vmovdqu64 64*1(felemB), ACC2b{%k2}{z}
    vmovdqu64 15*8 + 64*0(felemB), ACC3a
    vmovdqu64 15*8 + 64*1(felemB), ACC3b{%k2}{z}

    vpaddq 64*0 + .LpolyX(%rip), ACC0a, ACC0a
    vpaddq 64*1 + .LpolyX(%rip), ACC0b, ACC0b
    vpaddq 64*0 + .LpolyX(%rip), ACC1a, ACC1a
    vpaddq 64*1 + .LpolyX(%rip), ACC1b, ACC1b

    vpsubq ACC2a, ACC0a, ACC0a
    vpsubq ACC2b, ACC0b, ACC0b
    vpsubq ACC3a, ACC1a, ACC2a
    vpsubq ACC3b, ACC1b, ACC2b

    jmp fp2_normalize
###############################################################################
.globl C_ABI(fp2_add)
.p2align 6
C_ABI(fp2_add):

    mov $1, %eax
    kmovw %eax, %k1
    mov $0x7f, %eax
    kmovw %eax, %k2
    
    vmovdqu64 64*0(felemA), ACC0a
    vmovdqu64 64*1(felemA), ACC0b{%k2}{z}
    vmovdqu64 15*8 + 64*0(felemA), ACC1a
    vmovdqu64 15*8 + 64*1(felemA), ACC1b{%k2}{z}

    vmovdqu64 64*0(felemB), ACC2a
    vmovdqu64 64*1(felemB), ACC2b{%k2}{z}
    vmovdqu64 15*8 + 64*0(felemB), ACC3a
    vmovdqu64 15*8 + 64*1(felemB), ACC3b{%k2}{z}

    vpaddq ACC2a, ACC0a, ACC0a
    vpaddq ACC2b, ACC0b, ACC0b
    vpaddq ACC3a, ACC1a, ACC2a
    vpaddq ACC3b, ACC1b, ACC2b

    // Fallthrough
###############################################################################
.p2align 6
C_ABI(fp2_normalize):

    vpbroadcastq .LandMask(%rip), AND_MASK
    vpxorq ZERO, ZERO, ZERO

    # Now 'normalize' the acc to 52 bit words
    vpsrlq  $52, ACC0a, A0a
    vpsrlq  $52, ACC0b, A0b
    vpsrlq  $52, ACC2a, A1a
    vpsrlq  $52, ACC2b, A1b

    vpandq  AND_MASK, ACC0a, ACC0a
    vpandq  AND_MASK, ACC0b, ACC0b
    vpandq  AND_MASK, ACC2a, ACC2a
    vpandq  AND_MASK, ACC2b, ACC2b

    valignq $7, A0a, A0b, A0b
    valignq $7, ZERO, A0a, A0a
    valignq $7, A1a, A1b, A1b
    valignq $7, ZERO, A1a, A1a

    vpaddq  A0a, ACC0a, ACC0a
    vpaddq  A0b, ACC0b, ACC0b
    vpaddq  A1a, ACC2a, ACC2a
    vpaddq  A1b, ACC2b, ACC2b

    vpcmpuq $1, A0a, ACC0a, %k1
    vpcmpuq $1, A0b, ACC0b, %k2
    vpcmpuq $0, AND_MASK, ACC0a, %k3
    vpcmpuq $0, AND_MASK, ACC0b, %k4

    kmovb %k1, %eax
    kmovb %k2, %ecx
    kmovb %k3, %r8d
    kmovb %k4, %r9d

    add %al, %al
    adc %cl, %cl
    add %r8b, %al
    adc %r9b, %cl
    xor %r8b, %al
    xor %r9b, %cl
    kmovb %eax, %k1
    kmovb %ecx, %k2

    vpsubq AND_MASK, ACC0a, ACC0a{%k1}
    vpsubq AND_MASK, ACC0b, ACC0b{%k2}
    vpandq AND_MASK, ACC0a, ACC0a
    vpandq AND_MASK, ACC0b, ACC0b

    vpcmpuq $1, A1a, ACC2a, %k1
    vpcmpuq $1, A1b, ACC2b, %k2
    vpcmpuq $0, AND_MASK, ACC2a, %k3
    vpcmpuq $0, AND_MASK, ACC2b, %k4

    kmovb %k1, %eax
    kmovb %k2, %ecx
    kmovb %k3, %r8d
    kmovb %k4, %r9d

    add %al, %al
    adc %cl, %cl
    add %r8b, %al
    adc %r9b, %cl
    xor %r8b, %al
    xor %r9b, %cl
    kmovb %eax, %k1
    kmovb %ecx, %k2

    vpsubq AND_MASK, ACC2a, ACC2a{%k1}
    vpsubq AND_MASK, ACC2b, ACC2b{%k2}
    vpandq AND_MASK, ACC2a, ACC2a
    vpandq AND_MASK, ACC2b, ACC2b

    mov $0x7f, %eax
    kmovw %eax, %k1

    vmovdqu64 ACC0a, 64*0(felemR)
    vmovdqu64 ACC0b, 64*1(felemR){%k1}
    vmovdqu64 ACC2a, 15*8 + 64*0(felemR)
    vmovdqu64 ACC2b, 15*8 + 64*1(felemR){%k1}

    ret


###############################################################################
#define p1ptr %rdi
#define p2ptr %rsi
#define swap %rdx
.globl C_ABI(fp2_swap)
.p2align 6
C_ABI(fp2_swap):

    mov $0x7f, %eax
    kmovw %eax, %k2
    // TODO: get rid of the masks, not needed
    vmovdqu64 64*0(p1ptr), %zmm0
    vmovdqu64 64*1(p1ptr), %zmm1{%k2}{z}
    vmovdqu64 15*8 + 64*0(p1ptr), %zmm2
    vmovdqu64 15*8 + 64*1(p1ptr), %zmm3{%k2}{z}
    vmovdqu64 2*15*8 + 64*0(p1ptr), %zmm4
    vmovdqu64 2*15*8 + 64*1(p1ptr), %zmm5{%k2}{z}
    vmovdqu64 3*15*8 + 64*0(p1ptr), %zmm6
    vmovdqu64 3*15*8 + 64*1(p1ptr), %zmm7{%k2}{z}

    vmovdqu64 64*0(p2ptr), %zmm8
    vmovdqu64 64*1(p2ptr), %zmm9{%k2}{z}
    vmovdqu64 15*8 + 64*0(p2ptr), %zmm10
    vmovdqu64 15*8 + 64*1(p2ptr), %zmm11{%k2}{z}
    vmovdqu64 2*15*8 + 64*0(p2ptr), %zmm12
    vmovdqu64 2*15*8 + 64*1(p2ptr), %zmm13{%k2}{z}
    vmovdqu64 3*15*8 + 64*0(p2ptr), %zmm14
    vmovdqu64 3*15*8 + 64*1(p2ptr), %zmm15{%k2}{z}

    vpxorq %zmm16, %zmm16, %zmm16
    vpbroadcastq swap, %zmm17
    vpsubq %zmm17, %zmm16, %zmm16

    vmovdqa64 %zmm8, %zmm17
    vmovdqa64 %zmm9, %zmm18
    vmovdqa64 %zmm10, %zmm19
    vmovdqa64 %zmm11, %zmm20
    vmovdqa64 %zmm12, %zmm21
    vmovdqa64 %zmm13, %zmm22
    vmovdqa64 %zmm14, %zmm23
    vmovdqa64 %zmm15, %zmm24

    vpternlogq $0xd8, %zmm16, %zmm0, %zmm17
    vpternlogq $0xd8, %zmm16, %zmm1, %zmm18
    vpternlogq $0xd8, %zmm16, %zmm2, %zmm19
    vpternlogq $0xd8, %zmm16, %zmm3, %zmm20
    vpternlogq $0xd8, %zmm16, %zmm4, %zmm21
    vpternlogq $0xd8, %zmm16, %zmm5, %zmm22
    vpternlogq $0xd8, %zmm16, %zmm6, %zmm23
    vpternlogq $0xd8, %zmm16, %zmm7, %zmm24

    vpternlogq $0xe4, %zmm16, %zmm0, %zmm8
    vpternlogq $0xe4, %zmm16, %zmm1, %zmm9
    vpternlogq $0xe4, %zmm16, %zmm2, %zmm10
    vpternlogq $0xe4, %zmm16, %zmm3, %zmm11
    vpternlogq $0xe4, %zmm16, %zmm4, %zmm12
    vpternlogq $0xe4, %zmm16, %zmm5, %zmm13
    vpternlogq $0xe4, %zmm16, %zmm6, %zmm14
    vpternlogq $0xe4, %zmm16, %zmm7, %zmm15


    vmovdqu64 %zmm8, 64*0(p1ptr)
    vmovdqu64 %zmm9, 64*1(p1ptr){%k2}
    vmovdqu64 %zmm10, 15*8 + 64*0(p1ptr)
    vmovdqu64 %zmm11, 15*8 + 64*1(p1ptr){%k2}
    vmovdqu64 %zmm12, 2*15*8 + 64*0(p1ptr)
    vmovdqu64 %zmm13, 2*15*8 + 64*1(p1ptr){%k2}
    vmovdqu64 %zmm14, 3*15*8 + 64*0(p1ptr)
    vmovdqu64 %zmm15, 3*15*8 + 64*1(p1ptr){%k2}

    vmovdqu64 %zmm17, 64*0(p2ptr)
    vmovdqu64 %zmm18, 64*1(p2ptr){%k2}
    vmovdqu64 %zmm19, 15*8 + 64*0(p2ptr)
    vmovdqu64 %zmm20, 15*8 + 64*1(p2ptr){%k2}
    vmovdqu64 %zmm21, 2*15*8 + 64*0(p2ptr)
    vmovdqu64 %zmm22, 2*15*8 + 64*1(p2ptr){%k2}
    vmovdqu64 %zmm23, 3*15*8 + 64*0(p2ptr)
    vmovdqu64 %zmm24, 3*15*8 + 64*1(p2ptr){%k2}

    ret
###############################################################################
.globl C_ABI(fp_add)
.p2align 6
C_ABI(fp_add):

    mov $0x7f, %eax
    kmovw %eax, %k2
    
    vmovdqu64 64*0(felemA), ACC0a
    vmovdqu64 64*1(felemA), ACC0b{%k2}{z}

    vmovdqu64 64*0(felemB), ACC2a
    vmovdqu64 64*1(felemB), ACC2b{%k2}{z}

    vpaddq ACC2a, ACC0a, ACC0a
    vpaddq ACC2b, ACC0b, ACC0b

    // Fallthrough
###############################################################################
.p2align 6
C_ABI(fp_normalize):

    vpbroadcastq .LandMask(%rip), AND_MASK
    vpxorq ZERO, ZERO, ZERO

    # Now 'normalize' the acc to 52 bit words
    vpsrlq  $52, ACC0a, A0a
    vpsrlq  $52, ACC0b, A0b

    vpandq  AND_MASK, ACC0a, ACC0a
    vpandq  AND_MASK, ACC0b, ACC0b

    valignq $7, A0a, A0b, A0b
    valignq $7, ZERO, A0a, A0a

    vpaddq  A0a, ACC0a, ACC0a
    vpaddq  A0b, ACC0b, ACC0b

    vpcmpuq $1, A0a, ACC0a, %k1
    vpcmpuq $1, A0b, ACC0b, %k2
    vpcmpuq $0, AND_MASK, ACC0a, %k3
    vpcmpuq $0, AND_MASK, ACC0b, %k4

    kmovb %k1, %eax
    kmovb %k2, %ecx
    kmovb %k3, %r8d
    kmovb %k4, %r9d

    add %al, %al
    adc %cl, %cl

    add %r8b, %al
    adc %r9b, %cl

    xor %r8b, %al
    xor %r9b, %cl

    kmovb %eax, %k1
    kmovb %ecx, %k2

    vpsubq AND_MASK, ACC0a, ACC0a{%k1}
    vpsubq AND_MASK, ACC0b, ACC0b{%k2}
    vpandq AND_MASK, ACC0a, ACC0a
    vpandq AND_MASK, ACC0b, ACC0b

    mov $0x7f, %eax
    kmovw %eax, %k1

    vmovdqu64 ACC0a, 64*0(%rdi)
    vmovdqu64 ACC0b, 64*1(%rdi){%k1}

    ret

###############################################################################
.globl C_ABI(fp_sub)
.p2align 6
C_ABI(fp_sub):

    mov $0x7f, %eax
    kmovw %eax, %k2
    
    vmovdqu64 64*0(felemA), ACC0a
    vmovdqu64 64*1(felemA), ACC0b{%k2}{z}

    vmovdqu64 64*0(felemB), ACC2a
    vmovdqu64 64*1(felemB), ACC2b{%k2}{z}

    vpaddq 64*0 + .LpolyX(%rip), ACC0a, ACC0a
    vpaddq 64*1 + .LpolyX(%rip), ACC0b, ACC0b

    vpsubq ACC2a, ACC0a, ACC0a
    vpsubq ACC2b, ACC0b, ACC0b

    jmp fp_normalize

