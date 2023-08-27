`timescale 1ns / 10ps

// 
//////////////////////////////////////////////////////////////////////////////////


module uart_out_simulation();

reg clk_100;


reg button;
initial begin
button = 0;

forever
#400000 button = 1;
end

initial begin  
    clk_100 = 1'b0;

    forever
    #5 clk_100 = ~clk_100;

end

uart_out uart_out(
    .CLK100MHZ(clk_100),
    .button(button)
    );

//$monitor(button);

    
endmodule
