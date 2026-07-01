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
.extern sys_print
# 
# 
# 
.section .data
    msg_debug: .asciz "ENTREI\n"
    msg0: .asciz "Digite a expressao: \n"
    msg_cont:   .asciz "Deseja continuar? (s/n): \n"
    msg_inv_op: .asciz "Operacao desconhecida.\n"
    msg_erro_zero: .asciz "Erro: O Operando não pode ser igual a zero.\n"
    msg_erro_nao_positivo: .asciz "Erro: O Operando deve ser um número positivo.\n"
    msg_erro_nao_inteiro_negativo: .asciz "Erro: O Operando deve ser um número inteiro não-negativo.\n"
    msg_erro_base_log: .asciz "Erro: A base do logaritmo deve ser maior que 0 e diferente de 1.\n"
    msg_operador_maior: .asciz "Erro: O primeiro operando deve ser maior ou igual ao segundo.\n"
    msg_inv_exp: .asciz "Erro: Expressão inválida.\n"
    msg_func_malformado: .asciz "Erro: Função mal formada.\n"
    fmt_in: .asciz "%f"
    fmt_char: .asciz " %c"
    dez_float: .float 10.0
    zero_float: .float 0.0
    vetor_variaveis: .skip 26*4 # [10, a+20, 40]
    
.section .bss
    .lcomm buf_input, 64
    .lcomm buf_output, 4
    .lcomm continuar, 1 # controla o loop
    .lcomm vetor_funcoes, 832 # guarda as expressoes 
    
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
    mov (%rdi), %al # pega o primeiro carac
    cmp $'a', %al # ve se o primerrio carac é uma letra
    jl nao_variavel
    cmp $'z', %al
    jg nao_variavel

    movzx 1(%rdi), %ecx # anda o ponteiro -> vai pro segundo caracter
    cmp $'=', %cl # ve se é atribuicao
    je atribuicao    
    cmp $0, %cl  # ve se é EOF
    je consulta # a _> xmm0
    cmp $'(', %cl  # ve se é uma funcao
    je trata_funcao 
    
nao_variavel: # 
    call parse_operando # ################################################### a+b -> parse -> a -> consulta -> xmm0, b -> parse -> xmm0 
    movss %xmm0, num1 # num1 = xmm0
    mov (%rdi), %r12d # pega o operador e coloca em r12
    inc %rdi
    cmp $'!', %r12b
    je fatorial_caller
    cmp $'r', %r12b
    je raiz_caller
    cmp $'i', %r12b
    je inverso_caller

    call parse_operando 
    movss %xmm0, num2 # num2 = xmm0

    cmp $'+', %r12b
    je soma_caller
    cmp $'-', %r12b
    je subtracao_caller
    cmp $'*', %r12b
    je multiplicacao_caller
    cmp $'/', %r12b
    je divisao_caller
    cmp $'^', %r12b
    je exponenciacao_caller
    cmp $'c', %r12b
    je combinacao_caller
    cmp $'a', %r12b
    je arranjo_caller
    cmp $'l', %r12b
    je logaritmo_caller
    cmp $'p', %r12b
    je prox_primo_caller

op_invalida:
    mov $msg_inv_op, %rdi
    call sys_print
    jmp loop_prog
    
atribuicao:
    sub $'a', %al
    movzbq %al, %rax
    add $2, %rdi # pula a=
    call parse_numero
    movss %xmm0, vetor_variaveis(,%rax,4) # coloca o valor no vetor de variaveis 
    jmp loop_prog

consulta: # valor da variavel vai pra xmm0
    movb (%rdi), %al # pega a letra
    subb $'a', %al # 'a'->0, 'b'->1, ...
    movzbq %al, %rax # índice
    movss vetor_variaveis(,%rax,4), %xmm0
    call imprime_float
    jmp loop_prog


# Tratamento de funcoes 
trata_funcao:
    movzbl (%rdi), %eax # letra da funcao
    sub $'a', %al # tira o a em ascii do al pra pegar o indice da letra da funcao
    movzbl %al, %r13d

    lea 2(%rdi), %rcx # pula "f()"

procura_parenteses:
    movzbl (%rcx), %edx   
    test %dl, %dl
    je erro_func_malformado 
    cmp $')', %dl
    je fim_parenteses
    inc %rcx
    jmp procura_parenteses

fim_parenteses: 
    movzbl 1(%rcx), %edx # rcx aponta pro ')' e pega o próximo caractere
    cmp $'=', %dl
    je definicao_funcao
    jmp chama_funcao

