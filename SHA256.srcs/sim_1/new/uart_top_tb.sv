//`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////////
//// Company: 
//// Engineer: 
//// 
//// Create Date: 06/18/2025 08:55:28 PM
//// Design Name: 
//// Module Name: uart_top_tb
//// Project Name: 
//// Target Devices: 
//// Tool Versions: 
//// Description: 
//// 
//// Dependencies: 
//// 
//// Revision:
//// Revision 0.01 - File Created
//// Additional Comments:
//// 
////////////////////////////////////////////////////////////////////////////////////


//`timescale 1ns/1ps

//module uart_top_tb;

//    logic clk_100MHz;
//    logic rx;
//    logic baud_sample_clk;
//    wire dummy_out;  // match top-level output

//    // Instantiate the DUT (Design Under Test)
//    top dut (
//        .clk_100MHz(clk_100MHz),
//        .rx(rx),
//        .dummy_out(dummy_out)
//    );

//    // Clock generation: 100 MHz = 10ns period
//    always #5 clk_100MHz = ~clk_100MHz;

//   // Parameters for UART
//    parameter BAUD_RATE = 9600;
//    parameter CLK_FREQ = 100000000;
//    parameter BIT_PERIOD_NS = 1000000000 / BAUD_RATE;

//    task send_uart_byte(input [7:0] data);
//        integer i;
//        begin
//            // Start bit
//            rx = 0;
//            #(BIT_PERIOD_NS);

//            // Data bits (LSB first)
//            for (i = 0; i < 8; i = i + 1) begin
//                rx = data[i];
//                #(BIT_PERIOD_NS);
//            end

//            // Stop bit
//            rx = 1;
//            #(BIT_PERIOD_NS);

//            // Idle time between transmissions
//            #(BIT_PERIOD_NS * 2);
//        end
//    endtask

//    // Test scenario
//    initial begin
//        // Initialize
//        clk_100MHz = 0;
//        rx = 1;  // idle high

//        // Wait a few clocks
//        #(BIT_PERIOD_NS * 10);

//        // Send some bytes over UART
//        send_uart_byte(8'hAB);  
//        send_uart_byte(8'hCD);  
//        send_uart_byte(8'hEF);  // 01111110

//        // Wait some time
//        #(BIT_PERIOD_NS * 30);

//        $display("Simulation finished.");
//        $finish;
//    end

//endmodule

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/18/2025 08:55:28 PM
// Design Name: 
// Module Name: uart_top_tb
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


`timescale 1ns/1ps

module uart_top_tb;

    logic clk_100MHz;
    logic rx;
    logic baud_sample_clk;
    wire dummy_out;  // match top-level output

    
    top dut (
        .clk_100MHz(clk_100MHz),
        .rx(rx),
        .dummy_out(dummy_out)
    );

    
    always #5 clk_100MHz = ~clk_100MHz;

    parameter BAUD_RATE = 115200;
    parameter CLK_FREQ = 100000000;
    parameter BIT_PERIOD_NS = 1000000000 / BAUD_RATE;

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

//            // Idle time between transmissions
//            #(BIT_PERIOD_NS * 2);
        end
    endtask
    
    task send_data();
        begin
            // Send some bytes over UART
            repeat(8) begin
                send_uart_byte(8'h01);  
                send_uart_byte(8'h23);  
                send_uart_byte(8'h45);
                send_uart_byte(8'h67);  
                send_uart_byte(8'h89);  
                send_uart_byte(8'hab);
                send_uart_byte(8'hcd);  
                send_uart_byte(8'hef);  
            end
        end
    endtask
    

    // Test scenario
    initial begin
        // Initialize
        clk_100MHz = 0;
        rx = 1;  // idle high

        // Wait a few clocks
        #(BIT_PERIOD_NS * 10);

        send_data();

        // Wait some time
        #(BIT_PERIOD_NS * 30);

        $display("Simulation finished.");
        $finish;
    end

endmodule