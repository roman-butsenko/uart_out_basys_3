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
    
    `include "C:\Xilinx\projects\uart_out_basys_3\uart_out_2.srcs\sources_1\new\asci_characters.v"
    
    parameter 
    start_bit = 1'b0,
    stop_bit = 1'b1;
    
    // This is very important, in UART least significant bit
    // goes first (right after the start bit), so in order for
    // it to line up with the ASCII simbol instantiation, this
    // register is created a bit wierd
    
    reg [9:0] bit = 0;
    
    // each following package needs the bit to be different,
    // so the bit is formed dinamycally 
    
    // We're gonna write "Hello, world![new_line]", 14 characters in total
    
    reg [3:0] letter_count = 0; // this register has to store at least 14 states
    
    always@(*) begin
        case(letter_count)
            4'd0: bit = {stop_bit, H_let, start_bit};
            4'd1: bit = {stop_bit, e_let, start_bit};
            4'd2: bit = {stop_bit, l_let, start_bit};
            4'd3: bit = {stop_bit, l_let, start_bit};
            4'd4: bit = {stop_bit, o_let, start_bit};
            4'd5:  bit = {stop_bit, comma_let, start_bit};
            4'd6: bit = {stop_bit, space_let, start_bit};
            4'd7: bit = {stop_bit, w_let, start_bit};
            4'd8: bit = {stop_bit, o_let, start_bit};
            4'd9: bit = {stop_bit, r_let, start_bit};
            4'd10: bit = {stop_bit, l_let, start_bit};
            4'd11: bit = {stop_bit, d_let, start_bit};
            4'd12: bit = {stop_bit, exclam_let, start_bit};
            4'd13: bit = {stop_bit, new_line_let, start_bit};
            4'd14: bit = {stop_bit, return_let, start_bit};
            default:  bit = {stop_bit, exclam_let, start_bit};
        endcase
    end 
    
    always @ (posedge clk) begin
        if (!button) begin
            uart_tx_reg <= 1;
            bit_count = 0;
        end
        else begin
            uart_tx_reg <= bit[bit_count];
            if (bit_count == 9) begin
                bit_count <= 0;
                letter_count <= (letter_count == 4'd14) ? 4'd0 : letter_count + 1;
            end
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