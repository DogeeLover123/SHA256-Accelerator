`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/01/2025 09:54:10 AM
// Design Name: 
// Module Name: sigma_zero
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


module sigma_zero(
        input [31:0] X,
        output [31:0] X_sigma_zero
    );
    
    wire [31:0] rotr_seven, rotr_eighteen, shr_three;
    
    assign rotr_seven = {X[6:0], X[31:7]};
    assign rotr_eighteen  = {X[17:0], X[31:18]};
    assign shr_three = {3'b0, X[31:3]};
    
    assign X_sigma_zero = rotr_seven ^ rotr_eighteen ^ shr_three;
endmodule

