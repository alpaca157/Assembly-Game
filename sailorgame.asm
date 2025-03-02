#Jogo da forca temático sobre personagens do desenho animado "Sailor Moon"
.data

# Lista dos Personagens de Sailor Moon (Sailors Guardians)
    personagens: .word nome1, nome2, nome3, nome4, nome5, nome6, nome7, nome8, nome9, nome10, nome11
nome1: .asciiz "usagi tsukino"
nome2: .asciiz "ami mizuno"
nome3: .asciiz "rei hino"
nome4: .asciiz "makoto kino"
nome5: .asciiz "minako aino"
nome6: .asciiz "hotaru tomoe"
nome7: .asciiz "setsuna meiou"
nome8: .asciiz "michiru kaiou"
nome9: .asciiz "haruka tennou"
nome10: .asciiz "chibiusa"
nome11: .asciiz "tuxedo mask"

    # Mensagens do jogo
    menu: .asciiz "\n=== Jogo da Forca (Sailor Moon) ===\n1. Jogar\n2. Sair\nEscolha uma opcao: "
    msg_tentativa: .asciiz "\nDigite uma letra: "
#    msg_inicio: .asciiz "\n palavra da vez"
    msg_correta: .asciiz "\nLetra correta! Palavra: "
    msg_incorreta: .asciiz "\nLetra incorreta! Tentativas restantes: "
    msg_vitoria: .asciiz "\nParabens! Voce acertou o personagem: "
    msg_derrota: .asciiz "\nVocÃª perdeu! O personagem era: "
    nova_linha: .asciiz "\n"
    
    # Variáveis do jogo
    palavra_secreta: .space 20  # Armazena a palavra secreta escolhida
    tentativas: .word 10         # Número de tentativas
    progresso: .space 20  # Armazena as letras corretas já adivinhadas

.text
main:
    jal exibir_menu
    j main

exibir_menu:
    li $v0, 4
    la $a0, menu
    syscall

    li $v0, 5
    syscall

    beq $v0, 1, jogar
    beq $v0, 2, sair
    j main  

jogar:
    li $t0, 10
    sw $t0, tentativas  # Reset das tentativas

    jal escolher_personagem_aleatorio
    jal inicializar_progresso
    jal loop_jogo
    j main

escolher_personagem_aleatorio:
    li $v0, 42
    li $a1, 10  
    syscall

    la $t0, personagens 
    sll $a0, $a0, 2  
    add $t0, $t0, $a0  
    lw $t0, 0($t0)  

    la $t1, palavra_secreta
    li $t2, 0

copiar_personagem:
    lb $t3, 0($t0)
    sb $t3, 0($t1)
    beqz $t3, fim_copia
    addi $t0, $t0, 1
    addi $t1, $t1, 1
    j copiar_personagem

fim_copia:
    jr $ra

inicializar_progresso:
    la $t0, palavra_secreta
    la $t1, progresso
    li $t2, 0

loop_inicializar:
    lb $t3, 0($t0)
    beqz $t3, fim_inicializar
    li $t4, '_'
    sb $t4, 0($t1)
    addi $t0, $t0, 1
    addi $t1, $t1, 1
    j loop_inicializar

fim_inicializar:
    sb $zero, 0($t1)
    jr $ra

loop_jogo:
    li $v0, 4
    la $a0, msg_correta
    syscall
    la $a0, progresso
    syscall
    la $a0, nova_linha
    syscall

    li $v0, 4
    la $a0, msg_tentativa
    syscall
    li $v0, 12
    syscall
    move $t0, $v0

    jal verificar_letra
    beqz $v0, letra_incorreta

    jal verificar_vitoria
    beqz $v0, loop_jogo

    li $v0, 4
    la $a0, msg_vitoria
    syscall
    la $a0, palavra_secreta
    syscall
    j main

letra_incorreta:
    lw $t1, tentativas
    subi $t1, $t1, 1
    sw $t1, tentativas

    blez $t1, derrota

    li $v0, 4
    la $a0, msg_incorreta
    syscall
    li $v0, 1
    move $a0, $t1
    syscall
    la $a0, nova_linha
    syscall
    j loop_jogo

derrota:
    li $v0, 4
    la $a0, msg_derrota
    syscall
    la $a0, palavra_secreta
    syscall
    j main

verificar_letra:
    la $t1, palavra_secreta
    la $t2, progresso
    li $v0, 0  

loop_verificar:
    lb $t3, 0($t1)
    beqz $t3, fim_verificar
    beq $t3, $t0, letra_encontrada
    addi $t1, $t1, 1
    addi $t2, $t2, 1
    j loop_verificar

letra_encontrada:
    sb $t0, 0($t2)
    li $v0, 1  
    addi $t1, $t1, 1
    addi $t2, $t2, 1
    j loop_verificar

fim_verificar:
    jr $ra

verificar_vitoria:
    la $t0, progresso
    la $t1, palavra_secreta
    li $v0, 1  

loop_vitoria:
    lb $t2, 0($t0)
    lb $t3, 0($t1)
    beqz $t3, fim_vitoria
    beq $t2, '_', nao_vitoria
    addi $t0, $t0, 1
    addi $t1, $t1, 1
    j loop_vitoria

nao_vitoria:
    li $v0, 0  
    jr $ra

fim_vitoria:
    jr $ra

sair:
    li $v0, 10
    syscall
