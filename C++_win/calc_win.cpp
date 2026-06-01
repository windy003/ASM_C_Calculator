// calc_win.cpp — 命令行四则运算计算器 (Windows, C++ 版本)
// ----------------------------------------------------------
// 这是 ASM_win\calc_win.asm / C_win\calc_win.c 的 C++ 等价实现,
// 行为保持一致。改用 C++ 的 <iostream> 风格进行输入输出。
//
// 编译 (任选其一):
//   g++ calc_win.cpp -o calc.exe          (MinGW-w64 / MSYS2)
//   cl  calc_win.cpp /Fe:calc.exe /EHsc   (MSVC)
// 运行:
//   chcp 65001   (让控制台用 UTF-8 正确显示中文)
//   .\calc.exe
// 用法: 输入  12 + 5  这样的算式回车; 输入 q 或非数字退出
// ----------------------------------------------------------

#include <iostream>

int main()
{
    long long a, b;     // 两个操作数 (64 位有符号)
    char op;            // 运算符字符

    std::cout << "简易计算器 (输入如: 12 + 5),输入 q 退出\n";

    for (;;) {
        std::cout << "> ";

        // operator>> 会自动跳过空白并按类型解析。
        // 任一项读取失败 (含输入 q / EOF) 即退出循环。
        if (!(std::cin >> a >> op >> b))
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
                std::cout << "错误: 除数不能为 0\n";
                continue;
            }
            result = a / b;     // 整除 (截断)
            break;
        default:
            std::cout << "错误: 未知运算符 '" << op << "'\n";
            continue;
        }

        std::cout << "= " << result << "\n";
    }

    std::cout << "再见!\n";
    return 0;
}
