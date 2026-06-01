/* calc_win.c — 命令行四则运算计算器 (Windows, C 版本)
 * ----------------------------------------------------------
 * 这是 ASM_win\calc_win.asm 的 C 语言等价实现, 行为保持一致。
 *
 * 编译 (任选其一):
 *   gcc calc_win.c -o calc.exe          (MinGW-w64 / MSYS2)
 *   cl  calc_win.c /Fe:calc.exe         (MSVC)
 * 运行:
 *   chcp 65001   (让控制台用 UTF-8 正确显示中文)
 *   .\calc.exe
 * 用法: 输入  12 + 5  这样的算式回车; 输入 q 或非数字退出
 * ----------------------------------------------------------
 */

#include <stdio.h>

int main(void)
{
    long long a, b;     /* 两个操作数 (64 位有符号) */
    char op;            /* 运算符字符 */

    printf("简易计算器 (输入如: 12 + 5),输入 q 退出\n");

    for (;;) {
        printf("> ");

        /* " %lld %c %lld": %c 前的空格用于跳过空白
         * 成功读到 3 项才继续, 否则 (含输入 q / EOF) 退出 */
        if (scanf(" %lld %c %lld", &a, &op, &b) != 3)
            break;

        long long result;

        switch (op) {
        case '+':
            result = a + b;
            break;
        case '-':
            result = a - b;
            break;
        case '*':
            result = a * b;
            break;
        case '/':
            if (b == 0) {
                printf("错误: 除数不能为 0\n");
                continue;
            }
            result = a / b;     /* 整除 (截断) */
            break;
        default:
            printf("错误: 未知运算符 '%c'\n", op);
            continue;
        }

        printf("= %lld\n", result);
    }

    printf("再见!\n");
    return 0;
}
