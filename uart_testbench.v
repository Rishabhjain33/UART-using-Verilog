`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2022 Rishabh Jain
// ///////////////////////////////////////////////////////////////////////////////
// Create Date: 28.05.2022 23:24:28
// Design Name: Uart Testbench
// Module Name: uart_tb
// Project Name: UART using Verilog

// Description:     This testbench is used to verify and  
//                  validate the functionality of a uart transmitter
//                  and receiver 
//////////////////////////////////////////////////////////////////////////////////

`include "uart_tx.v"
`include "uart_rx.v"

module uart_tb ();

  // Input Clock: 10 MHz clock
  // Baud Rate: 115200
  // 10000000 / 115200 = 87 Clocks Per character.
  // Bits: 10 {1 start bit, 8 data bits, 1 stop bit}
  // Clocks per bit: 87/10 = 8.7 ~ 8
  parameter CLOCKPERIOD = 100;
  parameter CLKS_PER_BIT = 8;
  parameter BIT_PERIOD = 860;

  reg clk = 0;
  reg data_loaded = 0;
  wire Done;
  reg [7:0] tx_Databyte = 0;
  reg data_in = 1;
  wire [7:0] rx_Databyte;
  wire lineactive, uart_out;
  wire data_recieved; 

  // writes data byte for rx input
  task UART_WRITE_BYTE;
    input [7:0] i_Data;
    integer i;
    begin

      // Start Bit
data_in<= 1'b0;
      #(BIT_PERIOD);


      // Data Byte
      for (i=0; i<8; i=i+1)
        begin
data_in<= i_Data[i];
          #(BIT_PERIOD);
        end

      // Stop Bit
data_in<= 1'b1;
      #(BIT_PERIOD);
     end
endtask


uart2_r(clk, data_in, data_recieved, rx_Databyte);

uart2(clk, data_loaded, tx_Databyte, lineactive, uart_out, Done);


  always
    #(CLOCKPERIOD/2) clk<= ~clk;

  initial
    begin

      // Testing TX
@(posedge clk);
@(posedge clk);
data_loaded<= 1'b1;
tx_Databyte<= 8'hAA;
@(posedge clk);
data_loaded<= 1'b0;
@(posedge Done);

      // Testing RX
@(posedge clk);
      UART_WRITE_BYTE(8'h3F);
@(posedge clk);

      if (rx_Databyte == 8'h3F)
        $display("Correct Byte Received");
      else
        $display("Incorrect Byte Received");

    end
   initial #90000000 $finish;
initial begin
    $dumpfile("wave.vcd");  
    $dumpvars(0, uart_tb); 
  end

  
endmodule
