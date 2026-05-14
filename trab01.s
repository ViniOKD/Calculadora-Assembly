.global main

.section .data
	msg0: .asciz "Digite o primeiro numero: \n"
	msg1: .asciz "Digite o segundo numero: \n"
	msg2: .asciz "Digite a operação: \n"
	fmt_in: .asciz "%d"
	fmt_out: .asciz "Resultado: %d\n"
	fmt_char: .asciz " %c"

.bss 
	.lcomm num1, 4 # alocacao de 4 bytes para int ou float p/ primeiro numero
	.lcomm num2, 4 # alocacao de 4 bytes para int ou float p/ segundo numero
	.lcomm operador, 1 # aloca 1 byte p/ operador
	.lcomm temp, 4 # variavel temporaria

.section .text
main:
	push %rbp
	mov %rsp, %rbp

	mov $msg0, %rdi
	xor %eax, %eax
	call printf

	mov $fmt_in, %rdi
	mov $num1, %esi
	xor %eax, %eax
	call scanf

	mov $msg2, %rdi
	xor %eax, %eax
	call printf
	
	mov $fmt_in, %rdi
	mov $operador, %rsi
	xor %eax, %eax
	call scanf

	# Logica if-else para definir qual a operacao 

	movb operador, %al

	cmp $'+', %al
	je soma

	cmp $'-', %al
	je subtracao

	cmp $'*', %al
	je multiplicacao

	cmp $'/', %al
	je divisao
	
	cmp $'^', %al
	je exponenciacao

	cmp $'c', %al
	je combinacao
	
	cmp $'a', %al
	je arranjo

	cmp $'!', %al
	je fatorial

	cmp $'i', %al
	je inverso

	cmp $'r', %al
	je raiz

	cmp $'l', %al
	je logaritmo

	cmp $'p', %al
	je prox_primo

ler_numero:
    push %rbp            
    mov %rsp, %rbp

    mov $msg1, %rdi
    xor %eax, %eax
    call printf

    mov $fmt_in, %rdi
    mov $num2, %rsi
    xor %eax, %eax
    call scanf

    pop %rbp
    ret

imprime:
    push %rbp
    mov %rsp, %rbp

    mov $fmt_out, %rdi
    mov %eax, %esi       
    xor %eax, %eax
    call printf

    pop %rbp
    ret

finaliza:
	xor %eax, %eax
	pop %rbp
	ret

soma:
	call ler_numero
	add num2, %eax
	call imprime
	jmp finaliza

subtracao:
	call ler_numero
	sub num2, %eax
	call imprime
	jmp finaliza

multiplicacao:
	call ler_numero
	mul num2
	call imprime
	jmp finaliza

divisao:
	call ler_numero
	div num2
	call imprime
	jmp finaliza

exponenciacao:
	call ler_numero
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
	call imprime
	jmp finaliza

combinacao:

arranjo:

fatorial:
	mov $1, %eax
	cmp $1, %edi
	jle fim_fatorial

fat_loop:
	imull %edi, %eax
	subl $1, %edi
	cmp $1, %edi
	jg fat_loop

fim_fatorial:
	call imprime
	jmp finaliza
	
inverso:

raiz:

logaritmo:

prox_primo:






