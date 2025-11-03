!******************************************************************************
!
!  jacobi-1d-imper.F90: This file is part of the PolyBench/Fortran 1.0 test suite.
! 
!  Contact: Louis-Noel Pouchet <pouchet@cse.ohio-state.edu>
!  Web address: http://polybench.sourceforge.net
!
!******************************************************************************

! Include polybench common header. 
#include <fpolybench.h>

! Include benchmark-specific header. 
! Default data type is double, default size is 100x10000. 
#include "jacobi-1d-imper.h"

        subroutine kernel_jacobi1d(tsteps, n, a, b)
        implicit none

        DATA_TYPE, dimension(n) :: a
        DATA_TYPE, dimension(n) :: b
        integer :: n, tsteps
        integer :: i, t, j
!$pragma scop
        do t = 1, _PB_TSTEPS
          do i = 2, _PB_N - 1
            b(i) = SCALAR_VAL(0.33333) * (a(i - 1) + a(i) + a(i + 1))
          end do

          do j = 2, _PB_N -1
            a(j) = b(j)
          end do
        end do
!$pragma endscop
        end subroutine
