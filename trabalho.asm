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
	move $s0,$v0		# salva o descritor em $s0
	move $t0,$v0		# passa o descritor em $t0
#testar valor do arquivo lido
	li $v0, 1	#printar inteiro
	add $a0, $t0, $zero
	syscall
	li $v0, 11	#printar inteiro
	li $a0, '\n'
	syscall
# Le o arquivos para a memoria VGA
	move $a0,$s0		# $a0 recebe o descritor salvo em s0
	addi $a0, $a0, 54	# 54 bytes para cabecalho
	la $a1,0x10010000	# endereco de destino dos bytes lidos
	li $a2,0x80000		# quantidade de bytes, 2Elevado18 - produto de 512x512 vezes 32 bits para um pixel
	li $v0,14		# syscall de read file
	syscall			# retorna em $v0 o numero de bytes lidos
#testar valor do arquivo lido
	move $t0, $v0
	li $v0, 1	#printar inteiro
	add $a0, $t0, $zero
	syscall
#Fecha o arquivo
	move $a0,$s0		# $a0 recebe o descritor
	li $v0,16		# syscall de close file
	syscall			# retorna se foi tudo Ok
