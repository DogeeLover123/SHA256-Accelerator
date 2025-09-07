`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/01/2025 10:29:43 AM
// Design Name: 
// Module Name: block_decomp_tb
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


module block_decomp_tb(

    );
    
    wire [511:0] message;
    wire [511:0] W;
    wire message_ready;
    initial begin
        message = '1;
        message_ready = 1;
        
        block_decomp(message_ready, message, W);
    end
    
endmodule
