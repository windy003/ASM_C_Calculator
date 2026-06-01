; calc.asm — 命令行四则运算计算器 (Windows x64, NASM)
; ----------------------------------------------------------
; 编译链接 (需要 nasm 和 gcc/MinGW-w64):
;   nasm -f win64 calc.asm -o calc.obj
;   gcc calc.obj -o calc.exe
; 运行:
;   chcp 65001   (让控制台用 UTF-8 正确显示中文)
;   .\calc.exe
; 用法: 输入  12 + 5  这样的算式回车; 输入 q 或非数字退出
; ----------------------------------------------------------

bits 64
default rel                 ; 用 RIP 相对寻址, x64 链接更省事

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
    push rbp
    mov  rbp, rsp
    sub  rsp, 32              ; 影子空间 (Win64 调用约定要求), 此时 rsp 仍 16 字节对齐

    lea  rcx, [welcome]
    call printf

.loop:
    lea  rcx, [prompt]
    call printf

    ; scanf(" %lld %c %lld", &a, &op, &b)
    lea  rcx, [fmt_in]
    lea  rdx, [a]
    lea  r8,  [op]
    lea  r9,  [b]
    call scanf

    cmp  eax, 3              ; 成功读到 3 项? 否则视为退出 (含输入 q / EOF)
    jne  .done

    mov  rax, [a]           ; rax = a
    mov  r10, [b]           ; r10 = b
    movzx ecx, byte [op]    ; cl  = 运算符

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
    cqo                     ; 把 rax 符号扩展进 rdx:rax
    idiv r10                ; rax = 商, rdx = 余数
    ; jmp .print            ; 顺势落入 .print

.print:
    lea  rcx, [fmt_out]
    mov  rdx, rax
    call printf
    jmp  .loop

.div0:
    lea  rcx, [msg_div0]
    call printf
    jmp  .loop

.badop:
    lea  rcx, [msg_op]
    movzx edx, byte [op]
    call printf
    jmp  .loop

.done:
    lea  rcx, [msg_bye]
    call printf

    xor  eax, eax           ; return 0
    add  rsp, 32
    pop  rbp
    ret
