module multiplicador_q4 (
    input  signed [15:0] a,
    input  signed [15:0] b,
    output signed [15:0] s
);
    wire signed [31:0] aux;

    // multiplicação completa 
    assign aux = a * b;

    // ajuste do ponto fixo:
    assign s = aux[27:12];
endmodule