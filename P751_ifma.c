#include <stdint.h>
#include <string.h>

#define NWORDS_FIELD 15
#define MAX_INT_POINTS_ALICE 8
#define MAX_INT_POINTS_BOB 10

#define ALICE 0
#define BOB 1
#define OALICE_BITS 372
#define OBOB_BITS 379

#define MAX_Alice 186
#define MAX_Bob 239

#define NBITS_FIELD 751
#define MAXBITS_FIELD 768
#define FP2_ENCODED_BYTES 2 * ((NBITS_FIELD + 7) / 8)

typedef uint64_t felm_t[NWORDS_FIELD];
typedef felm_t f2elm_t[2];

typedef struct
{
    f2elm_t X;
    f2elm_t Z;
} point_proj; // Point representation in projective XZ Montgomery coordinates.

typedef point_proj point_proj_t[1];

const uint64_t A_gen_ifma[5 * NWORDS_FIELD] = {
    0x000ceab50ad8bc0d, 0x0005e457b1c2fc08, 0x000cd6e1d7d710f5, 0x000ae8738d92953d, 0x000a7ebee8a3418a, 0x0008345f03f46fba, 0x0007cfe2616c9a28, 0x000b4be50c8b9e16, 0x00039b6799643b2e, 0x000597a7ff9d56d5, 0x00021d410d97fe0a, 0x000a4a92a8f2ad52, 0x00054508e42abde4, 0x000ebf7d0178c137, 0x00000000004a0a75,
    0x000d21582e4118ad, 0x0005df400ae6cc41, 0x000aec407c2ecb7c, 0x000de8e34b521432, 0x000761e2ab085167, 0x000bcaa6094b3c50, 0x000df9ddd71032cf, 0x00057d905265605f, 0x000f7dba2681f9d7, 0x0009e9732def416c, 0x0006f77956ce00ce, 0x000576fb3094772b, 0x000b2d166e2a949f, 0x0002f665c6588ea2, 0x0000000000337a25,
    0x00026279148626cd, 0x0006b5baead56fe5, 0x000ab911fad60dc9, 0x000401e137d0bf07, 0x0004d3e925216196, 0x0005e4cd09a33740, 0x00069e4af733c538, 0x000d1169f6821367, 0x000c64ecfc721111, 0x000ba56507cd0dc7, 0x000995e4ae04dfad, 0x0007b992deeceab8, 0x0007bccd256aff1e, 0x000207f5fde1824c, 0x0000000000345cc7,
    0x00041dffd19b3e7f, 0x000b48c18e0bb844, 0x000380584b4dea99, 0x0000692de648ad31, 0x000d72761b6dfaee, 0x0005c672c3058de6, 0x000cba26fdc22397, 0x000e15f9133d4bc3, 0x000d5ae123793466, 0x000bb494276e321d, 0x000c9c99fb74cd99, 0x0005da6e4fd03f75, 0x000b95feb24d0937, 0x000e6a307e03cd17, 0x000000000044ad2e,
    0x0007f1ec71be8c36, 0x00053859b1ed78c1, 0x000529ff824d6df7, 0x000633a10839b2a8, 0x00003e9e25fdea79, 0x000a8054df1762fc, 0x000034c6467c4708, 0x000acb63530b60ec, 0x0000c6fc8c19bf71, 0x0005aca92467c3cb, 0x000d42050ba154a2, 0x000b4d5baa4ab074, 0x00044ba4962ac622, 0x0002bbf250aa70e6, 0x0000000000457f51};

const uint64_t B_gen_ifma[5 * NWORDS_FIELD] = {
    0x0001ef867ab0bcb9, 0x0009a45c76cfb6d7, 0x0001f034a5fdd76e, 0x000038b1ee69194b, 0x000e7b18a7761f3f, 0x000a486a52c84cf6, 0x0005aa75466fcf01, 0x00044164f797233f, 0x000331aeaec77db1, 0x0005185f83d9a22f, 0x000e2d4dc94f5b17, 0x0000f7b3858b15a4, 0x000635ac44515c99, 0x000a5b14eaf4ee2e, 0x000000000048e907,
    0x0004e7c075cc3a24, 0x00004aa430a49203, 0x00094c8677baf00b, 0x000b3aae0c9a755c, 0x000c4b064e9ebb08, 0x000dd04e826c661d, 0x00061f01b223684e, 0x000d43bc8a6360b6, 0x00008c633a79ab30, 0x0008e0092fbd6f39, 0x0002b9ba797337f8, 0x000fcb3252ddaf84, 0x000467ded2ca9dce, 0x0006117350e479f4, 0x00000000001ae9d1,
    0x000ed7b96c4ab279, 0x000178486ef1a8c9, 0x000c2f4299429da5, 0x000aef4926f20cd5, 0x0003b2e2858b4716, 0x000bcc3cac3eeb68, 0x0003a600460dda2f, 0x00050e6650a24c9f, 0x0004cb60c61775f8, 0x00082b196ebc78b3, 0x000cc7fec8cce966, 0x000d9b778d801d65, 0x0005324630f74af3, 0x0009018193e7592e, 0x00000000003aef05,
    0x00033769d0f314ef, 0x000e2659d11c0d67, 0x000d133f084c3086, 0x0005e23d5da27bcb, 0x0008ec9a8d586402, 0x000c781b3b645bf3, 0x000c9fb03ee6426d, 0x000ddc7bb40b83e3, 0x000bb7b4ab585e3a, 0x0006c2672e53eeaf, 0x0000397a1e62b655, 0x0004ac383daab923, 0x0008eb1ecdd2f39e, 0x000f1516da469247, 0x00000000003693cf,
    0x0007d8f72bd956dc, 0x000e9934884ae37e, 0x0003c3edd2d504b3, 0x00005d14e7fa1ecb, 0x0007610ceb75d635, 0x000b4cac446b1112, 0x000c1f70caf255b4, 0x00057d3e324d2f36, 0x0006181c3bb1a700, 0x000db2f2916ccc40, 0x00021ee51d1c92f1, 0x000c07c22031c32a, 0x000e4310e5103473, 0x00069c1148de9ef5, 0x00000000004d1227};

const uint64_t One[NWORDS_FIELD] = {
    0x00000000249ad67c, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0001f9800c542c00, 0x000b326488fe3b2a, 0x000e6176236db777, 0x000dd6e970232b83, 0x000d4d762277573f, 0x00054cd16c015f35, 0x0009fc72438c4fc7, 0x00000000001bf8f6};

