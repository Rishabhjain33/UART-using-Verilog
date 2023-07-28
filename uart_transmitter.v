`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2023 Rishabh Jain
// ///////////////////////////////////////////////////////////////////////////////
// Create Date: 28.07.2023 23:24:28
// Design Name: Uart Transmitter
// Module Name: uart_tx
// Project Name: UART using Verilog

// Description:     This transmitter is able to 
//                  transmit 8 bits of serial data, one start bit, one stop bit,
//                  and no parity bit.
//////////////////////////////////////////////////////////////////////////////////

module uart_tx (clk, data_loaded, data_byte, lineactive, uart_out, done);
  output lineactive, done;
  output reg uart_out;
  input clk, data_loaded;
  input [7:0] data_byte;

  parameter IDLE = 3'b000, START_BIT = 3'b001, DATA_BITS = 3'b010, STOP_BIT = 3'b011, RESET = 3'b100;
  parameter CLKS_PER_BIT   = 8;

  reg [2:0] tx_state = 0;
  reg [7:0] clock_counter = 0;
  reg [2:0] data_index = 0;
  reg [7:0] data_byte_reg = 0;
  reg done_reg = 0;
  reg lineactive_reg = 0;

  always @(posedge clk)
  begin
  case (tx_state)
IDLE : begin
uart_out<= 1'b1;         // Drive Line High for Idle
done_reg<= 1'b0;
clock_counter<= 0;
data_index<= 0;
         if (data_loaded == 1'b1)
         begin
lineactive_reg<= 1'b1;
data_byte_reg<= data_byte;
tx_state<= START_BIT;
          end
          else
tx_state<= IDLE;
          end 

  START_BIT : begin
uart_out<= 1'b0; // START BIT = 0
             // Wait CLKS_PER_BIT-1 clock cycles for start bit to finish
              if (clock_counter< CLKS_PER_BIT-1)
              begin
clock_counter<= clock_counter + 1;
tx_state<= START_BIT;
              end
              else
              begin
clock_counter<= 0;
tx_state<= DATA_BITS;
              end
              end 

  DATA_BITS : begin
uart_out<= data_byte_reg[data_index];
              if (clock_counter< CLKS_PER_BIT-1)
              begin
clock_counter<= clock_counter + 1;
tx_state<= DATA_BITS;
              end
              else
              begin
clock_counter<= 0;
                // Check if we have sent out all bits
                if (data_index< 7)
                  begin
data_index<= data_index + 1;
tx_state<= DATA_BITS;
                  end
                else
                  begin
data_index<= 0;
tx_state<= STOP_BIT;
                  end
              end
          end 

  STOP_BIT :  begin
uart_out<= 1'b1; //STOP BIT = 1
              if (clock_counter< CLKS_PER_BIT-1)
              begin
clock_counter<= clock_counter + 1;
tx_state<= STOP_BIT;
              end
              else
              begin
done_reg<= 1'b1;
clock_counter<= 0;
tx_state<= RESET;
lineactive_reg<= 1'b0;
              end
              end // case: STOP_BIT

RESET :
          begin
done_reg<= 1'b0;
tx_state<= IDLE;
          end

default :tx_state<= IDLE;

endcase
    end

  assign lineactive = lineactive_reg;
  assign done   = done_reg;

endmodule

