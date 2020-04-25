`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.04.2020 20:18:14
// Design Name: 
// Module Name: Zad_7_1_tb
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


module Zad_7_1_tb();

real inputFP, outputFP;
logic [15:0] input0, output0;

Zad_7_1 UUT (.input0, .output0);

initial begin
    input0 = 16'd3;
end

endmodule