const uint64_t Two[NWORDS_FIELD] = {
    0x000000004935acf8, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0003f30018a85800, 0x000664c911fc7654, 0x000cc2ec46db6eef, 0x000badd2e0465707, 0x000a9aec44eeae7f, 0x000a99a2d802be6b, 0x0003f8e487189f8e, 0x000000000037f1ed};

// Fixed parameters for isogeny tree computation
extern const unsigned int strat_Alice[MAX_Alice - 1];
extern const unsigned int strat_Bob[MAX_Bob - 1];

void norm2red(uint64_t *res, const uint64_t *a);
void red2norm(uint64_t out[12], const uint64_t in[15])
{
    out[0] = in[0] ^ in[1] << 52;

    out[1] = in[1] >> 12 ^ in[2] << 40;
    out[2] = in[2] >> 24 ^ in[3] << 28;
    out[3] = in[3] >> 36 ^ in[4] << 16;
    out[4] = in[4] >> 48 ^ in[5] << 4 ^ in[6] << 56;

    out[5] = in[6] >> 8 ^ in[7] << 44;
    out[6] = in[7] >> 20 ^ in[8] << 32;
    out[7] = in[8] >> 32 ^ in[9] << 20;
    out[8] = in[9] >> 44 ^ in[10] << 8 ^ in[11] << 60;

    out[9] = in[11] >> 4 ^ in[12] << 48;
    out[10] = in[12] >> 16 ^ in[13] << 36;
    out[11] = in[13] >> 28 ^ in[14] << 24;
}

static void init_basis(const uint64_t *gen, f2elm_t XP, f2elm_t XQ, f2elm_t XR)
{ // Initialization of basis points

    memcpy(XP[0], &gen[0 * NWORDS_FIELD], sizeof(felm_t));
    memcpy(XP[1], &gen[1 * NWORDS_FIELD], sizeof(felm_t));

    memcpy(XQ[0], &gen[2 * NWORDS_FIELD], sizeof(felm_t));
    memset(XQ[1], 0, sizeof(felm_t));

    memcpy(XR[0], &gen[3 * NWORDS_FIELD], sizeof(felm_t));
    memcpy(XR[1], &gen[4 * NWORDS_FIELD], sizeof(felm_t));
}

void fp2_mul_ifma(f2elm_t res, const f2elm_t a, const f2elm_t b);
void fp2_mul_ifma_x2(f2elm_t res1, const f2elm_t a1, const f2elm_t b1, f2elm_t res2, const f2elm_t a2, const f2elm_t b2);
void fp2_sqr_ifma(f2elm_t res, const f2elm_t a);
void fp2_add(f2elm_t res, const f2elm_t a, const f2elm_t b);
void fp2_sub(f2elm_t res, const f2elm_t a, const f2elm_t b);

void fp2_swap(point_proj_t a, point_proj_t b, int swap);

void fp_mul_ifma(felm_t res, felm_t a, felm_t b);
void fp_add(felm_t res, const felm_t a, const felm_t b);
void fp_sub(felm_t res, const felm_t a, const felm_t b);

void to_mont_ifma(felm_t rp, const felm_t ap);
void from_mont_ifma(felm_t rp, const felm_t ap);

void red2norm(uint64_t out[12], const felm_t in);

#define fp2mul_mont(a, b, r) fp2_mul_ifma(r, a, b)
#define fp2sqr_mont(a, r) fp2_sqr_ifma(r, a)
#define fp2add(a, b, r) fp2_add(r, a, b)
#define fp2sub(a, b, r) fp2_sub(r, a, b)
#define fp2correction

#define fpsqr_mont(a, r) fp_mul_ifma(r, a, a)
#define fpmul_mont(a, b, r) fp_mul_ifma(r, a, b)

#define fpadd(a, b, r) fp_add(r, a, b)
#define fpsub(a, b, r) fp_sub(r, a, b)

