`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/05/2025 07:44:17 PM
// Design Name: 
// Module Name: uart_sending_tb
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


module uart_sending_tb#(
    parameter HASH_PIPELINE_STAGES = 3
);

reg clk_100Mhz, rst;
wire baud_sample_recieving_clk, baud_sample_sending_clk;
wire tx, rx;
reg [HASH_PIPELINE_STAGES-1:0][511:0] H;
wire [HASH_PIPELINE_STAGES-1:0][511:0] message;
wire message_valid;
reg hash_valid, message_ready;
wire ready_to_recieve_hash;
reg ready_to_recieve_message;

always #5 clk_100Mhz = ~clk_100Mhz;

initial begin
    clk_100Mhz = 0;
    rst = 1;
    hash_valid = 0;
    message_ready = 1;
    ready_to_recieve_message = 1;
    H = 1536'h01234567890abcdef01234567890abcdef01234567890abcdef01234567890abcdef01234567890abcdef01234567890abcdef01234567890abcdef01234567890abcdef01234567890abcdef01234567890abcdef01234567890abcdef01234567890abcdef01234567890abcdef01234567890abcdef01234567890abcdef01234567890abcdef01234567890abcdef01234567890abcdef01234567890abcdef01234567890abcdef01234567890abcdef01234567890abcdef01234567890abcdef01234567890abcdef;
    repeat(2) @(posedge clk_100Mhz);
    rst = 0;
    hash_valid = 1;
    @(posedge clk_100Mhz);
    hash_valid = 0;
end

assign rx = tx;

initial begin
    wait(message_valid == 1);
    repeat(10000) @(posedge clk_100Mhz);
    assert(H == message) else $display("H!= message");
    @(posedge clk_100Mhz);
    $finish;
end

baud_rate_sample_generator gen(clk_100Mhz, rst, baud_sample_recieving_clk, baud_sample_sending_clk);
uart_recieving #(.HASH_PIPELINE_STAGES(3)) uart_rx(clk_100Mhz, baud_sample_recieving_clk, rst, rx, message, message_valid, ready_to_recieve_message, message_ready);
uart_sending #(.HASH_PIPELINE_STAGES(3)) uart_tx(clk_100Mhz, baud_sample_sending_clk, rst, tx, H, hash_valid, ready_to_recieve_hash);

endmodule
