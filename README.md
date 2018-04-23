# WORK IN PROGRESS, FOR INFORMATIONAL PURPOSES ONLY

## PQ SIDH/SIKE implementation using AVX512IFMA instructions

Using the AVX512IFMA (vpmadd52luq and vpmadd52huq) specifically designed for
prime field arithmetic allows a projected speedup of up to 4X on supporting
processors, when those become available.

### Current status

* Tested for correctness with Intel SDE
* EphemeralKeyGeneration_A and EphemeralKeyGeneration_B with P751 are implemented
* Using "standins": 3X performance gain on Xeon Gold (with two FMA units)
* Optimizations are 3-fold
    * Finite field *𝔽~p~* multiplication by performing a single horizontal Montgomery multiplication
    * Quadratic finite field *𝔽~p²~* multiplication and square by performing 3/4 horizontal Montgomery multiplications in parallel
    * A pair of quadratic finite field *𝔽~p²~* multiplications (where applicable) by performing 8 vertical Montgomery multiplications in parallel
    * AVX512 add/sub are also implemented

### How to test?

The Makefile generates to executables: sidh_ifma can be run with Intel SDE to
check for correctness. sidh_standin produces incorrect results, because it
replaces the IFMA instrutions with FMA instructions and can be executed on a
machine with AVX512 support to estimate performance.

### TODO

* EphemeralSecretAgreement_A and EphemeralSecretAgreement_B
* SIKE
* P503
* Using vertical representation throughout for greater speedups

### License

Available under the original [SIKE](https://github.com/Microsoft/PQCrypto-SIKE) license 