void fpinv_chain_mont(felm_t a)
{ // Chain to compute a^(p-3)/4 using Montgomery arithmetic.
    unsigned int i, j;
    felm_t t[27], tt;

    // Precomputed table
    fpsqr_mont(a, tt);
    fpmul_mont(a, tt, t[0]);
    fpmul_mont(t[0], tt, t[1]);
    fpmul_mont(t[1], tt, t[2]);
    fpmul_mont(t[2], tt, t[3]);
    fpmul_mont(t[3], tt, t[3]);
    for (i = 3; i <= 8; i++)
        fpmul_mont(t[i], tt, t[i + 1]);
    fpmul_mont(t[9], tt, t[9]);
    for (i = 9; i <= 20; i++)
        fpmul_mont(t[i], tt, t[i + 1]);
    fpmul_mont(t[21], tt, t[21]);
    for (i = 21; i <= 24; i++)
        fpmul_mont(t[i], tt, t[i + 1]);
    fpmul_mont(t[25], tt, t[25]);
    fpmul_mont(t[25], tt, t[26]);

    memcpy(tt, a, sizeof(felm_t));
    for (i = 0; i < 6; i++)
        fpsqr_mont(tt, tt);
    fpmul_mont(t[20], tt, tt);
    for (i = 0; i < 6; i++)
        fpsqr_mont(tt, tt);
    fpmul_mont(t[24], tt, tt);
    for (i = 0; i < 6; i++)
        fpsqr_mont(tt, tt);
    fpmul_mont(t[11], tt, tt);
    for (i = 0; i < 6; i++)
        fpsqr_mont(tt, tt);
    fpmul_mont(t[8], tt, tt);
    for (i = 0; i < 8; i++)
        fpsqr_mont(tt, tt);
    fpmul_mont(t[2], tt, tt);
    for (i = 0; i < 6; i++)
        fpsqr_mont(tt, tt);
    fpmul_mont(t[23], tt, tt);
    for (i = 0; i < 6; i++)
        fpsqr_mont(tt, tt);
    fpmul_mont(t[2], tt, tt);
    for (i = 0; i < 9; i++)
        fpsqr_mont(tt, tt);
    fpmul_mont(t[2], tt, tt);
    for (i = 0; i < 10; i++)
        fpsqr_mont(tt, tt);
    fpmul_mont(t[15], tt, tt);
    for (i = 0; i < 8; i++)
        fpsqr_mont(tt, tt);
    fpmul_mont(t[13], tt, tt);
    for (i = 0; i < 8; i++)
        fpsqr_mont(tt, tt);
    fpmul_mont(t[26], tt, tt);
    for (i = 0; i < 8; i++)
        fpsqr_mont(tt, tt);
    fpmul_mont(t[20], tt, tt);
    for (i = 0; i < 6; i++)
        fpsqr_mont(tt, tt);
    fpmul_mont(t[11], tt, tt);
    for (i = 0; i < 6; i++)
        fpsqr_mont(tt, tt);
    fpmul_mont(t[10], tt, tt);
    for (i = 0; i < 6; i++)
        fpsqr_mont(tt, tt);
    fpmul_mont(t[14], tt, tt);
    for (i = 0; i < 6; i++)
        fpsqr_mont(tt, tt);
    fpmul_mont(t[4], tt, tt);
    for (i = 0; i < 10; i++)
        fpsqr_mont(tt, tt);
    fpmul_mont(t[18], tt, tt);
    for (i = 0; i < 6; i++)
        fpsqr_mont(tt, tt);
    fpmul_mont(t[1], tt, tt);
    for (i = 0; i < 7; i++)
        fpsqr_mont(tt, tt);
    fpmul_mont(t[22], tt, tt);
    for (i = 0; i < 10; i++)
        fpsqr_mont(tt, tt);
    fpmul_mont(t[6], tt, tt);
    for (i = 0; i < 7; i++)
        fpsqr_mont(tt, tt);
    fpmul_mont(t[24], tt, tt);
    for (i = 0; i < 6; i++)
        fpsqr_mont(tt, tt);
    fpmul_mont(t[9], tt, tt);
    for (i = 0; i < 8; i++)
        fpsqr_mont(tt, tt);
    fpmul_mont(t[18], tt, tt);
    for (i = 0; i < 6; i++)
        fpsqr_mont(tt, tt);
    fpmul_mont(t[17], tt, tt);
    for (i = 0; i < 8; i++)
        fpsqr_mont(tt, tt);
    fpmul_mont(a, tt, tt);
    for (i = 0; i < 10; i++)
        fpsqr_mont(tt, tt);
    fpmul_mont(t[16], tt, tt);
    for (i = 0; i < 6; i++)
        fpsqr_mont(tt, tt);
    fpmul_mont(t[7], tt, tt);
    for (i = 0; i < 6; i++)
        fpsqr_mont(tt, tt);
    fpmul_mont(t[0], tt, tt);
    for (i = 0; i < 7; i++)
        fpsqr_mont(tt, tt);
    fpmul_mont(t[12], tt, tt);
    for (i = 0; i < 7; i++)
        fpsqr_mont(tt, tt);
    fpmul_mont(t[19], tt, tt);
    for (i = 0; i < 6; i++)
        fpsqr_mont(tt, tt);
    fpmul_mont(t[22], tt, tt);
    for (i = 0; i < 6; i++)
        fpsqr_mont(tt, tt);
    fpmul_mont(t[25], tt, tt);
    for (i = 0; i < 7; i++)
        fpsqr_mont(tt, tt);
    fpmul_mont(t[2], tt, tt);
    for (i = 0; i < 6; i++)
        fpsqr_mont(tt, tt);
    fpmul_mont(t[10], tt, tt);
    for (i = 0; i < 7; i++)
        fpsqr_mont(tt, tt);
    fpmul_mont(t[22], tt, tt);
    for (i = 0; i < 8; i++)
        fpsqr_mont(tt, tt);
    fpmul_mont(t[18], tt, tt);
    for (i = 0; i < 6; i++)
        fpsqr_mont(tt, tt);
    fpmul_mont(t[4], tt, tt);
    for (i = 0; i < 6; i++)
        fpsqr_mont(tt, tt);
    fpmul_mont(t[14], tt, tt);
    for (i = 0; i < 7; i++)
        fpsqr_mont(tt, tt);
    fpmul_mont(t[13], tt, tt);
    for (i = 0; i < 6; i++)
        fpsqr_mont(tt, tt);
    fpmul_mont(t[5], tt, tt);
    for (i = 0; i < 6; i++)
        fpsqr_mont(tt, tt);
    fpmul_mont(t[23], tt, tt);
    for (i = 0; i < 6; i++)
        fpsqr_mont(tt, tt);
    fpmul_mont(t[21], tt, tt);
    for (i = 0; i < 6; i++)
        fpsqr_mont(tt, tt);
    fpmul_mont(t[2], tt, tt);
    for (i = 0; i < 7; i++)
        fpsqr_mont(tt, tt);
    fpmul_mont(t[23], tt, tt);
    for (i = 0; i < 8; i++)
        fpsqr_mont(tt, tt);
    fpmul_mont(t[12], tt, tt);
    for (i = 0; i < 6; i++)
        fpsqr_mont(tt, tt);
    fpmul_mont(t[9], tt, tt);
    for (i = 0; i < 6; i++)
        fpsqr_mont(tt, tt);
    fpmul_mont(t[3], tt, tt);
    for (i = 0; i < 7; i++)
        fpsqr_mont(tt, tt);
    fpmul_mont(t[13], tt, tt);
    for (i = 0; i < 7; i++)
        fpsqr_mont(tt, tt);
    fpmul_mont(t[17], tt, tt);
    for (i = 0; i < 8; i++)
        fpsqr_mont(tt, tt);
    fpmul_mont(t[26], tt, tt);
    for (i = 0; i < 8; i++)
        fpsqr_mont(tt, tt);
    fpmul_mont(t[5], tt, tt);
    for (i = 0; i < 8; i++)
        fpsqr_mont(tt, tt);
    fpmul_mont(t[8], tt, tt);
    for (i = 0; i < 6; i++)
        fpsqr_mont(tt, tt);
    fpmul_mont(t[2], tt, tt);
    for (i = 0; i < 6; i++)
        fpsqr_mont(tt, tt);
    fpmul_mont(t[11], tt, tt);
    for (i = 0; i < 7; i++)
        fpsqr_mont(tt, tt);
    fpmul_mont(t[20], tt, tt);
    for (j = 0; j < 61; j++)
    {
        for (i = 0; i < 6; i++)
            fpsqr_mont(tt, tt);
        fpmul_mont(t[26], tt, tt);
    }
    memcpy(a, tt, sizeof(felm_t));
}

void fpinv_mont(felm_t a)
{ // Field inversion using Montgomery arithmetic, a = a^(-1)*R mod p.
    felm_t tt;
    memcpy(tt, a, sizeof(felm_t));
    fpinv_chain_mont(tt);
    fpsqr_mont(tt, tt);
    fpsqr_mont(tt, tt);
    fpmul_mont(a, tt, a);
}

