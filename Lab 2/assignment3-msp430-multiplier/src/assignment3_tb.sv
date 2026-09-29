

/*****************************************************************
 Testbench for MSP430 Hardware Multiplier (mult430)
 The testbench acts as the CPU:
   cpu_write(addr, data)  -> drives data_bus, pulses write_enable
   cpu_read (addr, data)  -> releases data_bus, pulses read_enable
 A software model computes the expected result for every test.
*****************************************************************/

`timescale 1ns/1ps

module mult430_tb;

    // address map
    localparam logic [15:0] ADDR_MPY  = 16'h0130;
    localparam logic [15:0] ADDR_MPYS = 16'h0132;
    localparam logic [15:0] ADDR_MAC  = 16'h0134;
    localparam logic [15:0] ADDR_MACS = 16'h0136;
    localparam logic [15:0] ADDR_OP2  = 16'h0138;
    localparam logic [15:0] ADDR_RESL = 16'h013A;
    localparam logic [15:0] ADDR_RESH = 16'h013C;

    // DUT signals
    logic        clk;
    logic        reset_n;
    logic [15:0] addr;
    wire  [15:0] data_bus;
    logic        write_enable;
    logic        read_enable;
    logic        busy;

    // CPU side tri-state driver
    logic        tb_drive;
    logic [15:0] tb_data;
    assign data_bus = tb_drive ? tb_data : 16'bz;

    // bookkeeping
    logic [31:0] model;        // expected contents of the result register
    integer      errors;
    integer      tests;

    // DUT
    mult430 dut (
        .clk          (clk),
        .reset_n      (reset_n),
        .addr         (addr),
        .data_bus     (data_bus),
        .write_enable (write_enable),
        .read_enable  (read_enable),
        .busy         (busy)
    );

    // clock: 10 ns period
    always #5 clk = ~clk;

    //------------------------------------------------------------
    // CPU write: set signals on negedge, DUT captures on posedge
    //------------------------------------------------------------
    task automatic cpu_write(input logic [15:0] a, input logic [15:0] d);
        @(negedge clk);
        addr         = a;
        tb_data      = d;
        tb_drive     = 1'b1;
        write_enable = 1'b1;
        @(negedge clk);
        write_enable = 1'b0;
        tb_drive     = 1'b0;
    endtask

    //------------------------------------------------------------
    // CPU read: release bus, sample half a cycle later
    //------------------------------------------------------------
    task automatic cpu_read(input logic [15:0] a, output logic [15:0] d);
        @(negedge clk);
        addr        = a;
        tb_drive    = 1'b0;
        read_enable = 1'b1;
        @(posedge clk);
        d = data_bus;
        @(negedge clk);
        read_enable = 1'b0;
    endtask

    //------------------------------------------------------------
    // wait until the multiplier is no longer busy
    //------------------------------------------------------------
    task automatic wait_done();
        @(negedge clk);
        while (busy) @(negedge clk);
    endtask

    //------------------------------------------------------------
    // expected product for a given mode
    //------------------------------------------------------------
    function automatic logic [31:0] expected_product(input logic [1:0] m,
                                                     input logic [15:0] a,
                                                     input logic [15:0] b);
        logic signed [31:0] sa, sb;
        if (m[0]) begin
            sa = $signed(a);            // sign-extend to 32 bits
            sb = $signed(b);
            expected_product = sa * sb;
        end
        else
            expected_product = {16'd0, a} * {16'd0, b};
    endfunction

    //------------------------------------------------------------
    // run one operation and check RESL / RESH
    //------------------------------------------------------------
    task automatic run_op(input string name, input logic [15:0] mode_addr,
                          input logic [15:0] a, input logic [15:0] b);
        logic [1:0]  m;
        logic [15:0] lo, hi;
        logic [31:0] got;

        m = mode_addr[2:1];            // 0130->00, 0132->01, 0134->10, 0136->11
        if (m[1]) model = model + expected_product(m, a, b);
        else      model = expected_product(m, a, b);

        cpu_write(mode_addr, a);
        cpu_write(ADDR_OP2,  b);
        wait_done();
        cpu_read(ADDR_RESL, lo);
        cpu_read(ADDR_RESH, hi);
        got = {hi, lo};

        tests = tests + 1;
        if (got === model)
            $display("PASS  %-5s a=0x%h b=0x%h  result=0x%h", name, a, b, got);
        else begin
            $display("FAIL  %-5s a=0x%h b=0x%h  result=0x%h expected=0x%h",
                     name, a, b, got, model);
            errors = errors + 1;
        end
    endtask

    //------------------------------------------------------------
    // test sequence
    //------------------------------------------------------------
    initial begin
        clk          = 1'b0;
        reset_n      = 1'b0;
        addr         = 16'h0000;
        write_enable = 1'b0;
        read_enable  = 1'b0;
        tb_drive     = 1'b0;
        tb_data      = 16'h0000;
        model        = 32'd0;
        errors       = 0;
        tests        = 0;

        repeat (2) @(posedge clk);
        @(negedge clk);
        reset_n = 1'b1;

        $display("\n---- Unsigned multiply (MPY) ----");
        run_op("MPY",  ADDR_MPY,  16'd3,     16'd5);       // 15
        run_op("MPY",  ADDR_MPY,  16'hFFFF,  16'hFFFF);    // 0xFFFE0001
        run_op("MPY",  ADDR_MPY,  16'd1234,  16'd0);       // 0

        $display("\n---- Signed multiply (MPYS) ----");
        run_op("MPYS", ADDR_MPYS, 16'hFFFD,  16'd5);       // -3 * 5  = -15
        run_op("MPYS", ADDR_MPYS, 16'hFFFC,  16'hFFFA);    // -4 * -6 = 24
        run_op("MPYS", ADDR_MPYS, 16'h8000,  16'h8000);    // -32768^2 = 0x40000000
        run_op("MPYS", ADDR_MPYS, 16'd0,     16'hFFFF);    // clear result to 0

        $display("\n---- Unsigned multiply-accumulate (MAC) ----");
        run_op("MAC",  ADDR_MAC,  16'd2,     16'd10);      // 0 + 20  = 20
        run_op("MAC",  ADDR_MAC,  16'd4,     16'd10);      // 20 + 40 = 60

        $display("\n---- Signed multiply-accumulate (MACS) ----");
        run_op("MACS", ADDR_MACS, 16'hFFFE,  16'd10);      // 60 - 20 = 40
        run_op("MACS", ADDR_MACS, 16'hFFFB,  16'hFFFB);    // 40 + 25 = 65

        $display("\n---- Write while busy must be ignored ----");
        model = expected_product(2'b00, 16'd7, 16'd7);    // expect 49
        cpu_write(ADDR_MPY, 16'd7);
        cpu_write(ADDR_OP2, 16'd7);
        cpu_write(ADDR_MAC, 16'd100);                      // MAC write while busy -> must be ignored
        wait_done();
        begin
            logic [15:0] lo, hi;
            cpu_read(ADDR_RESL, lo);
            cpu_read(ADDR_RESH, hi);
            tests = tests + 1;
            if ({hi, lo} === model)
                $display("PASS  BUSY  result=0x%h", {hi, lo});
            else begin
                $display("FAIL  BUSY  result=0x%h expected=0x%h", {hi, lo}, model);
                errors = errors + 1;
            end
        end

        $display("\n---- Bus released when not reading ----");
        begin
            logic [15:0] v;
            // 1) idle: nobody should drive the bus
            @(negedge clk);
            tests = tests + 1;
            if (data_bus === 16'hzzzz)
                $display("PASS  BUSZ  idle            bus=0x%h", data_bus);
            else begin
                $display("FAIL  BUSZ  idle            bus=0x%h expected=zzzz", data_bus);
                errors = errors + 1;
            end
            // 2) read a non-result address: multiplier must not drive
            cpu_read(ADDR_OP2, v);
            tests = tests + 1;
            if (v === 16'hzzzz)
                $display("PASS  BUSZ  read 0x0138     bus=0x%h", v);
            else begin
                $display("FAIL  BUSZ  read 0x0138     bus=0x%h expected=zzzz", v);
                errors = errors + 1;
            end
        end
        
        $display("\n---- Mode switching ----");
        run_op("MAC",  ADDR_MAC,  16'd3,     16'd3);       // 49 + 9       = 0x0000003A
        run_op("MPYS", ADDR_MPYS, 16'hFFFF,  16'hFFFF);    // -1 * -1      = 0x00000001
        run_op("MPY",  ADDR_MPY,  16'hFFFF,  16'd2);       // 65535 * 2    = 0x0001FFFE
        run_op("MACS", ADDR_MACS, 16'hFFFF,  16'd3);       // 0x1FFFE - 3  = 0x0001FFFB
        run_op("MAC",  ADDR_MAC,  16'hFFFF,  16'd1);       // + 65535      = 0x0002FFFA
        
        $display("\n---- Accumulate overflow / wrap-around ----");
        run_op("MPY",  ADDR_MPY,  16'hFFFF,  16'hFFFF);    // 0xFFFE0001
        run_op("MAC",  ADDR_MAC,  16'hFFFF,  16'hFFFF);    // 0x1_FFFC0002 -> 0xFFFC0002
        run_op("MPYS", ADDR_MPYS, 16'd0,     16'd0);       // clear to 0
        run_op("MACS", ADDR_MACS, 16'hFFFF,  16'd1);       // 0 - 1 -> 0xFFFFFFFF
        run_op("MAC",  ADDR_MAC,  16'd1,     16'd1);       // 0xFFFFFFFF + 1 -> 0x00000000
        
        
        $display("\n---- Reset in the middle of an operation ----");
        run_op("MPY",  ADDR_MPY,  16'h1234,  16'h0010);    // non-zero first: 0x00012340
        begin
            logic [15:0] lo, hi;
            logic        busy_before;
            cpu_write(ADDR_MPY, 16'd7);
            cpu_write(ADDR_OP2, 16'd9);                    // start 7 * 9
            repeat (5) @(negedge clk);                     // let it run a few steps
            busy_before = busy;
            reset_n = 1'b0;                                // async reset, no clock edge
            #1;
            tests = tests + 1;
            if (busy_before === 1'b1 && busy === 1'b0)
                $display("PASS  RST   busy was 1, dropped to 0 immediately on reset");
            else begin
                $display("FAIL  RST   busy before=%b after=%b (expected 1 then 0)",
                         busy_before, busy);
                errors = errors + 1;
            end
            repeat (2) @(negedge clk);
            reset_n = 1'b1;                                // release reset
            model = 32'd0;                                 // reset clears the result
            cpu_read(ADDR_RESL, lo);
            cpu_read(ADDR_RESH, hi);
            tests = tests + 1;
            if ({hi, lo} === model)
                $display("PASS  RST   result cleared to 0x%h", {hi, lo});
            else begin
                $display("FAIL  RST   result=0x%h expected=0x%h", {hi, lo}, model);
                errors = errors + 1;
            end
        end
        run_op("MPY",  ADDR_MPY,  16'd6,     16'd7);       // works after reset: 0x0000002A
           
 
        $display("\n---- Random tests (200 operations, all modes, seed 430) ----");
        begin
            logic [15:0] ra, rb, lo, hi, maddr;
            logic [1:0]  m;
            integer      i, rand_err;
            integer      cnt_mpy, cnt_mpys, cnt_mac, cnt_macs;
            void'($urandom(430));                          // fixed seed -> repeatable
            rand_err = 0;
            cnt_mpy = 0; cnt_mpys = 0; cnt_mac = 0; cnt_macs = 0;
            for (i = 0; i < 200; i = i + 1) begin
                // random mode: 0130, 0132, 0134, 0136
                m     = $urandom_range(0, 3);
                maddr = ADDR_MPY + {13'd0, m, 1'b0};
                case (m)
                    2'b00: cnt_mpy  = cnt_mpy  + 1;
                    2'b01: cnt_mpys = cnt_mpys + 1;
                    2'b10: cnt_mac  = cnt_mac  + 1;
                    2'b11: cnt_macs = cnt_macs + 1;
                endcase
                // operands, biased toward edge values
                case ($urandom_range(0, 7))
                    0: ra = 16'h0000;  1: ra = 16'hFFFF;
                    2: ra = 16'h8000;  3: ra = 16'h7FFF;
                    default: ra = $urandom;
                endcase
                case ($urandom_range(0, 7))
                    0: rb = 16'h0000;  1: rb = 16'hFFFF;
                    2: rb = 16'h8000;  3: rb = 16'h7FFF;
                    default: rb = $urandom;
                endcase
                // expected value
                if (m[1]) model = model + expected_product(m, ra, rb);
                else      model = expected_product(m, ra, rb);
                // run on the DUT
                cpu_write(maddr,    ra);
                cpu_write(ADDR_OP2, rb);
                wait_done();
                cpu_read(ADDR_RESL, lo);
                cpu_read(ADDR_RESH, hi);
                tests = tests + 1;
                if ({hi, lo} !== model) begin
                    rand_err = rand_err + 1;
                    errors   = errors + 1;
                    if (rand_err <= 10)
                        $display("FAIL  RAND #%0d mode=%b a=0x%h b=0x%h result=0x%h expected=0x%h",
                                 i, m, ra, rb, {hi, lo}, model);
                end
            end
            $display("RAND  200 ops (MPY %0d, MPYS %0d, MAC %0d, MACS %0d): %0d failures",
                     cnt_mpy, cnt_mpys, cnt_mac, cnt_macs, rand_err);
        end
        
        
        
                        
        $display("\n==== %0d tests, %0d errors ====", tests, errors);
        if (errors == 0) $display("All tests completed successfully\n");
        $finish;
    end

    // waveform dump
    initial begin
        $dumpfile("assignment3.dump");
        $dumpvars(0, mult430_tb);
    end

endmodule