module ondeamagicaacontece (
    input clk,
    input rst_n,
    input start,
    output pronto,
    output signed [15:0] resultado_mac
);

    // Sinais de Controle da FSM
    wire ctrl_calcular;
    wire ctrl_zerar;
    wire ctrl_somar_bias;
    wire [1:0] estado_monitor;

    // Sinais do Contador
    wire [9:0] addr_pixel;
    wire [6:0] addr_neuronio;
    wire fim_pixels;
    wire fim_neuronios;

    // Dados das Memórias
    wire signed [15:0] data_pixel;
    wire signed [15:0] data_peso;
    wire signed [15:0] data_bias;

    // --- LOGICA DE ATRASO (PIPELINE) ---
    // Atrasamos os sinais de controle para alinhar com a saída da memória
    reg pipe_calcular;
    reg pipe_zerar;
    reg pipe_somar_bias;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pipe_calcular   <= 0;
            pipe_zerar      <= 0;
            pipe_somar_bias <= 0;
        end else begin
            pipe_calcular   <= ctrl_calcular;
            pipe_zerar      <= ctrl_zerar;
            pipe_somar_bias <= ctrl_somar_bias;
        end
    end

    // --- INSTANCIAÇÃO DOS MÓDULOS ---

    // 1. Máquina de Estados (FSM)
    fsm_elm fsm_inst (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .fim_pixels(fim_pixels),
        .fim_neuronios(fim_neuronios),
        .calcular(ctrl_calcular),
        .zerar(ctrl_zerar),
        .somar_bias(ctrl_somar_bias),
        .pronto(pronto),
        .est(estado_monitor)
    );

    // 2. Contador de Endereços
    contador_elm cont_inst (
        .clk(clk),
        .rst_n(rst_n),
        .zerar(ctrl_zerar),
        .calcular(ctrl_calcular),
        .conta_pixel(addr_pixel),
        .conta_neuronio(addr_neuronio),
        .fim_pixels(fim_pixels),
        .fim_neuronios(fim_neuronios)
    );

    // 3. Memória de Pixels (Exemplo de BRAM/ROM)
    // Aqui você conectaria sua memória real. Exemplo:
    mem_pixels ram_pix (
        .clk(clk),
        .addr(addr_pixel),
        .data_out(data_pixel)
    );

    // 4. Memória de Pesos e Bias
    mem_pesos_bias mem_param (
        .clk(clk),
        .addr_p(addr_pixel),    // Endereço do peso muda com o pixel
        .addr_b(addr_neuronio), // Endereço do bias muda com o neurônio
        .peso_out(data_peso),
        .bias_out(data_bias)
    );

    // 5. Unidade MAC (Multiplication and Accumulation)
    // Nota: O MAC recebe os sinais "pipe_" que estão atrasados em 1 ciclo
    mac mac_inst (
        .clk(clk),
        .reset(!rst_n),
        .calcular(pipe_calcular), 
        .zerar(pipe_zerar),
        .pixel(data_pixel),
        .peso(data_peso),
        .bias(data_bias),
        .reset_soma(pipe_somar_bias),
        .saida(resultado_mac)
    );

endmodule