.global soma
.global subtracao
.global multiplicacao
.global divisao
.global exponenciacao
.global combinacao
.global arranjo
.global fatorial
.global inverso
.global imprime
.global num1
.global num2
.global temp
.global operacao

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


.section .text
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
	call fatorial # resultado vai ta no eax
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
	call fatorial
	mov %eax, temp
	mov num1, %edi
	sub num2, %edi
	call fatorial
	mov %eax, %ebx 
	mov temp, %eax
	idivl %ebx
	ret

	
fatorial: # recebe no edi
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

