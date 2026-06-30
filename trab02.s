.global main
.extern soma
.extern soma_int
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

.section .data
    msg0: .asciz "Digite a expressao: \n"
    msg_cont:   .asciz "Deseja continuar? (s/n): \n"
    msg_inv_op: .asciz "Operacao desconhecida.\n"
    fmt_in: .asciz "%f"
    fmt_char: .asciz " %c"
    dez_float: .float 10.0
    zero_float: .float 0.0

.section .bss
    .lcomm buf_input, 64
    .lcomm buf_output, 4
    .lcomm continuar, 1 # controla o loop

vetor_funcoes:
    .skip 108 # reserva 108 bytes para 27 inteiros

vetor_variaveis:
    .skip 108 # mesma coisa

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
    call sys_print 
    call sys_readline 
    
    mov $buf_input, %rdi # coloca o endereço de buf dentro de rdi
    call parse_numero
    movss %xmm0, num1
    # movss %xmm0, num1
    mov (%rdi), %r12d # pega o operador e coloca em r12
    inc %rdi
    cmp $'!', %r12b
    je fatorial_caller
    cmp $'r', %r12b
    je raiz_caller
    cmp $'i', %r12b
    je inverso_caller

    call parse_numero
    movss %xmm0, num2

    cmp  $'+', %r12b
    je   soma_caller
    cmp  $'-', %r12b
    je   subtracao_caller
    cmp  $'*', %r12b
    je   multiplicacao_caller
    cmp  $'/', %r12b
    je   divisao_caller
    cmp  $'^', %r12b
    je   exponenciacao_caller
    cmp  $'c', %r12b
    je   combinacao_caller
    cmp  $'a', %r12b
    je   arranjo_caller

# 
op_invalida:
    mov $msg_inv_op, %rdi
    call sys_print
    jmp loop_prog

# Callers
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
    cvttss2si %xmm0, %edi
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

# Loop
loop_prog:
    mov $msg_cont, %rdi
    call sys_print
    call sys_readline
    movb buf_input, %r12b

    cmp $'s', %r12b
    je loop_main

    cmp $'S', %r12b
    je loop_main
    
    jmp fim

#
# Funcao Parse
parse_numero: # o endereco do buffer esta em rdi
    push %rbp
    mov %rsp, %rbp
    push %rbx

    xor %ebx, %ebx
    movss zero_float, %xmm0 # acumulador

    movzx (%rdi), %ecx 
    cmp $'-', %cl
    jne parse_int_loop
    mov $1, %ebx
    inc %rdi

    // xor %eax, %eax # zera eax
    // xor %ebx, %ebx  # zera ebx, que será usado para marcar se o número é negativo
    // xor %ecx, %ecx # zera ecx, que será usado para armazenar o caractere atual
    // movzx (%rdi), %ecx # le um caractere
    // cmp $'-', %cl
    // jne parse_loop
    // mov $1, %ebx # se for negativo marca ebx com 1              
    // inc %rdi                   

parse_int_loop:
    movzx (%rdi), %eax # joga o endereco do rdi no eax
    cmp $'.', %cl
    je parse_real

    cmp $'0', %cl
    jl parse_fim
    cmp $'9', %cl
    jg parse_fim

    mulss dez_float, %xmm0 # multiplica o acumulador por 10.0

    sub $'0', %cl
    cvtsi2ss %ecx, %xmm1
    addss %xmm1, %xmm0 

    inc %rdi
    jmp parse_int_loop

parse_real:
    inc %rdi # pra pular o '.'
    movss dez_float, %xmm2 

parse_real_loop:
    movzx (%rdi), %ecx
    cmp $'0', %cl
    jl parse_fim
    cmp $'9', %cl
    jg parse_fim
    sub $'0', %cl
    cvtsi2ss %ecx, %xmm1

    divss %xmm2, %xmm1
    addss %xmm1, %xmm0
    mulss dez_float, %xmm2

    inc %rdi
    jmp parse_real




parse_fim:
    test %ebx, %ebx
    jz parse_ret
    
    # Se era negativo inverte o valor de xmm0
    movss zero_float, %xmm1
    subss %xmm0, %xmm1
    movaps %xmm1, %xmm0

parse_ret:
    pop %rbx
    ret
# Leitura
sys_readline:
    push %rbp
    mov  %rsp, %rbp
    push %rbx
    push %r15

    mov $buf_input, %rbx
    xor %r15, %r15

rl_loop:
    mov $0, %eax
    mov $0, %rdi
    mov %rbx, %rsi
    add %r15, %rsi # calcula o endereço onde o prox byte sera escrito
    mov $1, %rdx
    syscall

    cmp $0, %eax
    jle rl_fim               

    movzx (%rbx, %r15), %eax
    cmp $'\n', %al
    je rl_fim

    cmp $63, %r15
    jge rl_fim

    inc %r15
    jmp rl_loop

rl_fim:
    movb $0, (%rbx, %r15)
    mov %r15, %rax
    pop %r15
    pop %rbx
    pop %rbp
    ret

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

fim:
    pop %r12
    pop %r13
    pop %rbp
    ret

