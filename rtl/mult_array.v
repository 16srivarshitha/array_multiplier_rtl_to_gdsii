module mult_array (
    input        clk,
    input        rst_n,
    input  [3:0] a,
    input  [3:0] b,
    output reg [7:0] p
);
    reg [3:0] a_r, b_r;

    wire [3:0] pp [0:3];   // partial products
    wire [3:0] r  [0:3];   // bits passed down to the next row
    wire [3:0] s  [1:3];   // row sums
    wire [4:0] c  [1:3];   // row carries
    wire [7:0] p_next;

    // Partial products: pp[i][j] = a[j] & b[i]
    genvar i, j;
    generate
        for (i = 0; i < 4; i = i + 1) begin : pp_gen
            assign pp[i] = a_r & {4{b_r[i]}};
        end
    endgenerate

    // Row 0 has no adders
    assign r[0] = {1'b0, pp[0][3:1]};

    // Rows 1-3: four full adders each
    generate
        for (i = 1; i < 4; i = i + 1) begin : row
            assign c[i][0] = 1'b0;
            for (j = 0; j < 4; j = j + 1) begin : col
                full_adder fa (
                    .a   (pp[i][j]),
                    .b   (r[i-1][j]),
                    .cin (c[i][j]),
                    .sum (s[i][j]),
                    .cout(c[i][j+1])
                );
            end
            assign r[i] = {c[i][4], s[i][3:1]};
        end
    endgenerate

    assign p_next = {r[3], s[3][0], s[2][0], s[1][0], pp[0][0]};

    // Input and output registers
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            a_r <= 4'd0;
            b_r <= 4'd0;
            p   <= 8'd0;
        end else begin
            a_r <= a;
            b_r <= b;
            p   <= p_next;
        end
    end
endmodule