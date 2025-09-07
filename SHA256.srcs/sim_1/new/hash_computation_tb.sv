`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/04/2025 09:56:13 AM
// Design Name: 
// Module Name: hash_computation_tb
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


module hash_computation_tb#(
    parameter HASH_PIPELINE_STAGES = 3
);

    localparam MESSAGE_COUNTER_WIDTH = $clog2(HASH_PIPELINE_STAGES);
    wire W_ready, hash_valid;
    reg clk, rst;
    reg W_valid, hash_ready;
    reg [MESSAGE_COUNTER_WIDTH-1:0][64:1][31:0] W;
    wire [MESSAGE_COUNTER_WIDTH-1:0][8:1][31:0] H;
    reg  test;
    
    always #5 clk = ~clk;
    
    initial begin
        clk = 0;
        rst = 1;
        W_valid = 1;
        hash_ready = 1;
        repeat(2) @(posedge clk);
        rst = 0;
        
        repeat(10) test_tb;
        $finish;
    end
    
    task test_tb;
        set_W;
        check_hash;
    endtask
    
    task set_W;
        integer i;
        integer j;
        wait(W_ready);
        for(j = 0; j <= MESSAGE_COUNTER_WIDTH-1; j = j + 1) begin
            for (i = 1; i <= 64; i = i + 1) begin
                W[j][i] = $urandom();
            end
        end
    endtask
    
    task check_hash;
        integer i;
        wait(hash_valid);
        for(i = 1; i <= 8; i = i + 1) begin
            $display("H[%d] = %d", i, H[i]);
        end
    endtask
    
    hash_computation #(.HASH_PIPELINE_STAGES(3)) hash_computation(
         clk,
         rst,
         W_valid,
         W_ready,
         W,
         hash_valid,
         hash_ready,
         H);

endmodule


