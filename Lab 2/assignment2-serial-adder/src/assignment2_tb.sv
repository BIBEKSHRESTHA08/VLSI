`timescale 1ns/10ps

module assignment2_tb;

    logic       clk = 0;
    logic       rst_n;
    logic [7:0] data_in, data_out;
    logic       ldA, ldB, clrCarry, setCarry;
    logic       CarryOut, RDY;

    serial_adder dut (
        .clk      (clk),
        .rst_n    (rst_n),
        .data_in  (data_in),
        .data_out (data_out),
        .ldA      (ldA),
        .ldB      (ldB),
        .clrCarry (clrCarry),
        .setCarry (setCarry),
        .CarryOut (CarryOut),
        .RDY      (RDY)
    );

    always #5 clk = ~clk;   // 10ns clock period

    task automatic do_add(input [7:0] a, input [7:0] b);
        @(negedge clk);
        clrCarry = 1'b1;          // start each addition with carry cleared
        @(negedge clk);
        clrCarry = 1'b0;
        data_in = a; ldA = 1'b1;
        @(negedge clk);
        ldA = 1'b0;
        data_in = b; ldB = 1'b1;
        @(negedge clk);
        ldB = 1'b0;
        wait (RDY);
        @(negedge clk);
        $display("A=%0d  B=%0d  ->  result=%0d  carry=%0d", a, b, data_out, CarryOut);
    endtask

    task automatic do_add_cin(input [7:0] a, input [7:0] b);
        @(negedge clk);
        setCarry = 1'b1;          // carry-in = 1
        @(negedge clk);
        setCarry = 1'b0;
        data_in = a; ldA = 1'b1;
        @(negedge clk);
        ldA = 1'b0;
        data_in = b; ldB = 1'b1;
        @(negedge clk);
        ldB = 1'b0;
        wait (RDY);
        @(negedge clk);
        $display("A=%0d  B=%0d  +cin  ->  result=%0d  carry=%0d", a, b, data_out, CarryOut);
    endtask

    initial begin
        rst_n = 0; ldA = 0; ldB = 0; clrCarry = 0; setCarry = 0; data_in = 0;
        @(negedge clk);
        @(negedge clk);
        rst_n = 1;

        do_add(8'd3,   8'd5);      // expect result=8,  carry=0
        do_add(8'd200, 8'd100);    // expect result=44, carry=1 (300 wraps in 8 bits)
        do_add(8'd255, 8'd1);      // expect result=0,  carry=1
        do_add_cin(8'd3,   8'd5);  // expect result=9,  carry=0
        do_add_cin(8'd255, 8'd0);  // expect result=0,  carry=1

        #20 $finish;
    end

endmodule
