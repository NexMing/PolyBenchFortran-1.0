#! /bin/sh

## Behaviours are controlled by environment variables.

if test $# -ne 1; then
    echo "Usage:\n	$0 POLYBENCH_ROOT FILEPREFIX\ne.g." >&2
    echo "	$0 ~/PolyBenchFortran-1.0" >&2
    echo "	RISCV=true $0 ~/PolyBenchFortran-1.0" >&2
    echo "	CLEAN=true $0 ~/PolyBenchFortran-1.0" >&2
    exit 1
fi

set -e

DIRNAME=$(realpath $(dirname $0))
POLYBENCH_ROOT=$(realpath "$1")

while read l; do
    cd $POLYBENCH_ROOT/$(dirname $l)
    $DIRNAME/opt-build-one.sh "$POLYBENCH_ROOT" $(basename $l .F90)
    echo "\n\n\n"
done < $POLYBENCH_ROOT/utilities/benchmark_list