void fp2inv_mont(f2elm_t a)
{ // GF(p^2) inversion using Montgomery arithmetic, a = (a0-i*a1)/(a0^2+a1^2).
    f2elm_t t1;
    felm_t zero = {0};
    fpsqr_mont(a[0], t1[0]);    // t10 = a0^2
    fpsqr_mont(a[1], t1[1]);    // t11 = a1^2
    fpadd(t1[0], t1[1], t1[0]); // t10 = a0^2+a1^2
    fpinv_mont(t1[0]);          // t10 = (a0^2+a1^2)^-1
    fp_sub(a[1], zero, a[1]);   // a = a0-i*a1
    fpmul_mont(a[0], t1[0], a[0]);
    fpmul_mont(a[1], t1[0], a[1]); // a = (a0-i*a1)*(a0^2+a1^2)^-1
}

void inv_3_way_ifma(f2elm_t z1, f2elm_t z2, f2elm_t z3)
{ // 3-way simultaneous inversion
    // Input:  z1,z2,z3
    // Output: 1/z1,1/z2,1/z3 (override inputs).
    f2elm_t t0, t1, t2, t3;

    fp2mul_mont(z1, z2, t0); // t0 = z1*z2
    fp2mul_mont(z3, t0, t1); // t1 = z1*z2*z3
    fp2inv_mont(t1);         // t1 = 1/(z1*z2*z3)
    fp2mul_mont(z3, t1, t2); // t2 = 1/(z1*z2)
    fp2_mul_ifma_x2(t3, t2, z2, z2, t2, z1);
    //fp2mul_mont(t2, z2, t3); // t3 = 1/z1
    //fp2mul_mont(t2, z1, z2); // z2 = 1/z2
    fp2mul_mont(t0, t1, z3); // z3 = 1/z3
    memcpy(z1, t3, sizeof(f2elm_t));
}

void xDBLADD_ifma(point_proj_t P, point_proj_t Q, const f2elm_t xPQ, const f2elm_t A24)
{ // Simultaneous doubling and differential addition.
    // Input: projective Montgomery points P=(XP:ZP) and Q=(XQ:ZQ) such that xP=XP/ZP and xQ=XQ/ZQ, affine difference xPQ=x(P-Q) and Montgomery curve constant A24=(A+2)/4.
    // Output: projective Montgomery points P <- 2*P = (X2P:Z2P) such that x(2P)=X2P/Z2P, and Q <- P+Q = (XQP:ZQP) such that = x(Q+P)=XQP/ZQP.
    f2elm_t t0, t1, t2, t3;

    fp2add(P->X, P->Z, t0); // t0 = XP+ZP
    fp2sub(P->X, P->Z, t1); // t1 = XP-ZP

    fp2_mul_ifma_x2(P->X, t0, t0, P->Z, t1, t1);
    //fp2sqr_mont(t0, P->X); // XP = (XP+ZP)^2
    //fp2sqr_mont(t1, P->Z); // ZP = (XP-ZP)^2

    fp2add(Q->X, Q->Z, t2); // XQ = XQ+ZQ
    fp2sub(Q->X, Q->Z, t3); // t2 = XQ-ZQ

    fp2_mul_ifma_x2(t1, t1, t2, t0, t0, t3);
    //fp2mul_mont(t2, t1, t1); // t1 = (XP-ZP)*(XQ+ZQ)
    //fp2mul_mont(t3, t0, t0); // t0 = (XP+ZP)*(XQ-ZQ)

    fp2sub(P->X, P->Z, t2); // t2 = (XP+ZP)^2-(XP-ZP)^2
    fp2sub(t0, t1, Q->Z);   // ZQ = (XP+ZP)*(XQ-ZQ)-(XP-ZP)*(XQ+ZQ)

    fp2_mul_ifma_x2(P->X, P->X, P->Z, Q->X, A24, t2);
    //fp2mul_mont(P->X, P->Z, P->X); // XP = (XP+ZP)^2*(XP-ZP)^2
    //fp2mul_mont(t2, A24, Q->X);    // XQ = A24*[(XP+ZP)^2-(XP-ZP)^2]

    fp2add(Q->X, P->Z, P->Z); // ZP = A24*[(XP+ZP)^2-(XP-ZP)^2]+(XP-ZP)^2
    fp2add(t0, t1, Q->X);     // XQ = (XP+ZP)*(XQ-ZQ)+(XP-ZP)*(XQ+ZQ)

    fp2_mul_ifma_x2(Q->Z, Q->Z, Q->Z, Q->X, Q->X, Q->X);
    //fp2sqr_mont(Q->Z, Q->Z); // ZQ = [(XP+ZP)*(XQ-ZQ)-(XP-ZP)*(XQ+ZQ)]^2
    //fp2sqr_mont(Q->X, Q->X); // XQ = [(XP+ZP)*(XQ-ZQ)+(XP-ZP)*(XQ+ZQ)]^2

    fp2_mul_ifma_x2(P->Z, P->Z, t2, Q->Z, Q->Z, xPQ);
    //fp2mul_mont(P->Z, t2, P->Z);  // ZP = [A24*[(XP+ZP)^2-(XP-ZP)^2]+(XP-ZP)^2]*[(XP+ZP)^2-(XP-ZP)^2]
    //fp2mul_mont(Q->Z, xPQ, Q->Z); // ZQ = xPQ*[(XP+ZP)*(XQ-ZQ)-(XP-ZP)*(XQ+ZQ)]^2
}

static void LADDER3PT_ifma(const f2elm_t xP, const f2elm_t xQ, const f2elm_t xPQ, const uint64_t *m, const unsigned int AliceOrBob, point_proj_t R)
{
    point_proj_t R0 = {0}, R2 = {0};
    const f2elm_t A24 = {
        {0x00000000124d6b3e, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000fcc0062a1600, 0x000d9932447f1d95, 0x000f30bb11b6dbbb, 0x000eeb74b81195c1, 0x000ea6bb113bab9f, 0x000aa668b600af9a, 0x0004fe3921c627e3, 0x00000000000dfc7b},
        {0}};

    uint64_t mask;
    int i, nbits, bit, swap, prevbit = 0;

    if (AliceOrBob == ALICE)
    {
        nbits = OALICE_BITS;
    }
    else
    {
        nbits = OBOB_BITS;
    }

    // Initializing points
    memcpy(R0->X, xQ, sizeof(f2elm_t));
    memcpy(R0->Z[0], One, sizeof(felm_t));

    memcpy(R2->X, xPQ, sizeof(f2elm_t));
    memcpy(R2->Z[0], One, sizeof(felm_t));

    memcpy(R->X, xP, sizeof(f2elm_t));
    memcpy(R->Z[0], One, sizeof(felm_t));
    memset(R->Z[1], 0, sizeof(felm_t));

    // Main loop
    for (i = 0; i < nbits; i++)
    {
        bit = (m[i >> 6] >> (i & (64 - 1))) & 1;
        swap = bit ^ prevbit;
        prevbit = bit;
        fp2_swap(R, R2, swap);

        xDBLADD_ifma(R0, R2, R->X, A24);
        fp2_mul_ifma(R2->X, R->Z, R2->X);
    }
}

