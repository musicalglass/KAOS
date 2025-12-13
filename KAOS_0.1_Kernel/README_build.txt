KAOS_Horizons - Minimal 16/32-bit Menu Test
===========================================

MSYS2 / MinGW64 usage
---------------------

1. Open the "MSYS2 MinGW64" terminal.

2. Change into the KAOS_Horizons folder:

       cd /c/Users/YOURNAME/Documents/Assembly/KAOS_Horizons

3. Build everything:

       ./build.sh

   Notes:
   * Highlight and use SHIFT+Insert to paste into MSYS2.
   * The build script will assemble all modules and create drive.img.

4. Run the OS in QEMU:

       qemu-system-i386 -drive format=raw,file=drive.img \
                        -full-screen -monitor stdio

================================================================================================
This assumes you have already set up the following tools. A getting started video can be found here:
https://youtu.be/NgoVw3JHeTI

Update and Prepare MSYS2 MINGW64

pacman -Syu

When prompted, close the window after it finishes, then reopen MSYS2 MSYS and run again:

pacman -Su

Now everything is fully updated.

Step 2 — Install Needed Packages;
nasm → assembler
qemu → emulator (we’ll use qemu-system-i386 for 16-bit code)
make → simplifies rebuilds, has functions we will call
gdb → Gnu debugger
vim → simple built-in editor, has functions we will call
bc → convert to binary
rsync → for advanced build scripts

pacman -S mingw-w64-x86_64-nasm mingw-w64-x86_64-qemu make gdb vim bc
