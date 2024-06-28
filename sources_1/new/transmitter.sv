`timescale 1ns / 1ps
module transmitter #(
    parameter DATA_BITS = 8,
    parameter CLKS_PER_BIT = 868, //100_000_000 / 152_000 
    parameter FIFO = 4
)(
    input logic clk,
    input logic btnD,
    input logic btnC,
    input logic [DATA_BITS-1:0] data,
    input logic stage4,
    output logic tx,
    output logic [DATA_BITS-1:0] done,
    output logic [DATA_BITS-1:0] TXBUF[0:FIFO-1]
);
    //States
    localparam IDLE_STATE = 3'b000;
    localparam START_STATE = 3'b001;
    localparam SEND_BIT_STATE = 3'b010;
    localparam PARITY_STATE = 3'b011;
    localparam STOP_STATE = 3'b100;
    localparam END_STATE = 3'b101;
    logic [2:0] state = IDLE_STATE;
    
    //Internal Signals
    integer counter = 0;
    integer bit_index = 0;
    logic active = 0;
    logic parity_bit;
    logic TX = 1;
    logic PARITY_TYPE = 0; 
    logic [DATA_BITS-1:0] txbuf[0:FIFO-1];
    integer fifo_index = 0;

    //Button Debouncing
    logic btnC_deb, btnD_deb;
    button_debouncer debouncer_C(clk, btnC, btnC_deb);
    button_debouncer debouncer_D(clk, btnD, btnD_deb);
    parity#(DATA_BITS) calcTX(txbuf[fifo_index], PARITY_TYPE, parity_bit);

    assign done = txbuf[FIFO-1];
    assign TXBUF = txbuf;
    assign tx = TX;
    
    always @(posedge clk) begin 
        case(state)
        IDLE_STATE: begin
            TX <= 1;
            if(btnD_deb) begin
                txbuf[3] <= data;
                for(int num = 0; num < FIFO - 1; num = num + 1) begin
                    txbuf[num] <= txbuf[num + 1];
                end
                state <= START_STATE;
            end else if(btnC_deb) begin
                active <= 1;
                TX <= 0;
                bit_index <= 0;
                counter <= 0;
                fifo_index <= 0;
                state <= SEND_BIT_STATE; 
            end
        end
        
        START_STATE: state <= IDLE_STATE;
        
        SEND_BIT_STATE: begin
            counter <= counter + 1;
            if(counter >= CLKS_PER_BIT) begin
                counter <= 0;
                
                if(bit_index >= DATA_BITS) begin
                    TX <= bit_index == DATA_BITS ? parity_bit : 1;
                    if(bit_index == DATA_BITS + 2) begin
                        if(fifo_index  < FIFO - 1) begin
                            fifo_index <= fifo_index + 1;
                            bit_index <= 0;
                            TX <= 0;
                        end else begin
                            active <= 0;
                            state <= IDLE_STATE;
                        end
                    end else begin
                        bit_index <= bit_index + 1;
                    end
                end 
                
                else begin
                    bit_index <= bit_index + 1;
                    TX <= txbuf[fifo_index][bit_index];
                end
            end
        end
        
        default: state <= IDLE_STATE; 
        
        endcase
    end

endmodule
