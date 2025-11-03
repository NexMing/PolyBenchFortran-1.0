!******************************************************************************
!
!  jacobi-2d-imper.F90: This file is part of the PolyBench/Fortran 1.0 test suite.
! 
!  Contact: Louis-Noel Pouchet <pouchet@cse.ohio-state.edu>
!  Web address: http://polybench.sourceforge.net
!
!******************************************************************************

! Include polybench common header. 
#include <fpolybench.h>

! Include benchmark-specific header. 
! Default data type is double, default size is 20x1000. 
#include "jacobi-2d-imper.h"

        subroutine kernel_jacobi_2d_imper(tsteps, n, a, b)
        implicit none

        DATA_TYPE, dimension(n, n) :: a
        DATA_TYPE, dimension(n, n) :: b
        integer :: n, tsteps
        integer :: i, j, t

!$pragma scop
        do t = 1, _PB_TSTEPS
          do i = 2, _PB_N - 1
            do j = 2, _PB_N - 1
              b(j, i) = SCALAR_VAL(0.2) * (a(j, i) + a(j - 1, i) + a(1 + j, i) + &
                                           a(j, 1 + i) + a(j, i - 1))
            end do
          end do
          do i = 2, _PB_N - 1
            do j = 2, _PB_N - 1
              a(j, i) = b(j, i)
            end do
          end do
        end do
!$pragma endscop
        end subroutine
