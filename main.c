#include <stdint.h>
#include <stdio.h>
#include <string.h>

#include "./sidh_ref/P751_internal.h"

#include "measurements.h"

#ifndef PRIME_BITS
#define PRIME_BITS 751
#endif

#define DIGITS_64 ((PRIME_BITS + 63) / 64)
#define DIGITS_52 ((PRIME_BITS + 51) / 52)

#define OALICE_BITS 372
#define OBOB_BITS 379
#define SECRETKEY_A_BYTES (OALICE_BITS + 7) / 8
#define SECRETKEY_B_BYTES (OBOB_BITS + 7) / 8

#define MASK_ALICE 0x0F
#define MASK_BOB 0x03

typedef uint64_t num52[DIGITS_52];
typedef num52 felem[2];

void fp2_mul_ifma(felem res, felem a, felem b);
void fp2_sqr_ifma(felem res, felem a);
void fp2_mul_ifma_x2(felem res1, const felem a1, const felem b1, felem res2, const felem a2, const felem b2);
void fp_mul_ifma(uint64_t *rp, const uint64_t *ap, const uint64_t *bp);
void to_mont_ifma(uint64_t *rp, const uint64_t *ap);
void from_mont_ifma(uint64_t *rp, const uint64_t *ap);

void red2norm(uint64_t out[12], const uint64_t in[15]);
void norm2red(uint64_t *res, const uint64_t *a);

int EphemeralKeyGeneration_A_ifma(const unsigned char *PrivateKeyA, unsigned char *PublicKeyA);
int EphemeralKeyGeneration_B_ifma(const unsigned char *PrivateKeyB, unsigned char *PublicKeyB);

int rdrand64_step(uint64_t *rand)
{
  unsigned char ok;
  __asm__ volatile("rdrand %0; setc %1"
                   : "=r"(*rand), "=qm"(ok));
  return (int)ok;
}

static void rand_750(uint64_t out[DIGITS_64])
{
  for (int i = 0; i < DIGITS_64; i++)
  {
    while (!rdrand64_step((uint64_t *)&out[i]))
      ;
  }

  out[DIGITS_64 - 1] &= ((1ULL << (PRIME_BITS - 64 * (DIGITS_64 - 1))) - 1);
}

static void rand_bytes(uint8_t *out, size_t out_len)
{
  uint64_t temp;
  for (int i = 0; i < out_len; i++)
  {
    while (!rdrand64_step((uint64_t *)&temp))
      ;
    out[i] = temp;
  }
}

