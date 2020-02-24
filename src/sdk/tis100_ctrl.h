
// write binary instructions to TIS100 node
// node restarts
TIS100_write_instructions(u32 * instrs, u32 len);

// get status of interupt flags
u32 TIS100_get_irq_status();

// is the node ready for a call to TIS100_write_to_in_stream
u32 TIS100_is_ready_for_write();

// is the node ready for a call to TIS100_read_from_out_stream
u32 TIS100_is_ready_for_read();

// stream a value into node
void TIS100_write_to_in_stream(u32 val);

// stream a value out of node
u32 TIS100_read_from_out_stream(void);
