############################################
#	TESTES
# Trabalho 1 de OAC
# 
# Processamento de Imagens BMP em Assembly
############################################

.data
IMAGEM:		.asciiz "lena.bmp"  #string de nome do arquivo que sera lido

.text
INICIO:
# Preenche a tela de vermelho
	la $t1,0x10008000	# endereco inicial da Memoria VGA
	la $t2,0x10108000	# endereco final 
	la $t3,0x000000FF	# cor azul
LOOP:
 	beq $t1,$t2,FIM	# Se for o ultimo endereco entco sai do loop
	sw $t3,0($t1)		# escreve a word na memoria VGA
	addi $t1,$t1,4		# soma 4 ao endereco
	j LOOP			# fica no loop
	li $s0,0
FIM:
	# devolve o controle ao sistema operacional
	li $v0,10		# syscall de exit
	syscall
