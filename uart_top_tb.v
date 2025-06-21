`timescale 1ns / 1ps

module tb_uart_packetizer_dig;

  // Inputs
  reg clk;
  reg rst;
  reg [7:0] data;
  reg data_valid;
  reg tx_ready;
  reg wr_en;

  // Outputs
  wire serial_out;
  wire fifo_full;
  wire tx_busy;

  // DUT Instance(Device Under Test)
  uart_packetizer_dig uut (
    .clk(clk),
    .rst(rst),
    .data_in(data),
    .data_valid(data_valid),
    .wr_en(wr_en),
    .tx_ready(tx_ready),
    .serial_out(serial_out),  
    .fifo_full(fifo_full),
    .tx_busy(tx_busy)
  );

  // Clock generation (50MHz)
  always #10 clk = ~clk;

  // Stimulus
  initial begin
    // Initialize signals
    clk = 0;
    rst = 1;
    data = 8'd0;
    data_valid = 0;
    tx_ready = 0;
    wr_en = 0;

    // Reset pulse
    #40;
    rst = 0;

    //  1st data byte
    #20;
    data = 8'b10101100; // Packet 1
    wr_en = 1;
    data_valid = 1;
    #20;
    data_valid = 0;

    // 2nd data byte
    #40;
    data = 8'b11001010; // Packet 2
    data_valid = 1;
    #20;
    data_valid = 0;
    wr_en = 0;

    // Simulating tx_ready from external UART receiver
    #20;
    tx_ready = 1;
   #2_000_000;

    $finish;
  end

endmodule
