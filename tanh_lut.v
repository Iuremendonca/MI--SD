module tanh_lut(input wire signed[15:0] din, input rden, input clk, output wire signed[15:0] dout);

	wire e_negativo;
	wire [15:0] valor_absoluto;
	wire [15:0] dado;
	
	assign e_negativo = din[15];
	
	assign valor_absoluto = e_negativo ?(~din + 16'd1):(din);
	
	assign endereco_saturado = valor_absoluto > 16'd12280 ? 16'd12280: valor_absoluto;
	
	rom14x16 buscalut(.addres(endereco_saturado[13:0]), .rden(rden),.clock(clk),.q(dado));
	
	assign dout = e_negativo ? (~dado+16'd1): dado;
	
endmodule
	
	