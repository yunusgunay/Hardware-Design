`timescale 1ns / 1ps
module parity#(
    parameter DATA_BITS = 8
)(
    input logic [DATA_BITS-1:0] dataBits,
    input logic even_parity_bit,
    output logic parity_bit
);
    integer bit_index;
    integer bit_sum;
    
    always_comb begin
        bit_sum = 0;
        for (bit_index = 0; bit_index < DATA_BITS; bit_index++) begin
            bit_sum += dataBits[bit_index];
        end 
        parity_bit = even_parity_bit ? (bit_sum % 2 == 0) : (bit_sum % 2 != 0);
    end
endmodule