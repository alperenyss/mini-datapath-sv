module mini_datapath (
    input  logic        clk,
    input  logic        rst,
    input  logic [11:0] instr,
    output logic [3:0]  alu_result,
    output logic        zero
);

    localparam logic [1:0] OP_ADD  = 2'b00;
    localparam logic [1:0] OP_SUB  = 2'b01;
    localparam logic [1:0] OP_ADDI = 2'b10;

    logic [3:0] registers [0:3];
    logic [1:0] opcode;
    logic [1:0] rd;
    logic [1:0] rs1;
    logic [1:0] rs2;
    logic [3:0] immediate;
    logic [3:0] read_data1;
    logic [3:0] read_data2;
    logic [3:0] operand_b;
    logic        reg_write;

    assign opcode    = instr[11:10];
    assign rd        = instr[9:8];
    assign rs1       = instr[7:6];
    assign rs2       = instr[5:4];
    assign immediate = instr[3:0];

    always_comb begin
        read_data1 = registers[rs1];
        read_data2 = registers[rs2];
        operand_b  = read_data2;
        alu_result = 4'b0000;
        reg_write  = 1'b0;

        case (opcode)
            OP_ADD: begin
                alu_result = read_data1 + read_data2;
                reg_write  = 1'b1;
            end
            OP_SUB: begin
                alu_result = read_data1 - read_data2;
                reg_write  = 1'b1;
            end
            OP_ADDI: begin
                operand_b  = immediate;
                alu_result = read_data1 + operand_b;
                reg_write  = 1'b1;
            end
            default: begin
                alu_result = 4'b0000;
                reg_write  = 1'b0;
            end
        endcase
    end

    assign zero = (alu_result == 4'b0000);

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            for (int i = 0; i < 4; i = i + 1)
                registers[i] <= 4'b0000;
        end
        else if (reg_write) begin
            registers[rd] <= alu_result;
        end
    end

endmodule
