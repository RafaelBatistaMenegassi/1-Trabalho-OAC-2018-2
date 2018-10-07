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
PATH:		.asciiz ""			# path da imagem a ser digitada por usuario
BUF_PATH:	.space 200		# Buffer util para alocar um ocasional grande PATH
INV_PATH:	.asciiz "\nO endereço digitado nao pode ser encontrado. Tente novamente!\n\n"
INICIO:		.asciiz "----- Tratamento de Imagem BMP -----\n\nPara iniciar, favor digitar o endereço do arquivo: "
MENU:		.asciiz "\n----- Menu -----\n\nOpcao 1 - Imprimir Imagem na tela\nOpcao 2 - Efeito de borramento\nOpcao 3 - Efeito de extracao de bordas\nOpcao 4 - Efeito de binarizacao por limiar\nOpcao 5 - Processar nova imagem\nOpcao 6 - Finalizar programa\n\nSelecione uma opcao: "
TELA:		.asciiz "\n\n--- Leitura de Imagem no BitMap Display ---\n"
BORRA:		.asciiz "\n\n--- Efeito de Borramento ---\n"
BORDAS:		.asciiz "\n\n--- Efeito de Extracao de Bordas ---\n"
BINARIO:	.asciiz "\n\n--- Efeito de Binarizacao por Limiar ---\n"
VER_MENU:	.asciiz "\n\nERRO: favor digitar uma das opcoes numericas indicadas\n"
BIN_NUM:	.asciiz "\nDigite um numero entre 0 e 255 para ser o limiar.\n"
FIM_PILHA:	.word	0x7FFFEFFC

# ---------------------------------------------------------------------------

.text

.globl __MAIN

__PRE_PROC:
	# Convencoes para programa: 
	#  -> $s0 armazena a opcao digitada apos chamada de menu;
	#  -> $s1 armazena o endereco de retorno ao menu;
	#  -> $s7 armazena o numero de bytes da imagem lidos para fins de verificacao;

	# Requisicao de PATH do arquivo
	la $a0, INICIO
	li $v0, 4
	syscall

	la $a0, PATH
	li $a1, 200
	li $v0, 8
	syscall

	# Correcao de PATH: Substituicao do '\n' auto-inserido por um '\0', terminando a string	
	li $t8, '\n'
	li $t7, 0
	
CORRIGE_PATH:
	lb $t5, PATH($t7)
	addi $t7, $t7, 1
	bne $t5, $t8, CORRIGE_PATH
	
	li $t8, '\0'
	addi $t7, $t7, -1
	sb $t8, PATH($t7)	
	
	# Abre arquivo imagem
	la $a0, PATH	# string endereco/nome do arquivo
	li $a1, 0		# 0 para flag de leitura
	li $a2, 0		# modo ignorado
	li $v0, 13		# syscall de open file
	syscall			# retorna em $v0 o descritor do arquivo
	move $t0, $v0	# passa o descritor em $t0

	slt $t1, $t0, $zero
	beq $t1, $zero, ABRE_IMG # teste quanto a se o arquivo pode ser realmente aberto

	# falha ao tentar abrir arquivo
	la $a0, INV_PATH
	li $v0, 4
	syscall 
	
	j __PRE_PROC
	
ABRE_IMG:
	#convencoes para programa: $s0 armazena a opcao digitada, $s1 armazena o endereco de retorno ao menu, 
	#$s2 armazena final da pilha, $s3 armazena o começo da imagem em tons de cinza e $s4 o inicio da imagem borrada, quando gerada
	#Le o arquivo para a memoria VGA
	li $sp, 0x7FFFEFFC
	li $s0, 0
	li $s1, 0
	li $s2, 0
	li $s3, 0
	li $s4, 0
	addi $sp, $sp, -786486	# decrementa o ponteiro para a pilha para receber a imagem, numero refere-se a qtd de bytes do arq 786432 + 54 do cabecalho = 786486
	move $a0, $t0			# $a0 recebe o descritor armazenado em t0
	la $a1, ($sp)			# le a imagem na pilha -> 0x10008000
	li $a2, 786486
	li $v0, 14				# syscall de read file
	syscall					# retorna em $v0 o numero de bytes lidos
	move $s7, $v0			# salva o numero de bytes lidos em $s7 para fins de verificacao
	addi $sp, $sp, 54 		# pula cabecalho da imagem de 54 bytes
	move $s3, $sp			# armazena endereco em $s3
	
	# Fecha o arquivo
	move $a0, $s7		# $a0 recebe o descritor
	li $v0, 16			# syscall de close file
	syscall				# retorna se foi tudo Ok

