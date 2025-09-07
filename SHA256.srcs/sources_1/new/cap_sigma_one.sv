`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/02/2025 08:14:39 PM
// Design Name: 
// Module Name: cap_sigma_one
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

module cap_sigma_one( // 2 cycle latency
    input clk_100Mhz,
    input [31:0] cap_sigma_one_input,
    output reg [31:0] cap_sigma_one_output
);

wire [31:0] rot_r_six_wire, rot_r_eleven_wire, rot_r_twentyfive_wire, cap_sigma_one_output_wire;
reg  [31:0] rot_r_six, rot_r_eleven, rot_r_twentyfive;
 
assign rot_r_six_wire = {cap_sigma_one_input[5:0], cap_sigma_one_input[31:6]}; 
assign rot_r_eleven_wire = {cap_sigma_one_input[10:0], cap_sigma_one_input[31:11]}; 
assign rot_r_twentyfive_wire = {cap_sigma_one_input[24:0], cap_sigma_one_input[31:25]}; 

assign cap_sigma_one_output_wire = rot_r_six ^ rot_r_eleven ^ rot_r_twentyfive;

always @(posedge clk_100Mhz) begin
    rot_r_six <= rot_r_six_wire;
    rot_r_eleven <= rot_r_eleven_wire;
    rot_r_twentyfive <= rot_r_twentyfive_wire;
    
    cap_sigma_one_output <= cap_sigma_one_output_wire;
end

endmodule
