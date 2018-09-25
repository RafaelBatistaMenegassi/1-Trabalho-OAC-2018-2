############################################
#
# Trabalho 1 de OAC
# 
# Processamento de Imagens BMP em Assembly
#
# 	Felipe 
#	Rafael
#	Victor Santos Candeira, Matricula 17/0157636
#
############################################

.data
IMAGEM:		.asciiz "lena.bmp"  #string de nome do arquivo que sera lido, imagem 512x512 pixels

.text
INICIO:
	la $a0,IMAGEM	# string endereco/nome do arquivo
	li $a1,0		# 0 para flag de leitura
	li $a2,0		# modo ignorado
	li $v0,13		# syscall de open file
	syscall			# retorna em $v0 o descritor do arquivo
	move $t0,$v0		# passa o descritor em $t0
# Le o arquivos para a memoria VGA
	addi $sp, $sp, -57 # decrementa o ponteiro para a pilha, para receber a imagem
	move $a0,$t0		# $a0 recebe o descritor salvo em s0
	la $a1, ($sp)			# le a imagem na pilha
	li $a2,57		# quantidade de bytes, 2Elevado18 - produto de 512x512 vezes 32 bits para um pixel
	li $v0,14		# syscall de read file
	syscall			# retorna em $v0 o numero de bytes lidos
	move $s0, $v0
#testar valor do arquivo lido
	move $t0, $v0
	li $v0, 1	#printar inteiro
	add $a0, $t0, $zero
	syscall
#convencao para esse trecho: t0 armazena final da pilha, t1 armazena endereco a escrever na tela 
#t2, t3 e t4 armazenam cores e $t5 armazena a word a printar na tela
	la $t0, 0x7FFFEFFC # endereço do fim da pilha
	la $t1, 0x10010000 # endereco da tela bitmapDisplay
	addi $sp, $sp, 54 # pula cabecalho da imagem de 54 bytes
LOOP_TELA:
	beq $t0, $sp, LE_PROX #sinal de que chegou ao fim da pilha
	lb $t2, 0($sp)	#carrega em t2 azul
	lb $t3, 1($sp)	#carrega em t2 verde
	lb $t4, 2($sp)	#carrega em t2 vermelho
	addi $sp, $sp, 3 #avança ponteiro da pilha
	sll $t2, $t2, 24 # deslocamento para ocupar posicao do azul
	sll $t3, $t3, 16 # deslocamento para ocupar posicao do verde
	sll $t4, $t4, 8 # deslocamento para ocupar posicao do vermelho
	li $t5, 0 # garante que nao tera lixo em t5
	or $t5, $t5, $t2
	or $t5, $t5, $t3
	or $t5, $t5, $t4
	sw $t5, 0($t0) # printa na tela bitmap
	addi $t1, $t1, 4 #avança ponteiro da tela
	j LOOP_TELA
LE_PROX:
	addi $sp, $sp, -3
	move $a0,$s0		# $a0 recebe o descritor salvo em s0
	la $a1, ($sp)			# le a imagem na pilha
	li $a2,3		# quantidade de bytes, 2Elevado18 - produto de 512x512 vezes 32 bits para um pixel
	li $v0,14		# syscall de read file
	syscall			# retorna em $v0 o numero de bytes lidos
	#testar valor do arquivo lido
	move $s0, $v0
	li $v0, 1	#printar inteiro
	add $a0, $t0, $zero
	syscall
	li $v0, 11
	li $a0, '\n'
	syscall
	###
	li $t7, 1		#registrado usado para verificacao
	slt $t6, $s0, $t7	#se o numero de bits lidos e menor que 1, entao encerra o loop
	beq $t6, 1, FIM
	j LOOP_TELA
FIM:
	#Fecha o arquivo
	move $a0,$s0		# $a0 recebe o descritor
	li $v0,16		# syscall de close file
	syscall			# retorna se foi tudo Ok
	#encerra o programa
	li $v0, 10
	syscall