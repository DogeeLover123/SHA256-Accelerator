`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/02/2025 08:23:04 PM
// Design Name: 
// Module Name: Ch
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


module Ch( // 2 cycle latency
    input clk_100Mhz,
    input [31:0] X_in,
    input [31:0] Y_in,
    input [31:0] Z_in,
    output reg [31:0] Ch_out
    );
    
    wire [31:0] XY_wire, notX_and_Z_wire, Ch_out_wire;
    reg  [31:0] XY, notX_and_Z;
    
    assign XY_wire = X_in & Y_in;
    assign notX_and_Z_wire = ~X_in & Z_in;
    
    assign Ch_out_wire = XY ^ notX_and_Z;
    
    always @(posedge clk_100Mhz) begin
        XY <= XY_wire;
        notX_and_Z <= notX_and_Z_wire;
        Ch_out <= Ch_out_wire;
    end
    
endmodule
