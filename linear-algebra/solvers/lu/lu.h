/**
 * lu.h: This file is part of the PolyBench/Fortran 1.0 test suite.
 *
 * Contact: Louis-Noel Pouchet <pouchet@cse.ohio-state.edu>
 * Web address: http://polybench.sourceforge.net
 */
#ifndef LU_H
# define LU_H

/* Default to STANDARD_DATASET. */
# if !defined(MINI_DATASET) && !defined(SMALL_DATASET) && !defined(LARGE_DATASET) && !defined(EXTRALARGE_DATASET)
#  define STANDARD_DATASET
# endif

/* Do not define anything if the user manually defines the size. */
# ifndef N
/* Define the possible dataset sizes. */
#  ifdef MINI_DATASET
#   define N 32
#  endif

#  ifdef SMALL_DATASET
#   define N 128
#  endif

#  ifdef STANDARD_DATASET /* Default if unspecified. */
#   define N 1024
#  endif

#  ifdef LARGE_DATASET
#   define N 2000
#  endif

#  ifdef EXTRALARGE_DATASET
#   define N 4000
#  endif
# endif /* !N */

# define _PB_N POLYBENCH_LOOP_BOUND(N,n)

/* Default data type */
# if !defined(DATA_TYPE_IS_FLOAT) && !defined(DATA_TYPE_IS_DOUBLE)
#  define DATA_TYPE_IS_DOUBLE
# endif

# ifdef DATA_TYPE_IS_FLOAT
#  define DATA_TYPE real(kind=4)
#  define DATA_PRINTF_MODIFIER "(f0.2,1x)", advance='no'
# endif

# ifdef DATA_TYPE_IS_DOUBLE
#  define DATA_TYPE real(kind=8)
#  define DATA_PRINTF_MODIFIER "(f0.2,1x)", advance='no'
# endif


#endif /* !LU */
