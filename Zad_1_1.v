`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.04.2020 10:57:01
// Design Name: 
// Module Name: Zad_1_1
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


module Zad_1_1(
        input logic[11:0] input0,
        input logic[11:0] input1,
        output logic[23:0] output0
    );

always_comb begin
    output0<=input0*input1;
end

endmodule
