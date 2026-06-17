.global main

.section .data
	msg0: .asciz "Digite o primeiro numero: \n"
	msg1: .asciz "Digite o segundo numero: \n"
	msg2: .asciz "Digite a operação: \n"
	fmt_in: .asciz "%d"
	fmt_out: .asciz "Resultado: %d\n"
	fmt_char: .asciz " %c"
	msg_continue: .asciz "Deseja continuar?: (s/n) \n"
	msg_erro_zero: .asciz "Erro: O divisor não pode ser 0. \n"
.bss 
	.lcomm num1, 4 # alocacao de 4 bytes para int ou float p/ primeiro numero
	.lcomm num2, 4 # alocacao de 4 bytes para int ou float p/ segundo numero
	.lcomm operacao, 1 # aloca 1 byte p/ operador
	.lcomm temp, 4 # variavel temporaria
	.lcomm continuar, 1 # controla o loop
	.lcomm resultado, 4

.section .text
main:
    push %rbp
    mov %rsp, %rbp 
    call inicio

    pop %rbp
    ret


inicio:
    push %rbp
    mov %rsp, %rbp
    push %r12
    push %r13
loop_main:
    mov $msg0, %rdi
	xor %eax, %eax
	call printf

	mov $fmt_in, %rdi
	mov $num1, %rsi
	xor %eax, %eax
	call scanf

	mov $msg2, %rdi
	xor %eax, %eax
	call printf
	
	mov $fmt_char, %rdi
	mov $operacao, %rsi
	xor %eax, %eax
    call scanf

    movb operacao, %r12b
    # operacoes com 1 operando    
    cmp $'!', %r12b
	je fatorial_caller

	cmp $'i', %r12b
	je inverso_caller

    # Operacoes com 2 operandos
	mov $msg1, %rdi
    xor %eax, %eax
    call printf

    mov $fmt_in, %rdi
    mov $num2, %esi
    xor %eax, %eax
    call scanf

    cmp $'+', %r12b
    je soma_caller

    cmp $'c', %r12b
    je combinacao_caller

    cmp $'-', %r12b
	je subtracao_caller

	cmp $'*', %r12b
	je multiplicacao_caller

	cmp $'/', %r12b
	je divisao_caller
	
	cmp $'^', %r12b
	je exponenciacao_caller
	
	cmp $'a', %r12b
	je arranjo_caller
    


loop_prog:

	mov $msg_continue, %rdi
	xor %eax, %eax
	call printf

	mov $fmt_char, %rdi
	mov $continuar, %rsi
	xor %eax, %eax
	call scanf

	movb continuar, %r12b 

	cmp $'s', %r12b
	je loop_main

	cmp $'S', %r12b
	je loop_main

    jmp fim

# Chamadores

soma_caller:
    call soma
    call imprime
    jmp loop_prog

subtracao_caller:
    call subtracao
    call imprime
    jmp loop_prog

multiplicacao_caller:
    call multiplicacao
    call imprime
    jmp loop_prog

divisao_caller:
    call divisao
    jmp loop_prog

exponenciacao_caller:
    call exponenciacao
    call imprime
    jmp loop_prog

combinacao_caller:
    call combinacao
    jmp loop_prog

arranjo_caller:
    call arranjo
    jmp loop_prog

fatorial_caller:
    mov num1, %edi
    call fatorial_calc
    call imprime
    jmp loop_prog

inverso_caller:
    call inverso
    call imprime
    jmp loop_prog


fim:
    pop %r12
    pop %r13
    pop %rbp
    ret

# funcao imprime
imprime:
    push %rbp
    mov %rsp, %rbp
	# formatador de saida
    mov $fmt_out, %rdi
	# joga o eax no esi
    mov %eax, %esi       
    xor %eax, %eax
    call printf
    pop %rbp
    ret



# Funcoes

soma:
    push %rbp
    mov %rsp, %rbp
	# Trocar para registradores xmm
	mov num1, %eax
	add num2, %eax

	pop %rbp
    ret

subtracao:
    push %rbp
    mov %rsp, %rbp
	mov num1, %eax
	sub num2, %eax
	
	pop %rbp
    ret

multiplicacao:
    push %rbp
    mov %rsp, %rbp
	mov num1, %eax
	imull num2, %eax
	
	mov num1, %eax
	imull num2, %eax
    pop %rbp
	ret

divisao:
    push %rbp
    mov %rsp, %rbp
	mov num1, %eax
	mov num2, %ecx
	cmp $0, %ecx
	je erro_divisao
	
	idivl %ecx
    call imprime
fim_div:
    pop %rbp
	ret

erro_divisao:
	mov $msg_erro_zero, %rdi
	xor %eax, %eax
	call printf
    jmp fim_div

exponenciacao:
	push %rbp
	mov %rsp, %rbp
    mov num1, %eax
	mov %eax, temp
	jmp exp_check
	

exp_while:
	mov temp, %eax
    mov num1, %ecx
    imull %ecx, %eax
    mov %eax, temp
    subl $1, num2

exp_check:
    mov num2, %eax
    cmp $1, %eax
    jg exp_while

fim_exp:
    mov temp, %eax
	pop %rbp
	ret


combinacao:
    push %rbp
    mov %rsp, %rbp
    push %r12
    push %r13

	mov num1, %edi
	call arranjo_calc # retorna valor no eax
	mov %eax, %r12d # joga o calculo do arranjo na temp

    mov num2, %edi # joga num2 no edi 
	call fatorial_calc # resultado vai ta no eax
    mov %eax, %ecx
	# calcula o inverso -> 1/r!
    mov %r12d, %eax
    cdq
    idivl %ecx

	call imprime
    
    pop %r12
    pop %r13
	pop %rbp
    ret

# Arranjo
arranjo:
	push %rbp
	mov %rsp, %rbp
	mov num1, %edi
	call arranjo_calc
	call imprime
	pop %rbp
    ret

arranjo_calc:
	call fatorial_calc
	mov %eax, temp
	mov num1, %edi
	sub num2, %edi
	call fatorial_calc
	mov %eax, %ebx 
	mov temp, %eax
	idivl %ebx
	ret

	
fatorial_calc: # recebe no edi
    push %rbp
    mov %rsp, %rbp
	mov $1, %eax
	cmp $1, %edi
	jle fim_fat_calc

fat_loop:
	imull %edi, %eax
	subl $1, %edi
	cmp $1, %edi
	jg fat_loop

fim_fat_calc:
	pop %rbp
	ret

# AINDA NAO FUNCIONA PQ NAO TA EM REGISTRADORES PARA NUMEROS REAIS !!!!!!!!!!!!
inverso:

	# INiciar registro de ativação
	push %rbp
	mov %rsp, %rbp
	# Empilha registradores calle-save

	# bloco de codigo
	movl $1, %eax
	cdq

	movl num1, %ecx
	idivl %ecx
	# Restaurar registro de ativação da funcao chamadora pop %rbp
	pop %rbp
    ret

