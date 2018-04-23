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

.LR2:
.quad 0x000dad40589641fd, 0x000452a233046449, 0x000edb010161a696, 0x00036941472e3fd8
.quad 0x000e2082a2e7065e, 0x000904f8751f40bf, 0x0007fc814932cca8, 0x00033f174b08b2ee
.quad 0x0009814efb9f1375, 0x00099594a1afe512, 0x00043c75310de66d, 0x000197021a5b37b0
.quad 0x000cc1a272e73959, 0x000a733d7c97cd76, 0x0000000000292ee8, 0

.Lone:
.quad 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

.globl C_ABI(norm2red)
.p2align 6
C_ABI(norm2red):
    mov $0x3FFFFF, %eax
    kmovd %eax, %k1
    mov $0x7F, %eax
    kmovd %eax, %k2

    vmovdqa64 .LpermMask0(%rip), %zmm0
    vmovdqa64 .LshiftMask0(%rip), %zmm1
    vpbroadcastq .LandMask(%rip), %zmm10

    vpermw    52*0(%rsi), %zmm0, %zmm2
    vmovdqu16 52*1(%rsi), %zmm3{%k1}{z}
    vpermw    %zmm3, %zmm0, %zmm3

    vpsrlvq %zmm1, %zmm2, %zmm2
    vpsrlvq %zmm1, %zmm3, %zmm3
    vpsrlvq %zmm1, %zmm4, %zmm4

    vpandq %zmm10, %zmm2, %zmm2
    vpandq %zmm10, %zmm3, %zmm3
    vpandq %zmm10, %zmm4, %zmm4

    vmovdqu64 %zmm2, 64*0(%rdi)
    vmovdqu64 %zmm3, 64*1(%rdi){%k2}
    ret


#define res %rdi   // uint64_t *rp,
#define a0  %rsi   // const uint64_t *ap,
#define bpi %rdx   // const uint64_t *bptr,
#define m0  %rcx

#define b_ptr %rax

#define acc0 %r9

#define itr %r10
#define t0 %r11
#define t1 %r12
#define t2 %r13

#define A0 %zmm0
#define A1 %zmm1

#define M0 %zmm2
#define M1 %zmm3

#define ACC0 %zmm4
#define ACC0_xmm %xmm4
#define ACC1 %zmm5

#define Y_curr %zmm6
#define Y_prev %zmm7
#define B_curr %zmm8
#define B_prev %zmm9

#define TMP %zmm10
#define TMP_xmm %xmm10

#define ZERO %zmm11
#define AND_MASK %zmm12

#define ACC0b %zmm13
#define ACC1b %zmm14

###############################################################################
.globl C_ABI(to_mont_ifma)
.p2align 6
C_ABI(to_mont_ifma):
    leaq .LR2(%rip), bpi
    jmp C_ABI(fp_mul_ifma)
###############################################################################
.globl C_ABI(from_mont_ifma)
.p2align 6
C_ABI(from_mont_ifma):
    leaq .Lone(%rip), bpi
    jmp C_ABI(fp_mul_ifma)
###############################################################################
.globl C_ABI(fp_mul_ifma)
.p2align 6
C_ABI(fp_mul_ifma):

    push %rbx
    push %r12
    push %r13

    mov bpi, b_ptr

    mov $1, t0
    mov $0x3f, t1
    kmovq t0, %k1
    kmovq t1, %k2

    vpbroadcastq .LandMask(%rip), AND_MASK
    vpxorq ZERO, ZERO, ZERO

    # Load operands A into registers. A[0] is stored in ALU register, in order to compensate for the latency of IFMA when computing (A*B)[0] * K0
    vmovdqu64 8*1+64*0(a0), A0
    vmovdqu64 8*1+64*1(a0), A1{%k2}{z}
    mov 8*0(a0), a0

    # Load the modulii
    mov .Lpoly(%rip), m0
    vmovdqu64 8*1+64*0+.Lpoly(%rip), M0
    vmovdqu64 8*1+64*1+.Lpoly(%rip), M1{%k2}{z}

    # Prepare the accumulators
    vpxorq ACC0, ACC0, ACC0
    vpxorq ACC1, ACC1, ACC1
    vpxorq B_curr, B_curr, B_curr
    vpxorq Y_curr, Y_curr, Y_curr
    xor acc0, acc0

    mov $15, itr
