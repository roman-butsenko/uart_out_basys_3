`timescale 1ns / 10ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.08.2023 20:51:59
// Design Name: 
// Module Name: uart_out
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


module uart_out(
    input CLK100MHZ,
    output uart_tx,
    input uart_rx,
    input button,
    output data_led
    );
    
    
    
    reg uart_tx_reg;
    assign uart_tx = uart_tx_reg;
    
    wire clk;
    
    clk_gen clk_gen_instance(
        .CLK100MHZ(CLK100MHZ),
        .clk(clk)
        );
        
    reg [3:0] bit_count = 0;
    
    reg [10:0] bit = 11'b11011010000; // this should be utf-8 "h"
        
    always @ (posedge clk) begin
        if (!button) begin
            uart_tx_reg <= 1;
            bit_count = 0;
        end
        else begin
            uart_tx_reg <= bit[bit_count];
            if (bit_count == 10) bit_count <= 0;
            else bit_count <= bit_count + 1;          
        end
    end
    
    
    
endmodule


// Clock generator, corresponding to the baudrate of 9600
module clk_gen(
    input CLK100MHZ,
    output clk
    );
    
    reg clk_reg = 0;
    assign clk = clk_reg;
    
    reg [15:0] counter_reg = 0;
    
    always@(posedge CLK100MHZ) begin
        if (counter_reg == 5207) begin
            counter_reg <= 0;
            clk_reg <= ~clk_reg;
        end
        else begin
            counter_reg <= counter_reg + 1;
        end
    end
    
endmodule



// 