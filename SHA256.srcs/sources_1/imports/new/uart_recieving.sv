//////`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////////////
//////// Company: 
//////// Engineer: 
//////// 
//////// Create Date: 06/11/2025 10:15:32 PM
//////// Design Name: 
//////// Module Name: uart_recieving
//////// Project Name: 
//////// Target Devices: 
//////// Tool Versions: 
//////// Description: 
//////// 
//////// Dependencies: 
//////// 
//////// Revision:
//////// Revision 0.01 - File Created
//////// Additional Comments:
//////// 
////////////////////////////////////////////////////////////////////////////////////////

module uart_recieving #(
    parameter BYTES_RECIEVING = 64,
    parameter HASH_PIPELINE_STAGES
) (
    input clk_100Mhz,
    input baud_sample_clk,
    input rst,
    input rx,
    output reg [HASH_PIPELINE_STAGES-1:0][BYTES_RECIEVING*8 - 1:0] message,
    output reg message_valid,
    output reg ready_to_recieve_message,
    input message_ready
);

    localparam [1:0] idle = 2'b00,
                     start = 2'b01,
                     data = 2'b10,
                     stop = 2'b11;
                  
    localparam BYTE_COUNTER_WIDTH = $clog2(BYTES_RECIEVING);
    localparam MESSAGE_COUNTER_WIDTH = $clog2(HASH_PIPELINE_STAGES);
    
    reg [1:0] state, next_state;
    reg [2:0] data_bit_counter, data_bit_counter_next;
    reg [3:0] baud_sample_counter, baud_sample_counter_next;
    reg [BYTE_COUNTER_WIDTH:0] byte_counter, byte_counter_next;
    reg [7:0] byte_data, byte_data_next;
    reg prev_rx;
    reg new_message;
    reg [MESSAGE_COUNTER_WIDTH:0] message_counter;

    always @(posedge baud_sample_clk or posedge rst) begin
        if(rst) begin
            state <= idle;
            baud_sample_counter <= 0;
            data_bit_counter <= 0;
            byte_counter <= 0;
            byte_data <= 0;
            message <= 0;
            prev_rx <= 1;
            ready_to_recieve_message <= 1;
            message_counter <= 0;   
        end
        else begin
            
            if(message_counter < HASH_PIPELINE_STAGES && (prev_rx && !rx)) ready_to_recieve_message <= 0;
            if(message_counter == HASH_PIPELINE_STAGES && !message_valid) ready_to_recieve_message <= 1;
            
            if (byte_counter < BYTES_RECIEVING) begin
                state <= next_state;
                baud_sample_counter <= baud_sample_counter_next;
                data_bit_counter <= data_bit_counter_next;
                byte_counter <= byte_counter_next;
                byte_data <= byte_data_next;
    
                // Store byte when stop bit is reached (after full byte received)
                if (state == stop && baud_sample_counter == 7) begin
                    message[message_counter][BYTES_RECIEVING*8-1 - (byte_counter-1) * 8 -: 8] <= byte_data;
                end
            end else begin
                baud_sample_counter <= 0;
                data_bit_counter <= 0;
                byte_counter <= 0;
                byte_data <= 0;
                message[message_counter][7:0] <= byte_data;
                if(message_counter != HASH_PIPELINE_STAGES) begin
                    message_counter <= message_counter + 1;
                end
            end
        end
    end
    
    always @(posedge clk_100Mhz or posedge rst) begin
        if(rst) begin
            message_valid <= 0;            
            new_message <= 1;
        end
        else begin   
            if(message_counter == HASH_PIPELINE_STAGES) begin            
                if (byte_counter == 0 && state == stop) begin
                    if(!message_valid && new_message) begin //this is important so that message_valid doesn't assert twice in one baud_sample_clk.
                            message_valid <= 1;
                            new_message   <= 0;                 
                    end
                    else begin
                        if(message_ready) begin
                            message_valid <= 0;
                        end
                    end
                end 
                else begin                
                    message_valid <= 0;
                end
                
                if(!new_message & !rx) new_message <= 1;
            
            end
            
        end
    end

    always @(*) begin                
        case (state)
            idle: begin
                next_state = (prev_rx && !rx) ? start : idle;
                data_bit_counter_next = data_bit_counter;
                byte_counter_next = byte_counter;
                byte_data_next = byte_data;
                baud_sample_counter_next = (prev_rx && !rx) ? 0 : (baud_sample_counter + 1);
            end
            start: begin
                next_state = (baud_sample_counter == 15) ? data : start;
                data_bit_counter_next = 0;
                byte_counter_next = byte_counter;
                byte_data_next = byte_data;
                baud_sample_counter_next = baud_sample_counter + 1;
            end
            data: begin
                next_state = (baud_sample_counter == 15 && data_bit_counter == 7) ? stop : data;
                data_bit_counter_next =  data_bit_counter + ((baud_sample_counter == 15) ? 1 : 0);
                byte_counter_next = byte_counter + ((data_bit_counter == 7 && baud_sample_counter == 15) ? 1 : 0);
                byte_data_next = (baud_sample_counter == 7) ? {rx, byte_data[7:1]} : byte_data; // Shift in LSB first
                baud_sample_counter_next = baud_sample_counter + 1;
            end
            stop: begin
                next_state = (prev_rx && !rx) ? start : ((baud_sample_counter == 15) ? (byte_counter == 0 ? idle : start) : stop);
                data_bit_counter_next = data_bit_counter;
                byte_counter_next = byte_counter;
                byte_data_next = byte_data;
                baud_sample_counter_next = (prev_rx && !rx) ? 0 : (baud_sample_counter + 1);
            end
        endcase
    end

endmodule
