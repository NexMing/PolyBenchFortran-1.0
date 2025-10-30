cmake_minimum_required(VERSION 3.8)

project(PolyBenchFortran)

enable_language(Fortran)

if(CMAKE_Fortran_COMPILER_ID STREQUAL "GNU")
    message(STATUS "Using GNU Fortran")
    add_compile_options(-ffree-line-length-none)
elseif(CMAKE_Fortran_COMPILER_ID STREQUAL "LLVMFlang")
    message(STATUS "Using LLVMFlang Fortran")
else()
    message(WARNING "Unknown Fortran compiler: ${CMAKE_Fortran_COMPILER_ID}")
endif()

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
include_directories(utilities)
add_library(fpolybench utilities/fpolybench.c)
link_libraries(fpolybench)

add_compile_definitions(
    POLYBENCH_TIME
    POLYBENCH_CYCLE_ACCURATE_TIMER
    POLYBENCH_DUMP_ARRAYS
)

file(READ utilities/benchmark_list FILE_CONTENT)
string(REGEX REPLACE "\r?\n" ";" TESTCASES "${FILE_CONTENT}")

foreach(TESTCASE ${TESTCASES})
    get_filename_component(TEST_DIR ${TESTCASE} DIRECTORY)
    get_filename_component(TESTNAME ${TESTCASE} NAME_WE)
    add_executable(${TESTNAME} ${TESTCASE} ${TEST_DIR}/kernel.F90)
endforeach()
