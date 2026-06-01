; calc_linux.asm — 命令行四则运算计算器 (Linux x64 / WSL, NASM)
; ----------------------------------------------------------
; 编译链接 (需要 nasm 和 gcc):
;   nasm -f elf64 calc_linux.asm -o calc.o
;   gcc -no-pie calc.o -o calc        # -no-pie 让直接 call printf 更省事
; 运行:
;   ./calc
; 用法: 输入  12 + 5  这样的算式回车; 输入 q 或非数字退出
; ----------------------------------------------------------

bits 64
default rel

extern printf
extern scanf

; ------------------- 只读数据 -------------------
section .data
    welcome   db "简易计算器 (输入如: 12 + 5),输入 q 退出", 10, 0
    prompt    db "> ", 0
    fmt_in    db " %lld %c %lld", 0      ; %c 前的空格用于跳过空白
    fmt_out   db "= %lld", 10, 0
    msg_div0  db "错误: 除数不能为 0", 10, 0
    msg_op    db "错误: 未知运算符 '%c'", 10, 0
    msg_bye   db "再见!", 10, 0

; ------------------- 可写变量 -------------------
section .bss
    align 8
    a    resq 1               ; 第一个操作数 (64位有符号)
    b    resq 1               ; 第二个操作数
    op   resb 1               ; 运算符字符
         resb 7               ; 补齐对齐

; ------------------- 代码 -------------------
section .text
global main

main:
    push rbp                 ; 进入时 rsp%16==8, push 后 ==0, 满足调用前 16 字节对齐
    mov  rbp, rsp

    lea  rdi, [welcome]
    xor  eax, eax            ; 变参函数: 使用了 0 个向量(SSE)寄存器
    call printf

.loop:
    lea  rdi, [prompt]
    xor  eax, eax
    call printf

    ; scanf(" %lld %c %lld", &a, &op, &b)
    lea  rdi, [fmt_in]
    lea  rsi, [a]
    lea  rdx, [op]
    lea  rcx, [b]
    xor  eax, eax
    call scanf

    cmp  eax, 3             ; 成功读到 3 项? 否则视为退出 (含输入 q / EOF)
    jne  .done

    mov  rax, [a]          ; rax = a
    mov  r10, [b]          ; r10 = b
    movzx ecx, byte [op]   ; cl  = 运算符

    cmp  cl, '+'
    je   .add
    cmp  cl, '-'
    je   .sub
    cmp  cl, '*'
    je   .mul
    cmp  cl, '/'
    je   .div
    jmp  .badop

.add:
    add  rax, r10
    jmp  .print
.sub:
    sub  rax, r10
    jmp  .print
.mul:
    imul rax, r10
    jmp  .print
.div:
    test r10, r10
    jz   .div0
    cqo                    ; 把 rax 符号扩展进 rdx:rax
    idiv r10               ; rax = 商, rdx = 余数
    ; 顺势落入 .print

.print:
    lea  rdi, [fmt_out]
    mov  rsi, rax
    xor  eax, eax
    call printf
    jmp  .loop

.div0:
    lea  rdi, [msg_div0]
    xor  eax, eax
    call printf
    jmp  .loop

.badop:
    lea  rdi, [msg_op]
    movzx esi, byte [op]
    xor  eax, eax
    call printf
    jmp  .loop

.done:
    lea  rdi, [msg_bye]
    xor  eax, eax
    call printf

    xor  eax, eax          ; return 0
    pop  rbp
    ret
