; boot.asm - 简单的 BIOS 启动程序，加载内核和 RAMDisk
BITS 16
ORG 0x7C00

start:
    cli
    mov ax, 0x07C0
    add ax, 288
    mov ss, ax
    mov sp, 4096

    ; 加载内核到 0x1000
    mov bx, 0x1000
    mov dh, 1
    call load_kernel

    ; 加载 RAMDisk 到 0x8000
    mov bx, 0x8000       ; RAMDisk 地址
    mov dh, 64           ; 加载 64 扇区
    call load_ramdisk

    call enable_protected_mode
    jmp 0x08:kernel_start

load_kernel:
    mov ah, 0x02
    mov al, dh
    mov ch, 0
    mov cl, 2
    mov dh, 0
    int 0x13
    jc disk_error
    ret

load_ramdisk:
    mov ah, 0x02
    mov al, dh
    mov ch, 0
    mov cl, 3           ; RAMDisk 从第 3 扇区开始
    mov dh, 0
    int 0x13
    jc disk_error
    ret

disk_error:
    hlt

enable_protected_mode:
    in al, 0x64
    or al, 0x02
    out 0x64, al

    lgdt [gdt_descriptor]
    mov eax, cr0
    or eax, 1
    mov cr0, eax
    ret

[bits 32]
kernel_start:
    call kernel_main

gdt_start:
gdt_null: dq 0
gdt_code: dw 0xFFFF, 0x0000, 0x00, 10011010b, 11001111b, 0x00
gdt_data: dw 0xFFFF, 0x0000, 0x00, 10010010b, 11001111b, 0x00
gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

times 510-($-$$) db 0
dw 0xAA55
