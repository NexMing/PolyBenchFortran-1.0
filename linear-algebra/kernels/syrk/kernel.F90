!******************************************************************************
!
!  syrk.F90: This file is part of the PolyBench/Fortran 1.0 test suite.
! 
!  Contact: Louis-Noel Pouchet <pouchet@cse.ohio-state.edu>
!  Web address: http://polybench.sourceforge.net
!
!******************************************************************************

! Include polybench common header. 
#include <fpolybench.h>

! Include benchmark-specific header. 
! Default data type is double, default size is 4000. 
#include "syrk.h"

        subroutine kernel_syrk(ni, nj, alpha, beta, c, a)
        implicit none

        DATA_TYPE, dimension(ni, ni) :: a
        DATA_TYPE, dimension(nj, ni) :: c
        DATA_TYPE :: alpha , beta
        integer :: nj, ni
        integer :: i, j, k

!$pragma scop
        do i = 1, _PB_NI
          do j = 1, _PB_NI
            c(j, i) = c(j, i) * beta
          end do
        end do
        do i = 1, _PB_NI
          do j = 1, _PB_NI
            do k = 1, _PB_NJ
              c(j, i) = c(j, i) + (alpha * a(k, i) * a(k, j))
            end do
          end do
        end do
!$pragma endscop
        end subroutine
