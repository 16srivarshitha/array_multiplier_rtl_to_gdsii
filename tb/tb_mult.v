`timescale 1ns/1ps
module tb_mult;
    reg        clk = 0, rst_n = 0;
    reg  [3:0] a = 0, b = 0;
    wire [7:0] p;
    integer    i, j, errors = 0;

    mult_array dut (.clk(clk), .rst_n(rst_n), .a(a), .b(b), .p(p));

    always #5 clk = ~clk;   // 10 ns period

    initial begin
        $dumpfile("mult.vcd");
        $dumpvars(0, tb_mult);

        repeat (2) @(posedge clk);   // hold reset for 2 cycles
        @(negedge clk) rst_n = 1;

        for (i = 0; i < 16; i = i + 1)
            for (j = 0; j < 16; j = j + 1) begin
                @(negedge clk) begin a = i; b = j; end
                repeat (2) @(posedge clk);   // 2-cycle latency
                #1;
                if (p !== i * j) begin
                    errors = errors + 1;
                    $display("MISMATCH: a=%0d b=%0d p=%0d expected=%0d", i, j, p, i * j);
                end
            end

        if (errors == 0) $display("PASS: 256 vectors checked, 0 errors");
        else             $display("FAIL: 256 vectors checked, %0d errors", errors);
        $finish;
    end
endmodule