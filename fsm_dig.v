`timescale 1ns / 1ps

module fsm_dig #(
  parameter data_width = 8
)(
  input clk,
  input rst,
  input [data_width-1:0] d_in,
  input uart_busy,
  input fifo_empty,
  input tx_ready,

  output reg [data_width-1:0] d_out,
  output reg tx_start,
  output rd_en,
  output reg fsm_busy
);

  // State declarations
  localparam IDLE     = 2'b00,
             LOAD     = 2'b01,
             TRANSFER = 2'b10,
             WAIT     = 2'b11;

  reg [1:0] state, nxt_state;

  assign rd_en = (state == LOAD) ? 1'b1 : 1'b0;

  // State register
  always @(posedge clk) begin
    if (rst)
      state <= IDLE;
    else
      state <= nxt_state;
  end

  // Output and next-state logic
  always @(*) begin
    // Default values
    tx_start = 1'b0;
    fsm_busy = 1'b0;
    d_out    = d_out; // hold value by default
    nxt_state = state;

    case (state)
      IDLE: begin
        if (tx_ready)
          nxt_state = LOAD;
        else
          nxt_state = IDLE;
      end

      LOAD: begin
        fsm_busy = 1'b1;
        if (!fifo_empty)
          nxt_state = TRANSFER;
        else
          nxt_state = LOAD;
      end

      TRANSFER: begin
        d_out    = d_in;
        tx_start = 1'b1;
        nxt_state = WAIT;
      end

      WAIT: begin
        fsm_busy = 1'b1;
        if (!uart_busy)
          nxt_state = IDLE;
        else
          nxt_state = WAIT;
      end

      default: nxt_state = IDLE;
    endcase
  end

endmodule
