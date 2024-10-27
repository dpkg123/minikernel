; boot.asm
BITS 32                   ; 使用 32 位代码模式
extern kernel_main        ; 声明外部函数 kernel_main

SECTION .text
start:
    cli                   ; 禁用中断
    xor ax, ax            ; 清除数据段寄存器
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x9fbf        ; 初始化栈指针

    ; 加载保护模式
    mov eax, cr0
    or eax, 1             ; 设置保护模式位
    mov cr0, eax

    ; 跳转到保护模式
    jmp CODE_SEG:init_pm

[SECTION .gdt]
gdt_start:
    dq 0x0000000000000000 ; 空描述符
    dq 0x00cf9a000000ffff ; 代码段描述符
    dq 0x00cf92000000ffff ; 数据段描述符
gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

[SECTION .text]
CODE_SEG EQU 0x08
DATA_SEG EQU 0x10

init_pm:
    lgdt [gdt_descriptor] ; 加载 GDT
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov esp, 0x9fbf       ; 设置栈指针

    call kernel_main      ; 调用 C 内核入口

    cli                   ; 禁用中断
    hlt                   ; 停止 CPU

