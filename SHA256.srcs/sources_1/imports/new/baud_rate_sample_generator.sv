`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/11/2025 09:58:58 PM
// Design Name: 
// Module Name: baud_rate_sample_generator
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


module baud_rate_sample_generator # (
    parameter MAX_COUNT_VALUE_RECIEVING = 54,
    parameter MAX_COUNT_VAULE_SENDING = 868
    /*
    Recieving: For each baud rate "clock", I want to sample it 16 times, and then take the middle sample. This way there should be very high data integrity.
    100 mhz / 115200 / 16 = 52
    
    Sending: Don't need to oversample, so just 100 mhz / 115200 = 868
    */
) (
    input clk_100MHz,
    input rst,
    output baud_sample_clk_receiving,
    output baud_sample_clk_sending
);

    wire [5:0] clk_counter_recieving_next;
    reg [5:0] clk_counter_recieving_reg;
    
    wire [9:0] clk_counter_sending_next;
    reg [9:0] clk_counter_sending_reg;
    
    always @(posedge clk_100MHz) begin
        if(rst) begin
            clk_counter_recieving_reg <= 0;
            clk_counter_sending_reg <= 0;
        end
        else begin
            clk_counter_recieving_reg <= clk_counter_recieving_next;
            clk_counter_sending_reg <= clk_counter_sending_next;
        end
    end

    assign clk_counter_recieving_next = (clk_counter_recieving_reg == MAX_COUNT_VALUE_RECIEVING) ? 0 : clk_counter_recieving_reg + 1;
    assign baud_sample_clk_receiving = (clk_counter_recieving_reg == MAX_COUNT_VALUE_RECIEVING) ? 1 : 0;
    
    assign clk_counter_sending_next = (clk_counter_sending_reg == MAX_COUNT_VAULE_SENDING) ? 0 : clk_counter_sending_reg + 1;
    assign baud_sample_clk_sending = (clk_counter_sending_reg == MAX_COUNT_VAULE_SENDING) ? 1 : 0;

endmodule
