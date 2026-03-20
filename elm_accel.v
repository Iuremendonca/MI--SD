module elm_accel (
    input clk,
    input rst,
    // Interface com o HPS (ARM)
    input [31:0] instrucao,
    input hps_write,
    output [31:0] hps_readdata
);

    // ============================================================
    // Sinais Internos de Interconexão (Fios que ligam os módulos)
    // ============================================================
    wire fsm_busy, fsm_done, fsm_error;
    wire [3:0] elm_result;
    wire start_pulse;

    // Sinais vindos da ISA para as Memórias (Escrita - Porta A)
    wire [16:0] w_addr_isa;
    wire [9:0]  img_addr_isa;
    wire [6:0]  bias_addr_isa;
    wire [10:0] beta_addr_isa;
    wire [15:0] data_to_mem;
    wire wren_w, wren_img, wren_bias, wren_beta;

    // Sinais vindos da FSM de Cálculo para as Memórias (Leitura - Porta B)
    // Esses sinais serão controlados pelos seus colegas
    wire [16:0] w_addr_fsm;
    wire [9:0]  img_addr_fsm;
    wire [6:0]  bias_addr_fsm;
    wire [10:0] beta_addr_fsm;
    
    // Dados saindo das memórias para o MAC/Cálculo
    wire [15:0] q_weight, q_pixel, q_bias, q_beta;

    // ============================================================
    // 1. Instância da sua ISA (O seu módulo)
    // ============================================================
    isa_coprocessador u_isa (
        .clk(clk),
        .rst(rst),
        .instrucao(instrucao),
        .hps_write(hps_write),
        .hps_readdata(hps_readdata),
        .fsm_busy(fsm_busy),
        .fsm_done(fsm_done),
        .fsm_error(fsm_error),
        .elm_result(elm_result),
        .start_pulse(start_pulse),
        .w_addr(w_addr_isa),
        .img_addr(img_addr_isa),
        .bias_addr(bias_addr_isa),
        .beta_addr(beta_addr_isa),
        .data_to_mem(data_to_mem),
        .wren_w(wren_w),
        .wren_img(wren_img),
        .wren_bias(wren_bias),
        .wren_beta(wren_beta)
    );

    // ============================================================
    // 2. Instâncias das Memórias (Dual-Port RAMs)
    // Nota: Os nomes dos módulos (ram_2port_xxx) devem bater com o IP Catalog
    // ============================================================

    // RAM de Imagem (784 words x 16 bits)
    ram_2port_img u_img (
        .address_a (img_addr_isa), .data_a (data_to_mem), .wren_a (wren_img), .clock_a (clk), // Lado ISA
        .address_b (img_addr_fsm), .q_b (q_pixel), .clock_b (clk)                             // Lado FSM
    );

    // RAM de Pesos W (100.352 words x 16 bits)
    ram_2port_w u_w (
        .address_a (w_addr_isa), .data_a (data_to_mem), .wren_a (wren_w), .clock_a (clk),     // Lado ISA
        .address_b (w_addr_fsm), .q_b (q_weight), .clock_b (clk)                              // Lado FSM
    );

    // RAM de Bias (128 words x 16 bits)
    ram_2port_bias u_bias (
        .address_a (bias_addr_isa), .data_a (data_to_mem), .wren_a (wren_bias), .clock_a (clk), // Lado ISA
        .address_b (bias_addr_fsm), .q_b (q_bias), .clock_b (clk)                               // Lado FSM
    );

    // RAM de Pesos Beta (1280 words x 16 bits)
    ram_2port_beta u_beta (
        .address_a (beta_addr_isa), .data_a (data_to_mem), .wren_a (wren_beta), .clock_a (clk), // Lado ISA
        .address_b (beta_addr_fsm), .q_b (q_beta), .clock_b (clk)                               // Lado FSM
    );

    // ============================================================
    // 3. Módulo de Cálculo (FSM + MAC + Tanh + Argmax)
    // Aqui entra o trabalho dos seus colegas
    // ============================================================
    fsm_calculo_elm u_calculo (
        .clk(clk),
        .rst(rst),
        .start(start_pulse),      // Recebe o sinal de início da sua ISA
        .busy(fsm_busy),          // Devolve o status para sua ISA
        .done(fsm_done),          // Devolve o status para sua ISA
        .error(fsm_error),        // Devolve o status para sua ISA
        .result(elm_result),      // Devolve o dígito 0-9 para sua ISA

        // Interface de leitura das memórias
        .addr_img(img_addr_fsm),   .data_img(q_pixel),
        .addr_w(w_addr_fsm),       .data_w(q_weight),
        .addr_bias(bias_addr_fsm), .data_bias(q_bias),
        .addr_beta(beta_addr_fsm), .data_beta(q_beta)
    );

endmodule