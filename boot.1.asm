; boot.asm
BITS 16                   ; 使用 16 位代码模式
ORG 0x7c00                ; BIOS 将加载引导扇区到 0x7c00

start:
    cli                   ; 禁用中断
    xor ax, ax            ; 设置数据段寄存器
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x9fbf        ; 初始化栈指针

    ; 在屏幕上显示“启动内核”消息
    mov si, msg_loading
print_msg:
    mov ah, 0x0e
    lodsb
    cmp al, 0
    je pmode_switch
    int 0x10
    jmp print_msg

msg_loading db "Loading Kernel...", 0

pmode_switch:
    ; 设置 GDT (全局描述符表)
    lgdt [gdt_descriptor]

    ; 设置保护模式位
    mov eax, cr0
    or eax, 1
    mov cr0, eax

    ; 跳转到保护模式代码段
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
BITS 32                   ; 切换到 32 位代码模式
CODE_SEG EQU 0x08
DATA_SEG EQU 0x10

init_pm:
    ; 设置数据段寄存器
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov esp, 0x9fbf       ; 设置栈指针

    ; 调用内核主函数
    extern kernel_main
    call kernel_main

    ; 如果内核主函数返回，停止 CPU
halt:
    cli
    hlt
    jmp halt              ; 无限循环

times 510-($-$$) db 0     ; 填充到 510 字节
dw 0xaa55                 ; 引导扇区签名

