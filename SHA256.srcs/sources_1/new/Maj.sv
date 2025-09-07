`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/03/2025 11:48:10 AM
// Design Name: 
// Module Name: Maj
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


module Maj( // 2 cycle latency
    input clk_100Mhz,
    input [31:0] X_in,
    input [31:0] Y_in,
    input [31:0] Z_in,
    output reg [31:0] Maj_out
    );
    wire [31:0] XY_wire, XZ_wire, YZ_wire, Maj_out_wire;
    reg  [31:0] XY, XZ, YZ;
    
    assign XY_wire = X_in & Y_in;
    assign XZ_wire = X_in & Z_in;
    assign YZ_wire = Y_in & Z_in;
    
    assign Maj_out_wire = XY ^ XZ ^ YZ;;
    
    always @(posedge clk_100Mhz) begin
        XY <= XY_wire;
        XZ <= XZ_wire;
        YZ <= YZ_wire;
        Maj_out <= Maj_out_wire; 
    end 
endmodule
