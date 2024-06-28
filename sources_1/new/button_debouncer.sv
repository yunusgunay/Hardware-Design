`timescale 1ns / 1ps
module button_debouncer(
    input logic clk, 
    input logic btn_in, 
    output logic btn_deb
);
    logic btn_prev = 0;
    integer counter;
    
    always @(posedge clk) begin
        counter <= counter + 1;
        if(counter == 100_000) begin
            counter <= 0;
        end
        
        if(btn_in && !btn_prev && counter == 0) begin
            btn_prev <= 1;
            btn_deb <= 1;
        end else if(!btn_in && btn_prev && counter == 0) begin
            btn_prev <= 0;
            btn_deb <= 0;
        end else begin
            btn_deb <= 0;
        end
            
    
    end

endmodule
