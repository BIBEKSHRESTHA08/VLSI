`timescale 1ns/1ps

module gray_counter_tb;

  // internal nets
  logic clk;
  logic rstn;
  logic enc;
  logic [3:0] out;

  // instantiate gray_counter
  gray_counter gc (
               .reset_n (rstn),
               .clk  (clk),
               .en_count  (enc),
               .gc_out  (out));

  // clock
  always #10 clk = ~clk;

  // setup tests
  initial begin
    {clk, rstn, enc} <= 0;

    $monitor ("T=%0t rstn=%0b clk=%0b enc=%0b output=0x%0h", $time, rstn, clk, enc, out);

    repeat(2) @ (posedge clk);  // repeat block of statements 2 times
    rstn <= 1;
    repeat(2) @ (posedge clk);
    enc <= 1;
    repeat(8) @ (posedge clk);
    enc <= 0;
    repeat(2) @ (posedge clk);
    enc <=1;
    repeat(12) @ (posedge clk);

    $finish;
  end
endmodule
