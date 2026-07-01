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
.global sys_print

.section .data
	fmt_out: .asciz "Resultado: %d\n"
    fmt_out_float: .asciz "Resultado: %.2f\n"
	msg_erro_zero: .asciz "Erro: O divisor não pode ser 0. \n"
	float_um: .float 1.0
    cem_float:  .float 100.0
    char_ponto: .asciz "."
    char_menos: .asciz "-"
    char_nl:    .asciz "\n"
    char_zero:  .asciz "0"
.bss 
	.lcomm num1, 4 # alocacao de 4 bytes para int ou float p/ primeiro numero
	.lcomm num2, 4 # alocacao de 4 bytes para int ou float p/ segundo numero
	.lcomm operacao, 1 # aloca 1 byte p/ operador
	.lcomm temp, 4 # variavel temporaria
    .lcomm int_buffer, 32

.section .text

sys_print:
    push %rbp
    mov %rsp, %rbp
    push %rbx
    push %rcx

    mov %rdi, %rbx
    xor %rcx, %rcx

sp_len:
    cmpb $0, (%rbx, %rcx)
    je sp_write
    inc %rcx
    jmp sp_len

sp_write:
    mov $1, %eax 
    mov $1, %rdi
    mov %rbx, %rsi 
    mov %rcx, %rdx
    syscall

    pop %rcx
    pop %rbx
    pop %rbp
    ret

imprime_float:
    push %rbp
    mov %rsp, %rbp
    sub $16, %rsp         
    
    xorps %xmm1, %xmm1    
    ucomiss %xmm1, %xmm0  # Compara xmm0 com 0.0
    jae ifloat_pos        # Se for >= 0, pula

    lea char_menos(%rip), %rdi
    call sys_print
    
    xorps %xmm2, %xmm2
    subss %xmm0, %xmm2
    movaps %xmm2, %xmm0

ifloat_pos:
    cvttss2si %xmm0, %eax # Converte xmm0 truncando para inteiro
    mov %eax, -4(%rbp) # Salva a parte inteira na pilha
    call print_uint # Imprime a parte inteira
    

    lea char_ponto(%rip), %rdi
    call sys_print

    mov -4(%rbp), %eax    
    cvtsi2ss %eax, %xmm1  
    subss %xmm1, %xmm0    
    
    movss cem_float(%rip), %xmm2
    mulss %xmm2, %xmm0
    cvttss2si %xmm0, %eax

    # Se a fração for menor que 10, multiplicá-la por 100 resulta em algo < 10 (ex: 5).
    # Precisamos imprimir um '0' antes, para não sair "12.5" em vez de "12.05"
    cmp $10, %eax
    jge ifloat_frac_print
    
    mov %eax, -8(%rbp)    
    lea char_zero(%rip), %rdi
    call sys_print
    mov -8(%rbp), %eax

ifloat_frac_print:
    call print_uint   
  
    lea char_nl(%rip), %rdi
    call sys_print
    mov %rbp, %rsp
    pop %rbp
    ret

# Funcao Auxiliar: Converte %eax para ASCII e imprime
print_uint:
    push %rbp
    mov %rsp, %rbp
    push %rbx
    push %rcx
    push %rdx
    push %rdi
    push %rsi
    
    mov $int_buffer, %rsi
    add $30, %rsi         
    movb $0, (%rsi)       
    mov $10, %ebx        

    test %eax, %eax
    jnz uint_loop
    
    dec %rsi
    movb $'0', (%rsi)
    jmp uint_done

uint_loop:
    test %eax, %eax
    jz uint_done
    
    xor %edx, %edx      
    div %ebx            
    
    add $'0', %dl         
    dec %rsi             
    movb %dl, (%rsi)      
    jmp uint_loop

uint_done:
    mov %rsi, %rdi        
    call sys_print      
    
    pop %rsi
    pop %rdi
    pop %rdx
    pop %rcx
    pop %rbx
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
    
    movss num1(%rip), %xmm0
    movss num2(%rip), %xmm1
    
    xorps %xmm2, %xmm2
    ucomiss %xmm2, %xmm1
    je erro_divisao
    
    divss %xmm1, %xmm0
    mov $1, %eax             
    jmp fim_div

erro_divisao:
    lea msg_erro_zero(%rip), %rdi
    call sys_print          
    mov $0, %eax             

fim_div:
    pop %rbp
    ret

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
    
    call arranjo_calc 
    mov %eax, %r12d           # joga o calculo do arranjo em r12d
    
    #  Calcula fatorial
    movss num2(%rip), %xmm0   # Carrega o float num2
    cvttss2si %xmm0, %edi     # Converte para int
    call fatorial 
    mov %eax, %ecx
    
    # Calcula a Combinacao 
    mov %r12d, %eax
    cdq
    idivl %ecx


    cvtsi2ss %eax, %xmm0

    pop %r13
    pop %r12
    pop %rbp
    ret

# Arranjo
arranjo:
	push %rbp
    mov %rsp, %rbp
    
    call arranjo_calc
    cvtsi2ss %eax, %xmm0
    
    pop %rbp
    ret

arranjo_calc:
    #  calcula fatoria(num1)
    movss num1(%rip), %xmm0   # Carrega o float
    cvttss2si %xmm0, %edi     # Converte para int e joga no %edi
    call fatorial
    mov %eax, temp(%rip)      # Salva na temp
    
    # calcula fatorial(num1 - num2)
    movss num1(%rip), %xmm0   
    movss num2(%rip), %xmm1
    subss %xmm1, %xmm0        # Subtrai os floats primeiro (xmm0 = num1 - num2)
    cvttss2si %xmm0, %edi     # Converte a diferenca para int e joga no %edi
    
    call fatorial
    
    # divisao do arranjo (temp / fatorial(num1-num2))
    mov %eax, %ebx 
    mov temp(%rip), %eax
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
    cvtsi2ss %eax, %xmm0
	
	pop %rbp
	ret

logaritmo: # recebe logaritmando em xmm0 e base em xmm1
	push %rbp
	mov %rsp, %rbp
	sub $16, %rsp

	# calcula log2(logaritmando)
    movss %xmm0, (%rsp)
    fld1
	flds (%rsp)
    fyl2x

	# calcula log2(base)
    movss %xmm1, (%rsp)
    fld1
    flds (%rsp)
	fyl2x

	# mudanca de base

	fdivrp

	fstps (%rsp)
	movss (%rsp), %xmm0

	mov %rbp, %rsp
	pop %rbp
	ret
    