`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.04.2020 11:46:15
// Design Name: 
// Module Name: Zad_1_1_tb
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


module Zad_1_1_tb();

logic clk;
logic [12:0] input0, input1;
logic [23:0] output0;

Zad_1_1 UUT(.input0,.input1,.output0);

initial begin
    input0 = 12'hff0;
    input1 = 12'hff0;
end

always
begin
    clk = 1'b0;
    #5; // low for 5*timescale = 5ns
    clk = 1'b1;
    #5; //high for 5*timescale = 5ns
end

always@(posedge clk) begin
    if(input0*input1!=output0) begin
        $display("Multiplication error. Stop!");
        $stop;
    end;
    input0 = input0+1;
    input1 = input1+1;
end;
    

endmodule
