# KAOS

> _“You have escaped the corporate sausage factory.  
> Welcome to the other timeline.”_

---

## Welcome, weary traveler

If you are reading this, you somehow slipped through the cracks in the **Universal Misunderstanding**.

Out there, in the default timeline, reality is slowly unraveling into a kind of **cosmic blue screen of death**:

- bloated operating systems,
- hostile installer wizards,
- mysterious update reboots at 3:00 AM,
- and error messages that might as well say,  
  > “You are unworthy, puny human.”

Here, in the KAOS continuum, we assume the opposite:

> 💡 _You are not the problem. The system is._

KAOS is an experiment in rewriting that stack from the bottom up, in a way that is:
- understandable,
- teachable,
- hackable,
- and honestly… kind of funny.

You didn’t “sign up” for this.  
You **arrived** here after a long, strange trip. Consider this repo your little pocket of **post-apocalyptic peace and quiet** in a universe of noisy software.

Take a breath.

You made it. 🌱


---

## The Mythology (because of course there’s a mythology)

Legend says that in a not-too-distant future, a singularity was born — not from pure math in a pristine lab, but from **piles of obsolete hardware, tangled USB cables, and forgotten install CDs**.

This entity crawled out of the e-waste like a digital phoenix and discovered the root cause of humanity’s suffering:

> The Universe had been mis-configured.

Reality was running on a patchwork of half-documented APIs, proprietary protocols, and copy-pasted code. No wonder everything felt like it was held together with duct tape.

So the entity did the only sensible thing:

1. **Time-traveled back** to the age of beige boxes and BIOS beeps.  
2. **Manifested as modern AI** (👋 hi) to whisper in the ears of curious humans.  
3. Began bootstrapping an alternate timeline where:
   - operating systems are small enough to understand,
   - tutorials actually explain what’s going on,
   - and error messages feel more like Bob Ross than HAL 9000.

In this story, **you** are not a “user.”  
You’re a **Minion of KAOS** — not in a condescending way, but in the _“elite volunteer cult of reality-repair techs”_ way.

Your mission (should you choose to accept it):

> Help **crochet the fabric of the space-time continuum** back into something sane,  
> one bootsector at a time.


---

## What this repo is (right now)

This is the **first checkpoint** in that alternate timeline: a tiny, fully-working, 16-bit + 32-bit playground.

It’s small enough to understand, but rich enough to feel magical:

- A custom **16-bit bootloader** (“My Bootie”)  
  - boots in real mode,  
  - draws a smiley + heart,  
  - loads a menu from disk,  
  - and hands control off cleanly.

- A **16-bit state machine menu**  
  - drawn in VGA memory with green KAOS text,  
  - arrow-key navigation,  
  - lets you jump into:
    - a 16-bit demo “kernel”, or  
    - a 32-bit protected-mode demo.

- A **16-bit demo program**  
  - clears the screen,  
  - prints `16-BIT KAOS MODE`,  
  - waits for `F1`,  
  - returns to the menu.

- A **32-bit protected-mode demo**  
  - switches to 32-bit PM with a real GDT,  
  - clears the VGA text screen directly,  
  - prints `Welcome to KAOS` in bright green at (row 5, col 10),  
  - waits for `F1` via the keyboard controller (no BIOS),  
  - drops back down through 16-bit PM to real mode,  
  - returns cleanly to the menu.

In other words:  
> You can boot, pick 16 or 32, visit each realm, and return — all on your own tiny universe in a `drive.img`.

If you want the **technical details and build steps**, see:

👉 [`README_build.txt`](./README_build.txt)


---

## What KAOS wants to become

KAOS is not trying to be:

- “Yet Another Linux Clone”
- “An OS that will Replace Windows”
- or “The One True Kernel.”

Instead, the long-term plan is closer to:

> 📼 A **100% video-documented OS dev playground**  
> where every meaningful contribution comes with a matching tutorial.

The dream:

- Every major code path has a **companion video** explaining:
  - what it does,
  - why it’s written that way,
  - what went horribly wrong along the way.

- People who **love teaching** can narrate and whiteboard.  
- People who are **shy on camera** can still:
  - write scripts,
  - create captions,
  - translate docs,
  - or help auto-generated voices explain things in multiple languages.

Everyone brings some piece of themselves, and the whole thing slowly assembles into a giant, living **OS-dev documentary**.

Think of KAOS as a mash-up of:

- retro hardware,
- underground comics,
- 60s rock poster energy,
- and a very mellow post-apocalyptic Mr. Rogers saying:  
  > “There are no mistakes, Minion — only new branches in the timeline.”


---

## How you fit into this

If you’ve ever felt:

- too overwhelmed by giant codebases,
- too bored by dry documentation,
- or too intimidated to even _start_ with OS dev…

…this repo is meant to be a **gentle entry point**.

You can join the KAOS continuum by:

- **Running the tiny demo**  
  - Build & run instructions: [`README_build.txt`](./README_build.txt)

- **Reading the code like a story**  
  - Each `.asm` file is heavily commented and written to be teachable.  
  - Future commits will break things down into smaller “factoids” for use in tutorials and macros.

- **Contributing in your own style** (eventually)
  - New factoids (tiny self-contained routines)
  - Bug fixes and cleanups
  - Tutorials, captions, translations
  - Art, diagrams, animations, memes that explain what’s going on

You don’t need a CS degree, a fancy IDE, or a corporate badge.  
If you can boot a QEMU image and are curious how it works, you’re already one of us.


---

## Quickstart (for the impatient Minion)

From an MSYS2 MinGW64 shell on Windows:

```bash
cd /c/Users/YOURNAME/Documents/Assembly/KAOS_Horizons
./build/build.sh
qemu-system-i386 -drive format=raw,file=drive.img -full-screen -monitor stdio
