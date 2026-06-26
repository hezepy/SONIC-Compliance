# Like GNU `make`, but `just` rustier.
# https://just.systems/
# run `just` from this directory to see available commands

alias b := build
alias r := run
alias t := test
alias c := clean
alias ch := check

# Default command when 'just' is run without arguments
default:
  @just --list

# Get the number of cores
CORES := if os() == "macos" { `sysctl -n hw.ncpu` } else if os() == "linux" { `nproc` } else { "1" }

# Build the project
build *build_type='Release':
  @mkdir -p build
  @echo "Configuring the build system..."
  @cd build && cmake -S .. -B . -DCMAKE_BUILD_TYPE={{build_type}} -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
  @echo "Building the project..."
  @cd build && cmake --build . -j{{CORES}}

# Run a package
run *package='hello':
  @TRT_LIBS=""; \
  if [ -n "${TensorRT_ROOT:-}" ] && [ -d "${TensorRT_ROOT}/lib" ]; then TRT_LIBS="${TensorRT_ROOT}/lib"; fi; \
  if [ -d "/usr/local/cuda-12.8/targets/x86_64-linux/lib" ]; then \
    if [ -n "$TRT_LIBS" ]; then TRT_LIBS="$TRT_LIBS:/usr/local/cuda-12.8/targets/x86_64-linux/lib"; else TRT_LIBS="/usr/local/cuda-12.8/targets/x86_64-linux/lib"; fi; \
  fi; \
  if [ -n "$TRT_LIBS" ]; then \
    LD_LIBRARY_PATH="$TRT_LIBS:${LD_LIBRARY_PATH}" ./target/release/{{package}}; \
  else \
    ./target/release/{{package}}; \
  fi

# Run code quality tools
test:
  @echo "Running tests..."

# Remove build artifacts and non-essential files
clean:
  @echo "Cleaning..."
  @rm -rf build
  @rm -rf target

# Run code quality tools
check:
  @echo "Running code quality tools..."
  @cppcheck --error-exitcode=1 --project=build/compile_commands.json -i build/_deps/

