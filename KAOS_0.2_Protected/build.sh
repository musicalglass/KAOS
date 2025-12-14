#!/usr/bin/env bash
# ==============================================================
# KAOS Horizons LBA — Lesson 2 build
# role:
#   Assemble + write boot, menu, and PM payload
# ==============================================================

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
echo -e "${RED}Understood. Making your wishes reality now...${RESET}"
echo
echo -e "${GREEN}[*] Building KAOS 32 Bit Protected Mode ${RESET}"
echo

echo -e "[*] Rewriting our History..."
rm -f boot16.bin menu16.bin pm32.bin drive.img

echo
echo -e "${ORANGE}[*] Assembling KAOS Modules...${RESET}"
nasm -f bin boot/boot16.asm        -o boot16.bin
nasm -f bin kernel/menu16.asm     -o menu16.bin
nasm -f bin modules32/pm32.asm    -o pm32.bin

echo
echo -e "${BLUE}[*] Creating a new clean image...${RESET}"
dd if=/dev/zero of=drive.img bs=512 count=64

echo
echo -e "${VIOLET}[*] Grabbing My Bootie...${RESET}"
dd if=boot16.bin of=drive.img conv=notrunc bs=512 seek=0

echo
echo -e "${YELLOW}[*] Generating 16 Bit Launcher...${RESET}"
dd if=menu16.bin of=drive.img conv=notrunc bs=512 seek=1

echo
echo -e "${INDIGO}[*] Writing 32 Bit Application...${RESET}"
dd if=pm32.bin of=drive.img conv=notrunc bs=512 seek=9

echo
echo -e "${GREEN}=======================================${RESET}"
echo -e "${GREEN}       32 Bit Assemble Complete       ${RESET}"
echo -e "${GREEN}         Sow KAOS everywhere!       ${RESET}"
echo -e "${GREEN}=======================================${RESET}"

echo
echo -e "${BLUE}Run with QEMU:${RESET}"
echo -e "  qemu-system-i386 -drive format=raw,file=drive.img -full-screen -monitor stdio\n"
echo
echo -e "${INDIGO}Print Debug to the Console:${RESET}"
echo "  qemu-system-i386 -drive format=raw,file=drive.img \
  -debugcon stdio -global isa-debugcon.iobase=0x402"
