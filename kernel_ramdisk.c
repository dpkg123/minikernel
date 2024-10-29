#include <stddef.h>
#include <stdint.h>

#define VGA_ADDRESS 0xB8000
#define WHITE_ON_BLACK 0x07
#define SCREEN_WIDTH 80
#define SCREEN_HEIGHT 25
#define RAMDISK_ADDRESS 0x8000    // 假定 RAMDisk 被加载到此地址
#define RAMDISK_SIZE 0x10000      // 假定 RAMDisk 大小为 64KB

uint16_t *video_memory = (uint16_t *) VGA_ADDRESS;
size_t cursor_position = 0;

// 屏幕相关函数
void set_char_at_video_memory(char c, uint8_t color, size_t pos) {
    video_memory[pos] = ((uint16_t)color << 8) | c;
}

void clear_screen() {
    for (size_t i = 0; i < SCREEN_WIDTH * SCREEN_HEIGHT; i++) {
        set_char_at_video_memory(' ', WHITE_ON_BLACK, i);
    }
    cursor_position = 0;
}

void print_char(char c) {
    if (c == '\n') {
        cursor_position += SCREEN_WIDTH - cursor_position % SCREEN_WIDTH;
    } else {
        set_char_at_video_memory(c, WHITE_ON_BLACK, cursor_position++);
    }
}

void print(const char *str) {
    for (size_t i = 0; str[i] != '\0'; i++) {
        print_char(str[i]);
    }
}

// RAMDisk 解析相关函数
void load_ramdisk() {
    uint8_t *ramdisk = (uint8_t *) RAMDISK_ADDRESS;
    print("Loading RAMDisk...\n");

    // 假设 RAMDisk 中每个文件以 16 字节的文件名开头
    size_t offset = 0;
    while (offset < RAMDISK_SIZE) {
        char filename[17];
        size_t i;

        // 读取文件名（假设文件名为 16 字节，以 '\0' 结尾）
        for (i = 0; i < 16 && ramdisk[offset + i] != '\0'; i++) {
            filename[i] = ramdisk[offset + i];
        }
        filename[i] = '\0';

        if (filename[0] == '\0') {
            break;  // 没有更多文件，退出循环
        }

        // 输出文件名
        print("Found file: ");
        print(filename);
        print("\n");

        // 假设每个文件固定大小为 512 字节，移动到下一个文件
        offset += 512;
    }
}

// 内核主函数
void kernel_main() {
    clear_screen();
    print("Kernel Loaded Successfully!\n");
    print("Welcome to My Minimal Kernel with RAMDisk Support!\n\n");

    // 加载并显示 RAMDisk 内容
    load_ramdisk();

    // 无限循环，保持内核运行
    while (1) {}
}
