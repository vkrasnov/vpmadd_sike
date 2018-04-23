
#ifndef MEASURE_H
#define MEASURE_H

#ifndef REPEAT
#define REPEAT 100
#endif

#ifndef OUTER_REPEAT
#define OUTER_REPEAT 10
#endif

#ifndef WARMUP
#define WARMUP REPEAT / 4
#endif

unsigned long long RDTSC_start_clk, RDTSC_end_clk;
double RDTSC_total_clk;
double RDTSC_TEMP_CLK;
int RDTSC_MEASURE_ITERATOR;
int RDTSC_OUTER_ITERATOR;

inline static unsigned long get_Clks(void)
{
      unsigned hi, lo;
      __asm__ __volatile__("rdtscp\n\t"
                           : "=a"(lo), "=d"(hi)::"rcx");
      return ((unsigned long)lo) ^ (((unsigned long)hi) << 32);
}

#define RDTSC_MEASURE(x)                                                                                \
      for (RDTSC_MEASURE_ITERATOR = 0; RDTSC_MEASURE_ITERATOR < WARMUP; RDTSC_MEASURE_ITERATOR++)       \
      {                                                                                                 \
            {x};                                                                                        \
      }                                                                                                 \
      RDTSC_total_clk = 1.7976931348623157e+308;                                                        \
      for (RDTSC_OUTER_ITERATOR = 0; RDTSC_OUTER_ITERATOR < OUTER_REPEAT; RDTSC_OUTER_ITERATOR++)       \
      {                                                                                                 \
            RDTSC_start_clk = get_Clks();                                                               \
            for (RDTSC_MEASURE_ITERATOR = 0; RDTSC_MEASURE_ITERATOR < REPEAT; RDTSC_MEASURE_ITERATOR++) \
            {                                                                                           \
                  {x};                                                                                  \
            }                                                                                           \
            RDTSC_end_clk = get_Clks();                                                                 \
            RDTSC_TEMP_CLK = (double)(RDTSC_end_clk - RDTSC_start_clk) / REPEAT;                        \
            if (RDTSC_total_clk > RDTSC_TEMP_CLK)                                                       \
                  RDTSC_total_clk = RDTSC_TEMP_CLK;                                                     \
      }

#define MEASURE(x) RDTSC_MEASURE(x)

#endif
