`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/03/2025 12:33:45 PM
// Design Name: 
// Module Name: T_one
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


module T_one( // in total end to end 3 cycle latency
    input clk_100Mhz,
    input rst,
    input [31:0] e,
    input [31:0] f,
    input [31:0] g,
    input [31:0] h,
    input [31:0] K_i,
    input [31:0] W_i,
    output reg [31:0] T_one
);

wire [31:0] cap_sigma_one_e, Ch_e_f_g, T_one_wire;

wire [31:0] h_pipeline_out, K_i_pipeline_out, W_i_pipeline_out;

// 2 stage pipeline to match 2 cycle latency of cap_sigma_one nd Ch cap_sigma_one
// so that T_one_wire assignment doesn't use h, K_i, and W_i values that are meant for future values.
reg  [2:0] [31:0] h_pipeline, K_i_pipeline, W_i_pipeline; 

cap_sigma_one cap_sigma_one(clk_100Mhz, e, cap_sigma_one_e);
Ch Ch(clk_100Mhz, e, f, g, Ch_e_f_g);

assign h_pipeline_out = h_pipeline[2];
assign K_i_pipeline_out = K_i_pipeline[2];
assign W_i_pipeline_out = W_i_pipeline[2];

assign T_one_wire = h_pipeline_out + cap_sigma_one_e + Ch_e_f_g + K_i_pipeline_out + W_i_pipeline_out;

always @(posedge clk_100Mhz) begin
    if(rst) begin
        T_one <= 0;

        h_pipeline <= 0;
        K_i_pipeline <= 0;
        W_i_pipeline <= 0;
    end
    else begin 
        T_one <= T_one_wire;
        
        h_pipeline <= {h_pipeline[1:0], h};
        K_i_pipeline <= {K_i_pipeline[1:0], K_i};
        W_i_pipeline <= {W_i_pipeline[1:0], W_i};
    end
end

endmodule
