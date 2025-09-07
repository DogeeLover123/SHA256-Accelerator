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
    parameter WORD_WIDTH = 32,
    parameter HASH_PIPELINE_STAGES = 3
);
    reg clk_100Mhz, rst;
    wire baud_sample_recieving_clk, baud_sample_sending_clk;
    wire [511:0] message;
    wire [255:0] H, final_hash;
    wire message_valid, W_valid, W_ready, hash_valid, hash_ready, final_hash_valid;
    wire [NUM_WORDS:1][WORD_WIDTH - 1:0] W;
    reg rx, tx;
    wire rx2;
    wire message_ready, message_ready2, ready_to_recieve_message, ready_to_recieve_message2;
    
    reg [511:0] padded_input = 512'h12345678800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000020;

    //512'h1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef;

    assign rx2 = tx;
    assign message_ready2 = 1;
    
    always #5 clk_100Mhz <= ~clk_100Mhz; 
    
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
                send_uart_byte(padded_input[(511 - i*8) -: 8]);  // tried to do normal way but system verilog did NOT like that :(
            end
        end
    endtask
    

    // Test scenario
    initial begin
        // Initialize
        clk_100Mhz <= 0;
        rst <= 1;
        rx = 1;  // idle high
        
        #121000

        rst <= 0;
        #131000

        send_data();

        wait(final_hash_valid);
        $display("final hash output is: %d", final_hash);
        $finish;
    end
 
    
    baud_rate_sample_generator gen(clk_100Mhz, rst, baud_sample_recieving_clk, baud_sample_sending_clk);
    uart_recieving #(.BYTES_RECIEVING(64), .HASH_PIPELINE_STAGES(3)) uart_rx (clk_100Mhz, baud_sample_recieving_clk, rst, rx, message, message_valid, ready_to_recieve_message, message_ready);
    block_decomp #(.HASH_PIPELINE_STAGES(3)) block_decomp (clk_100Mhz, rst, message_valid, message_ready, message, W_valid, W_ready, W);
    hash_computation #(.HASH_PIPELINE_STAGES(3)) hash_computation(.clk_100Mhz(clk_100Mhz), .rst(rst), .W_valid(W_valid), .W_ready(W_ready), .W(W), .hash_valid(hash_valid), .hash_ready(hash_ready), .H(H));
    uart_sending #(.HASH_PIPELINE_STAGES(3)) uart_tx(clk_100Mhz, baud_sample_sending_clk, rst, tx, H, hash_valid, hash_ready);
    uart_recieving #(.BYTES_RECIEVING(32), .HASH_PIPELINE_STAGES(3)) check_output (clk_100Mhz, baud_sample_recieving_clk, rst, rx2, final_hash, final_hash_valid, ready_to_recieve_message2, message_ready2);
    

endmodule

