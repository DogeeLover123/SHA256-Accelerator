`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/02/2025 06:06:58 PM
// Design Name: 
// Module Name: sigma_module_tb
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


module sigma_module_tb;

    reg clk_100MHz;
    reg [31:0] sigma_zero_in, sigma_one_in;
    wire [31:0] sigma_zero_out, sigma_one_out;
    
    reg [31:0] cap_sigma_zero_in, cap_sigma_one_in;
    wire [31:0] cap_sigma_zero_out, cap_sigma_one_out;
    
    always #5 clk_100MHz = ~clk_100MHz;
    
    initial begin
        clk_100MHz  = 0;
        repeat(100) set_sigma_values;
        $finish;
    end
    
    task set_sigma_values;
        @(posedge clk_100MHz);
        sigma_zero_in = $random;
        sigma_one_in = $random;
    endtask
    
    sigma_zero sigma_zero(sigma_zero_in, sigma_zero_out);
    sigma_one sigma_one(sigma_one_in, sigma_one_out);
    
    cap_sigma_zero cap_sigma_zero(sigma_zero_in, sigma_zero_out);
    cap_sigma_one cap_sigma_one(cap_sigma_one_in, cap_sigma_one_out);
    
endmodule
