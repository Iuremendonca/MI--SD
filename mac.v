module mac(
    input clk,
    input reset,
    input calcular,        
    input zerar, 
    input signed [15:0] pixel,   
    input signed [15:0] peso,    
    input signed [15:0] bias,    
    input somar_bias,      
    output signed [15:0] saida 
);

    reg signed [31:0] acumulador;
    wire signed [31:0] produto;

    assign produto = pixel * peso;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            acumulador <= 32'd0;
        end else if (zerar) begin
            acumulador <= 32'd0;
        end else if (calcular) begin
            acumulador <= acumulador + produto;
        end else if (somar_bias) begin
            acumulador <= acumulador + (bias << 12);
        end
    end

    assign saida = acumulador[27:12]; 

endmodule