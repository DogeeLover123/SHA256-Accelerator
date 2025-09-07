`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/01/2025 09:19:06 AM
// Design Name: 
// Module Name: block_decomp
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
    
module block_decomp #(
    parameter NUM_WORDS = 64,
    parameter WORD_WIDTH = 32,
    parameter HASH_PIPELINE_STAGES
)(
    input clk_100Mhz,
    input rst,
    input message_valid,
    output reg message_ready,
    input [511:0] message,
    output reg W_valid,
    input W_ready,
    output reg [HASH_PIPELINE_STAGES-1:0][NUM_WORDS:1][WORD_WIDTH - 1:0] W
);
    localparam MESSAGE_COUNTER_WIDTH = $clog2(HASH_PIPELINE_STAGES);
    
    wire [NUM_WORDS:17][WORD_WIDTH - 1:0] W_sigma_one;
    wire [NUM_WORDS:17][WORD_WIDTH - 1:0] W_sigma_zero;
    reg [NUM_WORDS:1][WORD_WIDTH - 1:0] W_wire;
    
    reg [15:0] W_first_16;
    reg computing_block_decomp;
    reg [511:0] input_message;
    reg [3:0] counter;
    
    reg [MESSAGE_COUNTER_WIDTH:0] W_counter;
     
    always @(posedge clk_100Mhz) begin
        if(rst) begin
            message_ready <= 1;
            W_valid  <= 0;
            W <= 0;
            computing_block_decomp <= 0;
            W_first_16 <= 0;
            counter <= 0;
            input_message <= 0;
            W_counter <= 0;
        end
        else begin
            
            if(message_ready & message_valid) begin
                computing_block_decomp <= 1;
                message_ready <= 0;
                input_message <= message;
            end
                        
            if(W_valid & W_ready) begin
                message_ready <= 1;        
                computing_block_decomp <= 0;
                W_counter <= 0;
            end
            
            if(computing_block_decomp) begin
                counter <= counter + 1; 
                if(counter == 15) begin
                    W_counter <= W_counter + 1;                    
                    computing_block_decomp <= 0;
                    W[W_counter] <= W_wire;
                end
            end else begin
                message_ready <= W_counter != HASH_PIPELINE_STAGES; // If W_counter == HASH_PIPELINE_STAGES must wait for W_Valid and W_ready handshake we cannot recieve new messages
            end
            W_valid <= W_counter == HASH_PIPELINE_STAGES;
            
            
        end
    end
    
    generate 
        genvar k;
            for(k = 17; k <= 64; k = k + 1) begin : sigma_modules
                sigma_zero sigma_zero(W_wire[k - 15], W_sigma_zero[k]);
                sigma_one sigma_one(W_wire[k - 2], W_sigma_one[k]);
            end       
    endgenerate
        
    generate             
            //this method has an extremely long critical path, for indexes greater than 16+2 you can see the propogation delay increases exponentially because of the dependancies on previous 
            // index calculations. Not really a problem for under 16+2 because W[16:1] is done super simply, no calculation needed. not sure how I should pipeline this if needed..
            genvar i;
            for(i = 1; i <= 16; i = i+1) begin
                assign W_wire[i] = input_message[511 - WORD_WIDTH*(i-1): 512 - WORD_WIDTH * i];
            end
            
            genvar j;
            for(j = 17; j <= 64; j = j+1) begin
                assign W_wire[j] = W_sigma_one[j] + W[j - 7] + W_sigma_zero[j] + W[j - 16];
            end          
             
    endgenerate    
endmodule

