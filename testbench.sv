module tb;

    logic        clk;
    logic        rst;
    logic [11:0] instr;
    logic [3:0]  alu_result;
    logic        zero;

    mini_datapath dut (
        .clk(clk),
        .rst(rst),
        .instr(instr),
        .alu_result(alu_result),
        .zero(zero)
    );

    initial clk = 1'b0;
    always #5 clk = ~clk;

    task automatic run_instruction(
        input logic [11:0] command,
        input logic [3:0] expected_result,
        input logic expected_zero
    );
        begin
            instr = command;
            #1;
            if (alu_result !== expected_result || zero !== expected_zero) begin
                $display("FAIL: instr=%b result=%b zero=%b expected_result=%b expected_zero=%b",
                         instr, alu_result, zero, expected_result, expected_zero);
                $fatal(1);
            end
            else begin
                $display("PASS: instr=%b result=%0d zero=%b",
                         instr, alu_result, zero);
            end

            @(posedge clk);
            #1;
        end
    endtask

    initial begin
        rst   = 1'b1;
        instr = 12'b11_00_00_00_0000;
        #2;
        rst = 1'b0;
        @(negedge clk);

        // ADDI R0, R0, 5: R0 = 0 + 5 = 5
        run_instruction(12'b10_00_00_00_0101, 4'd5, 1'b0);

        // ADDI R1, R0, 3: R1 = 5 + 3 = 8
        run_instruction(12'b10_01_00_00_0011, 4'd8, 1'b0);

        // ADD R2, R0, R1: R2 = 5 + 8 = 13
        run_instruction(12'b00_10_00_01_0000, 4'd13, 1'b0);

        // SUB R3, R2, R1: reads back R2, so result must be 13 - 8 = 5
        run_instruction(12'b01_11_10_01_0000, 4'd5, 1'b0);

        // SUB R3, R1, R1: result is zero
        run_instruction(12'b01_11_01_01_0000, 4'd0, 1'b1);

        $display("PASS: all mini-datapath checks completed");
        $finish;
    end

endmodule
