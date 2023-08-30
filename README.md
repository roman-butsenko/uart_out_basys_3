# UART Out Basys 3 Project

Welcome to the **UART Out Basys 3 Project**! This project involves creating a UART transmitter and receiver on the Basys 3 FPGA development board. The repository contains Verilog code and explanations for both components.

## Introduction

Even though all the project files have "UART out" in their names, I decided to enhance the project midway by adding a receiver. This README will guide you through the code and concepts associated with the transmitter and receiver modules. The primary code can be found in [`uart_out_2.srcs/uart_out_2.v`](uart_out_2.srcs/uart_out_2.v).

## Clock Generation

The heart of the system is the `clk_gen` module. This module generates the clock signal required for both the transmitter and receiver to operate at a baud rate of 9600. If you are interested in this project, it might be worth your time, also checking out [this helpful resource](https://www.instructables.com/UART-Communication-on-Basys-3-FPGA-Dev-Board-Power/).

> **Note:** A baud rate of 9600 requires a clock signal period of 0.00010416 seconds, while our 100MHz signal, the one that is avaliable on Basys 3, has a period of 0.00000001 seconds. The author chose an inappropriate counter setup, counting to 10416. It is not suitable for that baudrate, since having a period of 0.00010416 seconds requires a change of state of clock signal once in 0.00005208 seconds or when the counter goes from 0 to 5207. Which is confirmed by the [source, which author referes to in step 7](https://itstillworks.com/12250910/how-to-create-a-simple-serial-uart-transmitter-in-verilog-hdl).

## Visualizing UART Output

To view UART output, the TeraTerm application is utilized. It supports various baud rates, even beyond the "standard" list. Additionally, an interesting feature is the answerback mechanism: when an inquiry symbol (UTF-8: 05, in hexadecimal) is transmitted, it sends user-defined symbols back to the transmitter, which aids in receiver testing.


## Visualizing UART Output

To view UART output, the TeraTerm application is utilized. It supports various baud rates, even beyond the "standard" list. Additionally, an interesting feature is the answerback mechanism: when an inquiry symbol (UTF-8: 05, in hexadecimal) is transmitted, it sends user-defined symbols back to the transmitter, which aids in receiver testing.

## Message Encoding

A clean codebase is maintained by offloading the UTF-8 message encoding into a separate file. This not only simplifies the primary code but also enhances readability.

## UART Transmission

The UART transmission from FPGA to computer is equipped with a debounce module. This ensures that the message isn't sent multiple times due to button holding or switch bouncing. Resources for understanding and implementing debouncing can be found [here](https://www.fpga4student.com/2017/04/simple-debouncing-verilog-code-for.html) and [here](https://circuitdigest.com/electronic-circuits/what-is-switch-bouncing-and-how-to-prevent-it-using-debounce-circuit).

## Message Formation

The message formation stage employs a multiplexer. In each iteration, it creates a distinct data byte, which is then transmitted through the UART.

## State Machines

Both the receiver and transmitter rely on state machines. These state machines are straightforward and have been designed using insights from HDLBits. This approach ensures robustness and minimizes potential bugs.

## Issues and Solutions

1. **LED 9 Not Illuminated:** LED 9, representing the stop bit, remains unlit. This suggests that both the start and stop bits are 0. Adjustments in the state machine are needed to receive a continuous stream of data.

2. **Initial Transmission Anomaly:** The initial transmission of "Hello, world!" after FPGA reprogramming begins with an "a" letter. To verify or refute this anomaly, an oscilloscope analysis is required.

Please note that this project is just my practice and not heavily optimised.

Feel free to explore the code, references, and concepts presented here. Your feedback and contributions are highly appreciated!

---

*Author: Roman Butsenko*  
*Date: 30.08.2023*  
*Contact: r.r.butsenko@gmail.com*
