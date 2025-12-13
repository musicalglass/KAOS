#!/usr/bin/env bash
# build.sh - KAOS_Horizons minimal 16/32-bit menu test
# Usage from MSYS2 MinGW64:
#   1) cd /c/Users/Tim/Documents/Stuff/Assembly/KAOS_Horizons
#   2) ./build.sh
#   3) qemu-system-i386 -drive format=raw,file=drive.img

set -e

# Color codes
PINK="\033[1;31m"        # Bright red
RED="\033[0;31m"        # Bright red
ORANGE="\033[0;33m"     # Normal yellow = good orange-ish
YELLOW="\033[1;33m"     # Bright yellow
GREEN="\033[1;32m"      # Bright green
BLUE="\033[1;34m"       # Bright blue
INDIGO="\033[0;34m"     # Deep normal blue
VIOLET="\033[1;35m"     # Bright magenta (nice purple)
RESET="\033[0m"

echo
echo -e "\n${INDIGO}[*] Now doing thy bidding...${RESET}\n"
echo

echo "[*] Cleaning..."
rm -f boot16.bin menu16.bin prog16.bin pm32.bin drive.img

echo -e "${GREEN}[*] Assembling...${RESET}"
nasm -f bin boot/boot16.asm        -o boot16.bin
nasm -f bin kernel/menu16.asm     -o menu16.bin
nasm -f bin modules16/prog16.asm  -o prog16.bin


echo -e "${RED}[*] Creating disk image...${RESET}"
dd if=/dev/zero of=drive.img bs=512 count=64

echo -e "${ORANGE}[*] Writing boot sector...${RESET}"
dd if=boot16.bin of=drive.img conv=notrunc bs=512 seek=0

echo -e "${YELLOW}[*] Writing menu16...${RESET}"
dd if=menu16.bin of=drive.img conv=notrunc bs=512 seek=1

echo -e "${BLUE}[*] Writing prog16...${RESET}"
dd if=prog16.bin of=drive.img conv=notrunc bs=512 seek=5


echo
echo -e "${GREEN}=======================================${RESET}"
echo -e "${GREEN}        KAOS Assemble Complete!       ${RESET}"
echo -e "${GREEN}=======================================${RESET}"
echo

echo -e "${PINK}Run with QEMU:${RESET}"
echo -e "  qemu-system-i386 -drive format=raw,file=drive.img -full-screen -monitor stdio\n"
echo
echo -e "${RED}Print Debug to the Console:${RESET}"
echo "  qemu-system-i386 -drive format=raw,file=drive.img \
  -debugcon stdio -global isa-debugcon.iobase=0x402"
