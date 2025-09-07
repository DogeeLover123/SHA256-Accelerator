`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/04/2025 01:30:32 PM
// Design Name: 
// Module Name: top_tb
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


module top_tb # (
    parameter BAUD_RATE = 115200,
    parameter CLK_FREQ = 100000000,
    parameter BIT_PERIOD_NS = 1000000000 / BAUD_RATE,
    parameter NUM_WORDS = 64,
    parameter WORD_WIDTH = 32
);
    reg clk_100Mhz, rst;
    wire baud_sample_clk;
    reg [511:0] message;
    reg message_valid;
    reg [NUM_WORDS:1][WORD_WIDTH - 1:0] W;
    
    reg [511:0] padded_inpbut = 512'h61626380000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000018;

    always #5 clk_100Mhz = ~clk_100Mhz; 
    
    task send_uart_byte(input [7:0] data);
        integer i;
        begin
            // Start bit
            rx = 0;
            #(BIT_PERIOD_NS);

            // Data bits (LSB first)
            for (i = 0; i < 8; i = i + 1) begin
                rx = data[i];
                #(BIT_PERIOD_NS);
            end

            // Stop bit
            rx = 1;
            #(BIT_PERIOD_NS);
        end
    endtask
    
    task send_data();
        begin
            integer i;
            // Send some bytes over UART
            for(int i = 0; i < 64; i = i + 1) begin //64 bytes
                send_uart_byte(padded_input[511-i*8:511-i*8-7]);  
            end
        end
    endtask
    

    // Test scenario
    initial begin
        // Initialize
        clk_100MHz = 0;
        rst = 1;
        rx = 1;  // idle high

        repeat(3) @(posedge clk_100MHz);

        send_data();

        wait(hash_valid);
        $finish;
    end
    
    
    baud_rate_sample_generator gen(clk_100Mhz, rst, baud_sample_recieving_clk, baud_sample_sending_clk);
    uart_recieving uart_rx(baud_sample_recieving_clk, rst, rx, message, message_valid, message_ready);
    block_decomp block_decomp(clk_100Mhz, rst, message_valid, message_ready, message, W);
    assign dummy_out = W[0];
endmodule

