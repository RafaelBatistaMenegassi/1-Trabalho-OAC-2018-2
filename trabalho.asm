############################################################
#
# Trabalho 1 de OAC
# 
# Processamento de Imagens BMP em Assembly
#
# 	Felipe 
#	Rafael Batista Menegassi, Matricula 14/0159355
#	Victor Santos Candeira, Matricula 17/0157636
#
############################################################

.data
BUF:		.space 1500000 		# Buffer util para a leitura da imagem (que ultrapassa a secao .data em 753718 bytes)
IMAGEM:		.asciiz "lena.bmp"  # string de nome do arquivo que sera lido, imagem 512x512 pixels
MENU:		.asciiz "----- Menu -----\n\nOpcao 1 - Imprimir Imagem na tela\nOpcao 2 - Efeito de Borramento\nOpcao 3 - Efeito de Extracao de Bordas\nOpcao 4 - Binarizacao por limiar\nOpcao 5 - Finalizar programa\n\nSelecione uma opcao: "
TELA:		.asciiz "\n\n--- Leitura de Imagem no BitMap Display ---\n\n"
BORRA:		.asciiz "\n\n--- Efeito de Borramento ---\n\n"
BORDAS:		.asciiz "\n\n--- Efeito de Extracao de Bordas ---\n\n"
BINARIO:	.asciiz "\n\n--- Efeito de Binarizacao por Limiar ---\n\n"

.text

.globl __MAIN

__MAIN:

	# menu
	la $a0, MENU
	li $v0, 4
	syscall

	# leitura de opcao digitada
	li $v0, 5
	syscall
	
	move $s2, $v0

	beq $s2, 1, SEL_TELA
	beq $s2, 2, SEL_BORRA
	beq $s2, 3, SEL_BORDAS
	beq $s2, 4, SEL_BINARIO
	beq $s2, 5, SEL_FIM
	
	j __MAIN
	
SEL_TELA:
	jal OP1_TELA
	j __MAIN
	
SEL_BORRA:
	jal OP2_BORRA
	j __MAIN
	
SEL_BORDAS:
	jal OP3_BORDAS
	j __MAIN
	
SEL_BINARIO:
	jal OP4_BINARIO
	j __MAIN
	
SEL_FIM:
	j OP5_FIM
	
# ----------------------------------------

OP1_TELA:

	la $a0, TELA
	li $v0, 4
	syscall

	# salva endereco de retorno em s3
	move $s3, $ra

	la $a0, IMAGEM	# string endereco/nome do arquivo
	li $a1, 0		# 0 para flag de leitura
	li $a2, 0		# modo ignorado
	li $v0, 13		# syscall de open file
	syscall			# retorna em $v0 o descritor do arquivo
	move $t0, $v0	# passa o descritor em $t0

	# Le o arquivos para a memoria VGA
	addi $sp, $sp, -786486	# decrementa o ponteiro para a pilha para receber a imagem, numero refere-se a qtd de bytes do arq 786432 + 54 do cabecalho = 786486
	move $a0, $t0			# $a0 recebe o descritor salvo em s0
	la $a1, ($sp)			# le a imagem na pilha -> 0x10008000
	li $a2, 786486
	li $v0, 14				# syscall de read file
	syscall					# retorna em $v0 o numero de bytes lidos
	move $s0, $v0

	# testar valor do arquivo lido
	# move $t0, $v0
	# li $v0, 1		# printar inteiro
	# add $a0, $t0, $zero
	# syscall

	# convencao para esse trecho: t5 armazena final da pilha, t4 armazena endereco a escrever na tela 
	# t2, t3 e t4 armazenam cores e $t5 armazena a word a printar na tela
	la $t5, 0x7FFFEFFC  # endereço do fim da pilha
	la $t4, ($gp) 		# endereco da tela bitmapDisplay -> 0x10008000
	addi $sp, $sp, 54 	# pula cabecalho da imagem de 54 bytes

LOOP_TELA:
	beq $t5, $sp, FIM_TELA # sinal de que chegou ao fim da pilha
	addi $t5, $t5, -3 # como arquivo bitmap eh escrito de "tras para frente", fazemos a leitura partindo do final para o inicio
	
	# lemos byte e byte do endereco de memoria, para agrupa-los nas cores corretas no formato mars (32 bits para um pixel) e carregar na tela
	lb $t0, 0($t5)
	lb $t1, 1($t5)
	lb $t2, 2($t5)
	sll $t1, $t1, 8  # deslocamento para ocupar posicao do verde
	sll $t2, $t2, 16 # deslocamento para ocupar posicao do vermelho
	li $t3, 0     	 # garante que nao tera lixo em t5
	or $t3, $t3, $t0
	or $t3, $t3, $t1
	or $t3, $t3, $t2
	sw $t3, 0($t4)   # printa na tela bitmap
	addi $t4, $t4, 4 # avança ponteiro da tela
	j LOOP_TELA

FIM_TELA:
	# Fecha o arquivo
	move $a0,$s0		# $a0 recebe o descritor
	li $v0,16			# syscall de close file
	syscall				# retorna se foi tudo Ok

	# recupera ra de s3 e retorna para a rotina anterior
	move $ra, $s3
	jr $ra

OP2_BORRA:

	la $a0, BORRA
	li $v0, 4
	syscall

	# salva endereco de retorno em s3
	move $s3, $ra

	# ...

	# recupera ra de s3 e retorna para a rotina anterior
	move $ra, $s3
	jr $ra

OP3_BORDAS:

	la $a0, BORDAS
	li $v0, 4
	syscall

	# salva endereco de retorno em s3
	move $s3, $ra

	# ...

	# recupera ra de s3 e retorna para a rotina anterior
	move $ra, $s3
	jr $ra

OP4_BINARIO:

	la $a0, BINARIO
	li $v0, 4
	syscall

	# salva endereco de retorno em s3
	move $s3, $ra

	# ...

	# recupera ra de s3 e retorna para a rotina anterior
	move $ra, $s3
	jr $ra

OP5_FIM:
	# encerra o programa
	li $v0, 10
	syscall

# ------------------------------------------------------------
