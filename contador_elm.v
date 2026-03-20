module contador_elm (
    input clk,
    input rst_n,
    input zerar,      //  reseta o contador de pixels para novo neurônio
    input calcular,   // enquanto calcular =1, ele incrementa
    output [9:0] conta_pixel,
    output [6:0] conta_neuronio,
    output fim_pixels,
    output fim_neuronios
);
    reg [9:0] p_reg;
    reg [6:0] n_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            p_reg <= 0;
            n_reg <= 0;
        end else if (zerar) begin
            p_reg <= 0;
        end else if (calcular) begin
            if (p_reg == 10'd783) begin 
                p_reg <= 0;
                n_reg <= n_reg + 1;
            end else begin
                p_reg <= p_reg + 1;
            end
        end
    end

    assign conta_pixel = p_reg;
    assign conta_neuronio = n_reg;
    assign fim_pixels = (p_reg == 10'd783);
    assign fim_neuronios = (n_reg == 7'd127);
endmodule