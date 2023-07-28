`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2022 Rishabh Jain
// ///////////////////////////////////////////////////////////////////////////////
// Create Date: 28.05.2022 23:24:28
// Design Name: Uart Receiver
// Module Name: uart_rx
// Project Name: UART using Verilog

// Description:     This receiver is able to 
//                  receive 8 bits of serial data, one start bit, one stop bit,
//                  and no parity bit.
//////////////////////////////////////////////////////////////////////////////////

module uart_rx (clk, data_in, data_recieved, databyte);
output [7:0] databyte;
output data_recieved;
input clk, data_in;

parameter IDLE = 3'b000, START_BIT = 3'b001, DATA_BITS = 3'b010, STOP_BIT = 3'b011, RESET = 3'b100;
parameter CLKS_PER_BIT   = 8;

reg Data_temp = 1'b1;
reg rx_Data   = 1'b1;

  reg [7:0] clock_counter = 0;
  reg [2:0] data_index = 0; //8 data bits 
  reg [7:0] databyte_reg = 0;
  reg data_recieved_reg = 0;
  reg [2:0] rx_state = 0;

  always @(posedge clk)
    begin
Data_temp<= data_in;
rx_Data<= Data_temp;
    end

  // RX FSM
  always @(posedge clk)
  begin
  case (rx_state)
IDLE : begin
data_recieved_reg<= 1'b0;
clock_counter<= 0;
data_index<= 0;
         if (rx_Data == 1'b0)  // Start bit detected
rx_state<= START_BIT;
         else
rx_state<= IDLE;
         end

  START_BIT :begin
             if (clock_counter == (CLKS_PER_BIT-1)/2)
             begin
             if (rx_Data == 1'b0)
              begin
clock_counter<= 0;  
rx_state<= DATA_BITS;
              end
             else
rx_state<= IDLE;
             end
             else
              begin
clock_counter<= clock_counter + 1;
rx_state<= START_BIT;
              end
             end          

        // Wait CLKS_PER_BIT-1 clock cycles to sample serial data
  DATA_BITS : begin
              if (clock_counter< CLKS_PER_BIT-1)
              begin
clock_counter<= clock_counter + 1;
rx_state<= DATA_BITS;
              end
              else
              begin
clock_counter<= 0;
databyte_reg[data_index] <= rx_Data;
                // Check if we have received all bits
              if (data_index< 7)
               begin
data_index<= data_index + 1;
rx_state<= DATA_BITS;
               end
              else
               begin
data_index<= 0;
rx_state<= STOP_BIT;
               end
              end
             end 

  STOP_BIT :begin
            // Wait CLKS_PER_BIT-1 clock cycles for Stop bit to finish
            if (clock_counter< CLKS_PER_BIT-1)
              begin
clock_counter<= clock_counter + 1;
rx_state<= STOP_BIT;
              end
            else
              begin
data_recieved_reg<= 1'b1;
clock_counter<= 0;
rx_state<= RESET;
              end
          end // case: STOP_BIT


        // Stay here 1 clock
RESET : begin
rx_state<= IDLE;
data_recieved_reg<= 1'b0;
          end


default :rx_state<= IDLE;

endcase
    end   

  assign data_recieved = data_recieved_reg;
  assign databyte = databyte_reg;   
endmodule // uart_rx
