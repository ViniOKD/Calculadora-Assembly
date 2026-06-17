.global main
.extern soma
.extern subtracao
.extern multiplicacao
.extern divisao
.extern exponenciacao
.extern combinacao
.extern arranjo
.extern fatorial
.extern inverso
.extern raiz
.extern imprime
.extern num1
.extern num2
.extern temp
.extern operacao
# gcc -o trab01 -no-pie trab01_v2.s lib.s
# fazer:
# - o primeiro operando DEVE ser um nuemro real
# - As operações “+”, “-”, “*”, “/”, “^”, “c”, “a” e “l” devem receber o segundo operando (outro número real);
# - raiz
# - log
# - proximo primo 
# - 	combinação, arranjo e fatorial, deve-se informar q n pode fzr operacoa quando houverem operandos negativos ou operandos que nao sao do tipo inteiro
# - 	combinação e arranjo o valor do primeiro operando deve ser maior ou igual ao valor do segundo operando
# - 	raiz deve informar que não é possivel realizar operacao com operando < 0
# - 	inverso deve informar que não e possivel realizar com numero = 0
# - 	log, o logaritmando deve ser maior que 0 e a base um numero positivo != 1


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
	.lcomm continuar, 1 # controla o loop

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

	cmp $'r', %r12b
	je raiz_caller

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
    call fatorial
    call imprime
    jmp loop_prog

inverso_caller:
    call inverso
    call imprime
    jmp loop_prog

raiz_caller:
	call raiz
	
	jmp loop_prog

fim:
    pop %r12
    pop %r13
    pop %rbp
    ret
