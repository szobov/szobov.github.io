#!/bin/bash

SOURCE="$(readlink -f ${1})"
SIZE="${2:-900x700}"
OUTPUT="${3:-${SOURCE}_out}"

if ! test -f "${SOURCE}"; then
	  echo "usage: $0 [source_file] [new_size] [output]"
	  echo "Source file not found: '$SOURCE'"
	  exit 1
fi

convert ${SOURCE} -resize ${SIZE} -strip ${OUTPUT}
