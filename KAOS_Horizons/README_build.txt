KAOS_Horizons - Minimal 16/32-bit Menu Test
===============================================

MSYS2 / MinGW64 usage
---------------------

1. Open "MSYS2 MinGW64" terminal.

2. Change Directories into the KAOS_Horizons folder:

   cd /c/Users/YOURNAME/Documents/Assembly/KAOS_Horizons

   (Or wherever you cloned the repo.)

3. Run the build script:

   ./build/build.sh

   Tips:
   * To paste the command into MSYS2, you can use SHIFT+Insert.

4. Run the image in QEMU:

   qemu-system-i386 -drive format=raw,file=drive.img

   Or fullscreen with monitor:

   qemu-system-i386 -drive format=raw,file=drive.img -full-screen -monitor stdio


What you should see
-------------------

1. Bootloader:
   * 80x25 text mode
   * Smiley + heart at (0,0)
   * Short delay
   * Control jumps to the 16-bit KAOS menu.

2. KAOS menu (menu16.bin):
   Title: "KAOS State Machine Menu"
   Options (arrow-key controlled):

     > Run 16-bit mode
       Run 32-bit mode

   * Use UP / DOWN arrows to move the ">". (Green text on black)
   * Press ENTER to select.
   * Hardware cursor is hidden.

3. Option: Run 16-bit mode
   * Loads prog16.bin to 0000:9000 and jumps there.
   * Screen shows:
        16-BIT KAOS MODE
        Press F1 to return to KAOS menu.
   * When you press F1:
        → returns directly to the KAOS menu at 0000:8000.

4. Option: Run 32-bit mode
   * Loads pm32.bin to 0000:A000 and jumps there.
   * Switches to 32-bit protected mode.
   * Clears the screen.
   * Writes "Welcome to KAOS" in bright green at row 5, col 10.
   * Waits for F1 using the keyboard controller only (no BIOS).
   * On F1:
        → drops cleanly back to 16-bit PM
        → switches back to real mode
        → jumps to 0000:8000 (KAOS menu).


Folders
-------

boot/
  boot16.asm      - 16-bit boot sector ("My Bootie"):
                    * Smiley + heart
                    * Short delay
                    * Loads 4 sectors from LBA 1 to 0000:8000
                    * Jumps to 0000:8000

kernel/
  menu16.asm      - 16-bit KAOS State Machine menu at 0000:8000:
                    * Arrow-key menu with two options:
                      - Run 16-bit mode (prog16.bin)
                      - Run 32-bit mode (pm32.bin)
                    * Drawn via VGA memory in KAOS green.

modules16/
  prog16.asm      - 16-bit test program at 0000:9000:
                    * Prints: "16-BIT KAOS MODE"
                    * Shows hint: "Press F1 to return to KAOS menu."
                    * Waits for F1 via keyboard controller
                    * Jumps back to menu at 0000:8000

modules32/
  pm32.asm        - 16/32-bit test program at 0000:A000:
                    * 16-bit stub -> 32-bit protected mode
                    * Clears screen in VGA text mode
                    * Prints "Welcome to KAOS" in bright green
                    * Waits for F1 via keyboard controller
                    * Drops back through 16-bit PM to real mode
                    * Jumps back to menu at 0000:8000


How the image is laid out
-------------------------

drive.img is a flat 64-sector (32 KiB) image.

LBA 0 : boot16.bin     (boot sector, [org 0x7C00])
LBA 1 : menu16.bin     (menu at [org 0x8000], loaded by boot16)
LBA 2–4 : (currently unused, zeros)
LBA 5 : prog16.bin     (16-bit test, [org 0x9000], loaded by menu16)
LBA 6–8 : (unused)
LBA 9 : pm32.bin       (16/32-bit test, [org 0xA000], loaded by menu16)
LBA 10–63 : (unused)
