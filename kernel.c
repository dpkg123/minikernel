// kernel.c
#include <stdint.h>

// 串行端口 I/O 端口地址
#define SERIAL_PORT 0x3F8

static inline void outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" : : "a"(data), "Nd"(port));
}

static inline uint8_t inb(uint16_t port) {
    uint8_t result;
    asm volatile ("inb %1, %0" : "=a"(result) : "Nd"(port));
    return result;
}

// 初始化串行端口
void init_serial() {
    outb(SERIAL_PORT + 1, 0x00);    // 禁用中断
    outb(SERIAL_PORT + 3, 0x80);    // 设置波特率分配
    outb(SERIAL_PORT + 0, 0x03);    // 设置波特率为 38400 (低字节)
    outb(SERIAL_PORT + 1, 0x00);    // 设置波特率为 38400 (高字节)
    outb(SERIAL_PORT + 3, 0x03);    // 8 位数据, 无校验, 1 位停止位
    outb(SERIAL_PORT + 2, 0xC7);    // 启用 FIFO，清除队列，设置 14 字节阈值
    outb(SERIAL_PORT + 4, 0x0B);    // 设置 IRQs，RTS/DSR 设置
}

// 检查串行端口是否准备好发送数据
int is_transmit_empty() {
    return inb(SERIAL_PORT + 5) & 0x20;
}

// 向串行端口发送一个字符
void serial_write(char c) {
    while (is_transmit_empty() == 0);
    outb(SERIAL_PORT, c);
}

// 向串行端口发送一个字符串
void serial_write_string(const char *str) {
    for (size_t i = 0; str[i] != '\0'; i++) {
        serial_write(str[i]);
    }
}

// 打印数字（简单的整数转换为字符串）
void serial_write_dec(int num) {
    char buffer[10];
    int i = 0;

    if (num == 0) {
        serial_write('0');
        return;
    }

    if (num < 0) {
        serial_write('-');
        num = -num;
    }

    while (num > 0) {
        buffer[i++] = '0' + (num % 10);
        num /= 10;
    }

    while (i > 0) {
        serial_write(buffer[--i]);
    }
}

// 内核异常处理
void panic(const char *message) {
    serial_write_string("Kernel Panic: ");
    serial_write_string(message);
    serial_write_string("\n");

    while (1);  // 停止执行
}

// 内核主函数
void kernel_main() {
    init_serial();
    serial_write_string("Hello, Extended Kernel World!\n");

    // 假设触发异常测试
    int test_value = -1;
    if (test_value < 0) {
        panic("Test exception: negative value encountered.");
    }

    // 进一步的内核逻辑（可扩展）
    while (1) {}  // 防止内核退出
}

