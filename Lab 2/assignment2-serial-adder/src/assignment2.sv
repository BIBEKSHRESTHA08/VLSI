// ============================================================
// Datapath: registers, full adder, carry register, bit counter
// ============================================================

`timescale 1ns/10ps
module datapath (
    input  logic        clk,
    input  logic        rst_n,
    input  logic [7:0]  data_in,
    output logic [7:0]  data_out,
    input  logic        ld_a,
    input  logic        ld_b,
    input  logic        shift_en,
    input  logic        clr_carry,
    input  logic        set_carry,
    output logic        carry_out,
    output logic        done_count
);

    logic [7:0] reg_a, reg_b;
    logic       carry_reg;
    logic [3:0] bit_count;
    logic       sum, carry_next;

    // Single 1-bit full adder (combinational)
    assign sum        = reg_a[0] ^ reg_b[0] ^ carry_reg;
    assign carry_next = (reg_a[0] & reg_b[0]) | (reg_a[0] & carry_reg) | (reg_b[0] & carry_reg);

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            reg_a     <= 8'b0;
            reg_b     <= 8'b0;
            carry_reg <= 1'b0;
            bit_count <= 4'b0;
        end else begin
            if (ld_a)          reg_a <= data_in;
            else if (shift_en) reg_a <= {sum, reg_a[7:1]};

            if (ld_b)          reg_b <= data_in;
            else if (shift_en) reg_b <= {1'b0, reg_b[7:1]};

            if (clr_carry)       carry_reg <= 1'b0;
            else if (set_carry)  carry_reg <= 1'b1;
            else if (shift_en)   carry_reg <= carry_next;

            if (ld_b)          bit_count <= 4'b0;
            else if (shift_en) bit_count <= bit_count + 1'b1;
        end
    end

    assign data_out   = reg_a;
    assign carry_out  = carry_reg;
    assign done_count = (bit_count == 4'd8);

endmodule


// ============================================================
// Control unit: 3-state FSM (IDLE -> ADD -> DONE -> IDLE)
// ============================================================
module control_unit (
    input  logic clk,
    input  logic rst_n,
    input  logic ldA,
    input  logic ldB,
    input  logic done_count,
    output logic ld_a,
    output logic ld_b,
    output logic shift_en,
    output logic rdy
);

    typedef enum logic [1:0] {IDLE, ADD, DONE} state_t;
    state_t state, next_state;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) state <= IDLE;
        else        state <= next_state;
    end

    always_comb begin
        ld_a       = 1'b0;
        ld_b       = 1'b0;
        shift_en   = 1'b0;
        rdy        = 1'b0;
        next_state = state;

        case (state)
            IDLE: begin
                if (ldA) ld_a = 1'b1;
                if (ldB) begin
                    ld_b       = 1'b1;
                    next_state = ADD;
                end
            end

            ADD: begin
                if (!done_count) shift_en = 1'b1;
                if (done_count) next_state = DONE;
            end

            DONE: begin
                rdy        = 1'b1;
                next_state = IDLE;
            end

            default: next_state = IDLE;
        endcase
    end

endmodule


// ============================================================
// Top level: connects datapath + control unit, external interface
// ============================================================
module serial_adder (
    input  logic       clk,
    input  logic        rst_n,
    input  logic [7:0]  data_in,
    output logic [7:0]  data_out,
    input  logic        ldA,
    input  logic        ldB,
    input  logic        clrCarry,
    input  logic        setCarry,
    output logic        CarryOut,
    output logic        RDY
);

    logic ld_a, ld_b, shift_en, done_count;

    control_unit u_ctrl (
        .clk        (clk),
        .rst_n      (rst_n),
        .ldA        (ldA),
        .ldB        (ldB),
        .done_count (done_count),
        .ld_a       (ld_a),
        .ld_b       (ld_b),
        .shift_en   (shift_en),
        .rdy        (RDY)
    );

    datapath u_dp (
        .clk        (clk),
        .rst_n      (rst_n),
        .data_in    (data_in),
        .data_out   (data_out),
        .ld_a       (ld_a),
        .ld_b       (ld_b),
        .shift_en   (shift_en),
        .clr_carry  (clrCarry),
        .set_carry  (setCarry),
        .carry_out  (CarryOut),
        .done_count (done_count)
    );

endmodule