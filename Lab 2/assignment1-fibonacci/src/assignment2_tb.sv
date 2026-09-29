// Testbench for fibonacci generator (module assignment2.sv)
`timescale 1ns/10ps

module assignment2_tb;

    logic        clk;
    logic        rst;
    logic        en;
    logic [15:0] OUT;

    FIBO dut ( .clk(clk), .rst(rst), .en(en), .OUT(OUT) );

    initial clk = 0;
    always #1 clk = ~clk;

    initial begin
        $monitor("Time=%0t | rst=%b en=%b | OUT=%0d ", $time, rst, en, OUT);
        rst = 1;
        en  = 0;
        @(posedge clk);
        rst = 0;
        en  = 0;
        @(posedge clk);
        en  = 1;
        repeat(5) @(posedge clk);   // f(0) through f(4)
        en  = 0;
        @(posedge clk);             // hold steady
        en  = 1;
        repeat(2) @(posedge clk);   // f(5), f(6)
        rst = 1;
        en  = 0;
        @(posedge clk);
        $display("Test finished.");
        $finish;
    end

endmodule
