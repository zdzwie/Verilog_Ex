`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.04.2020 20:45:57
// Design Name: 
// Module Name: Zad_8_1
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


module Zad_8_1(
       input logic [15:0] input0,
       output logic [4:-19] output0,
       input logic clk,
       input logic start,
       output logic ready
    );
    
//Constants
logic [4:-19] A = 24'h0F0F0D; //Fixed point [5:19] representation of 1.88235
logic [4:-19] B = 24'h169696; //Fixed point [5:19] representation of 2.82353
logic [4:-19] HALF = 32'h040000; //Fixed point [5:19] representation of 0.5
logic [4:-19] TWO = 32'h100000; //Fixed point [5:19] representation of 2

//Variables
logic [4:0] scaling; //Keeps scaling factor
logic [9:-38] mtpResult; //Temporary result of multiplication [5:19]*[5:19]
logic [4:-19] scaledVal;
logic [4:-19] approxedVal;
logic [4:-19] newVal;

logic mtp_start;
logic mtp_ready;

logic[23:0] mtp_input0;
logic[23:0] mtp_input1;
logic[47:0] mtp_output0;

Zad_6_2 mtp_inst(
        .clk(clk),
        .start(mtp_start),
        .ready(mtp_ready),
        .input0(mtp_input0),
        .input1(mtp_input1),
        .output0(mtp_output0));

enum{IDLE=0,COMP_AND_SCALE,MUL_A, SUB_B, MUL_SCALED, SUB_2, MUL_NEW, CHECK_EQ, ASSIGN_NEW, MUL_SCALING, DONE} state;

    always_ff@(posedge clk) begin: fsm
        case(state)
        IDLE: begin
            ready<=1'b0;
            if(start==1'b0) begin
                state<=IDLE;
            end
            else begin
                scaledVal<=input0;
                scaling = 5'd19;
                state<=COMP_AND_SCALE;
                end
         end
         COMP_AND_SCALE: begin
                if(scaledVal<HALF) begin
                    scaledVal<=scaledVal << 1;
                    scaling --;
                    state<=COMP_AND_SCALE;
                end
                else begin
                    state<=MUL_A;
                end
         end
         MUL_A: begin
                if(mtp_ready==1'b1) begin
                    mtpResult<=mtp_output0;
                    state<=SUB_B;
                 end
                 else begin
                    state<=MUL_A;
                 end
         end
         SUB_B: begin
                approxedVal <= B - mtpResult[4:-19];
                state<=MUL_SCALED;
         end
         MUL_SCALED: begin
                if(mtp_ready ==1'b1) begin
                    mtpResult<=mtp_output0;
                    state<=SUB_2;
                 end
                 else begin
                    state<=MUL_SCALED;
                 end
         end
         SUB_2: begin
            newVal <= TWO-mtpResult[4:-19];
            state <= MUL_NEW;
         end
         MUL_NEW: begin
                if(mtp_ready == 1'b1) begin
                    mtpResult <= mtp_output0;
                    state<=CHECK_EQ;
                 end
                 else begin
                    state <= MUL_NEW;
                 end
          end
          CHECK_EQ: begin
                if(approxedVal == mtpResult[4:-19]) begin
                    state <= DONE;
                end
                else begin
                    state<=ASSIGN_NEW;
                    newVal<=mtpResult[4:-19];
                end    
          end
          ASSIGN_NEW: begin
                approxedVal<=newVal;
                state<=MUL_SCALED;
          end
          DONE: begin
                output0<=(approxedVal >>scaling);
                ready<=1'b1;
                state<=IDLE;
          end                    
         endcase
    end: fsm
    
    always_comb begin
        case(state)
            MUL_A: begin
                mtp_start<= ~mtp_ready;
                mtp_input0 <=A;
                mtp_input1 <=scaledVal;
            end
            MUL_SCALING: begin
                mtp_start<= ~mtp_ready;
                mtp_input0<=scaling;
                mtp_input1 <=approxedVal;   
            end    
            MUL_SCALED: begin
                mtp_start<= ~mtp_ready;
                mtp_input0<=approxedVal;
                mtp_input1<=scaledVal;
            end
            MUL_NEW: begin
                mtp_start<= ~mtp_ready;
                mtp_input0<=approxedVal;
                mtp_input1 <=newVal; 
             end
            default: begin
                mtp_start <=1'b0;
            end                       
        endcase;
   end             
endmodule
