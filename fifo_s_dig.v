`timescale 1ns / 1ps

module fifo_dig#(
  parameter data_width = 8,
  parameter depth = 16)
  (
  input clk,
  input rst,
  input [data_width-1:0] d_in,
  input rd_en,
  input wr_en,
  input data_valid,
  output reg [data_width-1:0] d_out,
  output reg fifo_full,
  output reg fifo_empty
);

  reg [data_width-1:0] fifo[depth-1:0];
  reg [$clog2(depth)-1:0] rd_ptr, wr_ptr;
  reg [4:0] count;
  // Write logic
  always @(posedge clk) begin
    if (rst) begin
      wr_ptr <= 0;
     
    end else if (wr_en && !fifo_full && data_valid) begin
      fifo[wr_ptr] <= d_in;
      wr_ptr <= wr_ptr + 1;
    end
  end
  // Read logic
  always @(posedge clk) begin
    if (rst) begin
      d_out <= 0;
      rd_ptr <= 0;
    end else if (rd_en && !fifo_empty) begin
      d_out <= fifo[rd_ptr];
      rd_ptr <= rd_ptr + 1;
    end
  end

  // Count and status logic

  always @(posedge clk) begin
    if (rst) begin
      count <= 0;
      fifo_full <= 0;
      fifo_empty <= 1;

    end else begin
      case ({wr_en && data_valid && !fifo_full, rd_en && !fifo_empty})
        2'b10: count <= count + 1;
        2'b01: count <= count - 1;
        default: count <= count;
      endcase
      fifo_full <= (count == depth - 1);
      fifo_empty <= (count == 0);
    end
  end
endmodule