static void xDBL_ifma(const point_proj_t P, point_proj_t Q, const f2elm_t A24plus, const f2elm_t C24)
{ // Doubling of a Montgomery point in projective coordinates (X:Z).
    // Input: projective Montgomery x-coordinates P = (X1:Z1), where x1=X1/Z1 and Montgomery curve constants A+2C and 4C.
    // Output: projective Montgomery x-coordinates Q = 2*P = (X2:Z2).
    f2elm_t t0, t1, t2;

    fp2sub(P->X, P->Z, t0); // t0 = X1-Z1
    fp2add(P->X, P->Z, t1); // t1 = X1+Z1

    fp2_mul_ifma_x2(t0, t0, t0, t1, t1, t1);
    //fp2sqr_mont(t0, t0); // t0 = (X1-Z1)^2
    //fp2sqr_mont(t1, t1); // t1 = (X1+Z1)^2

    fp2sub(t1, t0, t2); // t1 = (X1+Z1)^2-(X1-Z1)^2

    fp2_mul_ifma_x2(Q->Z, t0, C24, t0, t2, A24plus);
    //fp2mul_mont(C24, t0, Q->Z);   // Z2 = C24*(X1-Z1)^2
    //fp2mul_mont(A24plus, t2, t0); // t0 = A24plus*[(X1+Z1)^2-(X1-Z1)^2]

    fp2add(Q->Z, t0, t0); // Z2 = A24plus*[(X1+Z1)^2-(X1-Z1)^2] + C24*(X1-Z1)^2

    fp2_mul_ifma_x2(Q->X, Q->Z, t1, Q->Z, t2, t0);
    //fp2mul_mont(t1, Q->Z, Q->X); // X2 = C24*(X1-Z1)^2*(X1+Z1)^2
    //fp2mul_mont(t0, t2, Q->Z);   // Z2 = [A24plus*[(X1+Z1)^2-(X1-Z1)^2] + C24*(X1-Z1)^2]*[(X1+Z1)^2-(X1-Z1)^2]
}

static void xDBLe_ifma(const point_proj_t P, point_proj_t Q, const f2elm_t A24plus, const f2elm_t C24, const int e)
{ // Computes [2^e](X:Z) on Montgomery curve with projective constant via e repeated doublings.
    // Input: projective Montgomery x-coordinates P = (XP:ZP), such that xP=XP/ZP and Montgomery curve constants A+2C and 4C.
    // Output: projective Montgomery x-coordinates Q <- (2^e)*P.
    int i;

    memcpy(Q, P, sizeof(point_proj));

    for (i = 0; i < e; i++)
    {
        xDBL_ifma(Q, Q, A24plus, C24);
    }
}

static void xTPL_ifma(const point_proj_t P, point_proj_t Q, const f2elm_t A24minus, const f2elm_t A24plus)
{ // Tripling of a Montgomery point in projective coordinates (X:Z).
    // Input: projective Montgomery x-coordinates P = (X:Z), where x=X/Z and Montgomery curve constants A24plus = A+2C and A24minus = A-2C.
    // Output: projective Montgomery x-coordinates Q = 3*P = (X3:Z3).
    f2elm_t t0, t1, t2, t3, t4, t5, t6, t7, t8;

    fp2sub(P->X, P->Z, t0); // t0 = X-Z
    fp2add(P->X, P->Z, t1); // t1 = X+Z
    fp2_mul_ifma_x2(t2, t0, t0, t3, t1, t1);
    //fp2sqr_mont(t0, t2);           // t2 = (X-Z)^2
    //fp2sqr_mont(t1, t3);           // t3 = (X+Z)^2
    fp2_mul_ifma_x2(t5, A24plus, t3, t6, A24minus, t2);
    //fp2mul_mont(t3, A24plus, t5);  // t5 = A24plus*(X+Z)^2
    //fp2mul_mont(A24minus, t2, t6); // t6 = A24minus*(X-Z)^2
    fp2_mul_ifma_x2(t7, t3, t5, t8, t2, t6);
    //fp2mul_mont(t3, t5, t7); // t3 = A24plus*(X+Z)^3
    //fp2mul_mont(t2, t6, t8); // t2 = A24minus*(X-Z)^3
    fp2add(t0, t1, t4);      // t4 = 2*X
    fp2sub(t1, t0, t0);      // t0 = 2*Z
    fp2sqr_mont(t4, t1);     // t1 = 4*X^2
    fp2sub(t1, t3, t1);      // t1 = 4*X^2 - (X+Z)^2
    fp2sub(t1, t2, t1);      // t1 = 4*X^2 - (X+Z)^2 - (X-Z)^2
    fp2sub(t8, t7, t7);      // t3 = A24minus*(X-Z)^3 - coeff*(X+Z)^3
    fp2sub(t5, t6, t8);      // t2 = A24plus*(X+Z)^2 - A24minus*(X-Z)^2
    fp2mul_mont(t1, t8, t1); // t1 = [4*X^2 - (X+Z)^2 - (X-Z)^2]*[A24plus*(X+Z)^2 - A24minus*(X-Z)^2]
    fp2add(t7, t1, t8);      // t2 = [4*X^2 - (X+Z)^2 - (X-Z)^2]*[A24plus*(X+Z)^2 - A24minus*(X-Z)^2] + A24minus*(X-Z)^3 - coeff*(X+Z)^3
    fp2sub(t7, t1, t1);      // t1 = A24minus*(X-Z)^3 - A24plus*(X+Z)^3 - [4*X^2 - (X+Z)^2 - (X-Z)^2]*[A24plus*(X+Z)^2 - A24minus*(X-Z)^2]
    fp2_mul_ifma_x2(t8, t8, t8, t1, t1, t1);
    //fp2sqr_mont(t8, t8); // t2 = t2^2
    //fp2sqr_mont(t1, t1); // t1 = t1^2
    fp2_mul_ifma_x2(Q->X, t4, t8, Q->Z, t1, t0);
    //fp2mul_mont(t4, t8, Q->X); // X3 = 2*X*t2
    //fp2mul_mont(t0, t1, Q->Z); // Z3 = 2*Z*t1
}

