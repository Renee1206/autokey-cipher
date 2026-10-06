# Autokey Cipher in x86 Assembly

使用 **x86 Assembly (MASM)** 實作的 Autokey 加解密程式。

本專案透過 Irvine32 Library 完成字串輸入輸出、亂數產生與十六進位顯示，並利用 **Autokey 的金鑰延伸概念搭配 XOR 運算**進行訊息加密與解密。

## 專案功能

- 輸入欲加密的 Plaintext
- 移除指定的空白與標點符號
- 自訂隨機初始金鑰長度 `L`
- 隨機產生 Printable ASCII Keyword
- 使用 Modified Plaintext 延伸 Autokey
- 使用 XOR 進行加密
- 將加密結果以十六進位格式輸出
- 根據初始 Keyword 與已解密內容逐步完成解密
- 顯示解密後的處理明文

## Autokey 原理

輸入的 Plaintext 會先經過字元過濾，產生 **Modified Plaintext**。

假設處理後的明文為：

```text
P0 P1 P2 P3 P4 P5 ...
```

使用者指定初始隨機金鑰長度 `L`。

程式首先產生長度為 `L` 的隨機 Keyword：

```text
K0 K1 ... K(L-1)
```

接著使用 Modified Plaintext 本身延伸後續金鑰，因此完整 Key Stream 為：

```text
K0 K1 ... K(L-1) P0 P1 P2 ...
```

也就是：

```text
Key[i] = RandomKeyword[i]         , i < L
Key[i] = ModifiedPlaintext[i - L] , i >= L
```

## Encryption

每一個 Modified Plaintext Byte 與對應的 Key Byte 進行 XOR：

```text
Ciphertext[i] = ModifiedPlaintext[i] XOR Key[i]
```

由於加密後可能產生不可顯示的字元，因此程式將 Ciphertext 以 **Hexadecimal** 格式輸出。

## Decryption

前 `L` 個 Byte 可以直接使用原始 Random Keyword 解密：

```text
ModifiedPlaintext[i] = Ciphertext[i] XOR RandomKeyword[i]
```

之後的 Key 則來自先前已經解密完成的 Modified Plaintext：

```text
ModifiedPlaintext[i] = Ciphertext[i] XOR ModifiedPlaintext[i - L]
```

因此可以逐步還原**處理後的明文（Modified Plaintext）**。

## Plaintext Processing

輸入的 Plaintext 在進行加密前會先經過字元過濾。

目前程式僅移除：

```text
ASCII space (0x20)
單引號 (')
逗號 (,)
句號 (.)
```

例如輸入：

```text
Hello, world.
```

處理後會變成：

```text
Helloworld
```

因此程式最後解密得到的也是：

```text
Helloworld
```

而不是原始輸入的：

```text
Hello, world.
```

程式不會自動轉換英文字母大小寫，因此大小寫會保留。

## Random Keyword

初始 Random Keyword 使用 Irvine32 Library 提供的：

```asm
Randomize
RandomRange
```

產生。

每一個 Key Byte 的範圍為：

```text
0x21 ~ 0x7E
```

也就是 Printable ASCII Characters。

使用者輸入的 Key Length `L` 必須符合：

```text
1 <= L <= Modified Plaintext Length
```

若輸入超出範圍，程式會顯示錯誤訊息並要求重新輸入。

## Program Flow

```text
Input Plaintext
      │
      ▼
Filter Plaintext
      │
      ▼
Modified Plaintext
      │
      ▼
Input Key Length L
      │
      ▼
Generate Random Keyword
      │
      ▼
Create Autokey
      │
      ▼
XOR Encryption
      │
      ▼
Display Ciphertext in Hex
      │
      ▼
XOR Decryption
      │
      ▼
Display Decrypted Modified Plaintext
```

程式主要包含以下 Procedures：

```asm
PromptForValidPlaintext
FilterPlaintext
PromptForValidL
GenerateRandomKey
CreateFullKey
Encrypt
Decrypt
```

## Output Format

執行程式後會依序顯示：

```text
Enter plaintext:
Modified Plaintext:
Enter random keyword length (L):
Key:
Encrypted Message (hex):
Decrypted Message:
```

其中每次執行所產生的 Random Keyword 不同，因此即使輸入相同的 Plaintext，也可能得到不同的 Ciphertext。

## Project Structure

```text
autokey-cipher/
│
├── 1122913_hw3.sln
├── .gitignore
│
└── 1122913_hw3/
    ├── 1122913_hw3.asm
    ├── 1122913_hw3.vcxproj
    └── 1122913_hw3.vcxproj.filters
```

### File Description

| File | Description |
|---|---|
| `1122913_hw3.asm` | Autokey 加密與解密的主要 Assembly 程式 |
| `1122913_hw3.vcxproj` | Visual Studio / MASM 專案設定 |
| `1122913_hw3.vcxproj.filters` | Visual Studio 專案檔案分類設定 |
| `1122913_hw3.sln` | Visual Studio Solution |
| `.gitignore` | Git 忽略檔案設定 |

## Development Environment

- Microsoft Visual Studio 2022
- MASM (Microsoft Macro Assembler)
- x86 / Win32
- Irvine32 Library
- Platform Toolset: `v143`

程式使用：

```asm
INCLUDE Irvine32.inc
```

並在 `Debug | Win32` 設定中連結：

```text
Irvine32.lib
```

目前專案的 Irvine32 Include 與 Library 路徑設定為：

```text
C:\Irvine
```

## How to Run

### 1. Install Visual Studio

安裝 Visual Studio 2022，並安裝 C++ Desktop Development 所需元件。

### 2. Configure Irvine32

準備 Irvine32 Library，並將相關檔案放置於：

```text
C:\Irvine
```

例如：

```text
C:\Irvine\Irvine32.inc
C:\Irvine\Irvine32.lib
```

若 Irvine32 安裝於其他位置，需要自行修改 Visual Studio 專案中的 Include Path 與 Additional Library Directories。

### 3. Open Project

使用 Visual Studio 開啟：

```text
1122913_hw3.sln
```

### 4. Select Platform

選擇：

```text
Debug | x86
```

在目前的 Solution 設定中，`Debug | x86` 對應至專案內部的：

```text
Debug | Win32
```

由於本專案使用 `Irvine32`，建議以 **32-bit x86 / Win32** 環境進行編譯與執行。

### 5. Build and Run

在 Visual Studio 中選擇：

```text
Build → Build Solution
```

完成編譯後執行程式，即可進行 Autokey 加密與解密。

## Implementation Highlights

本專案主要練習：

- x86 Assembly Language
- MASM 程式開發
- Register 與 Memory 操作
- String Processing
- Loop 與 Conditional Branch
- Procedure Design
- Random Number Generation
- XOR Encryption / Decryption
- Autokey Key Stream Generation
- Hexadecimal Data Representation
- Irvine32 Library 使用
