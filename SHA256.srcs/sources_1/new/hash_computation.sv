`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/02/2025 08:02:08 PM
// Design Name: 
// Module Name: hash_computation
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

module hash_computation #(
    parameter NUM_WORDS = 64,
    parameter WORD_WIDTH = 32,
    parameter HASH_PIPELINE_STAGES
)(
    input clk_100Mhz,
    input rst,
    input W_valid,
    output reg W_ready,
    input [MESSAGE_COUNTER_WIDTH-1:0][NUM_WORDS:1][WORD_WIDTH - 1:0] W,
    output reg hash_valid,
    input hash_ready,
    output reg [MESSAGE_COUNTER_WIDTH-1:0][8:1][31:0] H
);
    localparam MESSAGE_COUNTER_WIDTH = $clog2(HASH_PIPELINE_STAGES);
    
    reg [7:0] i;
    reg computing_hash_pipe2, computing_hash_pipe, computing_hash;
    reg [NUM_WORDS:1][WORD_WIDTH - 1:0] W_input;
    wire [31:0] K_i;
    reg [31:0] W_i_pipe, W_i;
    
    reg [31:0] T_one, T_two;
    
    reg [MESSAGE_COUNTER_WIDTH-1:0] W_index;
    
    always @(posedge clk_100Mhz) begin
        if(rst) begin
            H[1] <= 32'h6a09e667;   H[2] <= 32'hbb67ae85;   H[3] <= 32'h3c6ef372;   H[4] <= 32'ha54ff53a;
            H[5] <= 32'h510e527f;   H[6] <= 32'h9b05688c;   H[7] <= 32'h1f83d9ab;   H[8] <= 32'h5be0cd19;  
            
            i <= 1;
            W_ready <= 1;
            W_input <= 0;
            W_i_pipe <= 0;
            W_i      <= 0;
            hash_valid <= 0;
            computing_hash <= 0;
            computing_hash_pipe <= 0;
            computing_hash_pipe2 <= 0;
            W_index <= 0;
        end else begin
            computing_hash <= computing_hash_pipe;
            computing_hash_pipe <= computing_hash_pipe2;
            W_i            <= W_i_pipe;

            if(W_valid & W_ready) begin
                computing_hash_pipe2 <= 1;
                W_ready <= 0;
                W_input <= W;
                i <= i + 1;
                W_i_pipe <= W[1];
            end
            
            if(hash_valid & hash_ready) begin
                hash_valid <= 0;
                W_ready <= 1;
                H[1] <= 32'h6a09e667;   H[2] <= 32'hbb67ae85;   H[3] <= 32'h3c6ef372;   H[4] <= 32'ha54ff53a;
                H[5] <= 32'h510e527f;   H[6] <= 32'h9b05688c;   H[7] <= 32'h1f83d9ab;   H[8] <= 32'h5be0cd19;
            end    
            
            if(computing_hash_pipe2) begin
                if(i == 64) begin
                    computing_hash_pipe <= 1;
                    hash_valid <= 1;
                    i <= 1;
                end
                else begin                    
                    if(W_index == HASH_PIPELINE_STAGES - 1) begin
                        W_index <= 0;
                        i <= i + 1;
                    end
                    else begin
                        W_index <= W_index + 1;
                    end
                    W_i_pipe  <= W_input[i];
                end
            end
            
            if(computing_hash) begin          
                    H[W_index][8] <= H[W_index][7];
                    H[W_index][7] <= H[W_index][6];
                    H[W_index][6] <= H[W_index][5];
                    H[W_index][5] <= H[W_index][4] + T_one;
                    H[W_index][4] <= H[W_index][3];
                    H[W_index][3] <= H[W_index][2];
                    H[W_index][2] <= H[W_index][1];
                    H[W_index][1] <= T_one + T_two;                    
            end 
        end
    end
    
    T_one T_1(clk_100Mhz, rst, H[5], H[6], H[7], H[8], K_i, W_i, T_one);
    T_two T_2(clk_100Mhz, rst, H[1], H[2], H[3], T_two);
    
    //T_one T_1_test(H[5], H[6], H[7], H[8], 32'h71374491, 32'h80000000, T_one_test);
    
    K_ROM K_ROM(clk_100Mhz, rst, i, K_i);
    
endmodule