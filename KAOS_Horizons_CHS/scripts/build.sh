#!/usr/bin/env bash
# build.sh - KAOS_Horizons minimal 16/32-bit menu test
# Usage from MSYS2 MinGW64:
#   1) cd /c/Users/Tim/Documents/Stuff/Assembly/KAOS_Horizons
#   2) ./build/build.sh
#   3) qemu-system-i386 -drive format=raw,file=drive.img

set -e

echo
echo "[*] Now doing thy bidding..."
echo

echo "[*] Cleaning old outputs..."
rm -f boot16.bin menu16.bin prog16.bin pm32.bin drive.img

echo "[*] Assembling bootloader..."
nasm -f bin boot/boot16.asm   -o boot16.bin

echo "[*] Assembling 16-bit menu..."
nasm -f bin kernel/menu16.asm -o menu16.bin

echo "[*] Assembling 16-bit test program..."
nasm -f bin modules16/prog16.asm -o prog16.bin

echo "[*] Assembling 32-bit test stub..."
nasm -f bin modules32/pm32.asm   -o pm32.bin

echo "[*] Creating blank 64-sector image..."
dd if=/dev/zero of=drive.img bs=512 count=64

echo "[*] Writing boot sector (LBA 0)..."
dd if=boot16.bin of=drive.img conv=notrunc bs=512 seek=0

echo "[*] Writing menu16.bin to LBA 1..."
dd if=menu16.bin of=drive.img conv=notrunc bs=512 seek=1

echo "[*] Writing prog16.bin to LBA 5..."
dd if=prog16.bin of=drive.img conv=notrunc bs=512 seek=5

echo "[*] Writing pm32.bin to LBA 9..."
dd if=pm32.bin of=drive.img conv=notrunc bs=512 seek=9

echo
echo "=================================="
echo "    KAOS Assemble Complete!"
echo "=================================="
echo
echo "Run with QEMU - CTRL ALT F4 to exit Fullscreen Mode - CTRL ALT 2 to Debug"
echo "  qemu-system-i386 -drive format=raw,file=drive.img -full-screen -monitor stdio"
