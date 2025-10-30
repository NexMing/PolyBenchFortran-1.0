!******************************************************************************
!
!  reg_detect.F90: This file is part of the PolyBench/Fortran 1.0 test suite.
! 
!  Contact: Louis-Noel Pouchet <pouchet@cse.ohio-state.edu>
!  Web address: http://polybench.sourceforge.net
!
!******************************************************************************

! Include polybench common header. 
#include <fpolybench.h>

! Include benchmark-specific header. 
! Default data type is double, default size is 50. 
#include "reg_detect.h"

        subroutine kernel_reg_detect(niter, maxgrid, length, &
                              sumTang, mean, path, diff, sumDiff)
        implicit none

        integer :: maxgrid, niter, length
        DATA_TYPE, dimension (maxgrid, maxgrid) :: sumTang, mean, path
        DATA_TYPE, dimension (length, maxgrid, maxgrid) :: sumDiff, diff
        integer :: i, j, t, cnt

!$pragma scop
        do t = 1, _PB_NITER
          do j = 1, _PB_MAXGRID
            do i = j, _PB_MAXGRID
              do cnt = 1, _PB_LENGTH
                diff(cnt, i, j) = sumTang(i, j)
              end do
            end do
          end do

          do j = 1, _PB_MAXGRID
            do i = j, _PB_MAXGRID
              sumDiff(1, i, j) = diff(1, i, j)
              do cnt = 2, _PB_LENGTH
                sumDiff(cnt, i, j) = sumDiff(cnt - 1, i, j) + &
                                     diff(cnt, i, j)
              end do
              mean(i, j) = sumDiff(_PB_LENGTH, i, j)
            end do
          end do

          do i = 1, _PB_MAXGRID
            path(i, 1) = mean(i, 1)
          end do

          do j = 2, _PB_MAXGRID
            do i = j, _PB_MAXGRID
              path(i, j) = path(i - 1, j - 1) + mean(i, j)
            end do
          end do
        end do
!$pragma endscop
        end subroutine
