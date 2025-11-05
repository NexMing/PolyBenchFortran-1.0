#! /bin/sh

if test $# -ne 2; then
    echo "Usage:\n	$0 POLYBENCH_ROOT FILEPREFIX\ne.g." >&2
    echo "	$0 ~/playground/PolyBenchFortran-1.0 ./adi" >&2
    echo "	RISCV=true $0 ~/playground/PolyBenchFortran-1.0 ./adi" >&2
    echo "	CLEAN=true $0 ~/playground/PolyBenchFortran-1.0 ./adi" >&2
    exit 1
fi

set -e

################################################################################
# Utilities
################################################################################
run() { echo "$ \033[4m$*\033[0m\n"; $*; }
echoG() { echo "\033[32m$*\033[0m"; }
echoB() { echo "\033[34m$*\033[0m"; }

fix_captures() { sed -i 's/captures([^)]*)//g' $1; }

################################################################################
# Variables
################################################################################
POLYBENCH_ROOT=$(realpath $1)
FSRC=$2.F90
#FSRC_1=$2-1.F90
#FSRC_2=$2-2.F90
FSRC_1=$2.F90
FSRC_2=kernel.F90

OPT_LEVEL=3

COMMON_FLAGS="-O${OPT_LEVEL} -I${POLYBENCH_ROOT}/utilities/ -DPOLYBENCH_TIME -DPOLYBENCH_CYCLE_ACCURATE_TIMER -DPOLYBENCH_DUMP_ARRAYS"

common_init() {
    CLANG_1=~/playground/llvm-project/build/bin/clang
    FLANG_1=~/playground/llvm-project/build/bin/flang
    FIR_OPT_1=~/playground/llvm-project/build/bin/fir-opt
    MLIR_OPT_1=~/playground/llvm-project/build/bin/mlir-opt
    MLIR_TRANSLATE_1=~/playground/llvm-project/build/bin/mlir-translate
    LD_1=~/playground/llvm-project/build/bin/flang
}

riscv_init() {
    NORMAL_FLAGS="--target=riscv64-unknown-linux-gnu"
    FC1_FLAGS="-triple riscv64-unknown-linux-gnu"
    CFLAGS="$COMMON_FLAGS -march=rv64gcv -fPIC"
    FFLAGS="$COMMON_FLAGS"
    LDFLAGS="-march=rv64gcv -O${OPT_LEVEL} -static"

    CLANG_2=~/Terapines/ZCC/4.1.6/bin/zcc
    FLANG_2=~/Terapines/ZCC/4.1.6/bin/zfc
    LD_2=~/Terapines/ZCC/4.1.6/bin/zfc
}

x64_init() {
    NORMAL_FLAGS=""
    FC1_FLAGS=""
    CFLAGS="$COMMON_FLAGS -fPIC"
    FFLAGS="$COMMON_FLAGS"
    LDFLAGS="-O${OPT_LEVEL}"

    CLANG_2=~/playground/llvm-project/build/bin/clang
    FLANG_2=~/playground/llvm-project/build/bin/flang
    LD_2=~/playground/llvm-project/build/bin/flang
}

# Spliting source code into 2 parts
# (`sed` do not support non-greedy match, so we use `perl` instead.)
split_source() {
    perl -0777 -pe 's/subroutine kernel_.*?end subroutine//s' $1 > $2
    grep '#include.*' $1 > $3
    perl -0777 -ne 'print $1 if /(subroutine kernel_.*?end subroutine)/s' $1 >> $3
}

common_init

if test "$RISCV" = true; then
    riscv_init
else
    x64_init
fi

DEPFILE=${POLYBENCH_ROOT}/utilities/fpolybench

################################################################################
# Build dependencies
################################################################################
echoG "Generating $DEPFILE.o ..."
run $CLANG_2 $CFLAGS $NORMAL_FLAGS -c $DEPFILE.c -o $DEPFILE.o

################################################################################
################################################################################
#echoB "Spliting the source files ..."
#split_source $FSRC $FSRC_1 $FSRC_2

################################################################################
# Build un-optimized version
################################################################################
echoG "Generating unoptimized $FSRC.unopt.elf ..."

