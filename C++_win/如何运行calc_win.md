# 在 Windows 11 上运行 calc_win.cpp

`calc_win.cpp` 是 `ASM_win\calc_win.asm` / `C_win\calc_win.c` 的 C++ 等价实现，功能完全一致：
一个命令行四则运算计算器。它只用到标准库 `<iostream>`，所以**一步即可编译**。

你机器上已安装的编译器：

- g++：`C:\msys64\ucrt64\bin\g++.exe`（MSYS2 UCRT64，gcc 自带 C++ 编译器）

---

## 一、编译（在本目录 `C++_win` 下执行）

> 用 PowerShell 打开本目录，运行下面任意一种方式。

### 方式 A：g++ 在 PATH 中

```powershell
g++ calc_win.cpp -o calc.exe
```

### 方式 B：用 g++ 全路径（PATH 里没有 g++ 时）

```powershell
& "C:\msys64\ucrt64\bin\g++.exe" calc_win.cpp -o calc.exe
```

### 方式 C：用 MSVC 的 cl（装了 Visual Studio 时）

```powershell
cl calc_win.cpp /Fe:calc.exe /EHsc
```

命令没有报错、并生成了 `calc.exe` 就算成功。可以确认一下：

```powershell
Get-Item calc.exe
```

---

## 二、运行

```powershell
# 让控制台用 UTF-8，中文提示才不会乱码
chcp 65001

# 运行
.\calc.exe
```

### 用法

- 输入形如 `12 + 5` 的算式后回车，支持 `+ - * /`
- 整数运算，`/` 为整除（截断）
- 输入 `q` 或任何非数字内容回车即退出

示例：

```
简易计算器 (输入如: 12 + 5),输入 q 退出
> 12 + 5
= 17
> 100 / 7
= 14
> 8 * 9
= 72
> q
再见!
```

---

## 三、常见问题

**1. 提示 `g++` / `cl` 不是内部或外部命令**
说明当前 PowerShell 没找到编译器。要么把编译器路径加进 PATH，要么用上面的“方式 B”全路径调用；
`cl` 则需在 “Developer PowerShell for VS” 里运行。

**2. 中文显示成乱码**
运行前先执行 `chcp 65001`，把控制台代码页切到 UTF-8。
（Windows Terminal 默认通常已是 UTF-8；老的 conhost 必须手动切。）

**3. 想重新编译**
直接重复“一、编译”里的命令即可，会覆盖旧的 `calc.exe`。

---

## 四、一键脚本（可选）

把下面内容存成 `build.ps1`，运行 `.\build.ps1` 即可编译并启动：

```powershell
& "C:\msys64\ucrt64\bin\g++.exe" calc_win.cpp -o calc.exe
if ($LASTEXITCODE -ne 0) { Write-Host "编译失败" -ForegroundColor Red; exit 1 }

chcp 65001 > $null
Write-Host "编译成功，启动 calc.exe`n" -ForegroundColor Green
.\calc.exe
```

---

## 五、与其他版本的区别

- **构建步骤**：ASM 版需要 `nasm` 汇编 + `gcc` 链接两步；C / C++ 版只需一步编译。
- **代码风格**：C 版用 `scanf` / `printf`；C++ 版改用 `std::cin` / `std::cout`（`>>`、`<<` 流操作）。
- **运行行为**：三者完全一致（同样的提示语、同样的输入格式、同样的整除与错误处理）。
