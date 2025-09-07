`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/02/2025 08:14:39 PM
// Design Name: 
// Module Name: cap_sigma_zero
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

module cap_sigma_zero( // 2 cycle latency
    input clk_100Mhz,
    input [31:0] cap_sigma_zero_input,
    output reg [31:0] cap_sigma_zero_output
);

wire [31:0] rot_r_two_wire, rot_r_thirteen_wire, rot_r_twentytwo_wire, cap_sigma_zero_output_wire;
reg [31:0] rot_r_two, rot_r_thirteen, rot_r_twentytwo;

assign rot_r_two_wire = {cap_sigma_zero_input[1:0], cap_sigma_zero_input[31:2]}; 
assign rot_r_thirteen_wire = {cap_sigma_zero_input[12:0], cap_sigma_zero_input[31:13]}; 
assign rot_r_twentytwo_wire = {cap_sigma_zero_input[21:0], cap_sigma_zero_input[31:22]}; 

assign cap_sigma_zero_output_wire = rot_r_two ^ rot_r_thirteen ^ rot_r_twentytwo;

always @(posedge clk_100Mhz) begin
     rot_r_two <= rot_r_two_wire;
     rot_r_thirteen <= rot_r_thirteen_wire;
     rot_r_twentytwo <= rot_r_twentytwo_wire;
     cap_sigma_zero_output <= cap_sigma_zero_output_wire; 
end   
 
endmodule
