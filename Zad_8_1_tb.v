`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.04.2020 21:31:34
// Design Name: 
// Module Name: Zad_8_1_tb
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


module Zad_8_1_tb();

logic clk;
logic start;
logic ready;

logic[15:0] input0;
logic[4:-19] output0;

int tmp_i, input_i;
real input_r, check_r, output_r;
logic ready_prev;

Zad_8_1 UUT(.clk, .start, .ready, .input0, .output0);

always
begin
    clk = 1'b0;
    #5; // low for 5*timescale = 5ns
    clk = 1'b1;
    #5; //high for 5*timescale = 5ns
end

initial begin
    input_i = 3;
    input_r = input_i;
    check_r = 1 / input_r;
    input0 <= input_i;
    start <= 1'b1;
end
always@( posedge clk ) begin
    start <= ready; //self handshaking
end;

always@( posedge clk ) begin
    if ( ready == 1'b1 /*&& ready_prev == 1'b0*/ ) begin // new value arrived
        input_r = input0;
        check_r = 1 / input_r;
        output_r = output0;
        output_r = output_r / ( 2 ** 19 );
        
        $display ( "Input is %f. Output is %f. Correct result is %f", input_r,
        output_r, check_r);
        
        input_i ++;
        input0 <= input_i;
    end
end
endmodule
