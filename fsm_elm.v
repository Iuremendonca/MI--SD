module fsm_elm (
    input clk,
    input rst_n,
    input start,
    input fim_pixels,
    input fim_neuronios,
    output reg calcular,
    output reg zerar,
    output reg somar_bias,
    output reg pronto, 
    output reg [1:0] est // Saída para monitoramento
);

    // Estados
    localparam REPOUSO      = 2'd0,
               CALC_OCULTO  = 2'd1,
               ATIVACAO     = 2'd2,
               FIM          = 2'd3;

    reg [1:0] estado, proximo_estado;

    // 1. Registrador de estado
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            estado <= REPOUSO;
        else
            estado <= proximo_estado;
    end

    always @(*) begin
        proximo_estado = estado; 
        est            = estado;
        calcular       = 0;
        zerar          = 0;
        somar_bias     = 0;
        pronto         = 0;

        case (estado)
            REPOUSO: begin
					pronto = 0;
                if (start) begin
                    zerar = 1;
                    proximo_estado = CALC_OCULTO;
                end
            end

            CALC_OCULTO: begin
                if (fim_pixels) begin
                    somar_bias = 1;
                    proximo_estado = ATIVACAO;
                end else begin
                    calcular    = 1;
                    proximo_estado = CALC_OCULTO;
                end
            end

            ATIVACAO: begin
                if (fim_neuronios) begin
                    proximo_estado = FIM;
                end else begin
                    zerar       = 1;
                    proximo_estado = CALC_OCULTO;
                end
            end

            FIM: begin
                pronto = 1;
                proximo_estado = REPOUSO;
            end

            default: proximo_estado = REPOUSO;
        endcase
    end
    
    
endmodule