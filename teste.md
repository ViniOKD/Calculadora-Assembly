# Fluxo


**Main** (main, inicio, loop_main, nao_variavel, op_invalida, atribuicao, consulta, trata_funcao, procura_parenteses, fim_parenteses, definicao_funcao, copia_corpo, chama_funcao)
**Avalia_funcao**
**Callers**
**Parser**(parse_operando, po_numero, parse_numero, parse_int_loop, parse_real, parse_real_loop, parse_fim, parse_ret)
**sys_read_line**(sys_readline, rl_loop, rl_fim,)
## Parser LEMBRAR QUE MUDEI UM REGISTRADOR CL PARA ECX PARA TESTAR
No inicio, o endereço do buffer está no rdi

**Quando a entrada é uma variavel** -> nao tem frame de ativação | sera q tem q ter
Registradores:
- xmm0 -> Acumulador
- rdi -> funciona como cursor/ponteiro
- eax -> tem o valor do caracter
- rdx -> tem o vetor_variaveis
- al -> indice
- rax -> indice
- xmm0 -> tem a variavel

**Quando a entrada é numero/constante**
Registradores empilhados: 
- rbp -> padrão pra ativar o frame de ativação
- rbx -> callee-saved, usado para guardar flag de sinal

Registradores gerais:
- xmm0 -> Acumulador iniciado em 0.0
- rdi -> ponteiro
- ecx -> valor do caracter
- ebx -> marcador de sinal (0 se o numero for positivo, 1 se o numero for negativo)
- xmm1 -> tem o valor temporario da constante, antes de converter e jogar de volta pro ac xmm0
- xmm2 -> outro reg temporario

## Readline
Regs Empilhados:
- rbp -> ativa frame
- rbx -> callee-saved, guarda o endereco base do buffer de input, onde a linha vai ser armazenada
- r15 -> callee-saved, contador de quantos caracteres ja foram lidos, comeca em 0

Regs:
- rax -> qtd de bytes lidos
- rsi -> aponta pra prox posicao livre

## Avalia funcao
**regs callee:**
- rbp -> padrao
- r13 -> Armazena o Operador (+,-,*, ....)
- r14 ->
- r15

**regs**:
- rdi -> ponteiro
- eax -> letra da funcao
- rsi -> tem o vetor_variaveis
- 




# Problemas

Nao_variavel e avalia_funcao estão com codigos duplicados

