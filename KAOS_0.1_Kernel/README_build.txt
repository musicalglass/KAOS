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


