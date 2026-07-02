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
.extern logaritmo
.extern float_um
.extern imprime
.extern imprime_float
.extern prox_primo
.extern num1
.extern num2
.extern temp
.extern operacao

# gcc -o trab01 -no-pie trab01.s lib.s

.section .data
	msg0: .asciz "Digite o primeiro numero: \n"
	msg1: .asciz "Digite o segundo numero: \n"
	msg2: .asciz "Digite a operação: \n"
    msg_inv_op: .asciz "Operacao desconhecida.\n"
    msg_erro_zero: .asciz "Erro: O Operando não pode ser igual a zero.\n"
    msg_erro_nao_positivo: .asciz "Erro: O Operando deve ser um número positivo.\n"
    msg_erro_nao_inteiro_negativo: .asciz "Erro: O Operando deve ser um número inteiro não-negativo.\n"
    msg_erro_base_log: .asciz "Erro: A base do logaritmo deve ser maior que 0 e diferente de 1.\n"
    msg_operador_maior: .asciz "Erro: O primeiro operando deve ser maior ou igual ao segundo.\n"
	fmt_in: .asciz "%f"
	fmt_char: .asciz " %c"
	msg_continue: .asciz "Deseja continuar?: (s/n) \n"
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

    cmp $'p', %r12b
    je prox_primo_caller

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

    cmp $'l', %r12b
	je logaritmo_caller

op_invalida:
    mov $msg_inv_op, %rdi
    call printf
    jmp loop_prog

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
    call imprime_float
    jmp loop_prog

subtracao_caller:
    call subtracao
    call imprime_float
    jmp loop_prog

multiplicacao_caller:
    call multiplicacao
    call imprime_float
    jmp loop_prog

divisao_caller:
    call divisao
    
    # Verifica o codigo de status que voltou no %eax
    test %eax, %eax       
    jz loop_prog          # Se for 0 (jz = Jump if Zero), pula a impressao e volta pro loop
    
    # Se nao for zero, a divisao deu certo, entao imprime o float
    call imprime_float    
    jmp loop_prog

exponenciacao_caller:
    call exponenciacao
    call imprime_float
    jmp loop_prog

combinacao_caller:
    movss num1, %xmm0
    call valida_inteiro_positivo
    test %edx, %edx
    jz erro_nao_inteiro_negativo # caso não seja inteiro positivo, vai para erro

    movss num2, %xmm0
    call valida_inteiro_positivo
    test %edx, %edx
    jz erro_nao_inteiro_negativo 

    movss num1, %xmm1
    ucomiss %xmm1, %xmm0 # compara num1 com num2
    ja erro_operador_maior # 

    call combinacao
    call imprime_float
    jmp loop_prog

arranjo_caller:
    movss num1, %xmm0
    call valida_inteiro_positivo
    test %edx, %edx
    jz erro_nao_inteiro_negativo # caso não seja inteiro positivo, vai para erro

    movss num2, %xmm0
    call valida_inteiro_positivo
    test %edx, %edx
    jz erro_nao_inteiro_negativo 

    movss num1, %xmm1
    ucomiss %xmm1, %xmm0 # compara num1 com num2
    ja erro_operador_maior # 

    call arranjo
    call imprime_float
    jmp loop_prog

fatorial_caller:
    movss num1, %xmm0
    call valida_inteiro_positivo
    test %edx, %edx
    jz erro_nao_inteiro_negativo # caso não seja inteiro positivo, vai para erro

    mov %eax, %edi # passa o valor inteiro de num1 para %edi

    call fatorial
    cvtsi2ss %eax, %xmm0
    call imprime_float
    jmp loop_prog

inverso_caller:
    movss num1, %xmm0
    call valida_igual_zero
    test %edx, %edx
    jz erro_igual_zero # caso seja igual a zero, vai para erro

    call inverso
    call imprime_float
    jmp loop_prog

raiz_caller:
    movss num1, %xmm0
    call valida_positivo
    test %edx, %edx
    jz erro_nao_positivo # caso não seja positivo, vai para erro

	call raiz
    call imprime_float
	jmp loop_prog

prox_primo_caller:
    movss num1, %xmm0
    call valida_inteiro_positivo
    test %edx, %edx
    jz erro_nao_inteiro_negativo # caso não seja inteiro positivo, vai para erro


    call prox_primo
    call imprime_float
    jmp loop_prog

logaritmo_caller:
    movss num1, %xmm0
    call valida_positivo
    test %edx, %edx
    jz erro_nao_positivo # caso não seja positivo, vai para erro

    movss num1, %xmm0
    call valida_igual_zero
    test %edx, %edx
    jz erro_igual_zero # caso seja igual a zero, vai para erro

    movss num2, %xmm1
    call valida_base_log
    test %edx, %edx
    jz erro_base_log # caso não seja válido, vai para erro

    call logaritmo
    call imprime_float
    jmp loop_prog


# Validacoes 

valida_inteiro_positivo:
    push %rbp
    mov %rsp, %rbp
    xorps %xmm2, %xmm2

    ucomiss %xmm2, %xmm0
    jb invalido # caso num1 < 0, vai para invalido

    cvttss2si %xmm0, %eax # converte para inteiro

    cvtsi2ss %eax, %xmm1 # volta pra float

    ucomiss %xmm1, %xmm0 # compara num1 com o inteiro convertido
    jne invalido # caso num1 não seja inteiro, vai para invalido

    mov $1, %edx
    pop %rbp
    ret

invalido:
    mov $0, %edx
    pop %rbp
    ret

valida_positivo:
    push %rbp
    mov %rsp, %rbp
    xorps %xmm2, %xmm2

    ucomiss %xmm2, %xmm0
    jb invalido_positivo # caso num1 < 0, vai para invalido

    mov $1, %edx
    pop %rbp
    ret

invalido_positivo:
    mov $0, %edx
    pop %rbp
    ret

valida_base_log:
    push %rbp
    mov %rsp, %rbp
    xorps %xmm2, %xmm2

    ucomiss %xmm2, %xmm1
    jbe base_invalida

    movss float_um, %xmm2
    ucomiss %xmm2, %xmm1
    je base_invalida

    mov $1, %edx
    pop %rbp
    ret

base_invalida:
    mov $0, %edx
    pop %rbp
    ret



valida_igual_zero:
    push %rbp
    mov %rsp, %rbp
    xorps %xmm2, %xmm2

    ucomiss %xmm2, %xmm0
    je invalido_igual_zero # caso num1 != 0, vai para invalido

    mov $1, %edx
    pop %rbp
    ret

invalido_igual_zero:
    mov $0, %edx
    pop %rbp
    ret

# Mensagens de erro

erro_nao_inteiro_negativo:
    mov $msg_erro_nao_inteiro_negativo, %rdi
    xor %eax, %eax
    call printf
    jmp loop_prog

erro_nao_positivo:
    mov $msg_erro_nao_positivo, %rdi
    xor %eax, %eax
    call printf
    jmp loop_prog

erro_igual_zero:
    mov $msg_erro_zero, %rdi
    xor %eax, %eax
    call printf
    jmp loop_prog

erro_base_log:
    mov $msg_erro_base_log, %rdi
    xor %eax, %eax
    call printf
    jmp loop_prog

erro_operador_maior:
    mov $msg_operador_maior, %rdi
    xor %eax, %eax
    call printf
    jmp loop_prog
# Fim

fim:
    pop %r12
    pop %r13
    pop %rbp
    ret


