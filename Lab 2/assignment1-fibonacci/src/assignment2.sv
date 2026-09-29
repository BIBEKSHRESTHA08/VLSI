`timescale 1ns/10ps

module FIBO ( input  logic        clk,
              input  logic        rst,
              input  logic        en,
              output logic [15:0] OUT );

    logic [15:0] previous;
    logic [15:0] current;

    always_ff @(posedge rst, posedge clk)
    begin
        if (rst) begin
            OUT      <= 16'b0;
            current  <= 16'b0;
            previous <= 16'b1;
        end
        else if (en) begin
            previous <= current;
            current  <= current + previous;
            OUT      <= current + previous;
        end
    end

endmodule
