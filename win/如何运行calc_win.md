# 在 Windows 11 上运行 calc_win.asm

`calc_win.asm` 是用 **NASM** 写的 x64 Windows 汇编程序，它调用了 C 库的 `printf` / `scanf`，
所以构建分两步：先用 **nasm** 汇编成目标文件，再用 **gcc (MinGW-w64)** 链接出 exe。

你机器上这两个工具都已安装：

- nasm：`D:\files\forPathBig\nasm.exe`
- gcc：`C:\msys64\ucrt64\bin\gcc.exe`（MSYS2 UCRT64）

---

## 一、构建（在本目录 `D:\files\projects\tmp` 下执行）

> 用 PowerShell 打开本目录，依次运行：

```powershell
# 1. 汇编：calc_win.asm -> calc.obj
nasm -f win64 calc_win.asm -o calc.obj

# 2. 链接：calc.obj -> calc.exe
gcc calc.obj -o calc.exe
```

两条命令都没有报错、且生成了 `calc.exe`，就算成功。可以确认一下：

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

**1. 提示 `nasm` / `gcc` 不是内部或外部命令**
说明当前 PowerShell 没找到工具。要么把上面两个路径加进 PATH，要么直接用全路径调用：

```powershell
& "D:\files\forPathBig\nasm.exe" -f win64 calc_win.asm -o calc.obj
& "C:\msys64\ucrt64\bin\gcc.exe" calc.obj -o calc.exe
```

**2. 中文显示成乱码**
运行前先执行 `chcp 65001`，把控制台代码页切到 UTF-8。
（Windows Terminal 默认通常已是 UTF-8；老的 conhost 必须手动切。）

**3. 链接报 `undefined reference to printf/scanf` 之类**
确认用的是 `gcc` 链接（它会自动带上 C 运行库），不要用纯 `ld` 链接。

**4. 想重新构建**
直接重复“一、构建”里的两条命令即可，会覆盖旧的 `calc.obj` / `calc.exe`。

---

## 四、一键脚本（可选）

如果想省事，可以把下面内容存成 `build.ps1`，每次双击或运行 `.\build.ps1` 即可构建并运行：

```powershell
nasm -f win64 calc_win.asm -o calc.obj
if ($LASTEXITCODE -ne 0) { Write-Host "汇编失败" -ForegroundColor Red; exit 1 }

gcc calc.obj -o calc.exe
if ($LASTEXITCODE -ne 0) { Write-Host "链接失败" -ForegroundColor Red; exit 1 }

chcp 65001 > $null
Write-Host "构建成功，启动 calc.exe`n" -ForegroundColor Green
.\calc.exe
```
