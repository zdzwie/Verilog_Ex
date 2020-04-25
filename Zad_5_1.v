`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.04.2020 16:30:27
// Design Name: 
// Module Name: Zad_5_1
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


module Zad_5_1(
    input logic clk,
    input logic start,
    output logic ready,
    input logic [23:0] input0,
    input logic [23:0] input1,
    output logic [47:0] output0
    );
    
//Signals definition
logic[11:0] a0,a1,b0,b1;

assign a0 = input0[11:0];
assign a1 = input0[23:12];

assign b0 = input1[11:0];
assign b1 = input1[23:12];

logic[23:0] tmp;
logic[47:0] result;

assign output0 = result;

//FSM

enum {IDLE=0, P0, P1, P2, DONE} state;

    always_ff @ (posedge clk) begin: fsm
        case(state)
            IDLE: begin
                ready <=1'b0;
                if(start==1'b0) begin
                    state<=IDLE;
                 end
                 else begin
                    result<=48'h0;
                    tmp<=a0*b0;
                    state<=P0;
                end
            end
            P0: begin
                result[23:0]<=tmp;
                tmp <= a1*b0;
                state <=P1;
            end
            P1: begin
                result[35:12]<=result[35:12]+tmp;
                tmp<=a0*b1;
                state<=P2;
            end
            P2: begin
                result[36:12] <= result[35:12] + tmp;
                tmp = a1*b1;
                state<=DONE;
            end
            DONE: begin
                result[47:24]<=result[47:24] + tmp;
                ready<=1'b1;
                state<=IDLE;
            end
       endcase
   end: fsm
endmodule
