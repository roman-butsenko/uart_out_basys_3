`timescale 1ns / 10ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Roman Butsenko
// 
// Create Date: 27.08.2023 20:51:59
// Design Name: 
// Module Name: uart_out
// Project Name: uart_out
// 
//////////////////////////////////////////////////////////////////////////////////


module uart_out(
    input CLK100MHZ,
    output uart_tx,
    input uart_rx,
    input button,
    output [15:0] LED
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
    // bits for UART
    start_bit = 1'b0,
    stop_bit = 1'b1,
    //variables for state machine
    TRANSMIT = 1'b1,
    IDLE = 1'b0;
    
    reg state = 0;
    reg next_state = 0;
    
    debounce trans_start(
        .sig(button),
        .clk(clk),
        .sig_debounced(button_sig_debounced));
        
     reg button_debounced = 0;                              // had to create this because
     always@(*)                                             // x state of button_debounce 
     button_debounced <= (button_sig_debounced) ? 1:0;      // in the beginning was screwing me over
        
    // This is very important, in UART least significant bit
    // goes first (right after the start bit), so in order for
    // it to line up with the ASCII simbol instantiation, this
    // register is created a bit wierd
    
    reg [9:0] byte = 0;
    
    // each following package needs the bit to be different,
    // so the bit is formed dinamycally 
    
    // We're gonna write "Hello, world![new_line]", 14 characters in total
    
    reg [4:0] letter_count = 0; // this register has to store at least 14 states
    
    always@(*) begin
        case(letter_count)
            5'd0: byte = {stop_bit, H_let, start_bit};
            5'd1: byte = {stop_bit, e_let, start_bit};
            5'd2: byte = {stop_bit, l_let, start_bit};
            5'd3: byte = {stop_bit, l_let, start_bit};
            5'd4: byte = {stop_bit, o_let, start_bit};
            5'd5: byte = {stop_bit, comma_let, start_bit};
            5'd6: byte = {stop_bit, space_let, start_bit};
            5'd7: byte = {stop_bit, w_let, start_bit};
            5'd8: byte = {stop_bit, o_let, start_bit};
            5'd9: byte = {stop_bit, r_let, start_bit};
            5'd10: byte = {stop_bit, l_let, start_bit};
            5'd11: byte = {stop_bit, d_let, start_bit};
            5'd12: byte = {stop_bit, exclam_let, start_bit};
            5'd13: byte = {stop_bit, new_line_let, start_bit};
            5'd14: byte = {stop_bit, return_let, start_bit};
            5'd15: byte = {stop_bit, enq_let, start_bit};
            // enq stands for enquiry and is a symnol that tera term
            // is looking for, after recieving it, it creates an
            //answerback that can be read to implement 
            //fullduplex UART
            
            default:  byte = {stop_bit, exclam_let, start_bit};
        endcase
    end 
    
    //____state machine
    always@(posedge clk) state <= next_state; 
    
    //state transition
    always@(*)
        case(state)
            TRANSMIT: begin
                next_state <= (letter_count == 5'd16) ? IDLE : TRANSMIT;
            end
            IDLE: begin
               next_state <= (button_debounced) ? TRANSMIT : IDLE;
            end
            default: uart_tx_reg = 1;
        endcase
 
    //state outputs
    always@(posedge clk)
        case(next_state)
            TRANSMIT: begin
                uart_tx_reg = byte[bit_count];
                if (bit_count == 9) begin
                        bit_count = 0;
                        letter_count = letter_count + 1;
                    end
                else bit_count = bit_count + 1;
            end
            IDLE: begin
                uart_tx_reg <= 1;
                bit_count <= 0;
                letter_count <= 0;
            end
        endcase
    //____state machine end      
    
    
    // UART recieve
    
    reg data_led_reg = 0;
    assign LED [15] = data_led_reg;
    // I checjed with led, I can notice the blink
    // if it recieves the same data as it transmits 
    
    //output will be monitored through LEDs
    reg [9:0] led_data;
    assign LED [9:0] = led_data [9:0]; 

    parameter
    RECEIVE = 1,
    IDLE_RX = 0;
    
    reg state_rx = IDLE_RX;
    reg next_state_rx = IDLE_RX;
    
    reg [3:0] receive_count = 0;
    reg [9:0] receive_data = 0;
    
    //idea for debugging: counting the amount of negative and positive impulses on rx
    
    //____state machine
    always@(posedge clk) state_rx <= next_state_rx; 
    
    //state transition
    always@(*)
        case(state_rx)
            RECEIVE: begin
               next_state_rx <= (receive_count == 4'd9) ? IDLE_RX : RECEIVE;
            end
            IDLE_RX: begin
               next_state_rx <= (uart_rx == 0) ? RECEIVE : IDLE_RX;
            end            
        endcase
        
    //state outputs
    always@(posedge clk)
        case(next_state_rx)
            RECEIVE: begin
                led_data [9:0] <= 10'b1000000001; // this is just to have visual indication of the stat
                receive_data[9:0] <= {uart_rx, receive_data[9:1]};
                receive_count = receive_count + 1;
                
            end
            IDLE_RX: begin
                receive_count <= 0;
                led_data [9:0] <= receive_data[9:0];
             
            end
        endcase      
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

// debouncing circuit
module debounce(
    input sig,
    input clk,
    output sig_debounced);
    
    wire d1_out;
    wire d2_out;
    wire n_d2_out;
    
    
    //wouldn't hurt adding another clk
    // divider here
    dff dff_1(sig, clk, d1_out);
    dff dff_2(d1_out, clk, d2_out);
    
    assign n_d2_out = ~d2_out;
    
    assign sig_debounced = d1_out & n_d2_out;  
endmodule

//Just a d-flop flop
module dff (input d, input clk, output reg q);
    always@(posedge clk) q<=d;
endmodule 