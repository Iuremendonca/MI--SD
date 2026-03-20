module ativacao ( //so para funs de ligar as camadas, ainda preciso fazer essa camada
	input signed [15:0] entrada, 
   output signed [15:0] saida
	);
	
	assign saida  =  entrada [15:0];
	
endmodule