# ---------------------------------------------------------------------------
	lw $s2, FIM_PILHA($zero)	#final da pilha
ESCALA_CINZA:
	# convencao para esse trecho:
	# $t0, $t1 e $t2 armazenam cores, $t3 armazena a word a printar na tela 
	# $t5 armazena inicialmente final da pilha e decrementa em direcao a $s3, que eh o final da imagem colorida
	move $t5, $s2

LOOP_CINZA:
	beq $t5, $s3, __MAIN 	# sinal de que chegou ao fim da pilha
	addi $t5, $t5, -3 		# como arquivo bitmap eh escrito de "tras para frente", fazemos a leitura partindo do final para o inicio
	# lemos byte e byte do endereco de memoria, para a partir disso calcular o tom de cinza equivalente 
	lb $t0, 0($t5)
	mul $t0, $t0, 11		# convencao de atribuir peso 0,11 ao tom azul na escala de cinza
	lb $t1, 1($t5)
	mul $t1, $t1, 59		# convencao de atribuir peso 0,59 ao tom verde na escala de cinza
	lb $t2, 2($t5)
	mul $t2, $t2, 30		# convencao de atribuir peso 0,3 ao tom vermelho na escala de cinza
	li $t3, 0     	 		# limpa t3
	add $t3, $t0, $t1
	add $t3, $t3, $t2
	li $t4, 100
	div $t3, $t4			# apos $t3 ser o somatorio das multiplicacoes, divide por 100 e obterm o byte em escala de cinza
	mfhi $t4				# resto da divisao
	mflo $t3				# quociente da divisao
	slti $a0, $t4, 51		# trecho para arredondar divisao por 100
	beq $a0, 0, ARREDONDA_CINZA
RETORNA_CINZA:
	move $t0, $t3
	move $t1, $t3
	move $t2, $t3
	li $t3, 0     	 		# limpa t3
	sll $t1, $t1, 8  		# deslocamento para ocupar posicao do verde
	sll $t2, $t2, 16 		# deslocamento para ocupar posicao do vermelho
	or $t3, $t3, $t0
	or $t3, $t3, $t1
	or $t3, $t3, $t2
	addi $sp, $sp, -4 		# avança ponteiro da pilha
	sw $t3, ($sp)   		# adiciona pilha
	j LOOP_CINZA

ARREDONDA_CINZA:
	addi $t3, $t3, 1
	j RETORNA_CINZA
	
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
	beq $s0, 5, SEL_NOVA_IMG
	beq $s0, 6, SEL_FIM
	
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
	la $a0, BIN_NUM
	li $v0, 4
	syscall
	li $v0, 5
	syscall
	move $a0, $v0
	jal OP4_BINARIO
	j __MAIN
	
SEL_NOVA_IMG:
	j __PRE_PROC
	
SEL_FIM:
	j OP6_FIM
	
# ---------------------------------------------------------------------------
OP1_TELA:
	move $s1, $ra			# salva endereco de retorno em s1
	jal PRINTA_PRETO		# funcao para primeiramente printar toda a tela de preto novamente
	# convencao para esse trecho: 
	# $t4 armazena endereco da tela que avanca sequencialmente
	# $t5 armazena inicialmente final da pilha e eh decrementado em direcao a $s3, que eh o final da imagem colorida
	# $t0, $t1 e $t2 armazenam cores e $t3 armazena a word a printar na tela
	# $t6 armazena numero de inversao do endereco a printar na tela, de forma que a img nao saia espelhada
	# $t7 armazena o endereco a imprimir na tela, sendo a soma de $t6 e $t4
	move $t5, $s2
	la $t4, ($gp) 			# endereco da tela bitmapDisplay -> 0x10008000
	li $t6, 2044			# tamanho de uma linha da tela -4

