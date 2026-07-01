.global soma
.global subtracao
.global multiplicacao
.global divisao
.global exponenciacao
.global combinacao
.global arranjo
.global fatorial
.global inverso
.global float_um
.global soma_int
.global raiz
.global logaritmo
.global imprime
.global prox_primo
.global imprime_float
.global num1
.global num2
.global temp
.global operacao

.section .data
	fmt_out: .asciz "Resultado: %d\n"
    fmt_out_float: .asciz "Resultado: %.2f\n"
	msg_erro_zero: .asciz "Erro: O divisor não pode ser 0. \n"
	float_um: .float 1.0
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

imprime_float:
	push %rbp
	mov %rsp, %rbp
	# formatador de saida
	mov $fmt_out_float, %rdi
	# 
	cvtss2sd %xmm0, %xmm0
	mov $1, %eax
	call printf
	pop %rbp
	ret
# Funcoes


soma:
    push %rbp
    mov %rsp, %rbp
	# Trocar para registradores xmm
	movss num1, %xmm0
	movss num2, %xmm1
	addss %xmm1, %xmm0

	pop %rbp
    ret

subtracao:
    push %rbp
    mov %rsp, %rbp
	movss num1, %xmm0
	movss num2, %xmm1
	subss %xmm1, %xmm0
	
	pop %rbp
    ret

multiplicacao:
    push %rbp
    mov %rsp, %rbp
	movss num1, %xmm0
	movss num2, %xmm1
	mulss %xmm1, %xmm0

    pop %rbp
	ret

divisao:
    push %rbp
    mov %rsp, %rbp
	movss num1, %xmm0
	movss num2, %xmm1
	xorps %xmm2, %xmm2
	ucomiss %xmm2, %xmm1
	je erro_divisao
	
	divss %xmm1, %xmm0

    call imprime_float
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

	movss num1, %xmm0 # acumulador
	movss num1, %xmm1 # base
	movss num2, %xmm2 # expoente
	cvttss2si %xmm2, %ecx # converte expoente para inteiro
	cmp $0, %ecx
	je exp_caso_zero

	
	cmp $1, %ecx
	je fim_exp

exp_loop:
	mulss %xmm1, %xmm0
	sub $1, %ecx
	cmp $1, %ecx
	jg exp_loop
	jmp fim_exp

exp_caso_zero:
	movss float_um, %xmm0

fim_exp:
	; mov temp, %eax
	pop %rbp
	ret


combinacao:
    push %rbp
    mov %rsp, %rbp
    push %r12
    push %r13
	cvtss2si num1, %edi # converte num1 para inteiro e joga no edi
	call arranjo_calc # retorna valor no eax
	mov %eax, %r12d # joga o calculo do arranjo na temp
	cvtss2si num2, %edi # converte num1 para inteiro e joga no edi

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
	xor %edx, %edx
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

inverso:
	push %rbp
	mov %rsp, %rbp
	# bloco de codigo
	movss float_um, %xmm0
	divss num1, %xmm0
	
	
	pop %rbp
    ret

raiz:
    push %rbp
    mov %rsp, %rbp

    movss num1, %xmm0 
    sqrtss   %xmm0, %xmm0 # faz a operacao

    pop %rbp
    ret


# primo
eh_primo:
	push %rbp
	mov %rsp, %rbp
	cmp $2, %edi
	jl nao_primo
	je sim_primo

	mov $2, %ecx

loop_primo:
	cmp %ecx, %edi
	jle sim_primo

	mov %edi, %eax
	cdq
	idivl %ecx
	test %edx, %edx
	je nao_primo
	inc %ecx
	jmp loop_primo

sim_primo:
	mov $1, %eax
	pop %rbp
	ret

nao_primo:
	mov $0, %eax
	pop %rbp
	ret

prox_primo:
	push %rbp
	mov %rsp, %rbp
	cvttss2si num1, %eax

	mov %eax, %edi
	inc %edi

busca_primo:
	call eh_primo
	test %eax, %eax
	jne achou_primo
	inc %edi
	jmp busca_primo

achou_primo:
	mov %edi, %eax
	call imprime
	pop %rbp
	ret

logaritmo: # recebe logaritmando em xmm0 e base em xmm1
	push %rbp
	mov %rsp, %rbp
	sub $16, %rsp

	# Calcula log2(logaritmando)
	movss float_um, %xmm2
	movss %xmm2, (%rsp)
	flds (%rsp)

	movss %xmm0, (%rsp)
	flds (%rsp)

	fyl2x
	# Calcula log2(base)
	movss float_um, %xmm2
	movss %xmm2, 4(%rsp)
	flds 4(%rsp)

	movss %xmm1, 4(%rsp)
	flds 4(%rsp)

	fyl2x

	# Mudanca de base

	fdivrp

	fstps (%rsp)
	movss (%rsp), %xmm0

	mov %rbp, %rsp
	pop %rbp
	ret
