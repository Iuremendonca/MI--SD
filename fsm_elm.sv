module fsm_elm (
    input clk,
    input reset,
    input start,                // Vem do comando START [cite: 107]
    input fim_pixels,
    input fim_neuronios,
    output reg clk_en_mac,      // Habilita cálculo na MAC
    output reg limpa_mac,       // Zera o acumulador
    output reg somar_bias,      // Pulso para somar bias
    output reg inc_pixel,       // Incrementa contador de pixels
    output reg inc_neuronio,    // Incrementa contador de neurônios
    output reg pronto           // Sinal de DONE [cite: 110]
);
    typedef enum {REPOUSO, CALC_MAC, SOMA_BIAS, ATIVACAO, PROX_NEURONIO, FINAL} estado_t;
    estado_t estado_atual, prox_estado;

    always @(posedge clk or posedge reset) begin
        if (reset) estado_atual <= REPOUSO;
        else estado_atual <= prox_estado;
    end

    always @(*) begin
        // Valores padrão
        clk_en_mac = 0; limpa_mac = 0; somar_bias = 0;
        inc_pixel = 0; inc_neuronio = 0; pronto = 0;
        prox_estado = estado_atual;

        case (estado_atual)
            REPOUSO: begin
                if (start) begin 
                    limpa_mac = 1;
                    prox_estado = CALC_MAC;
                end
            end

            CALC_MAC: begin
                clk_en_mac = 1;
                inc_pixel = 1;
                if (fim_pixels) prox_estado = SOMA_BIAS;
            end

            SOMA_BIAS: begin
                somar_bias = 1;
                prox_estado = ATIVACAO;
            end

            ATIVACAO: begin
                // Tempo para a LUT processar e salvar na RAM [cite: 29]
                prox_estado = PROX_NEURONIO;
            end

            PROX_NEURONIO: begin
                if (fim_neuronios) prox_estado = FINAL;
                else begin
                    inc_neuronio = 1;
                    limpa_mac = 1; // Prepara para o próximo neurônio
                    prox_estado = CALC_MAC;
                end
            end

            FINAL: begin
                pronto = 1;
                if (!start) prox_estado = REPOUSO;
            end
        endcase
    end
endmodule