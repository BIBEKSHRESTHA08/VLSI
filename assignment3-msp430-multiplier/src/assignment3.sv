

/*****************************************************************
 MSP430 Hardware Multiplier Accelerator
 Modes: MPY (0x0130), MPYS (0x0132), MAC (0x0134), MACS (0x0136)
 OP2 write (0x0138) starts the operation
 Result: RESL (0x013A) = result[15:0], RESH (0x013C) = result[31:16]
 Multiply method: 16-cycle shift-and-add on magnitudes, sign fixed at end
*****************************************************************/

//================================================================
// Control unit: FSM  IDLE -> LOAD -> CALC (16 cycles) -> DONE
//================================================================

`timescale 1ns/1ps

module mult430_ctrl (
    input  logic clk,
    input  logic reset_n,
    input  logic start,      // pulse: OP2 was written
    output logic load,       // load magnitudes into datapath
    output logic step,       // do one shift-and-add step
    output logic finish,     // apply sign, update result
    output logic busy
);
    typedef enum logic [1:0] {IDLE = 2'b00, LOAD = 2'b01,
                              CALC = 2'b10, DONE = 2'b11} state_t;
    state_t state, next_state;
    logic [3:0] count;

    // state register
    always_ff @(posedge clk or negedge reset_n)
        if (!reset_n) state <= IDLE;
        else          state <= next_state;

    // step counter (counts 0..15 while in CALC)
    always_ff @(posedge clk or negedge reset_n)
        if (!reset_n)            count <= 4'd0;
        else if (state == CALC)  count <= count + 4'd1;
        else                     count <= 4'd0;

    // next-state logic
    always_comb begin
        next_state = state;
        case (state)
            IDLE: if (start)          next_state = LOAD;
            LOAD:                     next_state = CALC;
            CALC: if (count == 4'd15) next_state = DONE;
            DONE:                     next_state = IDLE;
        endcase
    end

    // outputs
    assign load   = (state == LOAD);
    assign step   = (state == CALC);
    assign finish = (state == DONE);
    assign busy   = (state != IDLE);
endmodule

//================================================================
// Datapath: magnitudes, shift-and-add, sign fix, accumulate
//================================================================
module mult430_dp (
    input  logic        clk,
    input  logic        reset_n,
    input  logic [15:0] op1,
    input  logic [15:0] op2,
    input  logic [1:0]  mode,     // mode[0] = signed, mode[1] = accumulate
    input  logic        load,
    input  logic        step,
    input  logic        finish,
    output logic [31:0] result
);
    logic [31:0] mcand;        // multiplicand, shifts left each step
    logic [15:0] mplier;       // multiplier, shifts right each step
    logic [31:0] product;      // running unsigned product
    logic        neg;          // final product must be negated
    logic [15:0] mag1, mag2;   // operand magnitudes
    logic [31:0] signed_prod;  // product with sign applied

    // magnitude = two's complement negate if signed mode and negative
    assign mag1 = (mode[0] && op1[15]) ? (~op1 + 16'd1) : op1;
    assign mag2 = (mode[0] && op2[15]) ? (~op2 + 16'd1) : op2;

    // apply sign at the end
    assign signed_prod = neg ? (~product + 32'd1) : product;

    always_ff @(posedge clk or negedge reset_n)
        if (!reset_n) begin
            mcand   <= 32'd0;
            mplier  <= 16'd0;
            product <= 32'd0;
            neg     <= 1'b0;
            result  <= 32'd0;
        end
        else if (load) begin
            mcand   <= {16'd0, mag1};
            mplier  <= mag2;
            product <= 32'd0;
            neg     <= mode[0] & (op1[15] ^ op2[15]);
        end
        else if (step) begin
            if (mplier[0]) product <= product + mcand;
            mcand  <= mcand << 1;
            mplier <= mplier >> 1;
        end
        else if (finish) begin
            if (mode[1]) result <= result + signed_prod;   // MAC / MACS
            else         result <= signed_prod;            // MPY / MPYS
        end
endmodule

//================================================================
// Top module: bus interface, registers, tri-state data bus
//================================================================
module mult430 (
    input  logic        clk,
    input  logic        reset_n,
    input  logic [15:0] addr,
    inout  wire  [15:0] data_bus,
    input  logic        write_enable,
    input  logic        read_enable,
    output logic        busy
);
    localparam logic [15:0] ADDR_MPY  = 16'h0130;
    localparam logic [15:0] ADDR_MPYS = 16'h0132;
    localparam logic [15:0] ADDR_MAC  = 16'h0134;
    localparam logic [15:0] ADDR_MACS = 16'h0136;
    localparam logic [15:0] ADDR_OP2  = 16'h0138;
    localparam logic [15:0] ADDR_RESL = 16'h013A;
    localparam logic [15:0] ADDR_RESH = 16'h013C;

    logic [15:0] op1, op2;
    logic [1:0]  mode;
    logic [31:0] result;
    logic        wr_ok, start, load, step, finish;
    logic        rd_en;
    logic [15:0] rd_data;

    // a write is accepted only when not busy and not reading
    assign wr_ok = write_enable && !read_enable && !busy;
    assign start = wr_ok && (addr == ADDR_OP2);

    // write registers
    always_ff @(posedge clk or negedge reset_n)
        if (!reset_n) begin
            op1  <= 16'd0;
            op2  <= 16'd0;
            mode <= 2'b00;
        end
        else if (wr_ok) begin
            case (addr)
                ADDR_MPY:  begin op1 <= data_bus; mode <= 2'b00; end
                ADDR_MPYS: begin op1 <= data_bus; mode <= 2'b01; end
                ADDR_MAC:  begin op1 <= data_bus; mode <= 2'b10; end
                ADDR_MACS: begin op1 <= data_bus; mode <= 2'b11; end
                ADDR_OP2:  op2 <= data_bus;
                default:   ;
            endcase
        end

    // read mux
    always_comb begin
        rd_en   = 1'b0;
        rd_data = 16'h0000;
        if (read_enable && !write_enable) begin
            if (addr == ADDR_RESL) begin
                rd_en   = 1'b1;
                rd_data = result[15:0];
            end
            else if (addr == ADDR_RESH) begin
                rd_en   = 1'b1;
                rd_data = result[31:16];
            end
        end
    end

    // tri-state driver: drive only on a valid read, else release the bus
    assign data_bus = rd_en ? rd_data : 16'bz;

    // control unit
    mult430_ctrl u_ctrl (
        .clk     (clk),
        .reset_n (reset_n),
        .start   (start),
        .load    (load),
        .step    (step),
        .finish  (finish),
        .busy    (busy)
    );

    // datapath
    mult430_dp u_dp (
        .clk     (clk),
        .reset_n (reset_n),
        .op1     (op1),
        .op2     (op2),
        .mode    (mode),
        .load    (load),
        .step    (step),
        .finish  (finish),
        .result  (result)
    );
endmodule