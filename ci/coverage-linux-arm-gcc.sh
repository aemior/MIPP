#!/bin/bash
set -x

THREADS=$(grep -c ^processor /proc/cpuinfo)
PWD=$(pwd)

function gen_coverage_info {
	build=$1
	mkdir $build
	cd $build
	cmake .. -G"Unix Makefiles" -DCMAKE_CXX_COMPILER=g++ -DCMAKE_BUILD_TYPE=Debug -DCMAKE_CXX_FLAGS_DEBUG="-g -O0" -DCMAKE_CXX_FLAGS="-Wall -funroll-loops -finline-functions --coverage $2" -DCMAKE_EXE_LINKER_FLAGS="--coverage"
	rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi
	make -j $THREADS
	rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi
	./bin/run_tests
	rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi
	lcov --capture --directory CMakeFiles/run_tests.dir/src/ --output-file ../code_coverage_files/$build.info
	rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi
	lcov --remove ../code_coverage_files/$build.info "*/usr*" "*lib/*" "*/tests/src*" --output-file ../code_coverage_files/$build.info
	rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi
	cd ..
}

cd tests
mkdir code_coverage_files || true

build_root=build_coverage_linux_arm_gcc
gen_coverage_info "${build_root}_nointr"     "-DMIPP_NO_INTRINSICS"
gen_coverage_info "${build_root}_neon32"     "-mfpu=neon"
gen_coverage_info "${build_root}_neon32_fma" "-mfpu=neon-vfpv4"