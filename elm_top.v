module elm_top (
    input clk,
    input rst_n,
    input start,
    input signed [15:0] pixel,
    input signed [15:0] peso,
    input signed [15:0] bias,
    output signed [15:0] saida,
    output pronto
);

    // sinais internos
    wire calcular, incrementar, zerar, somar_bias;
    wire fim_pixels, fim_neuronios;
    wire [9:0] conta_pixel;
    wire [6:0] conta_neuronio;
    wire signed [15:0] mac_out;

    // -------------------
    // FSM
    // -------------------
    fsm_elm fsm (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .fim_pixels(fim_pixels),
        .fim_neuronios(fim_neuronios),
        .calcular(calcular),
        .incrementar(incrementar),
        .zerar(zerar),
        .somar_bias(somar_bias),
        .pronto(pronto)
    );

    // -------------------
    // CONTADOR
    // -------------------
    contador_elm contador (
        .clk(clk),
        .reset(rst_n),
        .incrementa(incrementar),
        .conta_pixel(conta_pixel),
        .conta_neuronio(conta_neuronio),
        .fim_pixels(fim_pixels),
        .fim_neuronios(fim_neuronios)
    );

    // -------------------
    // MAC
    // -------------------
    mac mac_unit (
        .clk(clk),
        .reset(~rst_n),
        .calcular(calcular),
        .zerar(zerar),
        .pixel(pixel),
        .peso(peso),
        .bias(bias),
        .reset_soma(somar_bias),
        .saida(mac_out)
    );

    // -------------------
    // ATIVAÇÃO
    // -------------------
    ativacao ativ (
        .entrada(mac_out),
        .saida(saida)
    );

endmodule