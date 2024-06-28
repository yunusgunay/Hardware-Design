`timescale 1ns / 1ps
module main #(
    parameter DATA_BITS = 8,
    parameter CLK_FREQ = 100_000_000,
    parameter BAUD_RATE = 115_200 
)(
    input logic clk,
    input logic [DATA_BITS-1:0] data,
    input logic btnC, btnU, btnL, btnD, btnR,
    input logic stage4,
    input logic RX,
    
    output logic [DATA_BITS-1:0] leds,
    output logic [3:0] an,
    output logic [6:0] seg,    
    output logic TX,
    output logic [DATA_BITS-1:0] output_leds
);
    logic [DATA_BITS-1:0] tx;
    logic [DATA_BITS-1:0] rx;
    logic [15:0] seven_segment_in;
    logic [15:0] seven_segment_reg = 0;
    logic [DATA_BITS-1:0] TXBUF [0:3];
    logic [DATA_BITS-1:0] RXBUF [0:3];
    logic tx_start, tx_active;
    logic tx_done, rx_done;
    initial begin
        tx = 0;
        tx_start = 0;
        TXBUF = '{default:0};
        RXBUF = '{default:0};
    end

    transmitter #(
        .CLKS_PER_BIT(CLK_FREQ / BAUD_RATE),
        .DATA_BITS(DATA_BITS),
        .FIFO(4)
    ) uart_tx(
        .clk(clk),
        .btnD(btnD),
        .btnC(btnC),
        .data(data),
        .stage4(stage4),
        .tx(TX),
        .done(leds),
        .TXBUF(TXBUF)
    );

    receiver #(
        .CLKS_PER_BIT(CLK_FREQ / BAUD_RATE),
        .DATA_BITS(DATA_BITS),
        .FIFO(4)
    ) uart_rx(
        .clk(clk),
        .RX(RX),
        .data_available(rx_done),
        .RXBUF(RXBUF)
    );
    assign output_leds = RXBUF[3];

    seven_seg #(
        .DATA_BITS(DATA_BITS),
        .FIFO(4)
    ) s_seg(
        .clk(clk), 
        .btnL(btnL), 
        .btnR(btnR), 
        .btnU(btnU), 
        .TXBUF(TXBUF), 
        .RXBUF(RXBUF), 
        .seg(seg), 
        .an(an)
    );
    
endmodule