LOOP_TELA:
	beq $t5, $s3, VOLTA_MENU_TELA # sinal de que chegou ao fim da pilha
	addi $t5, $t5, -3 	# como arquivo bitmap eh escrito de "tras para frente", fazemos a leitura partindo do final para o inicio
	# lemos byte e byte do endereco de memoria, para agrupa-los nas cores corretas no formato mars (32 bits para um pixel) e carregar na tela
	lb $t0, 0($t5)
	lb $t1, 1($t5)
	lb $t2, 2($t5)
	sll $t1, $t1, 8  		# deslocamento para ocupar posicao do verde
	sll $t2, $t2, 16 		# deslocamento para ocupar posicao do vermelho
	li $t3, 0     	 		# garante que nao tera lixo em $t3
	or $t3, $t3, $t0
	or $t3, $t3, $t1
	or $t3, $t3, $t2
	add $t7, $t6, $t4 		# corrige a posicao a se imprimir na tela
	sw $t3, ($t7)   		# printa na tela bitmap
	addi $t4, $t4, 4 		# avança ponteiro da tela
	beq $t6, -2044, VOLTA_T6
	addi $t6, $t6, -8 		# para manter a posicao correta
	j LOOP_TELA

VOLTA_T6:
	li $t6, 2044
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
	move $s1, $ra			# salva endereco de retorno em s1
	jal PRINTA_PRETO		# funcao para primeiramente printar toda a tela de preto novamente
	
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
	move $s1, $ra			# salva endereco de retorno em s1
	jal PRINTA_PRETO		# funcao para primeiramente printar toda a tela de preto novamente

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
	move $s1, $ra			# salva endereco de retorno em s1
	jal PRINTA_PRETO		# funcao para primeiramente printar toda a tela de preto novamente
	
	# convencao para esse trecho: 
	# $t4 armazena endereco da tela que avanca sequencialmente
	# $t5 armazena inicialmente final do trecho da pilha relativo a imagem cinza e eh decrementado em direcao a $sp, que eh o final da imagem colorida
	# $t3 armazena a word a printar na tela
	# $t6 armazena numero de inversao do endereco a printar na tela, de forma que a img nao saia espelhada
	# $t7 armazena o endereco a imprimir na tela, sendo a soma de $t6 e $t4
	# $a0 armazena o numero indicado pelo usuario
	move $t5, $s3
	la $t4, ($gp) 			# endereco da tela bitmapDisplay -> 0x10008000
	li $t6, 2044			# tamanho de uma linha da tela -4

LOOP_TELA_BINARIO:
	beq $t5, $sp, VOLTA_MENU_BINARIO # sinal de que chegou ao fim da pilha
	addi $t5, $t5, -4 		# como arquivo bitmap eh escrito de "tras para frente", fazemos a leitura partindo do final para o inicio
	lb $t3, 1($t5)     	 	# le um byte que identifica a cor cinza em t3
	slt $t0, $t3, $a0		# 45 estabelecido como faixa de limiar para binarizacao
	beq $t0, 0, ARREDONDA_CIMA_BINARIO
	li $t3, 0x00FFFFFF				# caso $t3 seja menor que limiar, forca para 0x00FFFFFF, ou seja cor branca
VOLTA_BINARIO:
	add $t7, $t6, $t4 		# corrige a posicao a se imprimir na tela
	sw $t3, ($t7)   		# printa na tela bitmap
	addi $t4, $t4, 4 		# avança ponteiro da tela
	beq $t6, -2044, VOLTA_T6_BINARIO
	addi $t6, $t6, -8 		# para manter a posicao correta
	j LOOP_TELA_BINARIO

ARREDONDA_CIMA_BINARIO:
	li $t3, 0x00000000		# caso $t3 seja maior que limiar, forca para 0, ou seja cor preta
	j VOLTA_BINARIO

VOLTA_T6_BINARIO:
	li $t6, 2044
	j LOOP_TELA_BINARIO

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
	la $t1,0x10008000		# endereco inicial da Memoria VGA
	la $t2,0x10108000		# endereco final 
	la $t3,0x00000000		# cor preta
LOOP_PRETO:
 	beq $t1,$t2,VOLTA_FUNC	# Se for o ultimo endereco entco sai do loop
	sw $t3,0($t1)			# escreve a word na memoria VGA
	addi $t1,$t1,4			# soma 4 ao endereco
	j LOOP_PRETO			# fica no loop
	li $s0,0
VOLTA_FUNC:
	jr $ra

# ---------------------------------------------------------------------------

OP6_FIM:
	# encerra o programa
	li $v0, 10
	syscall

# ---------------------------------------------------------------------------
