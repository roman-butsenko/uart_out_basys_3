`timescale 1ns / 10ps
//////////////////////////////////////////////////////////////////////////////////
// Company: hanging out co.
// Engineer: Roman Butsenko
// 
// Create Date: 10.08.2023 20:51:59
// Design Name: 
// Module Name: uart_out
// Project Name: UART out
// Target Devices: Basys 3
// Tool Versions: 
// Description: communicating between terra term console and FPGA
 
//////////////////////////////////////////////////////////////////////////////////


module uart_out(
    input CLK100MHZ,
    input button,
    output uart_tx,
    input uart_rx,
    output data_led
    );
    
    
    reg uart_tx_reg;
    assign uart_tx = uart_tx_reg;
    
    wire clk; //
    
    //clk generator
    clk_gen clk_gen_instance(
        .CLK100MHZ(CLK100MHZ),
        .clk(clk)
        );
            
    reg [3:0] bit_count = 0; //this register counts the bits in a transmitted byte
    
    `include "C:\Xilinx\projects\uart_out_basys_3\uart_out_2.srcs\sources_1\new\asci_characters.v"
    
    parameter 
    start_bit = 1'b0,
    stop_bit = 1'b1;
    
    reg [9:0] byte = 0;
    
    // each following package needs the bit to be different,
    // so the bit is formed dinamycally 
    
    // We're gonna write "Hello, world![new_line]", 14 characters in total
    
    reg [3:0] letter_count = 0; // this register has to store at least 14 states
                                // is stores the number of the current letter in the transmission
    
    // This is very important, in UART least significant bit
    // goes first (right after the start bit), so in order for
    // it to line up with the ASCII simbol instantiation, this
    // register is created a bit wierd
    
    always@(*) begin
        case(letter_count)
            4'd0: byte = {stop_bit, H_let, start_bit};
            4'd1: byte = {stop_bit, e_let, start_bit};
            4'd2: byte = {stop_bit, l_let, start_bit};
            4'd3: byte = {stop_bit, l_let, start_bit};
            4'd4: byte = {stop_bit, o_let, start_bit};
            4'd5: byte = {stop_bit, comma_let, start_bit};
            4'd6: byte = {stop_bit, space_let, start_bit};
            4'd7: byte = {stop_bit, w_let, start_bit};
            4'd8: byte = {stop_bit, o_let, start_bit};
            4'd9: byte = {stop_bit, r_let, start_bit};
            4'd10: byte = {stop_bit, l_let, start_bit};
            4'd11: byte = {stop_bit, d_let, start_bit};
            4'd12: byte = {stop_bit, exclam_let, start_bit};
            4'd13: byte = {stop_bit, new_line_let, start_bit};
            4'd14: byte = {stop_bit, return_let, start_bit};
            default:  byte = {stop_bit, x_let, start_bit};
        endcase
    end
    
    // logic, that describes the signal to start the transmission
    reg transmit = 0;
    wire button_deb;
    
    debounce button_debiunce(
        .sig(button),
        .clk(clk),
        .sig_debounced(button_deb)
        );
        
    always@(*) begin 
    if (button_deb) transmit <= 1;
    if (letter_count == 4'd14) transmit <= 0;
    
    //TX line control
    always @ (posedge clk) begin
        if (!transmit) begin
            uart_tx_reg <= 1;
            bit_count = 0;
        end
        else if (transmit) begin
            uart_tx_reg <= byte[bit_count];
            if (bit_count == 9) begin
                bit_count <= 0;
                
                if (letter_count == 4'd14) begin
                    letter_count = 4'd0;            // transmission is finished until
                                     // the button is pressed again (see button_debounce)
                end
                else letter_count = letter_count + 1; // switching to the next symbol
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

//Debouncing module
// if input is high, output will go high for 1 clk period
// without that module transmission is
// interrupted if the butten is let go off
module debounce(
    input sig,
    input clk,
    output sig_debounced
    );
    
    wire dff_1_out;
    wire dff_2_out;
    wire inv_dff_2_out;
    
    dff dff_deb_1 (.clk(clk), .d(sig), .q(dff_1_out));
    dff dff_deb_2 (.clk(clk), .d(dff_1_out), .q(dff_2_out));
    
    assign inv_dff_2_out = ~dff_2_out;
    
    assign sig_debounced = inv_dff_2_out & dff_1_out;
    
endmodule

// just a simple D-flipflop
module dff(
    input clk,
    input d,
    output reg q
    );
    
    always@ (posedge clk) q<=d;
    
endmodule