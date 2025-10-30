!******************************************************************************
!
!  covariance.F90: This file is part of the PolyBench/Fortran 1.0 test suite.
! 
!  Contact: Louis-Noel Pouchet <pouchet@cse.ohio-state.edu>
!  Web address: http://polybench.sourceforge.net
!
!******************************************************************************

! Include polybench common header. 
#include <fpolybench.h>

! Include benchmark-specific header. 
! Default data type is double, default size is 4000. 
#include "covariance.h"

      program covariance
      implicit none
      external kernel_covariance

      DATA_TYPE :: FLOAT_N
      POLYBENCH_2D_ARRAY_DECL(dat,DATA_TYPE,N, M)
      POLYBENCH_2D_ARRAY_DECL(symmat,DATA_TYPE,M, M)
      POLYBENCH_1D_ARRAY_DECL(mean,DATA_TYPE,M)
      polybench_declare_prevent_dce_vars
      polybench_declare_instruments

!     Allocation of Arrays
      POLYBENCH_ALLOC_2D_ARRAY(dat, N, M)
      POLYBENCH_ALLOC_2D_ARRAY(symmat, M, M)
      POLYBENCH_ALLOC_1D_ARRAY(mean, M)

!     Initialization
      call init_array(M, N, FLOAT_N, dat)

!     Kernel Execution
      polybench_start_instruments

      call kernel_covariance(M, N, FLOAT_N, dat, symmat, mean)

      polybench_stop_instruments
      polybench_print_instruments

!     Prevent dead-code elimination. All live-out data must be printed
!     by the function call in argument. 
      polybench_prevent_dce(print_array(M, symmat ));

!     Deallocation of Arrays 
      POLYBENCH_DEALLOC_ARRAY(dat)
      POLYBENCH_DEALLOC_ARRAY(symmat)
      POLYBENCH_DEALLOC_ARRAY(mean)

      contains

        subroutine init_array(m, n, float_n, dat)
        implicit none

        DATA_TYPE, dimension(n, m) :: dat
        DATA_TYPE :: float_n
        integer :: m, n
        integer :: i, j

        float_n = 1.2D0
        do i = 1, m 
          do j = 1, n 
            dat(j, i) = (DBLE((i - 1) * (j - 1))) / DBLE(m)
          end do
        end do
        end subroutine


        subroutine print_array(m, symmat)
        implicit none

        DATA_TYPE, dimension(m, m) :: symmat
        integer :: m
        integer :: i, j
        do i = 1, m
          do j = 1, m
            write(0, DATA_PRINTF_MODIFIER) symmat(j, i)
            if (mod(((i - 1) * m) + j - 1, 20) == 0) then
              write(0, *)
            end if
          end do
        end do
        write(0, *)
        end subroutine



      end program
