.global _start
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
# as --64 -o trab02.o trab02.s
# as --64 -o lib.o lib.s
# ld -o programa trab02.o lib.o
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
    vetor_variaveis: .skip 26*4 # 
    
.section .bss
    .lcomm buf_input, 64
    .lcomm buf_output, 4
    .lcomm continuar, 1 # controla o loop
    .lcomm vetor_funcoes, 832 # guarda as expressoes 
    
.section .text
_start:
    call inicio
    mov $60, %rax    # syscall exit
    xor %rdi, %rdi
    syscall
    
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
    # ve se o primeiro carac é uma letra
    cmp $'a', %al 
    jl nao_variavel
    cmp $'z', %al
    jg nao_variavel

    movzx 1(%rdi), %ecx # anda o ponteiro -> vai pro segundo caracter
    cmp $'=', %cl # ve se é atribuicao
    je atribuicao    
    cmp $0, %cl  # ve se é EOF
    je consulta 
    cmp $'(', %cl  # ve se é uma funcao
    je trata_funcao 
    
nao_variavel: 
    call parse_operando # Dps do parse_operando, o ponteiro (rdi) aponta pro operador e o valor vem em xmm0

    movss %xmm0, num1 # num1 = xmm0
    mov (%rdi), %r12d # pega o operador e coloca em r12
    inc %rdi
    cmp $'!', %r12b
    je fatorial_caller
    cmp $'r', %r12b
    je raiz_caller
    cmp $'i', %r12b
    je inverso_caller
    cmp $'p', %r12b
    je prox_primo_caller

    call parse_operando # resultado vem em xmm0, rdi vai estar em EOF/quebra de linha?
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
    

op_invalida:
    mov $msg_inv_op, %rdi
    call sys_print
    jmp loop_prog
    
atribuicao:
    sub $'a', %al # pega o indice da letra da variavel (0-25)
    movzbq %al, %rax # joga no rax, zero extendendo
    add $2, %rdi # anda o ponteiro pra pular a letra e o '='
    call parse_numero # resultado vem em xmm0
    movss %xmm0, vetor_variaveis(,%rax,4) # coloca o valor no vetor de variaveis 
    jmp loop_prog

consulta: # valor da variavel vai pra xmm0 
    # o caracter da variavel ja esta em al?
    movb (%rdi), %al # pega a letra
    subb $'a', %al # calcula o indice da letra da variavel (0-25)
    movzbq %al, %rax # joga no rax
    movss vetor_variaveis(,%rax,4), %xmm0  # pega o valor da variavel no vetor e joga no xmm0
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
    movzbl 1(%rcx), %edx
    cmp $'=', %dl
    je definicao_funcao
    test %dl, %dl # '\0' depois do ')' -> chamada isolada (imprime direto)
    je chama_funcao
    jmp nao_variavel 

# Define funcao -> Salva no vetor_funcoes[indice] o corpo da funcao
definicao_funcao:
    # O %rdi original ainda aponta para o começo da string (ex: "f(a)=10+a")
    # Portanto, a letra do parâmetro ('a') está exatamente no deslocamento 2
    movzbl 2(%rdi), %r9d # Salva o parâmetro temporariamente em %r9d
    
    lea 2(%rcx), %rsi # %rsi aponta para o caractere depois do '=' (início do corpo)
    
    # Calcula o endereço destino no vetor de funções
    mov %r13, %rax
    imul $32, %rax
    mov $vetor_funcoes, %rdi
    add %rax, %rdi # %rdi = destino: vetor_funcoes[indice]

    # Grava o parâmetro no byte 0 e avança o ponteiro
    movb %r9b, (%rdi)
    inc %rdi # O corpo começará a ser gravado no byte 1

    mov $30, %r8 # Ajusta o limite de cópia (sobram 30 bytes + 1 pro null)
    
copia_corpo:
    movzbl (%rsi), %eax
    movb %al, (%rdi)
    test %al, %al
    je loop_prog # fim da string original
    inc %rsi
    inc %rdi
    dec %r8
    jnz copia_corpo

    movb $0, (%rdi) # Força terminador caso o limite estoure
    jmp loop_prog

