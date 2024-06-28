`timescale 1ns / 1ps
module receiver #(
    parameter DATA_BITS = 8,
    parameter CLKS_PER_BIT = 868, //100_000_000 / 152_000
    parameter FIFO = 4
)(
    input logic clk,
    input logic RX,
    output logic data_available,
    output logic [DATA_BITS-1:0] RXBUF[0:FIFO-1]
);
    //States
    localparam IDLE_STATE = 3'b000;
    localparam START_STATE = 3'b001;
    localparam GET_BIT_STATE = 3'b010;
    localparam PARITY_STATE = 3'b011;
    localparam STOP_STATE = 3'b100;
    localparam END_STATE = 3'b101;
    logic [2:0] state = IDLE_STATE;
    
    //Internal Signals
    integer counter = 0;
    integer bit_index = 0;
    logic PARITY_TYPE = 0;
    logic parity_bit;
    logic data_avail = 0;
    logic [DATA_BITS-1:0] rxbuf[0:FIFO-1];
    assign RXBUF = rxbuf;

    parity#(DATA_BITS) calcRX(rxbuf[3], PARITY_TYPE, parity_bit);
    
    logic rx_buffer = 1'b1; 
    logic rx = 1'b1;
    always @(posedge clk) begin
        rx_buffer <= RX;
        rx <= rx_buffer; 
    end
    
    always @(posedge clk) begin
        if(data_avail) begin
            counter <= counter + 1;
            if(counter >= CLKS_PER_BIT) begin
                if(bit_index < DATA_BITS) begin
                    rxbuf[3][bit_index] <= rx;
                end else if((bit_index == DATA_BITS) && (rx != parity_bit)) begin
                    data_avail <= 0;
                    rxbuf[3] <= '0;
                end
                
                else if(bit_index == DATA_BITS + 2) begin
                    data_avail <= 0;
                end
                
                counter <= 0;
                bit_index <= bit_index + 1;
            end 
        end
        
        else begin
            if(rx == 1'b0) begin
                data_avail <= 1;
                counter <= 0;
                bit_index <= 0;
                rxbuf[3] <= '0;
                for(int num = 0; num < FIFO - 1; num = num + 1) begin
                    rxbuf[num] <= rxbuf[num+1];
                end 
            end
        end
        
    end
    
endmodule 