`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/03/2025 12:46:42 PM
// Design Name: 
// Module Name: T_two
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


module T_two( // end to end 3 cycle latency
    input clk_100Mhz,
    input rst,
    input [31:0] a,
    input [31:0] b,
    input [31:0] c,
    output reg [31:0] T_two
);

wire [31:0] cap_sigma_zero_a, Maj_a_b_c, T_two_wire;

cap_sigma_zero cap_sigma_zero(clk_100Mhz, a, cap_sigma_zero_a);
Maj Maj(clk_100Mhz, a, b, c, Maj_a_b_c);

assign T_two_wire = cap_sigma_zero_a + Maj_a_b_c;

always @(posedge clk_100Mhz) begin
    if(rst) T_two <= 0;
    else T_two = T_two_wire;
end

endmodule
