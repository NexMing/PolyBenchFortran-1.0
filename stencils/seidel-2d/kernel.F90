!******************************************************************************
!
!  seidel-2d.F90: This file is part of the PolyBench/Fortran 1.0 test suite.
! 
!  Contact: Louis-Noel Pouchet <pouchet@cse.ohio-state.edu>
!  Web address: http://polybench.sourceforge.net
!
!******************************************************************************

! Include polybench common header. 
#include <fpolybench.h>

! Include benchmark-specific header. 
! Default data type is double, default size is 20x1000. 
#include "seidel-2d.h"

        subroutine kernel_seidel(tsteps, n, a)
        implicit none

        DATA_TYPE, dimension(n, n) :: a
        integer :: n, tsteps
        integer :: i, t, j

!$pragma scop
        do t = 1, _PB_TSTEPS
          do i = 2, _PB_N - 1
            do j = 2, _PB_N - 1
            a(j, i) = (a(j - 1, i - 1) + a(j, i - 1) + a(j + 1, i - 1) + &
                       a(j - 1, i) + a(j, i) + a(j + 1, i) + &
                       a(j - 1, i + 1) + a(j, i + 1) + &
                       a(j + 1, i + 1))/SCALAR_VAL(9.0)
            end do
          end do
        end do
!$pragma endscop
        end subroutine
