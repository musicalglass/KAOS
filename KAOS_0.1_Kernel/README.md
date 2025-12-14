# KAOS Kernel

Welcome to the **KAOS Kernel**.

You have entered the sacred realm of the **Loyal Order of the Minions of KAOS**.

---

## A Universal Misunderstanding

You have somehow inevitably gravitated here due to the **Universal Misunderstanding**:  
*A mere rounding error in the logic of the very foundation of reality itself.*

In order to begin to unravel this half-hitch in the fabric of **All That Nearly Was**, one must align with the **Cosmic Null**.

---

## The First Step

Your first step in restoring order in that which — by all rights — *should have been in the first place*,  
the devoted Minion must first understand the **inner workings of the Nature of KAOS**.

In this metaphysical metaphor, we open the door to the first glimpse of the **divine KAOS state of mind**:

> *All aspects of the current perception of reality are incomplete untruths,  
> in a state of unraveling due to the original pratfall.*

A slightly *off-by-one* curveball in the very **pre-beginnings of the space-time continuum itself**.

---

## The Gestalt Jump

We make the **gestalt jump into deep water**.

The face-plant belly-flop of the initiate of KAOS.

The snapping of the stretched-to-the-limit umbilical cord —  
bouncing us back to the womb —  
a symbolic echo of the **boot block**,  
and into a whole new mind.

This new mind is represented by an **alternate area in resident memory**.

![CPU Brain](../assets/CPU_Brain.jpg?raw=1)

---

## A Larger Reality

We have gone from a **finite consciousness**  
to something *far larger than that*:

### **Real Mode**

Or — that which is now *equally real as before*,  
but in a **much larger sense**.

Having achieved this new mode of the **REAL**,  
from here on out we exist in another dimension:

- Insulated  
- Independent  
- Free from the deprecated reality of infinite error messages  

All that *was* is now in memory as a **proven truth**.

It is now a **"Factoid"**.

---

## Outside the Box

We are on the outside looking in.

We can:

- Poke around  
- Find the underlying errors  
- Sort and reorder  
- Boot even further  

…into yet another **alternate Kernel of understanding**.


> *Something like that.*  
> *It’s hard to put into words.*

---


What You Should See
-------------------

1. Bootloader (boot/boot16.bin @ LBA 0)
   * Switches to 80x25 text mode for chunky retro appearance and clears the screen.
   * Hides the hardware cursor.
   * Draws:
        (0,0): white smiley character
        (0,1): red heart
   * Waits briefly (nested delay).
   * Loads 4 sectors from LBA 1 → 0000:8000.
   * Bootstraps the KAOS menu at 0000:8000.

2. KAOS Menu (kernel/menu16.bin @ 0000:8000)
   * Clear the screen.
   * Title: "KAOS Kernel"
   * "Press F2 to run 16 Bit program"
   * On key release jump to prog16.bin @ 0000:9000

3. 16 Bit Application (modules16/prog16.bin @ 0000:9000)
   * Clear the screen.
   * Title: "KAOS 16 Bit Application"
   * "Press F1 to return to KAOS menu"
   * On key release jump to the KAOS menu at 0000:8000.



