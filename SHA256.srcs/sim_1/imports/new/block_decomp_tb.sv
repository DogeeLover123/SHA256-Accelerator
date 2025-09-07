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


module block_decomp_tb #(
    parameter NUM_WORDS = 64,
    parameter WORD_WIDTH = 32,
    parameter HASH_PIPELINE_STAGES = 3
);

    reg [511:0] message;
    wire [HASH_PIPELINE_STAGES-1:0][NUM_WORDS:1][WORD_WIDTH - 1:0] W;
    reg message_valid, W_ready;
    reg clk_100MHz;
    reg rst;    
    wire message_ready, W_valid;
    
    always #5 clk_100MHz = ~clk_100MHz;

    initial begin
        clk_100MHz  = 0;
        rst = 1;
        message = '1;
        message_valid = 1;
        W_ready = 1;
        repeat(2) @(posedge clk_100MHz);
        rst = 0;
        repeat(HASH_PIPELINE_STAGES) set_message;
        show_values;
        $finish;
    end 
    
    task set_message;
        integer i;
        wait(message_ready);
        for (i = 1; i < 16; i = i + 1) begin
            message[(i-1)*32 +: 32] = $urandom();
        end
    endtask

    task show_values; 
        integer i;
        integer W_index;
        wait(W_valid);
        for(W_index = 0; W_index < HASH_PIPELINE_STAGES; W_index = W_index + 1) begin
            for(i = 1; i <= NUM_WORDS; i = i + 1) begin
                $display("W[%0d][%0d] = %h", W_index, i, W[W_index][i]);
            end
        end
    endtask
    
    block_decomp #(.HASH_PIPELINE_STAGES(3)) dut(clk_100MHz, rst, message_valid, message_ready, message, W_valid, W_ready, W);

    
endmodule
