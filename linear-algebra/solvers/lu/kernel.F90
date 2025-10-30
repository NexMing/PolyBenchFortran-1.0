!******************************************************************************
!
!  lu.F90: This file is part of the PolyBench/Fortran 1.0 test suite.
! 
!  Contact: Louis-Noel Pouchet <pouchet@cse.ohio-state.edu>
!  Web address: http://polybench.sourceforge.net
!
!******************************************************************************

! Include polybench common header. 
#include <fpolybench.h>

! Include benchmark-specific header. 
! Default data type is double, default size is 1024. 
#include "lu.h"

        subroutine kernel_lu(n, a)
        implicit none

        DATA_TYPE, dimension(n, n) :: a
        integer :: n
        integer :: i, j, k

!$pragma scop
        do k = 1, _PB_N
          do j = k + 1, _PB_N
            a(j, k) = a(j, k) / a(k, k)
          end do
          do i = k + 1, _PB_N
            do j = k + 1, _PB_N
              a(j, i) = a(j, i) - (a(k, i) * a(j, k))
            end do
          end do
        end do
!$pragma endscop
        end subroutine
