.global main

# gcc -o trab01 -no-pie trab01.s
# fazer:
# - o primeiro operando DEVE ser um nuemro real
# - As operações “+”, “-”, “*”, “/”, “^”, “c”, “a” e “l” devem receber o segundo operando (outro número real);
# - combinacao
# - inverso
# - raiz
# - log
# - proximo primo 
# - Na operacao de divisao, verificar se o divisor = 0
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
	.lcomm num1, 4 # alocacao de 4 bytes para int ou float p/ primeiro numero
	.lcomm num2, 4 # alocacao de 4 bytes para int ou float p/ segundo numero
	.lcomm operador, 1 # aloca 1 byte p/ operador
	.lcomm temp, 4 # variavel temporaria
	.lcomm continuar, 1 # controla o loop
.section .text
main:
	push %rbp
	mov %rsp, %rbp

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
	mov $operador, %rsi
	xor %eax, %eax
	call scanf



	# Logica if-else para definir qual a operacao 
	movb operador, %al

	# Operacoes de 1 operando
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
	

	# Operacoes com 2 operandos
	mov $msg1, %rdi
    xor %eax, %eax
    call printf

    mov $fmt_in, %rdi
    mov $num2, %esi
    xor %eax, %eax
    call scanf


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

	
imprime:
    push %rbp
    mov %rsp, %rbp
    mov $fmt_out, %rdi
    mov %eax, %esi       
    xor %eax, %eax
    call printf
    pop %rbp
    ret

loop_prog:
	push %rbp
	mov %rsp, %rbp

	mov $msg_continue, %rdi
	xor %eax, %eax
	call printf

	mov $fmt_char, %rdi
	mov $continuar, %rsi
	xor %eax, %eax
	call scanf

	movb continuar, %al 

	cmp $'s', %al
	je main

	cmp $'S', %al
	je main

	pop %rbp
	ret

finaliza:
	xor %eax, %eax
	pop %rbp
	ret

soma:
	mov num1, %eax
	add num2, %eax

	call imprime
	call loop_prog
	jmp finaliza

subtracao:
	mov num1, %eax
	sub num2, %eax
	call imprime
	call loop_prog
	jmp finaliza

multiplicacao:
	mov num1, %eax
	imull num2, %eax
	
	mov num1, %eax
	imull num2, %eax
	call imprime
	call loop_prog
	jmp finaliza

divisao:
	mov num1, %eax
	mov num2, %ecx
	cmp $0, %ecx
	je erro_divisao
	
	idivl %ecx 
	call imprime
	call loop_prog
	jmp finaliza

erro_divisao:
	mov $msg_erro_zero, %rdi
	xor %eax, %eax
	call printf
	call loop_prog
	jmp finaliza

exponenciacao:
    mov num1, %eax
	mov %eax, temp
	jmp exp_check
	call loop_prog
	jmp finaliza

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
	call loop_prog
	jmp finaliza

combinacao:
	mov num1, %edi
	call arranjo_calc
	# salvar registradores caller-save
	call inverso
	# restaurar regsitradores caller-save
	call loop_prog
	jmp finaliza

arranjo:
	push %rbp
	mov %rsp, %rbp
	mov num1, %edi
	call arranjo_calc
	call imprime
	call loop_prog
	pop %rbp
	jmp finaliza

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

fatorial: 
	mov num1, %edi
	call fatorial_calc 
	call imprime
	call loop_prog
	jmp finaliza 

fatorial_calc:
	mov $1, %eax
	cmp $1, %edi
	jle fim_fat_calc

fat_loop:
	imull %edi, %eax
	subl $1, %edi
	cmp $1, %edi
	jg fat_loop

fim_fat_calc:
	ret
	
inverso:
	# INiciar registro de ativação
	# Empilha registradores calle-save
	# 
	# blooc de codigo

	# Restaurar registro de ativação da funcao chamadora pop %rbp
	# Restaurar registradores calle-save pop 
	# ret

	call loop_prog
	jmp finaliza

raiz:
	call loop_prog
	jmp finaliza

logaritmo:
	call loop_prog
	jmp finaliza

prox_primo:
	call loop_prog
	jmp finaliza
