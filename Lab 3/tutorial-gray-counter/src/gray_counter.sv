/****************************************************************
  MODULE: graycount, Sequential Circuit Example: gray_counter.sv

****************************************************************/
module gray_counter (reset_n, clk, en_count, gc_out);
        input logic reset_n;        // active-low RESET signal
        input logic clk;            // clock signal
        input logic en_count;       // counting is enabled when en_count = 1
        output logic [3:0] gc_out;  // current value of counter

        // Compute new gc_out value based on current gc_out value

  always_ff @(negedge reset_n or posedge clk)
    begin
      if (~reset_n)
         gc_out <= 0;
      else begin
        if (en_count) begin
           case (gc_out)
             4'b0000:  gc_out <= 4'b0001;
             4'b0001:  gc_out <= 4'b0011;
             4'b0011:  gc_out <= 4'b0010;
             4'b0010:  gc_out <= 4'b0110;
             4'b0110:  gc_out <= 4'b0111;
             4'b0111:  gc_out <= 4'b0101;
             4'b0101:  gc_out <= 4'b0100;
             4'b0100:  gc_out <= 4'b1100;
             4'b1100:  gc_out <= 4'b1101;
             4'b1101:  gc_out <= 4'b1111;
             4'b1111:  gc_out <= 4'b1110;
             4'b1110:  gc_out <= 4'b1010;
             4'b1010:  gc_out <= 4'b1011;
             4'b1011:  gc_out <= 4'b1001;
             4'b1001:  gc_out <= 4'b1000;
             4'b1000:  gc_out <= 4'b0000;
             default:  gc_out <= 4'b0000;
           endcase
        end // end of if (en_count)
      end // end of else
 end // end of module
endmodule
