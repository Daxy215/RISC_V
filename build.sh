#!/bin/bash

set -euo pipefail

SRC_DIR="src"
BUILD_DIR="build"

mkdir -p "$BUILD_DIR"

# Compile packages first (order matters)
RTL_FILES=(
    "$SRC_DIR/opcodes.sv"
    "$SRC_DIR/instruction_fields_t.sv"
    "$SRC_DIR/alu_arithmetic_types.sv"
    "$SRC_DIR/control_unit_write_source.sv"
)

# Automatically discover RTL modules
for file in "$SRC_DIR"/*.sv; do
    case "$(basename "$file")" in
        opcodes.sv|instruction_fields_t.sv|alu_arithmetic_types.sv|control_unit_write_source.sv|*_tb.sv)
            continue
            ;;
    esac

    RTL_FILES+=("$file")
done

# Build and run an individual testbench
run_test() {
    local name="$1"
    local tb_file="$SRC_DIR/${name}_tb.sv"
    local output="$BUILD_DIR/${name}_tb"

    if [[ ! -f "$tb_file" ]]; then
        echo "Error: Testbench not found: $tb_file"
        exit 1
    fi

    echo "================================"
    echo "Testing: $name"
    echo "================================"

    verilator --binary --timing --assert -Wno-fatal \
      --top-module "${name}_tb" \
      --Mdir "$BUILD_DIR/${name}_obj" \
      -o "${name}_tb" \
      "${RTL_FILES[@]}" \
      "$tb_file"

    "$BUILD_DIR/${name}_obj/${name}_tb"

    echo "Finished: $name"
    echo
}

# Automatically run all testbenches
run_all_tests() {
    local found=false

    for file in "$SRC_DIR"/*_tb.sv; do
        [[ -f "$file" ]] || continue

        found=true

        local name
        name=$(basename "$file" _tb.sv)

        run_test "$name"
    done

    if [[ "$found" == false ]]; then
        echo "No testbenches found."
        exit 1
    fi
}

# Main
case "${1:-}" in -tb)
        if [[ "${2:-all}" == "all" ]]; then
            run_all_tests
        else
            run_test "$2"
        fi
        ;;

    "")
        run_test soc
        ;;

    *)
        echo "Usage:"
        echo "  $0                       Run SoC simulation"
        echo "  $0 -tb <name>            Run specific test"
        echo "  $0 -tb all               Run all tests"
        exit 1
        ;;
esac
