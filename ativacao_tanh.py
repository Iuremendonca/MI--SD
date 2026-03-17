import math
def gerar_mif_tanh():
    escala= 4096
    x_max=3

    profundidade = int(escala*x_max)
    largura_bits = 16

    nome_arquivo = "tanh_lut.mif"

    with open(nome_arquivo,"w") as f:
        f.write(f"DEPTH = {profundidade};\n")
        f.write(f"WIDTH = {largura_bits};\n")
        f.write("ADDRESS_RADIX = DEC;\n")
        f.write("DATA_RADIX = DEC;\n")
        f.write("CONTENT BEGIN\n")

        for endereco in range (profundidade):
            x_real = (endereco/escala)
            y_real = math.tanh(x_real)

            y_inteiro= round(y_real*escala)

            if(y_inteiro>escala):
                y_inteiro=escala

            f.write(f"{endereco} : {y_inteiro};\n")
        f.write("END;\n")


if __name__=="__main__":
    gerar_mif_tanh()