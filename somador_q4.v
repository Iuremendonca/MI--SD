module somador_q4 (
    input  signed [15:0] a,
    input  signed [15:0] b,
    output signed [15:0] soma
);
    assign soma = a + b;
endmodule