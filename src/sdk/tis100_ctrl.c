
#include <tis100.h>
#include <xparameters.h>
#include "xil_io.h"

// reg0
// write: send data to node up_in bus
// read: read data from down_out bust
#define TIS100_DATA_STREAM_REG_OFFSET TIS100_S00_AXI_SLV_REG0_OFFSET
// reg1
// read only irq status register bit 0: output_ready 1: ready_for_input
#define TIS100_IRQ_STATUS_REG_OFFSET TIS100_S00_AXI_SLV_REG1_OFFSET
#define TIS100_IRQ_STATUS_IN_READY_MASK 1
#define TIS100_IRQ_STATUS_OUT_VALID_MASK 2
// reg2
// r/w interrupt enable
#define TIS100_IRQ_EN_REG_OFFSET TIS100_S00_AXI_SLV_REG2_OFFSET
// reg3
// write instruction address
#define TIS100_INSTR_WRITE_ADDR_REG_OFFSET TIS100_S00_AXI_SLV_REG3_OFFSET
// reg 4
// write instruction value
#define TIS100_INSTR_WRITE_DATA_REG_OFFSET TIS100_S00_AXI_SLV_REG4_OFFSET

void TIS100_write_instructions(u32 * instrs, u32 len) {
	u32 i;
	for (i = 0; i < len; i++) {
		TIS100_mWriteReg(XPAR_TIS100_0_S00_AXI_BASEADDR, TIS100_INSTR_WRITE_ADDR_REG_OFFSET, i);
		TIS100_mWriteReg(XPAR_TIS100_0_S00_AXI_BASEADDR, TIS100_INSTR_WRITE_DATA_REG_OFFSET, instrs[i]);
	}
}

u32 TIS100_get_irq_status() {
	return TIS100_mReadReg(XPAR_TIS100_0_S00_AXI_BASEADDR, TIS100_IRQ_STATUS_REG_OFFSET);
}

u32 TIS100_is_ready_for_write() {
	return TIS100_get_irq_status() & TIS100_IRQ_STATUS_OUT_VALID_MASK;
}

u32 TIS100_is_ready_for_read() {
	return TIS100_get_irq_status() & TIS100_IRQ_STATUS_IN_READY_MASK;
}

void TIS100_write_to_in_stream(u32 val) {
	TIS100_mWriteReg(XPAR_TIS100_0_S00_AXI_BASEADDR, TIS100_DATA_STREAM_REG_OFFSET, val);
}

u32 TIS100_read_from_out_stream() {
	return TIS100_mReadReg(XPAR_TIS100_0_S00_AXI_BASEADDR, TIS100_DATA_STREAM_REG_OFFSET);
}
