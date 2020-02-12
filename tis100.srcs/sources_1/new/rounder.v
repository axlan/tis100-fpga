`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/11/2020 06:12:06 PM
// Design Name: 
// Module Name: rounder
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module rounder(
        input signed [11:0] in,
        input signed [10:0] out
    );
    localparam MIN_VAL = -11'sd999;
    localparam MAX_VAL = 11'sd999;
    
    assign out = (in < MIN_VAL) ? MIN_VAL :
          (in > MAX_VAL) ? MAX_VAL :
          in;
endmodule
