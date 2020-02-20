#!/usr/bin/env sh
source scripts/env.sh

#SCRIPT_PATH=../../../../../scripts
# cd tis100/tis100.sim/sim_1/behav/xsim/
# xsim  op_decode_tb_behav -key {Behavioral:sim_1:Functional:op_decode_tb} -tclbatch $SCRIPT_PATH/run_tests.tcl -log simulate1.log

vivado -mode batch -source scripts/run_tests.tcl | tee simulation.log
python scripts/check_sim_logs.py simulation.log 7
