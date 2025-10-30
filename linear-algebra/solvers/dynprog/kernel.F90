!******************************************************************************
!
!  dynprog.F90: This file is part of the PolyBench/Fortran 1.0 test suite.
! 
!  Contact: Louis-Noel Pouchet <pouchet@cse.ohio-state.edu>
!  Web address: http://polybench.sourceforge.net
!
!******************************************************************************

! Include polybench common header. 
#include <fpolybench.h>

! Include benchmark-specific header. 
! Default data type is double, default size is 50. 
#include "dynprog.h"

        subroutine kernel_dynprog(tsteps , length, c, w, sumC, output)
        implicit none

        DATA_TYPE, dimension(length, length) :: w, c
        DATA_TYPE, dimension(length, length, length) :: sumC
        integer :: i, j, iter, k
        integer :: length, tsteps
        DATA_TYPE :: output

!$pragma scop
        output = 0

        do iter = 1, _PB_TSTEPS
          do i = 1, _PB_LENGTH
            do j = 1, _PB_LENGTH
              c(j, i) = 0
            end do
          end do

          do i = 1, _PB_LENGTH - 1
            do j = i + 1, _PB_LENGTH 
              sumC(i, j, i) = 0
              do k = i + 1, j - 1
                sumC(k, j, i) = sumC(k - 1, j, i) + c(k, i) + c(j, k)
              end do
              c(j, i) = sumC(j - 1, j, i) + w(j, i)
            end do
          end do
          output = output + c(_PB_LENGTH, 1)
        end do
!$pragma endscop
        end subroutine
