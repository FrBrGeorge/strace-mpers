#!/bin/sh -e

echo -n 'lib_m32_a_SOURCES = ' > mpers_m32_sources.am
grep -l '#include DEF_MPERS_TYPE(\([^)[:space:]]*\))$' *.c | \
    tr '\n' ' ' >> mpers_m32_sources.am

echo -n 'lib_mx32_a_SOURCES = ' > mpers_mx32_sources.am
grep -l '#include DEF_MPERS_TYPE(\([^)[:space:]]*\))$' *.c | \
    tr '\n' ' ' >> mpers_mx32_sources.am
