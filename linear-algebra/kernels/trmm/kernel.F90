!******************************************************************************
!
!  trmm.F90: This file is part of the PolyBench/Fortran 1.0 test suite.
! 
!  Contact: Louis-Noel Pouchet <pouchet@cse.ohio-state.edu>
!  Web address: http://polybench.sourceforge.net
!
!******************************************************************************

! Include polybench common header. 
#include <fpolybench.h>

! Include benchmark-specific header. 
! Default data type is double, default size is 4000. 
#include "trmm.h"


        subroutine kernel_trmm(ni, alpha, a, b)
        implicit none

        DATA_TYPE, dimension(ni, ni) :: a
        DATA_TYPE, dimension(ni, ni) :: b
        DATA_TYPE :: alpha
        integer :: ni
        integer :: i, j, k

!$pragma scop
        do i = 2, _PB_NI 
          do j = 1, _PB_NI 
            do k = 1, i - 1
              b(j, i) = b(j, i) + (alpha * a(k, i) * b(k, j))
            end do
          end do
        end do
!$pragma endscop
        end subroutine