# Chama uma funcao ja definida -> Avalia o argumento e executa o corpo
chama_funcao:
    inc %rdi # Vai pro '('
    cmpb $'(', (%rdi)
    jne erro_func_malformado
    inc %rdi # Vai pro argumento (ex: '2')

    call parse_operando          
    cmpb $')', (%rdi)
    jne erro_func_malformado
    inc %rdi                      

    movaps %xmm0, %xmm7          

    mov $vetor_funcoes, %rsi     
    mov %r13, %rax               
    imul $32, %rax
    add %rax, %rsi # %rsi aponta pro vetor da função

    movzbl (%rsi), %eax # Lê o parâmetro que salvamos na definicao (byte 0)
    test %al, %al
    je erro_func_malformado # Se for 0, função não existe
    cmp $'a', %al
    jl erro_func_malformado
    cmp $'z', %al
    jg erro_func_malformado
    sub $'a', %al                
    movzbq %al, %rax
    movss %xmm7, vetor_variaveis(,%rax,4)
    inc %rsi # Pula o byte do parâmetro, caindo no começo do corpo
    mov %rsi, %rdi # Redireciona o %rdi (ex: agora ele aponta para "10+a")
    jmp nao_variavel # Avalia a expressão da função

avalia_funcao:
    push %rbp
    mov %rsp, %rbp

    push %r13
    push %r14
    push %r15

    movzbl (%rdi), %eax # letra da funcao
    sub $'a', %al
    movzbl %al, %r13d # indice da funcao
    add $2, %rdi # pula "f(" -> aponta pro argumento

    call parse_operando # avalia o argumento (numero, variavel ou outra chamada)
    cmpb $')', (%rdi)
    jne af_malformado
    inc %rdi # pula ')'
    mov %rdi, %r14 # guarda o %rdi externo (posicao depois do ')')

    movaps %xmm0, %xmm7 # guarda o valor do argumento

    mov $vetor_funcoes, %rsi # joga o vetor no rsi
    mov %r13, %rax # indice no rax
    imul $32, %rax # multiplica por 32 (tamanho de cada funcao)
    add %rax, %rsi # %rsi aponta pro inicio da funcao no vetor_funcoes, entao somando com rax ele aponta pro byte 0 da funcao (parametro)
    movzbl (%rsi), %eax # parametro (byte 0)
    test %al, %al
    je af_malformado # funcao nao definida
    cmp $'a', %al
    jl af_malformado
    cmp $'z', %al
    jg af_malformado
    sub $'a', %al
    movzbq %al, %rax
    movss %xmm7, vetor_variaveis(,%rax,4) # parametro := argumento

    inc %rsi # %rsi -> corpo da funcao
    mov %rsi, %r15 # guarda ponteiro do copo

    mov num1, %eax # guarda num1 e num2 na pilha, pois eles serão sobrescritos
    push %rax
    mov num2, %eax
    push %rax

    mov %r15, %rdi # avalia o corpo "operando OP operando" sem imprimir
    call parse_operando
    movss %xmm0, num1
    movzbl (%rdi), %r13d # operador do corpo
    inc %rdi

    cmp $'!', %r13b
    je af_fatorial
    cmp $'r', %r13b
    je af_raiz
    cmp $'i', %r13b
    je af_inverso
    cmp $'p', %r13b
    je af_prox_primo

    call parse_operando
    movss %xmm0, num2

    cmp $'+', %r13b
    je af_soma
    cmp $'-', %r13b
    je af_sub
    cmp $'*', %r13b
    je af_mul
    cmp $'/', %r13b
    je af_div
    cmp $'^', %r13b
    je af_exp

    cmp $'l', %r13b
    je af_logaritmo
    cmp $'c', %r13b
    je af_combinacao
    cmp $'a', %r13b
    je af_arranjo


    movss num1, %xmm0 # operador nao suportado no corpo: devolve o operando 1
    jmp af_fim

af_soma:
    call soma
    jmp af_fim

af_sub:
    call subtracao
    jmp af_fim
    
af_mul:
    call multiplicacao
    jmp af_fim

af_div:
    call divisao
    # Verifica o codigo de status que voltou no %eax
    test %eax, %eax       
    jz loop_prog # Se for 0 (jz = Jump if Zero), pula a impressao e volta pro loop
    
    # Se nao for zero, a divisao deu certo, entao imprime o float
    jmp af_fim

