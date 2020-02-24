open_project tis100/tis100.xpr
launch_runs impl_1 -to_step write_bitstream
wait_on_run impl_1
write_hw_platform -fixed -force  -include_bit tis100/design_top_wrapper.xsa