int main()
{

  int i;

  do
  {
    felm_t fa, fb, fr;
    num52 r, a, b;
    uint64_t res_ifma[DIGITS_64];

    rand_750(fa);
    rand_750(fb);

    norm2red(a, (uint64_t *)fa);
    norm2red(b, (uint64_t *)fb);
    to_mont_ifma(a, a);
    to_mont_ifma(b, b);

    MEASURE({ fp_mul_ifma(r, a, b); });

    from_mont_ifma(r, r);
    red2norm(res_ifma, r);
    printf("Mont mul IFMA Cycles/op: %.0f\n", RDTSC_total_clk);

    to_mont(fa, fa);
    to_mont(fb, fb);
    MEASURE({ fpmul751_mont(fa, fb, fr); });
    from_mont(fr, fr);
    printf("Mont mul ref Cycles/op: %.0f\n", RDTSC_total_clk);

    printf("%s\n", memcmp(fr, res_ifma, sizeof(res_ifma)) ? "FP MUL Fail"
                                                          : "FP MUL Success");
  } while (0);

  do
  {
    felem a, b, r, r2;
    f2elm_t fa, fb, fr;
    uint64_t res_ifma[2][DIGITS_64];

    rand_750(fa[0]);
    rand_750(fa[1]);
    rand_750(fb[0]);
    rand_750(fb[1]);
    norm2red(a[0], (uint64_t *)fa[0]);
    norm2red(a[1], (uint64_t *)fa[1]);
    norm2red(b[0], (uint64_t *)fb[0]);
    norm2red(b[1], (uint64_t *)fb[1]);
    to_mont_ifma(a[0], a[0]);
    to_mont_ifma(a[1], a[1]);
    to_mont_ifma(b[0], b[0]);
    to_mont_ifma(b[1], b[1]);

    MEASURE({ fp2_mul_ifma(r, a, b); });

    from_mont_ifma(r[0], r[0]);
    from_mont_ifma(r[1], r[1]);
    red2norm(res_ifma[0], r[0]);
    red2norm(res_ifma[1], r[1]);
    printf("Mont FP2 mul IFMA Cycles/op: %.0f\n", RDTSC_total_clk);

    to_mont(fa[0], fa[0]);
    to_mont(fa[1], fa[1]);
    to_mont(fb[0], fb[0]);
    to_mont(fb[1], fb[1]);

    MEASURE({ fp2mul751_mont(fa, fb, fr); });

    from_mont(fr[0], fr[0]);
    from_mont(fr[1], fr[1]);
    printf("Mont FP2 mul ref Cycles/op: %.0f\n", RDTSC_total_clk);

    printf("%s\n", memcmp(fr, res_ifma, sizeof(res_ifma)) ? "FP2 MUL Fail"
                                                          : "FP2 MUL Success");

    MEASURE({ fp2_mul_ifma_x2(r, a, b, r2, a, b); });

    from_mont_ifma(r[0], r[0]);
    from_mont_ifma(r[1], r[1]);
    red2norm(res_ifma[0], r[0]);
    red2norm(res_ifma[1], r[1]);

    printf("Dual Mont FP2 mul IFMA Cycles/op: %.0f\n", RDTSC_total_clk);

    printf("%s\n", memcmp(fr, res_ifma, sizeof(res_ifma)) ? "Dual FP2 MUL 1/2 Fail"
                                                          : "Dual FP2 MUL 1/2 Success");

    from_mont_ifma(r2[0], r2[0]);
    from_mont_ifma(r2[1], r2[1]);
    red2norm(res_ifma[0], r2[0]);
    red2norm(res_ifma[1], r2[1]);

    printf("%s\n", memcmp(fr, res_ifma, sizeof(res_ifma)) ? "Dual FP2 MUL 2/2 Fail"
                                                          : "Dual FP2 MUL 2/2 Success");

    MEASURE({ fp2_sqr_ifma(r, a); });

    from_mont_ifma(r[0], r[0]);
    from_mont_ifma(r[1], r[1]);
    red2norm(res_ifma[0], r[0]);
    red2norm(res_ifma[1], r[1]);
    printf("Mont FP2 sqr IFMA Cycles/op: %.0f\n", RDTSC_total_clk);

    MEASURE({ fp2sqr751_mont(fa, fr); });

    from_mont(fr[0], fr[0]);
    from_mont(fr[1], fr[1]);
    printf("Mont FP2 sqr ref Cycles/op: %.0f\n", RDTSC_total_clk);

    printf("%s\n", memcmp(fr, res_ifma, sizeof(res_ifma)) ? "FP2 SQR Fail"
                                                          : "FP2 SQR Success");

  } while (0);

  do
  {
    unsigned char ephemeralsk_alice[SECRETKEY_A_BYTES];
    unsigned char ephemeralsk_bob[SECRETKEY_B_BYTES];
    unsigned char ct1[564] = {0};
    unsigned char ct2[564] = {0};
    rand_bytes(ephemeralsk_alice, sizeof(ephemeralsk_alice));
    rand_bytes(ephemeralsk_bob, sizeof(ephemeralsk_bob));
    ephemeralsk_alice[SECRETKEY_A_BYTES - 1] &= MASK_ALICE;
    ephemeralsk_bob[SECRETKEY_B_BYTES - 1] &= MASK_BOB;

    MEASURE({ EphemeralKeyGeneration_A(ephemeralsk_alice, ct1); });

    printf("Ref EphemeralKeyGeneration_A Cycles/op: %.0f\n", RDTSC_total_clk);

    MEASURE({ EphemeralKeyGeneration_A_ifma(ephemeralsk_alice, ct2); });

    printf("IFMA EphemeralKeyGeneration_A Cycles/op: %.0f\n", RDTSC_total_clk);

    printf("%s\n", memcmp(ct1, ct2, sizeof(ct1)) ? "EphemeralKeyGeneration_A Fail"
                                                 : "EphemeralKeyGeneration_A Success");

    MEASURE({ EphemeralKeyGeneration_B(ephemeralsk_bob, ct1); });

    printf("Ref EphemeralKeyGeneration_B Cycles/op: %.0f\n", RDTSC_total_clk);

    MEASURE({ EphemeralKeyGeneration_B_ifma(ephemeralsk_bob, ct2); });

    printf("IFMA EphemeralKeyGeneration_B Cycles/op: %.0f\n", RDTSC_total_clk);

    printf("%s\n", memcmp(ct1, ct2, sizeof(ct1)) ? "EphemeralKeyGeneration_B Fail"
                                                 : "EphemeralKeyGeneration_B Success");
  } while (0);
}
