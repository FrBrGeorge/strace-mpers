#!/bin/sh -e

ARCH_FLAG=$1
PARSER_FILE=$2
CC=$3
CFLAGS="$4 -c -I. -gdwarf-4"

VAR_NAME='mpers_target_var'
BITS_DIR="mpers${ARCH_FLAG}"

mkdir -p ${BITS_DIR}
m_types=`cat ${PARSER_FILE} |
	sed -n 's/#include DEF_MPERS_TYPE(\([^)[:space:]]*\))$/\1/p'`
for m_type in ${m_types}; do
	awk "/^#include MPERS_DEFS/ {print \"$m_type $VAR_NAME;\"; exit};
		/^[[:space:]]*#[[:space:]]*include[[:space:]]*\"xlat\\// {next};
		!/DEF_MPERS_TYPE/ {print};"\
		$PARSER_FILE > ${BITS_DIR}/${m_type}.c
	$CC $CFLAGS ${BITS_DIR}/${m_type}.c \
		$ARCH_FLAG -o ${BITS_DIR}/${m_type}.o
	readelf --debug-dump=info ${BITS_DIR}/${m_type}.o > \
		${BITS_DIR}/${m_type}.dwarf
		file=${BITS_DIR}/${m_type}.dwarf
	sed -n '
		/^[[:space:]]*<1>/,/^[[:space:]]*<1><[^>]\+>: Abbrev Number: 0/!d
		/^[[:space:]]*<[^>]\+><[^>]\+>: Abbrev Number: 0/d
		s/^[[:space:]]*<[[:xdigit:]]\+>[[:space:]]\+//
		s/^[[:space:]]*\(\(<[[:xdigit:]]\+>\)\{2\}\):[[:space:]]\+/\1\n/
		p
		' $file |
		awk -v VAR_NAME="$VAR_NAME" -v ARCH_FLAG="${ARCH_FLAG#-}" \
		-f mpers.awk > ${BITS_DIR}/${m_type}.h
done
