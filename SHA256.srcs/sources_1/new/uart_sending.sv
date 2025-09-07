//////`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/04/2025 02:05:43 PM
// Design Name: 
// Module Name: uart_sending
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


//////timescale 1ns / 1ps
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

module uart_sending #(
    parameter BYTES_SENDING = 32,
    parameter HASH_PIPELINE_STAGES
)(
    input clk_100Mhz,
    input baud_sample_clk,
    input rst,
    output reg tx,
    input [HASH_PIPELINE_STAGES-1:0][BYTES_SENDING*8 - 1:0] H,
    input hash_valid,
    output reg ready_to_receive_hash
);
    
    localparam [1:0] idle = 2'b00,
                     start = 2'b01,
                     data = 2'b10,
                     stop = 2'b11;
                     
    localparam BYTE_COUNTER_WIDTH = $clog2(BYTES_SENDING);
    localparam MESSAGE_COUNTER_WIDTH = $clog2(HASH_PIPELINE_STAGES);
    
    reg [1:0] state, next_state;
    reg [2:0] data_bit_counter, data_bit_counter_next;
    reg [BYTE_COUNTER_WIDTH:0] byte_counter, byte_counter_next;
    reg [HASH_PIPELINE_STAGES-1:0][BYTES_SENDING-1:0][7:0] H_input;
    reg tx_next;
    reg [MESSAGE_COUNTER_WIDTH:0] message_counter;

    always @(posedge baud_sample_clk or posedge rst) begin
        if(rst | message_counter == HASH_PIPELINE_STAGES) begin
            state <= 0;
            data_bit_counter <= 0;
            byte_counter <= BYTES_SENDING;
            tx <= 1;
            message_counter <= 0;
        end
        else begin

            if(ready_to_receive_hash & hash_valid) begin
                byte_counter <= BYTES_SENDING;
            end
            if (!ready_to_receive_hash) begin
                state <= next_state;
                data_bit_counter <= data_bit_counter_next;
                byte_counter <= byte_counter_next;
                tx <= tx_next;                                
            end else begin
                state <= idle;
                data_bit_counter <= 0;
                byte_counter <= BYTES_SENDING;
                tx <= 1;
                message_counter <= 0;
            end
        end
    end
    
    always @(posedge clk_100Mhz) begin
        if(rst) begin
            H_input <= 0;
            ready_to_receive_hash <= 1;
            
        end
        else begin
            if(ready_to_receive_hash & hash_valid) begin
                H_input <= H;
                ready_to_receive_hash <= 0;
            end
            
            if(message_counter == 3 && !ready_to_receive_hash && !hash_valid) ready_to_receive_hash <= 1; 
        end
    end

    always @(*) begin       
        
        case (state)
            idle: begin
                next_state = !ready_to_receive_hash ? start : idle;
                data_bit_counter_next = 0;
                byte_counter_next = byte_counter;
                tx_next = ready_to_receive_hash;
            end
            start: begin
                next_state = data;
                data_bit_counter_next = 0;
                byte_counter_next = byte_counter;
                tx_next = H_input[byte_counter-1][data_bit_counter];
            end
            data: begin            
                next_state = (data_bit_counter == 7) ? stop : data;
                data_bit_counter_next = data_bit_counter + 1;
                byte_counter_next = byte_counter;
                tx_next = (data_bit_counter == 7) ? 1 : H_input[byte_counter-1][data_bit_counter_next];
            end
            stop: begin                
                data_bit_counter_next = data_bit_counter;
                byte_counter_next = byte_counter - 1;
                next_state = (byte_counter_next != 0) ? start : idle;
                tx_next = (byte_counter_next != 0) ? 0 : 1; // tx is high if idle
                
                if(byte_counter_next == 0) begin            
                    message_counter <= (message_counter == 3) ? 0 : message_counter + 1;
                end
            end
        endcase
    end

endmodule