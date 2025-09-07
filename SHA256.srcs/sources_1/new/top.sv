`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/11/2025 07:19:59 PM
// Design Name: 
// Module Name: top
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


module top # (
    parameter BAUD_RATE = 115200,
    parameter CLK_FREQ = 100000000,
    parameter BIT_PERIOD_NS = 1000000000 / BAUD_RATE,
    parameter NUM_WORDS = 64,
    parameter WORD_WIDTH = 32
) (
    input clk_100Mhz,
    input rx,
    output tx
);
    reg clk_100Mhz, rst;
    wire baud_sample_recieving_clk, baud_sample_sending_clk;
    wire [511:0] message;
    wire [255:0] H;
    wire message_valid, W_valid, W_ready, hash_valid, hash_ready;
    wire [NUM_WORDS:1][WORD_WIDTH - 1:0] W;
    wire message_ready, ready_to_recieve_message;
    
    
    baud_rate_sample_generator gen(clk_100Mhz, rst, baud_sample_recieving_clk, baud_sample_sending_clk);
    uart_recieving uart_rx(clk_100Mhz, baud_sample_recieving_clk, rst, rx, message, message_valid, ready_to_recieve_message, message_ready);
    block_decomp block_decomp(clk_100Mhz, rst, message_valid, message_ready, message, W_valid, W_ready, W);
    hash_computation hash_computation(.clk_100Mhz(clk_100Mhz), .rst(rst), .W_valid(W_valid), .W_ready(W_ready), .W(W), .hash_valid(hash_valid), .hash_ready(hash_ready), .H(H));
    uart_sending uart_tx(clk_100Mhz, baud_sample_sending_clk, rst, tx, H, hash_valid, hash_ready);    

endmodule

