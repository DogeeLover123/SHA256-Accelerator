`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/01/2025 09:42:58 AM
// Design Name: 
// Module Name: sigma_one
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


module sigma_one(
        input [31:0] X,
        output [31:0] X_sigma_one
    );
    
    wire [31:0] rotr_nineteen, rotr_seventeen, shr_ten;
    
    assign rotr_nineteen = {X[18:0], X[31:19]};
    assign rotr_seventeen  = {X[16:0], X[31:17]};
    assign shr_ten = {10'b0, X[31:10]};
    
    assign X_sigma_one = rotr_nineteen ^ rotr_seventeen ^ shr_ten;
endmodule
