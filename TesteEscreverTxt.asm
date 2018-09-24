############################################
#	Victor Santos Candeira, Matricula 17/0157636
############################################

.data
TESTE:		.asciiz "teste.txt"
TEXTO:		.asciiz "Escrever um arquivo de texto por assembly da certo\t:)\n"

.text
INICIO:
	la $a0,TESTE	# string endereco/nome do arquivo
	li $a1,1		# escrever
	li $a2,0		# binario
	li $v0,13		# syscall de open file
	syscall			# retorna em $v0 o descritor do arquivo
	move $s0,$v0		# salva o descritor em $s0
#testar valor do arquivo lido
	li $v0, 1	#printar inteiro
	move $a0, $s0
	syscall
	li $v0, 11	#printar inteiro
	li $a0, '\n'
	syscall
# escrever um texto no arquivo
	move $a0, $s0
	la $a1, TEXTO
	li $a2, 55
	li $v0, 15
	syscall
#testar valor do arquivo lido
	move $t0, $v0
	li $v0, 1	#printar inteiro
	add $a0, $t0, $zero
	syscall
	li $v0, 11	#printar inteiro
	li $a0, '\n'
	syscall
#Fecha o arquivo
	move $a0,$s0		# $a0 recebe o descritor
	li $v0,16		# syscall de close file
	syscall			# retorna se foi tudo Ok
