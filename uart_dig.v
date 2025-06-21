`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 31.05.2025 12:40:47
// Design Name: 
// Module Name: uart_dig
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

module uart_tx_dig #(
  parameter clk_freq = 50000000,
  parameter baud_rate = 9600,
  parameter data_width = 8
)(
  input [data_width-1:0] d_in,
  input tx_start,
  input clk,
  input rst,
  output reg ser_data,
  output reg uart_busy
);
//internal signals 
  reg [9:0] data_frame;
  reg [3:0] bit_count;
  reg [13:0] clk_count;

  localparam clk_per_bit = clk_freq / baud_rate;

  always @(posedge clk) begin
    if (rst) begin
      ser_data   <= 1'b1;
      uart_busy  <= 1'b0;
      bit_count  <= 4'd0;
      clk_count  <= 14'd0;
    end
    else begin
      if (tx_start && !uart_busy) begin
        data_frame <= {1'b1, d_in, 1'b0}; // stop, data, start
        uart_busy  <= 1'b1;
        bit_count  <= 4'd0;
        clk_count  <= 14'd0;
      end
      else if (uart_busy) begin
        ser_data <= data_frame[bit_count];

        if (clk_count < clk_per_bit - 1) begin
          clk_count <= clk_count + 1;
        end else begin
          clk_count <= 0;
          bit_count <= bit_count + 1;

          if (bit_count == 4'd9) begin // last bit sent, move to idle
            uart_busy <= 1'b0;
            ser_data  <= 1'b1; // idle line
          end
        end
      end
    end
  end
endmodule

