CC?=clang

TARGET_OS=$(shell uname -s)

ifeq ($(TARGET_OS),Darwin)
	CFLAGS= -std=c99 -O3 -g -D_AMD64_ -D__LINUX__ -mavx512f -mavx512bw -mavx512dq -mavx512ifma 
else
	ifeq ($(CC),clang)
		CFLAGS= -std=c99 -O3 -g -D_AMD64_ -D__LINUX__ -mavx512f -mavx512bw -mavx512dq -mavx512ifma 
	else
		CFLAGS= -std=c99 -O3 -g -D_AMD64_ -D__LINUX__ -mavx512f
	endif
endif

CFLAGS+=-D_MULX_ -D_ADX_

SRC_REAL=fp2_751_ifma.S fp_751_ifma.S fp2_packed_751_ifma.S
SRC_STANDIN=$(SRC_REAL:.S=_standin.S)
SOURCES=./sidh_ref/fp_x64_asm.S ./sidh_ref/fp_x64.c ./sidh_ref/P751.c ./sidh_ref/random/random.c ./sidh_ref/sha3/fips202.c P751_ifma.c
OBJECTS=$(SOURCES:.c=.o)
EXE_REAL=sidh_ifma
EXE_STANDIN=sidh_standin

all: $(SOURCES) $(SRC_STANDIN) $(SRC_REAL) $(EXE_REAL) $(EXE_STANDIN)

$(SRC_STANDIN): %_standin.S: %.S
	cat $<  | sed 's/vpmadd52luq/VFMADD231PD/; s/vpmadd52huq/VFMADD231PD/;' > $@

$(EXE_REAL): main.c ./sidh_ref/sidh.c $(OBJECTS) $(SRC_REAL)
	$(CC) main.c $(OBJECTS) $(SRC_REAL) $(CFLAGS) -o $@ -DREPEAT=1 -DOUTER_REPEAT=1

$(EXE_STANDIN): main.c ./sidh_ref/sidh.c $(OBJECTS) $(SRC_STANDIN)
	$(CC) main.c $(OBJECTS) $(SRC_STANDIN) $(CFLAGS) -o $@ -DREPEAT=20 -DOUTER_REPEAT=20

.o: ./sidh_ref/sidh.c
	$(CC) $(CFLAGS) $< -o $@

clean:
	rm -f *.o ./sidh_ref/*.o $(EXE_REAL) $(EXE_STANDIN) $(SRC_STANDIN)
