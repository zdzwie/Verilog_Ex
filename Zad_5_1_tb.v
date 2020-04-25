`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.04.2020 17:25:45
// Design Name: 
// Module Name: Zad_5_1_tb
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


module Zad_5_1_tb();

logic clk, start, ready;
logic [23:0] input0, input1;
logic [47:0] output0;

Zad_5_1 UUT (.clk, .start, .ready, .input0, .input1, .output0);

initial begin
    input0 <= 24'h1;
    input1 <= 24'h1;
    start  <= 1'b1;
 end
 
always
begin
    clk = 1'b0;
    #5; // low for 5*timescale = 5ns
    clk = 1'b1;
    #5; //high for 5*timescale = 5ns
end

always@(posedge clk) begin
    if(ready==1'b1) begin
      if(input0*input1!=output0) begin
        $display("Multiplication error.Stop");
        $stop;
     end
     input0 <= input0 + 1;
     input1 <= input1 + 1;
   end
   start<=ready;
end
endmodule
