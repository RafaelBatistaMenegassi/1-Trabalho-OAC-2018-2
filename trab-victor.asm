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
TELA:		.asciiz "\n\n--- Leitura de Imagem no BitMap Display ---\n"
BORRA:		.asciiz "\n\n--- Efeito de Borramento ---\n"
BORDAS:		.asciiz "\n\n--- Efeito de Extracao de Bordas ---\n"
BINARIO:	.asciiz "\n\n--- Efeito de Binarizacao por Limiar ---\n"
VER_MENU:	.asciiz "\n\nERRO: favor digitar uma das opcoes numericas indicadas\n"
FIM_PILHA:	.word	0x7FFFEFFC

.text
	#convencoes para programa: $s0 armazena a opcao digitada, $s1 armazena o endereco de retorno ao menu, 
	#$s7 armazena o numero de bytes lidos para fins de verificacao
	
	#Abre arquivo imagem
	la $a0, IMAGEM	# string endereco/nome do arquivo
	li $a1, 0		# 0 para flag de leitura
	li $a2, 0		# modo ignorado
	li $v0, 13		# syscall de open file
	syscall			# retorna em $v0 o descritor do arquivo
	move $t0, $v0	# passa o descritor em $t0
	
	#Le o arquivo para a memoria VGA
	addi $sp, $sp, -786486	# decrementa o ponteiro para a pilha para receber a imagem, numero refere-se a qtd de bytes do arq 786432 + 54 do cabecalho = 786486
	move $a0, $t0			# $a0 recebe o descritor salvo em s0
	la $a1, ($sp)			# le a imagem na pilha -> 0x10008000
	li $a2, 786486
	li $v0, 14				# syscall de read file
	syscall					# retorna em $v0 o numero de bytes lidos
	move $s7, $v0			# salva o numero de bytes lidos em $s7 para fins de verificacao
	addi $sp, $sp, 54 	# pula cabecalho da imagem de 54 bytes
	# Fecha o arquivo
	move $a0,$s7		# $a0 recebe o descritor
	li $v0,16			# syscall de close file
	syscall				# retorna se foi tudo Ok

.globl __MAIN

__MAIN:
	# menu
	la $a0, MENU
	li $v0, 4
	syscall

	# leitura de opcao digitada
	li $v0, 5
	syscall
	
	move $s0, $v0
	beq $s0, 1, SEL_TELA
	beq $s0, 2, SEL_BORRA
	beq $s0, 3, SEL_BORDAS
	beq $s0, 4, SEL_BINARIO
	beq $s0, 5, SEL_FIM
	# mensagem em caso de usuario digitar uma opcao fora das indicadas
	la $a0, VER_MENU
	li $v0, 4
	syscall
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
	
# ---------------------------------------------------------------------------
OP1_TELA:
	move $s1, $ra		# salva endereco de retorno em s1
	jal PRINTA_PRETO	#funcao para primeiramente printar toda a tela de preto novamente
	# convencao para esse trecho: t5 armazena final da pilha, t4 armazena endereco da tela que avanca sequencialmente
	# t0, t1 e t2 armazenam cores e $t3 armazena a word a printar na tela
	lw $t5, FIM_PILHA($zero)
	la $t4, ($gp) 		# endereco da tela bitmapDisplay -> 0x10008000

LOOP_TELA:
	beq $t5, $sp, VOLTA_MENU_TELA # sinal de que chegou ao fim da pilha
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

VOLTA_MENU_TELA:
	# printa msg de leitura da imagem na tela
	la $a0, TELA
	li $v0, 4
	syscall
	# recupera ra de s1 e retorna para a rotina anterior
	move $ra, $s1
	jr $ra

#---------------------------------
OP2_BORRA:
	move $s1, $ra		# salva endereco de retorno em s1
	jal PRINTA_PRETO	#funcao para primeiramente printar toda a tela de preto novamente
	
	# ...

VOLTA_MENU_BORRA:
	# printa msg de leitura da imagem na tela
	la $a0, BORRA
	li $v0, 4
	syscall
	# recupera ra de s1 e retorna para a rotina anterior
	move $ra, $s1
	jr $ra

#---------------------------------
OP3_BORDAS:
	move $s1, $ra		# salva endereco de retorno em s1
	jal PRINTA_PRETO	#funcao para primeiramente printar toda a tela de preto novamente

	# ...

VOLTA_MENU_BORDAS:
	# printa msg de leitura da imagem na tela
	la $a0, BORDAS
	li $v0, 4
	syscall
	# recupera ra de s1 e retorna para a rotina anterior
	move $ra, $s1
	jr $ra

#---------------------------------
OP4_BINARIO:
	move $s1, $ra		# salva endereco de retorno em s1
	jal PRINTA_PRETO	#funcao para primeiramente printar toda a tela de preto novamente
	
	# ...

VOLTA_MENU_BINARIO:
	# printa msg de leitura da imagem na tela
	la $a0, BINARIO
	li $v0, 4
	syscall
	# recupera ra de s1 e retorna para a rotina anterior
	move $ra, $s1
	jr $ra

#---------------------------------
PRINTA_PRETO:
# Preenche a tela de preto
	la $t1,0x10008000	# endereco inicial da Memoria VGA
	la $t2,0x10108000	# endereco final 
	la $t3,0x00000000	# cor preta
LOOP_PRETO:
 	beq $t1,$t2,VOLTA_FUNC	# Se for o ultimo endereco entco sai do loop
	sw $t3,0($t1)		# escreve a word na memoria VGA
	addi $t1,$t1,4		# soma 4 ao endereco
	j LOOP_PRETO			# fica no loop
	li $s0,0
VOLTA_FUNC:
	jr $ra

# ---------------------------------------------------------------------------
OP5_FIM:
	# encerra o programa
	li $v0, 10
	syscall
# ---------------------------------------------------------------------------
