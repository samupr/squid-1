#!/bin/sh
#
# test all header files (.h) for dependancy issues.
#
# Ideally this test should be performed twice before any code is accepted.
# With or without inline enabled.  This is needed because the .cci files
#  are only included into the .h files when inline mode is enabled.
#
# This script should be run from the makefile with the directory path and ccflags
#
cc="${1}"

if test "${2}" = ""; then
	dir="."
else
	dir="${2}"
fi

exitCode=0

for f in `cd ${dir} && ls -1 *.h 2>/dev/null`; do
	echo -n "Testing ${dir}/${f} ..."
	hdr=`echo "${f}" | sed s/.h//`
	if [ ! -e ./testHeaderDeps_${hdr}.o -o ${dir}/${f} -nt ./testHeaderDeps_${hdr}.o ]; then
		(	echo "/* This file is AUTOMATICALLY GENERATED. DO NOT ALTER IT */"
			echo "#include \"${dir}/${f}\" "
			echo "int main( int argc, char* argv[] ) { return 0; } "
		) >./testHeaderDeps_${hdr}.cc

		# run compile test on the new file.
		# DEBUG: echo "TRY: ${cc} -o testHeaderDeps.o ./testHeaderDeps_${hdr}.cc"
		${cc} -c -o testHeaderDeps_${hdr}.o ./testHeaderDeps_${hdr}.cc
		rm ./testHeaderDeps_${hdr}.cc
	fi
	if [ ! -f testHeaderDeps_${hdr}.o ]; then
		rm testHeaders
		exitCode=1
	else
		echo "OK."
		# unit-tests require an app to run.
		# our most-recent object suits this purpose.
		# let's link or some tests will fail
		${cc} ./testHeaderDeps_${hdr}.o -o ./testHeaders
	fi
done

exit $exitCode
