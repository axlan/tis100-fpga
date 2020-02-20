open_project tis100/tis100.xpr

set_property -name {xsim.simulate.runtime} -value {100us} -objects [get_filesets sim_1]

set test_benches {"alu_tb" "op_decode_tb" "registers_tb" "instr_rom_tb" "dir_manager_tb" "t21_node_tb" "t21_2_node_tb" }

foreach test_bench $test_benches {
    set_property top $test_bench [get_filesets sim_1]
    set_property top_lib xil_defaultlib [get_filesets sim_1]
    update_compile_order -fileset sim_1
    launch_simulation
    close_sim
}
