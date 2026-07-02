# Calculadora em Assembly (x86-64 AT&T)

Projeto da disciplina **Programação para Interfaceamento de Hardware e Software**
Este projeto contém duas versões de uma calculadora escrita em
Assembly x86-64 (sintaxe AT&T, GAS).

- Trab01: cada operando e o operador são lidos em linhas separadas.
- Trab02: a expressão inteira é digitada em uma única linha, com parser próprio e 
suporte a variáveis e funções de um parâmetro ´f(x)=x!´ e ´f(5)´ ou ´a+f(5)´
- lib.s: biblioteca externa com as operações matemáticas e rotinas de entrada/saída. Usa
syscall direto, calculam e retornam o valor para o programa principal, que imprime o resultado.

# Integrantes

- Isadora Dantas Bruchmam | RA: 140870
- Vinicius Taguchi Okada | RA: 140064

# Como compilar

- Trabalho 1:
´´´bash
gcc -o trab01 -no-pie trab01.s lib.s
´´´
- Trabalho 2:
´´´bash
as --64 -o trab02.o trab02.s
as --64 -o lib.o lib.s
ld -o programa trab02.o lib.o
´´´
Caso queira compilar o Trabalho 2 com gcc, é preciso trocar a funcao global ´_start´ por ´main´