void xTPLe_ifma(const point_proj_t P, point_proj_t Q, const f2elm_t A24minus, const f2elm_t A24plus, const int e)
{ // Computes [3^e](X:Z) on Montgomery curve with projective constant via e repeated triplings.
    // Input: projective Montgomery x-coordinates P = (XP:ZP), such that xP=XP/ZP and Montgomery curve constants A24plus = A+2C and A24minus = A-2C.
    // Output: projective Montgomery x-coordinates Q <- (3^e)*P.
    int i;

    memcpy(Q, P, sizeof(point_proj));

    for (i = 0; i < e; i++)
    {
        xTPL_ifma(Q, Q, A24minus, A24plus);
    }
}

static void get_4_isog_ifma(const point_proj_t P, f2elm_t A24plus, f2elm_t C24, f2elm_t *coeff)
{ // Computes the corresponding 4-isogeny of a projective Montgomery point (X4:Z4) of order 4.
    // Input:  projective point of order four P = (X4:Z4).
    // Output: the 4-isogenous Montgomery curve with projective coefficients A+2C/4C and the 3 coefficients
    //         that are used to evaluate the isogeny at a point in eval_4_isog().

    fp2sub(P->X, P->Z, coeff[1]); // coeff[1] = X4-Z4
    fp2add(P->X, P->Z, coeff[2]); // coeff[2] = X4+Z4

    fp2_mul_ifma_x2(coeff[0], P->Z, P->Z, A24plus, P->X, P->X);
    //fp2sqr_mont(P->Z, coeff[0]); // coeff[0] = Z4^2
    //fp2sqr_mont(P->X, A24plus);  // A24plus = X4^2

    fp2add(coeff[0], coeff[0], coeff[0]); // coeff[0] = 2*Z4^2
    fp2add(A24plus, A24plus, A24plus);    // A24plus = 2*X4^2

    fp2_mul_ifma_x2(C24, coeff[0], coeff[0], A24plus, A24plus, A24plus);
    //fp2sqr_mont(coeff[0], C24);    // C24 = 4*Z4^4
    //fp2sqr_mont(A24plus, A24plus); // A24plus = 4*X4^4

    fp2add(coeff[0], coeff[0], coeff[0]); // coeff[0] = 4*Z4^2
}

static void eval_4_isog_ifma(point_proj_t P, f2elm_t *coeff)
{ // Evaluates the isogeny at the point (X:Z) in the domain of the isogeny, given a 4-isogeny phi defined
    // by the 3 coefficients in coeff (computed in the function get_4_isog()).
    // Inputs: the coefficients defining the isogeny, and the projective point P = (X:Z).
    // Output: the projective point P = phi(P) = (X:Z) in the codomain.
    f2elm_t t0, t1, t2;

    fp2add(P->X, P->Z, t0); // t0 = X+Z
    fp2sub(P->X, P->Z, t1); // t1 = X-Z

    fp2_mul_ifma_x2(P->X, t0, coeff[1], t0, t0, t1);
    //fp2mul_mont(t0, coeff[1], P->X); // X = (X+Z)*coeff[1]
    //fp2mul_mont(t0, t1, t0);             // t0 = (X+Z)*(X-Z)

    fp2_mul_ifma_x2(P->Z, coeff[2], t1, t0, coeff[0], t0);
    //fp2mul_mont(t1, coeff[2], P->Z); // Z = (X-Z)*coeff[2]
    //fp2mul_mont(t0, coeff[0], t0);   // t0 = coeff[0]*(X+Z)*(X-Z)

    fp2add(P->X, P->Z, t1);   // t1 = (X-Z)*coeff[2] + (X+Z)*coeff[1]
    fp2sub(P->X, P->Z, P->Z); // Z = (X-Z)*coeff[2] - (X+Z)*coeff[1]

    fp2_mul_ifma_x2(t1, t1, t1, P->Z, P->Z, P->Z);
    //fp2sqr_mont(t1, t1);     // t1 = [(X-Z)*coeff[2] + (X+Z)*coeff[1]]^2
    //fp2sqr_mont(P->Z, P->Z); // Z = [(X-Z)*coeff[2] - (X+Z)*coeff[1]]^2

    fp2add(t1, t0, P->X); // X = coeff[0]*(X+Z)*(X-Z) + [(X-Z)*coeff[2] + (X+Z)*coeff[1]]^2
    fp2sub(P->Z, t0, t0); // t0 = [(X-Z)*coeff[2] - (X+Z)*coeff[1]]^2 - coeff[0]*(X+Z)*(X-Z)

    fp2_mul_ifma_x2(P->X, P->X, t1, P->Z, P->Z, t0);
    //fp2mul_mont(P->X, t1, P->X); // Xfinal
    //fp2mul_mont(P->Z, t0, P->Z); // Zfinal
}

static void get_3_isog_ifma(const point_proj_t P, f2elm_t A24minus, f2elm_t A24plus, f2elm_t *coeff)
{ // Computes the corresponding 3-isogeny of a projective Montgomery point (X3:Z3) of order 3.
    // Input:  projective point of order three P = (X3:Z3).
    // Output: the 3-isogenous Montgomery curve with projective coefficient A/C.
    f2elm_t t0, t1, t2, t3, t4, t5;

    fp2sub(P->X, P->Z, coeff[0]); // coeff0 = X-Z
    fp2add(P->X, P->Z, coeff[1]); // coeff1 = X+Z
    fp2_mul_ifma_x2(t0, coeff[0], coeff[0], t1, coeff[1], coeff[1]);
    //fp2sqr_mont(coeff[0], t0);      // t0 = (X-Z)^2
    //fp2sqr_mont(coeff[1], t1);      // t1 = (X+Z)^2
    fp2add(t0, t1, t2);             // t2 = (X+Z)^2 + (X-Z)^2
    fp2add(coeff[0], coeff[1], t3); // t3 = 2*X
    fp2sqr_mont(t3, t3);            // t3 = 4*X^2
    fp2sub(t3, t2, t3);             // t3 = 4*X^2 - (X+Z)^2 - (X-Z)^2
    fp2add(t1, t3, t2);             // t2 = 4*X^2 - (X-Z)^2
    fp2add(t3, t0, t3);             // t3 = 4*X^2 - (X+Z)^2
    fp2add(t0, t3, t4);             // t4 = 4*X^2 - (X+Z)^2 + (X-Z)^2
    fp2add(t4, t4, t4);             // t4 = 2(4*X^2 - (X+Z)^2 + (X-Z)^2)
    fp2add(t1, t4, t4);             // t4 = 8*X^2 - (X+Z)^2 + 2*(X-Z)^2
    fp2add(t1, t2, t5);             // t4 = 4*X^2 + (X+Z)^2 - (X-Z)^2
    fp2add(t5, t5, t5);             // t4 = 2(4*X^2 + (X+Z)^2 - (X-Z)^2)
    fp2add(t0, t5, t5);             // t4 = 8*X^2 + 2*(X+Z)^2 - (X-Z)^2
    fp2_mul_ifma_x2(A24minus, t2, t4, t5, t5, t3);
    // fp2mul_mont(t2, t4, A24minus);  // A24minus = [4*X^2 - (X-Z)^2]*[8*X^2 - (X+Z)^2 + 2*(X-Z)^2]
    // fp2mul_mont(t3, t5, t5);        // t4 = [4*X^2 - (X+Z)^2]*[8*X^2 + 2*(X+Z)^2 - (X-Z)^2]
    fp2sub(t5, A24minus, t0);      // t0 = [4*X^2 - (X+Z)^2]*[8*X^2 + 2*(X+Z)^2 - (X-Z)^2] - [4*X^2 - (X-Z)^2]*[8*X^2 - (X+Z)^2 + 2*(X-Z)^2]
    fp2add(A24minus, t0, A24plus); // A24plus = 8*X^2 - (X+Z)^2 + 2*(X-Z)^2
}

