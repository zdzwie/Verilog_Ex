`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.04.2020 19:27:05
// Design Name: 
// Module Name: Zad_7_1
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


module Zad_7_1(
       input logic [15:0] input0,
       output logic [4:-19] output0
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

real resultFP; //To display human readable

always_comb begin
    
    //Here scaledVal = input
    scaledVal = input0; //IDLE
    scaling = 19;
    //Scale tmpValue to range [0.5, 1] in integer
    //In difference to oryginal algorithm multiply by two in each iteration
    while(scaledVal <HALF) begin //COMP_AND_SCALE
        scaledVal = scaledVal<<1;
        scaling--;
    end
    
    //Take linear approximation x0 = 2.82353-1.88235*d
    mtpResult = scaledVal*A;
    approxedVal = mtpResult>>19;
    approxedVal = B-approxedVal;
    
    while(1) begin //iterate x(i+1) = x(i)*(2-x(i)*d)
        mtpResult = approxedVal*scaledVal;
        newVal = mtpResult >> 19;
        newVal = TWO - newVal;
        mtpResult = approxedVal*newVal;
        newVal = mtpResult >> 19;
        
        if(approxedVal == newVal) begin 
            break; 
        end
        approxedVal = newVal;
     end
      
      approxedVal = approxedVal >> scaling;
      
      output0 = approxedVal;
      
      $display("Binary result is = %b",approxedVal);
      resultFP = approxedVal;
      resultFP = resultFP/2**19;
      $display("Real value is = %f",resultFP);
     
end
endmodule