echoB "Generating $FSRC_1.ll and $FSRC_2.ll ..."
run $FLANG_2 -S -emit-llvm $NORMAL_FLAGS $FFLAGS $FSRC_1 -o $FSRC_1.ll
run $FLANG_2 -S -emit-llvm $NORMAL_FLAGS $FFLAGS $FSRC_2 -o $FSRC_2.ll

fix_captures $FSRC_1.ll
fix_captures $FSRC_2.ll

echoB "Generating $FSRC_1.o and $FSRC_2.o ..."
run $FLANG_2 -O${OPT_LEVEL} -c $FSRC_1.ll -o $FSRC_1.o
run $FLANG_2 -O${OPT_LEVEL} -c $FSRC_2.ll -o $FSRC_2.o

echoB "Linking $FSRC.unopt.elf ..."
run $LD_2 $LDFLAGS $DEPFILE.o $FSRC_1.o $FSRC_2.o -o $FSRC.unopt.elf

################################################################################
# Build optimized version
################################################################################

echoG "Generating optimized $FSRC.opt.elf ..."

echoB "Generating $FSRC_2.fir ..."
run $FLANG_1 -fc1 $FC1_FLAGS -DPOLYBENCH_USE_SCALAR_LB -emit-fir $FFLAGS \
    $FSRC_2 -o $FSRC_2.fir

echoB "Generating $FSRC_2.opt1.mlir ..."
run $FIR_OPT_1 --cg-rewrite --external-name-interop --fir-to-scf --fir-to-mlir --fold-memref-alias-ops \
    --convert-scf-to-cf  --cse --canonicalize --mem2reg \
    $FSRC_2.fir -o $FSRC_2.opt1.mlir

echoB "Generating $FSRC_2.opt2.mlir ..."
run $MLIR_OPT_1 --lift-cf-to-scf --cse --canonicalize --fold-memref-alias-ops \
    --test-scf-uplift-while-to-for --cse --canonicalize \
    $FSRC_2.opt1.mlir -o $FSRC_2.opt2.mlir

echoB "Generating $FSRC_2.opt3.mlir ..."
run $MLIR_OPT_1 --raise-scf-to-affine --affine-loop-invariant-code-motion --affine-raise-from-memref \
    --cse --canonicalize \
    $FSRC_2.opt2.mlir -o $FSRC_2.opt3.mlir

echoB "Generating $FSRC_2.opt4.mlir ..."
run $MLIR_OPT_1 --affine-loop-invariant-code-motion --affine-parallelize --cse --canonicalize \
    $FSRC_2.opt3.mlir -o $FSRC_2.opt4.mlir

echoB "Generating $FSRC_2.opt5.mlir ..."
run $MLIR_OPT_1 --lower-affine --convert-scf-to-cf='enable-vectorize-hints=true' \
    --finalize-memref-to-llvm --convert-func-to-llvm='use-bare-ptr-memref-call-conv=true' \
    --convert-to-llvm --reconcile-unrealized-casts \
    $FSRC_2.opt4.mlir -o $FSRC_2.opt5.mlir

echoB "Generating $FSRC_2.opt.ll ..."
run $MLIR_TRANSLATE_1 --mlir-to-llvmir \
    $FSRC_2.opt5.mlir -o $FSRC_2.opt.ll

echoB "Fixing captures(...) in ll file ..."
fix_captures $FSRC_2.opt.ll

echoB "Generating $FSRC_2.opt.o ..."
run $FLANG_2 -O${OPT_LEVEL} -c $FSRC_2.opt.ll -o $FSRC_2.opt.o

echoB "Generating $FSRC_2.opt.elf ..."
run $LD_2 $LDFLAGS $DEPFILE.o $FSRC_1.o $FSRC_2.opt.o -o $FSRC.opt.elf

################################################################################
# Run benchmarks
################################################################################
#echoG "Running benchmarks..."
#${POLYBENCH_ROOT}/utilities/time_benchmark.sh ./$FSRC.unopt.elf > bench-1.txt
#${POLYBENCH_ROOT}/utilities/time_benchmark.sh ./$FSRC.opt.elf > bench-2.txt

################################################################################
# Clean
################################################################################
if test "$CLEAN" = true; then
    #run rm $FSRC_1 $FSRC_2 *.o *.fir *.mlir *.ll $DEPFILE.o
    run rm *.o *.fir *.mlir *.ll $DEPFILE.o
fi
