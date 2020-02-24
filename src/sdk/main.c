/******************************************************************************
*
* Copyright (C) 2009 - 2014 Xilinx, Inc.  All rights reserved.
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* Use of the Software is limited solely to applications:
* (a) running on a Xilinx device, or
* (b) that interact with a Xilinx device through a bus or interconnect.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
* XILINX  BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF
* OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*
* Except as contained in this notice, the name of the Xilinx shall not be used
* in advertising or otherwise to promote the sale, use or other dealings in
* this Software without prior written authorization from Xilinx.
*
******************************************************************************/

/*
 * helloworld.c: simple test application
 *
 * This application configures UART 16550 to baud rate 9600.
 * PS7 UART (Zynq) is not initialized by this application, since
 * bootrom/bsp configures it to baud rate 115200
 *
 * ------------------------------------------------
 * | UART TYPE   BAUD RATE                        |
 * ------------------------------------------------
 *   uartns550   9600
 *   uartlite    Configurable only in HW design
 *   ps7_uart    115200 (configured by bootrom/bsp)
 */

#include "xil_io.h"
#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"
#include "tis100_ctrl.h"
#include <xparameters.h>
#include <sleep.h>
#include <xgpiops.h>

#define GPIO_DEVICE_ID		 XPAR_XGPIOPS_0_DEVICE_ID
#define LED_PIN		47	/*	MIO47,	pin	connected	to	LED		*/
#define BUTTON_PIN	51	/*	MIO51,	pin	connected	to	button	*/

//	global	variables
XGpioPs gpio_ps;
/*	The	driver	instance	for	GPIO	Device.	*/
XGpioPs_Config *config_ptr;

// output from `python scripts/compiler.py -t cu32 -o test.h data/test_mult.tis`
u32 test_mult_instrs[] = {
    0b000101000000000000001,
    0b001000000000000000000,
    0b010000000000001010000,
    0b001000000000000000000,
    0b010100000000000001000,
    0b100100011111111100000,
    0b001000000000000000000,
    0b000100100000000000011
};

int main()
{
	s32 read;
	int status;
    init_platform();


	//	initialize	the	GpioPs	driver.
	config_ptr	=	XGpioPs_LookupConfig(GPIO_DEVICE_ID);
	status	=	XGpioPs_CfgInitialize(&gpio_ps,	config_ptr,	config_ptr->BaseAddr);
	if (status	!=	XST_SUCCESS)	{	return XST_FAILURE;	}
	//	configure	the	LED	pin	as	output
	XGpioPs_SetDirectionPin(&gpio_ps,	LED_PIN,	1);
	XGpioPs_SetOutputEnablePin(&gpio_ps,	LED_PIN,	1);
	//	Set	the	direction	for	the	specified	pin	to	be	input.
	XGpioPs_SetDirectionPin(&gpio_ps,	BUTTON_PIN,	0);

	XGpioPs_WritePin(&gpio_ps,	LED_PIN,	0);

	print("Sending instructions\n\r");
	TIS100_write_instructions(test_mult_instrs, sizeof(test_mult_instrs) / sizeof(u32));

    print("Waiting for user button\n\r");

    while(XGpioPs_ReadPin(&gpio_ps,	BUTTON_PIN) == 0);


    print("Wrote 5 to reg0\n\r");
    TIS100_write_to_in_stream(5);
    while(!TIS100_is_ready_for_read()) {
    	print("Wait\n\r");
    }
    read = TIS100_read_from_out_stream();
    xil_printf("Read %d from reg0\n\r", read);


    print("Wrote 100 to reg0\n\r");
    TIS100_write_to_in_stream(100);
    while(!TIS100_is_ready_for_write()) {
        	print("Wait\n\r");
    }
    read = TIS100_read_from_out_stream();
    xil_printf("Read %d from reg0\n\r", read);

    XGpioPs_WritePin(&gpio_ps,	LED_PIN,	1);

    cleanup_platform();
    return 0;
}
