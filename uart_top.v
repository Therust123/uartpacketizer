module uart_packetizer_dig #(
    parameter baud_rate = 9600,
    parameter clk_freq = 50_000_000,
    parameter data_width = 8,
    parameter depth = 16
)(
    input wire clk,
    input wire rst,
    input wire [data_width-1:0] data_in,
    input data_valid,
    input wire wr_en,
    input wire tx_ready,

    output wire serial_out,
    output wire fifo_full,
    output wire tx_busy
);

    // Internal signals
    wire [data_width-1:0] fifo_data_out;
    wire fifo_empty;
    wire rd_en;
    wire tx_start;
    wire uart_tx_busy;
    wire [data_width-1:0] tx_data;


    // FIFO instance
    fifo_dig #(
        .depth(depth),
        .data_width(data_width)
    ) fifo_inst (
        .d_in(data_in),
        .rst(rst),
        .clk(clk),
        .data_valid(data_valid),
        .rd_en(rd_en),
        .wr_en(wr_en),
        .d_out(fifo_data_out),
        .fifo_full(fifo_full),
        .fifo_empty(fifo_empty)
    );

    // FSM instance
    fsm_dig #(
        .data_width(data_width)
    ) fsm_inst (
        .clk(clk),
        .rst(rst),
        .fifo_empty(fifo_empty),
        .d_in(fifo_data_out),
        .tx_ready(tx_ready),
        .uart_busy(uart_tx_busy),
        .d_out(tx_data),
        .tx_start(tx_start),
        .fsm_busy(tx_busy),
        .rd_en(rd_en)
    );

    // UART transmitter instance
    uart_tx_dig #(
        .baud_rate(baud_rate),
        .clk_freq(clk_freq),
        .data_width(data_width)
    ) uart_inst (
        .clk(clk),
        .rst(rst),
        .tx_start(tx_start),
        .d_in(tx_data),
        .uart_busy(uart_tx_busy),
        .ser_data(serial_out)
    );

endmodule
