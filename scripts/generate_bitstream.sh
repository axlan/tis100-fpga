#!/usr/bin/env sh
source scripts/env.sh

vivado -mode batch -source scripts/generate_bitstream.tcl
