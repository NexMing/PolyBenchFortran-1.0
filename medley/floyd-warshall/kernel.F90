!******************************************************************************
!
!  floyd-warshall.F90: This file is part of the PolyBench/Fortran 1.0 test suite.
! 
!  Contact: Louis-Noel Pouchet <pouchet@cse.ohio-state.edu>
!  Web address: http://polybench.sourceforge.net
!
!******************************************************************************

! Include polybench common header. 
#include <fpolybench.h>

! Include benchmark-specific header. 
! Default data type is double, default size is 1024. 
#include "floyd-warshall.h"

        subroutine kernel_floyd_warshall(n, path)
        implicit none

        DATA_TYPE, dimension(n,n) :: path
        integer :: n
        integer :: i, j, k

!$pragma scop
        do k=1, _PB_N
          do i=1, _PB_N
            do j=1, _PB_N
               if( path(j, i) .GE. path(k, i) + path(j, k) ) then
                 path(j, i) = path(k, i) + path(j, k)
               end if
            end do
          end do
        end do
!$pragma endscop
        end subroutine
