#!/usr/bin/env bash
# build.sh - KAOS_Horizons minimal 16/32-bit menu test
# MSYS2 / MinGW64 compatible

set -e

# --------------------------------------------------
# Colors (KAOS themed)
# --------------------------------------------------
GREEN="\033[1;32m"
BLUE="\033[1;34m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
VIOLET="\033[1;35m"     # Bright magenta (nice purple)
RESET="\033[0m"

echo
echo -e "${GREEN}[*] KAOS build starting...${RESET}"
echo

# --------------------------------------------------
# Clean
# --------------------------------------------------
echo "[*] Cleaning old binaries..."
rm -f boot16.bin menu16.bin prog16.bin pm32.bin drive.img

# --------------------------------------------------
# Assemble
# --------------------------------------------------
echo -e "${BLUE}[*] Assembling sources...${RESET}"
nasm -f bin boot/boot16.asm        -o boot16.bin
nasm -f bin kernel/menu16.asm     -o menu16.bin
nasm -f bin modules16/prog16.asm  -o prog16.bin
nasm -I modules32/ -f bin modules32/pm32.asm -o pm32.bin

# --------------------------------------------------
# Create disk image
# --------------------------------------------------
echo -e "${RED}[*] Creating disk image...${RESET}"
dd if=/dev/zero of=drive.img bs=512 count=64

# --------------------------------------------------
# Write binaries to fixed LBAs
# --------------------------------------------------
echo -e "${ORANGE}[*] Writing boot sector...${RESET}"
dd if=boot16.bin of=drive.img conv=notrunc bs=512 seek=0

echo -e "${YELLOW}[*] Writing menu16.bin (LBA 1)...${RESET}"
dd if=menu16.bin of=drive.img conv=notrunc bs=512 seek=1

echo -e "${BLUE}[*] Writing prog16.bin (LBA 5)...${RESET}"
dd if=prog16.bin of=drive.img conv=notrunc bs=512 seek=5

echo -e "${VIOLET}[*] Writing prog32.bin ${RESET}"
dd if=pm32.bin of=drive.img conv=notrunc bs=512 seek=9

# --------------------------------------------------
# Done
# --------------------------------------------------
echo
echo -e "${GREEN}=======================================${RESET}"
echo -e "${GREEN}        KAOS Assemble Complete          ${RESET}"
echo -e "${GREEN}=======================================${RESET}"
echo
echo -e "${PINK}Run with QEMU:${RESET}"
echo -e "  qemu-system-i386 -drive format=raw,file=drive.img -full-screen -monitor stdio\n"
echo
echo -e "${RED}Print Debug to the Console:${RESET}"
echo "  qemu-system-i386 -drive format=raw,file=drive.img \
  -debugcon stdio -global isa-debugcon.iobase=0x402"