static void eval_3_isog_ifma(point_proj_t Q, const f2elm_t *coeff)
{ // Computes the 3-isogeny R=phi(X:Z), given projective point (X3:Z3) of order 3 on a Montgomery curve and
    // a point P with 2 coefficients in coeff (computed in the function get_3_isog()).
    // Inputs: projective points P = (X3:Z3) and Q = (X:Z).
    // Output: the projective point Q <- phi(Q) = (X3:Z3).
    f2elm_t t0, t1, t2;

    fp2add(Q->X, Q->Z, t0); // t0 = X+Z
    fp2sub(Q->X, Q->Z, t1); // t1 = X-Z
    fp2_mul_ifma_x2(t0, t0, coeff[0], t1, t1, coeff[1]);
    //fp2mul_mont(t0, coeff[0], t0); // t0 = coeff0*(X+Z)
    //fp2mul_mont(t1, coeff[1], t1); // t1 = coeff1*(X-Z)
    fp2add(t0, t1, t2); // t2 = coeff0*(X-Z) + coeff1*(X+Z)
    fp2sub(t1, t0, t0); // t0 = coeff0*(X-Z) - coeff1*(X+Z)
    fp2_mul_ifma_x2(t2, t2, t2, t0, t0, t0);
    //fp2sqr_mont(t2, t2);         // t2 = [coeff0*(X-Z) + coeff1*(X+Z)]^2
    //fp2sqr_mont(t0, t0);         // t1 = [coeff0*(X-Z) - coeff1*(X+Z)]^2
    fp2_mul_ifma_x2(Q->X, Q->X, t2, Q->Z, Q->Z, t0);
    //fp2mul_mont(Q->X, t2, Q->X); // X3final = X*[coeff0*(X-Z) + coeff1*(X+Z)]^2
    //fp2mul_mont(Q->Z, t0, Q->Z); // Z3final = Z*[coeff0*(X-Z) - coeff1*(X+Z)]^2
}

static void fp2_encode(const f2elm_t x, unsigned char *enc)
{ // Conversion of GF(p^2) element from Montgomery to standard representation, and encoding by removing leading 0 bytes
    unsigned int i;
    f2elm_t tt;
    uint64_t t[12 * 2];

    from_mont_ifma(tt[0], x[0]);
    from_mont_ifma(tt[1], x[1]);

    red2norm(t, tt[0]);
    red2norm(&t[12], tt[1]);

    for (i = 0; i < FP2_ENCODED_BYTES / 2; i++)
    {
        enc[i] = ((unsigned char *)t)[i];
        enc[i + FP2_ENCODED_BYTES / 2] = ((unsigned char *)t)[i + MAXBITS_FIELD / 8];
    }
}

static void fp2_decode(const unsigned char *enc, f2elm_t x)
{
    unsigned int i;
    uint64_t t[12 * 2];

    memset(x, 0, sizeof(f2elm_t));
    for (i = 0; i < FP2_ENCODED_BYTES / 2; i++)
    {
        ((unsigned char *)t)[i] = enc[i];
        ((unsigned char *)t)[i + MAXBITS_FIELD / 8] = enc[i + FP2_ENCODED_BYTES / 2];
    }

    norm2red(x[0], t);
    norm2red(x[1], &t[12]);
    to_mont_ifma(x[0], x[0]);
    to_mont_ifma(x[1], x[1]);
}