1:
        vpxorq ACC0b, ACC0b, ACC0b
        vpxorq ACC1b, ACC1b, ACC1b

        # High multiplications
        vpmadd52huq B_curr, A0, ACC0b
        vpmadd52huq B_curr, A1, ACC1b

        vpmadd52huq Y_curr, M0, ACC0b
        vpmadd52huq Y_curr, M1, ACC1b

        # Shift the ACC in zmms right by a word
        valignq $1, ACC0, ACC1, ACC0
        valignq $1, ACC1, ZERO, ACC1
        mov     a0, %rdx

        mulx    (b_ptr), t0, t2
        add     t0, acc0
        adc     $0, t2

        mov     acc0, %rdx
        and     .LandMask(%rip), %rdx

        vpbroadcastq %rdx, Y_curr
        vpbroadcastq (b_ptr), B_curr

        mulx    m0, t0, t1
        add     t0, acc0
        adc     t1, t2

        shrd    $52, t2, acc0

        # Low multiplications
        vpmadd52luq B_curr, A0, ACC0b
        vpmadd52luq B_curr, A1, ACC1b

        vpmadd52luq Y_curr, M0, ACC0
        vpmadd52luq Y_curr, M1, ACC1

        vpaddq ACC0b, ACC0, ACC0
        vpaddq ACC1b, ACC1, ACC1

        vmovq ACC0_xmm, t0
        add t0, acc0

        lea 8(b_ptr), b_ptr
        dec itr
    jne 1b

    vmovq acc0, TMP_xmm

    vmovdqa64 TMP, ACC0{%k1}

    valignq $7, A0, A1, A1
    valignq $7, ZERO, A0, A0

    valignq $7, M0, M1, M1
    valignq $7, ZERO, M0, M0

    # The last high multiplications
    vpmadd52huq B_curr, A0, ACC0
    vpmadd52huq B_curr, A1, ACC1

    vpmadd52huq Y_curr, M0, ACC0
    vpmadd52huq Y_curr, M1, ACC1

    # Now 'normalize' the result to 52 bit words
    vpsrlq  $52, ACC0, A0
    vpsrlq  $52, ACC1, A1

    vpandq  AND_MASK, ACC0, ACC0
    vpandq  AND_MASK, ACC1, ACC1

    valignq $7, A0, A1, A1
    valignq $7, ZERO, A0, A0

    vpaddq  A0, ACC0, ACC0
    vpaddq  A1, ACC1, ACC1

    vpcmpuq $1, A0, ACC0, %k1
    vpcmpuq $1, A1, ACC1, %k2

    kmovb   %k1, %eax
    kmovb   %k2, %ebx

    add %al, %al
    adc %cl, %cl

    vpcmpuq $0, AND_MASK, ACC0, %k1
    vpcmpuq $0, AND_MASK, ACC1, %k2

    kmovb   %k1, %r8d
    kmovb   %k2, %r9d

    add %r8b, %al
    adc %r9b, %bl

    xor %r8b, %al
    xor %r9b, %bl

    kmovb %eax, %k1
    kmovb %ebx, %k2

    vpsubq AND_MASK, ACC0, ACC0{%k1}
    vpsubq AND_MASK, ACC1, ACC1{%k2}

    vpandq AND_MASK, ACC0, ACC0
    vpandq AND_MASK, ACC1, ACC1

    mov $0x7f, t0
    kmovq t0, %k1

    vmovdqu64 ACC0, 64*0(res)
    vmovdqu64 ACC1, 64*1(res){%k1}
 bail:
    pop     %r13
    pop     %r12
    pop     %rbx
    ret
