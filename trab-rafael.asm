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
IMG:	.asciiz	"lena.bmp"
end:	.word	0x00000000


.text
    la $a0,IMG
    li $a1,0
    li $a2,0
    li $v0,13
    syscall
    
    # Carregando imagem VGA memory
    move $t5, $v0
    move $a0,$v0
    la $a1, end # Aqui vc pode escolher vários segmentos diferentes da memória de dados, mas veja que eles devem ser os mesmos que estão na ferramenta bitmap display. Se vc usar outro início de intervalo ela não vai funcionar
    li $a2, 262144
    li $v0, 14
    syscall
            
    li $t1, 0
    li $t2, 4
    li $t3, 1048576
    
    # Loop para tentar ler imagem e escrever no bitmap display
loop:
    lw $t4, end($t1)
    sw $t4, end($t1)
    addu $t1, $t1, $t2
    bne $t1, $t3, loop  
    
    # Close File
    li $v0, 16
    syscall
    
    # Exit
    li $v0, 10
    syscall