`timescale 1ns / 1ps
module seven_seg#(
    parameter DATA_BITS = 8,
    parameter FIFO = 4
)(
    input logic clk, 
    input logic btnL, btnR, btnU,
    input logic [DATA_BITS-1:0] TXBUF[0:FIFO-1], 
    input logic [DATA_BITS-1:0] RXBUF[0:FIFO-1],
    output logic [6:0] seg, 
    output logic [3:0] an
);
    logic btnL_deb, btnR_deb, btnU_deb;
    button_debouncer deb_L(clk, btnL, btnL_deb);
    button_debouncer deb_R(clk, btnR, btnR_deb);
    button_debouncer deb_U(clk, btnU, btnU_deb);

    //Internal Signals
    logic [1:0] pageIndex = 0;
    logic RXorTX = 0;
    logic [DATA_BITS-1:0] active_byte;
    logic [1:0] enable;
    logic [FIFO-1:0] pageNo;
    integer digits = 0, duration = 0;
    
    always_ff @(posedge clk) begin
        if(btnL_deb) pageIndex <= (pageIndex == 0) ? 3 : pageIndex - 1;
        if(btnR_deb) pageIndex <= (pageIndex == 3) ? 0 : pageIndex + 1;
        if(btnU_deb) RXorTX <= ~RXorTX;
        
        duration <= duration + 1;
        if(duration == 99_999) begin
            duration <= 0;
            if(enable == 2'b11)
                enable = 0;
            else
                enable <= enable + 1;
        end
    end
    
    always_comb begin
        if(RXorTX) //True when isRX
            active_byte = RXBUF[pageIndex];
        else
            active_byte = TXBUF[pageIndex];
    end
    assign pageNo = {2'b00, pageIndex};
    
    always_comb begin
        case(enable)
            2'b00: an = 4'b1110;
            2'b01: an = 4'b1101;
            2'b10: an = 4'b1011;
            2'b11: an = 4'b0111;
        endcase
        
        case(enable)
            2'b00: digits = active_byte[3:0];
            2'b01: digits = active_byte[7:4];
            2'b10: digits = pageIndex;
            2'b11: digits = RXorTX ? 16 : 17;
        endcase
        seg = decode_to_segment(digits);
    end
    
    function logic [6:0] decode_to_segment(input logic [4:0] digit);
        case(digit)
            4'h0: decode_to_segment = 7'b1000000; // 0
            4'h1: decode_to_segment = 7'b1111001; // 1
            4'h2: decode_to_segment = 7'b0100100; // 2
            4'h3: decode_to_segment = 7'b0110000; // 3
            4'h4: decode_to_segment = 7'b0011001; // 4
            4'h5: decode_to_segment = 7'b0010010; // 5
            4'h6: decode_to_segment = 7'b0000010; // 6
            4'h7: decode_to_segment = 7'b1111000; // 7
            4'h8: decode_to_segment = 7'b0000000; // 8
            4'h9: decode_to_segment = 7'b0010000; // 9
            4'hA: decode_to_segment = 7'b0001000; // A
            4'hB: decode_to_segment = 7'b0000011; // b
            4'hC: decode_to_segment = 7'b1000110; // C
            4'hD: decode_to_segment = 7'b0100001; // d
            4'hE: decode_to_segment = 7'b0000110; // E
            4'hF: decode_to_segment = 7'b0001110; // F
            5'd16: decode_to_segment = 7'b0101111; // t
            5'd17: decode_to_segment = 7'b0000111; // r
            default: decode_to_segment = 7'b1111111; // invalid
        endcase
    endfunction
    
endmodule