int EphemeralKeyGeneration_A_ifma(const unsigned char *PrivateKeyA, unsigned char *PublicKeyA)
{ // Alice's ephemeral public key generation
    // Input:  a private key PrivateKeyA in the range [0, 2^eA - 1].
    // Output: the public key PublicKeyA consisting of 3 elements in GF(p^2) which are encoded by removing leading 0 bytes.
    point_proj_t R, phiP = {0}, phiQ = {0}, phiR = {0}, pts[MAX_INT_POINTS_ALICE];
    f2elm_t XPA, XQA, XRA, coeff[3];
    unsigned int i, row, m, index = 0, pts_index[MAX_INT_POINTS_ALICE], npts = 0, ii = 0;

    f2elm_t C24 = {
        {0x000000004935acf8, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0003f30018a85800, 0x000664c911fc7654, 0x000cc2ec46db6eef, 0x000badd2e0465707, 0x000a9aec44eeae7f, 0x000a99a2d802be6b, 0x0003f8e487189f8e, 0x000000000037f1ed},
        {0}};

    f2elm_t A24plus = {
        {0x00000000249ad67c, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0001f9800c542c00, 0x000b326488fe3b2a, 0x000e6176236db777, 0x000dd6e970232b83, 0x000d4d762277573f, 0x00054cd16c015f35, 0x0009fc72438c4fc7, 0x00000000001bf8f6},
        {0}};

    // Initialize basis points
    init_basis(A_gen_ifma, XPA, XQA, XRA);
    init_basis(B_gen_ifma, phiP->X, phiQ->X, phiR->X);
    memcpy(phiP->Z, One, sizeof(felm_t));
    memcpy(phiQ->Z, One, sizeof(felm_t));
    memcpy(phiR->Z, One, sizeof(felm_t));

    // Retrieve kernel point
    LADDER3PT_ifma(XPA, XQA, XRA, (uint64_t *)PrivateKeyA, ALICE, R);

    // Traverse tree
    index = 0;
    for (row = 1; row < MAX_Alice; row++)
    {
        while (index < MAX_Alice - row)
        {
            memcpy(pts[npts]->X, R->X, sizeof(f2elm_t));
            memcpy(pts[npts]->Z, R->Z, sizeof(f2elm_t));
            pts_index[npts++] = index;
            m = strat_Alice[ii++];
            xDBLe_ifma(R, R, A24plus, C24, (int)(2 * m));
            index += m;
        }
        get_4_isog_ifma(R, A24plus, C24, coeff);

        for (i = 0; i < npts; i++)
        {
            eval_4_isog_ifma(pts[i], coeff);
        }
        eval_4_isog_ifma(phiP, coeff);
        eval_4_isog_ifma(phiQ, coeff);
        eval_4_isog_ifma(phiR, coeff);

        memcpy(R->X, pts[npts - 1]->X, sizeof(f2elm_t));
        memcpy(R->Z, pts[npts - 1]->Z, sizeof(f2elm_t));
        index = pts_index[npts - 1];
        npts -= 1;
    }

    get_4_isog_ifma(R, A24plus, C24, coeff);
    eval_4_isog_ifma(phiP, coeff);
    eval_4_isog_ifma(phiQ, coeff);
    eval_4_isog_ifma(phiR, coeff);

    inv_3_way_ifma(phiP->Z, phiQ->Z, phiR->Z);
    fp2_mul_ifma_x2(phiP->X, phiP->X, phiP->Z, phiQ->X, phiQ->X, phiQ->Z);
    //fp2mul_mont(phiP->X, phiP->Z, phiP->X);
    //fp2mul_mont(phiQ->X, phiQ->Z, phiQ->X);
    fp2mul_mont(phiR->X, phiR->Z, phiR->X);

    // Format public key
    fp2_encode(phiP->X, PublicKeyA);
    fp2_encode(phiQ->X, PublicKeyA + FP2_ENCODED_BYTES);
    fp2_encode(phiR->X, PublicKeyA + 2 * FP2_ENCODED_BYTES);

    return 0;
}

int EphemeralKeyGeneration_B_ifma(const unsigned char *PrivateKeyB, unsigned char *PublicKeyB)
{ // Bob's ephemeral public key generation
    // Input:  a private key PrivateKeyB in the range [0, 2^Floor(Log(2,oB)) - 1].
    // Output: the public key PublicKeyB consisting of 3 elements in GF(p^2) which are encoded by removing leading 0 bytes.
    point_proj_t R, phiP = {0}, phiQ = {0}, phiR = {0}, pts[MAX_INT_POINTS_BOB];
    f2elm_t XPB, XQB, XRB, coeff[3], A = {0};
    unsigned int i, row, m, index = 0, pts_index[MAX_INT_POINTS_BOB], npts = 0, ii = 0;

    f2elm_t A24plus = {{0x000000004935acf8, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0003f30018a85800, 0x000664c911fc7654, 0x000cc2ec46db6eef, 0x000badd2e0465707, 0x000a9aec44eeae7f, 0x000a99a2d802be6b, 0x0003f8e487189f8e, 0x000000000037f1ed},
                       {0}};

    f2elm_t A24minus = {{0x000fffffb6ca5307, 0x000fffffffffffff, 0x000fffffffffffff, 0x000fffffffffffff, 0x000fffffffffffff, 0x000fffffffffffff, 0x000fffffffffffff, 0x0000ac8771e692ff, 0x000167add1f02031, 0x000aaabd12d63250, 0x000ca0c5879094e0, 0x0000b5598636c600, 0x0004fe180463c6f7, 0x0000268d39c8897b, 0x000000000037f3e8},
                        {0}};

    uint64_t temp[12];
    uint64_t ifma_temp[15];
    // Initialize basis points
    init_basis(B_gen_ifma, XPB, XQB, XRB);
    init_basis(A_gen_ifma, phiP->X, phiQ->X, phiR->X);
    memcpy(phiP->Z, One, sizeof(felm_t));
    memcpy(phiQ->Z, One, sizeof(felm_t));
    memcpy(phiR->Z, One, sizeof(felm_t));

    // Retrieve kernel point
    LADDER3PT_ifma(XPB, XQB, XRB, (uint64_t *)PrivateKeyB, BOB, R);

    // Traverse tree
    index = 0;
    for (row = 1; row < MAX_Bob; row++)
    {
        while (index < MAX_Bob - row)
        {
            memcpy(pts[npts]->X, R->X, sizeof(f2elm_t));
            memcpy(pts[npts]->Z, R->Z, sizeof(f2elm_t));
            pts_index[npts++] = index;
            m = strat_Bob[ii++];
            xTPLe_ifma(R, R, A24minus, A24plus, (int)m);
            index += m;
        }
        get_3_isog_ifma(R, A24minus, A24plus, coeff);

        for (i = 0; i < npts; i++)
        {
            eval_3_isog_ifma(pts[i], coeff);
        }
        eval_3_isog_ifma(phiP, coeff);
        eval_3_isog_ifma(phiQ, coeff);
        eval_3_isog_ifma(phiR, coeff);

        memcpy(R->X, pts[npts - 1]->X, sizeof(f2elm_t));
        memcpy(R->Z, pts[npts - 1]->Z, sizeof(f2elm_t));

        index = pts_index[npts - 1];
        npts -= 1;
    }

    get_3_isog_ifma(R, A24minus, A24plus, coeff);
    eval_3_isog_ifma(phiP, coeff);
    eval_3_isog_ifma(phiQ, coeff);
    eval_3_isog_ifma(phiR, coeff);

    inv_3_way_ifma(phiP->Z, phiQ->Z, phiR->Z);
    fp2mul_mont(phiP->X, phiP->Z, phiP->X);
    fp2mul_mont(phiQ->X, phiQ->Z, phiQ->X);
    fp2mul_mont(phiR->X, phiR->Z, phiR->X);

    // Format public key
    fp2_encode(phiP->X, PublicKeyB);
    fp2_encode(phiQ->X, PublicKeyB + FP2_ENCODED_BYTES);
    fp2_encode(phiR->X, PublicKeyB + 2 * FP2_ENCODED_BYTES);

    return 0;
}