# Define funcao -> Salva no vetor_funcoes[indice] o corpo da funcao
definicao_funcao:
    # O %rdi original ainda aponta para o começo da string (ex: "f(a)=10+a")
    # Portanto, a letra do parâmetro ('a') está exatamente no deslocamento 2
    movzbl 2(%rdi), %r9d         # Salva o parâmetro temporariamente em %r9d
    
    lea 2(%rcx), %rsi            # %rsi aponta para o caractere depois do '=' (início do corpo)
    
    # Calcula o endereço destino no vetor de funções
    mov %r13, %rax
    imul $32, %rax
    mov $vetor_funcoes, %rdi
    add %rax, %rdi               # %rdi = destino: vetor_funcoes[indice]

    # Grava o parâmetro no byte 0 e avança o ponteiro
    movb %r9b, (%rdi)
    inc %rdi                     # O corpo começará a ser gravado no byte 1

    mov $30, %r8                 # Ajusta o limite de cópia (sobram 30 bytes + 1 pro null)
    
copia_corpo:
    movzbl (%rsi), %eax
    movb %al, (%rdi)
    test %al, %al
    je loop_prog                 # fim da string original
    inc %rsi
    inc %rdi
    dec %r8
    jnz copia_corpo

    movb $0, (%rdi)              # Força terminador caso o limite estoure
    jmp loop_prog

# Chama uma funcao ja definida -> Avalia o argumento e executa o corpo
chama_funcao:

    inc %rdi                      # Vai pro '('
    cmpb $'(', (%rdi)
    jne erro_func_malformado
    inc %rdi                      # Vai pro argumento (ex: '2')

    call parse_operando          
    cmpb $')', (%rdi)
    jne erro_func_malformado
    inc %rdi                      

    movaps %xmm0, %xmm7          

    mov $vetor_funcoes, %rsi     
    mov %r13, %rax               
    imul $32, %rax
    add %rax, %rsi               # %rsi aponta pro vetor da função

    movzbl (%rsi), %eax          # Lê o parâmetro que salvamos na definicao (byte 0)
    test %al, %al
    je erro_func_malformado      # Se for 0, função não existe

    cmp $'a', %al
    jl erro_func_malformado
    cmp $'z', %al
    jg erro_func_malformado

    sub $'a', %al                
    movzbq %al, %rax
    movss %xmm7, vetor_variaveis(,%rax,4)

    inc %rsi                     # Pula o byte do parâmetro, caindo no começo do corpo
    mov %rsi, %rdi               # Redireciona o %rdi (ex: agora ele aponta para "10+a")

    jmp nao_variavel             # Avalia a expressão da função

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

logaritmo_caller:
    movss num1, %xmm0
    call valida_positivo
    test %edx, %edx
    jz erro_nao_positivo # caso não seja positivo, vai para erro

    movss num1, %xmm0
    call valida_igual_zero
    test %edx, %edx
    jz erro_igual_zero # caso seja igual a zero, vai para erro


    call valida_base_log
    test %edx, %edx
    jz erro_base_log # caso não seja válido, vai para erro


    movss num1, %xmm0
    movss num2, %xmm1
    call logaritmo
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

# Parser
parse_operando: # rdi aponta pro caractere atual retorna valor em xmm0, avança rdi
    movzx (%rdi), %eax
    cmp $'a', %al
    jl po_numero
    cmp $'z', %al
    jg po_numero
    sub $'a', %al
    movzbq %al, %rax
    mov $vetor_variaveis, %rdx
    movss (%rdx, %rax, 4), %xmm0
    inc %rdi
    ret

po_numero:
    jmp parse_numero
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
                

parse_int_loop:
    movzx (%rdi), %ecx # joga o endereco do rdi no eax
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
    jmp parse_real_loop


parse_fim:
    test %ebx, %ebx
    jz parse_ret
    
    # Se era negativo inverte o valor de xmm0
    movss zero_float, %xmm1
    subss %xmm0, %xmm1
    movaps %xmm1, %xmm0

parse_ret:
    pop %rbx
    pop %rbp
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

    ucomiss %xmm2, %xmm0
    jbe base_invalida

    movss float_um, %xmm2
    ucomiss %xmm2, %xmm0
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
    call sys_print
    jmp loop_prog

erro_nao_positivo:
    mov $msg_erro_nao_positivo, %rdi
    xor %eax, %eax
    call sys_print
    jmp loop_prog

erro_igual_zero:
    mov $msg_erro_zero, %rdi
    xor %eax, %eax
    call sys_print
    jmp loop_prog

erro_base_log:
    mov $msg_erro_base_log, %rdi
    xor %eax, %eax
    call sys_print
    jmp loop_prog

erro_operador_maior:
    mov $msg_operador_maior, %rdi
    xor %eax, %eax
    call sys_print
    jmp loop_prog

erro_expressao_invalida:
    mov $msg_inv_exp, %rdi
    xor %eax, %eax
    call sys_print
    jmp loop_prog

erro_func_malformado:
    mov $msg_func_malformado, %rdi
    call sys_print
    jmp loop_prog

fim:
    pop %r12
    pop %r13
    pop %rbp
    ret
