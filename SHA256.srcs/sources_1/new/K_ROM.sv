`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/17/2025 10:34:00 AM
// Design Name: 
// Module Name: K_ROM
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

/*
module K_ROM(
    input clk_100Mhz,
    input rst,
    input [7:0] addr,
    output reg [31:0] K_i
);
    
    localparam int K_DEPTH = 64;
    localparam int K_AW    = $clog2(K_DEPTH); 
    
    // Force BRAM inference
    (* rom_style = "block", ram_style = "block" *)
    reg [31:0] K_ROM [1:K_DEPTH];
    
    reg [31:0] K_i_pipe, K_i; // add an additional output register for higher fmax (so 2 cycle latency)
    
    initial begin
      $readmemh("K.mem", K_ROM);
    end
    
    always_ff @(posedge clk_100Mhz) begin
      if (rst) begin
        K_i_pipe   <= K_ROM[1];
        K_i        <= K_ROM[1];
      end else begin
        K_i_pipe   <= K_ROM[addr];   
        K_i        <= K_i_pipe; // 2-cycle latency
      end
    end
endmodule
*/
module K_ROM #(
    parameter int K_DEPTH = 64,
    parameter int DATA_W  = 32
) (
    input  logic                   clk,
    input  logic                   rst,
    input  logic [$clog2(K_DEPTH)-1:0] addr,   // 0..63
    output logic [DATA_W-1:0]      K_i        // 2-cycle latency
);

    // Force block RAM inference
    (* rom_style = "block", ram_style = "block" *)
    logic [DATA_W-1:0] K_mem [0:K_DEPTH-1];

    // Pipeline regs (addr_q -> K_pipe -> K_i)
    logic [$clog2(K_DEPTH)-1:0] addr_q;
    logic [DATA_W-1:0]          K_pipe;

    // Initialize from hex file: one 32-bit word per line, no "0x" prefix
    initial $readmemh("K.mem", K_mem);  // lines map to indices 0..K_DEPTH-1

    always_ff @(posedge clk) begin
        if (rst) begin
            addr_q <= '0;
            K_pipe <= '0;
            K_i    <= '0;
        end else begin
            // cycle 0: capture address
            addr_q <= addr;

            // cycle 1: synchronous read (registered inside this process)
            K_pipe <= K_mem[addr_q];

            // cycle 2: optional extra output register (your choice for Fmax)
            K_i <= K_pipe;
        end
    end

endmodule