af_logaritmo:
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
    jmp af_fim

af_combinacao:
    call combinacao
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

    jmp af_fim

af_arranjo:
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
    jmp af_fim
    
af_fatorial:
    movss num1, %xmm0
    call valida_inteiro_positivo
    test %edx, %edx
    jz erro_nao_inteiro_negativo # caso não seja inteiro positivo, vai para erro

    mov %eax, %edi # passa o valor inteiro de num1 para %edi

    call fatorial
    cvtsi2ss %eax, %xmm0
    jmp af_fim


af_raiz:
    movss num1, %xmm0
    call valida_positivo
    test %edx, %edx
    jz erro_nao_positivo # caso não seja positivo, vai para erro
    call raiz
    jmp af_fim

af_inverso:
    movss num1, %xmm0
    call valida_igual_zero
    test %edx, %edx
    jz erro_igual_zero # caso seja igual a zero, vai para erro
    call inverso
    jmp af_fim

af_prox_primo:
    movss num1, %xmm0
    call valida_inteiro_positivo
    test %edx, %edx
    jz erro_nao_inteiro_negativo
    call prox_primo
    jmp af_fim

af_exp:
    call exponenciacao
    jmp af_fim

af_fim:
    pop %rax # restaura num2 
    mov %eax, num2
    pop %rax # restaura num1
    mov %eax, num1
    mov %r14, %rdi # restaura %rdi externo (depois do ')')
    pop %r15
    pop %r14
    pop %r13
    pop %rbp
    ret

af_malformado:
    pop %rax
    pop %r15
    pop %r14
    pop %r13
    pop %rbp
    jmp erro_func_malformado

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
    movzx (%rdi), %eax  # le o byte apontado pelo rdi
    # Verificação se o caracter é uma letra, pula para 'po_numero' caso não seja letra
    cmp $'a', %al
    jl po_numero
    cmp $'z', %al
    jg po_numero
    # Verifica o caracter afrente do cursor, se for '(' entendemos que é o nome de uma funcao sendo chamada
    cmpb $'(', 1(%rdi) 
    je avalia_funcao

    # Apartir daqui assumimos que a entrada é uma variavel,
    sub $'a', %al # Transforma o caracter em indice de 0-25, com 'a' = 0
    movzbq %al, %rax  # joga esse indice no rax, zero estendendo ele pra caber sem guardar lixo
    mov $vetor_variaveis, %rdx # carrega o 'vetor_variaveis' no rdx
    movss (%rdx, %rax, 4), %xmm0 # le o flot na posicao (rax * 4) | xmm0 =vetor_variaveis[indice=rax] 
    inc %rdi # avança o ponteiro
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

    # verifica se o numero é negativo ou nao
    # se for, marca o %ebx com 1
    movzx (%rdi), %ecx 
    cmp $'-', %cl
    jne parse_int_loop
    mov $1, %ebx
    inc %rdi
                
# A cada iteração le um caracter, se encontrar '.'
# muda o parsing da parte fracionaria
# Se for diferente de um numero 0-9, encerra
parse_int_loop:
    movzx (%rdi), %ecx # joga o caracter rdi no ecx
    cmp $'.', %cl 
    je parse_real 

    # ve se é numero 0-9, se nao for, sai do loop
    cmp $'0', %cl
    jl parse_fim
    cmp $'9', %cl
    jg parse_fim
    # multiplica o acumulador por 10.0
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

    mov $buf_input, %rbx # joga o buffer pro rbx
    xor %r15, %r15 # zera r15

rl_loop:
    mov $0, %eax   # syscall pra sys_read
    mov $0, %rdi   
    mov %rbx, %rsi # joga o buffer pro rsi e soma r15 pra ir pro prox byte
    add %r15, %rsi # 
    mov $1, %rdx   # qtd de bytes a ler
    syscall        # le 1 byte e escreve no endereco passado -> rdx?

    cmp $0, %eax   # se syscall retornar 0, EOF, entao termina
    jle rl_fim               

    # ve se é quebra de linha/Enter, se for termina 
    movzx (%rbx, %r15), %eax
    cmp $'\n', %al
    je rl_fim


    cmp $63, %r15
    jge rl_fim

    # Continua o loop pra ler tudo
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
