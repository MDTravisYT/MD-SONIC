> [!NOTE]
> The original disassembly used for this project is very incomplete and a bit poorly documented. This should not be used as a base for future projects, but can be referenced.

> [!CAUTION]
> This project is not permitted to be sold in any way, such as a physical reproduction cartridge or console pack-in. If you find this project on there, *you've been scammed*!

# MD-SONIC
This is a port of the Yuusei demo of Sonic CD to stock Sega Mega Drive, better known as v0.02 or the 1204 prototype. It is directly built off of the R11B__.MMD file in the disk, which originally handled Round 1 Zone 1 Past. This project was started on August 4, 2024 using a disassembly by KatKuriN.

This port features:

- Zones 1 and 2 of ~~Palmtree Panic~~ Salad Plain (Not just R11A!)
- **NEW:** R13D, including its boss ported from 510!
- Functional time travel
- A Sega and Title screen
- New sound effects
- Pausing
- Level select (LRLRLR): Can access all normally accessible levels from v0.02 plus R13D, and a bonus level, R31A (objectless)!
- 
This port isn't fully feature-complete. Missing big features include:

- Time Attack
- Time travel cutscene
- The music. Unfortunately, the full soundtrack could not be translated to the Mega Drive's sound chips in time for the submission, so what you'll hear is music borrowed from Sonic 1.
- Good Future levels (you can't access them in the original demo anyway)

Bugs present in the original demo are mostly retained here, but certain ones have been fixed due to the porting method. Those would include:

- Sonic's sprites being bugged
- Time and rings clearing upon time travel
- Time travel not working on spinning platforms
- Any sound related bug that existed in the original version (The project now uses Sonic 1's sound driver)

Another notable feature in this port, **Lock-On Technology!** This will allow you to play custom user-generated levels within this port without the need to modify the source code! These are known as PAKs, which are appended to the end of the ROM data and detected by the game when it's attached. To use or even create a PAK, download the ZIP file in the "Extras" section, place this ROM in the folder, and run one of the two BAT files depending on what you want to do. Maybe you want to add in your own R2, or want to port another Sonic CD level to feel how it functions in v0.02. The filesizes I set up is the limit! The ZIP contains two BAT files, one to lock on the ROM to a PAK file, and one to create your own PAK file, which you can do by using SonLVL. The template included with the ZIP is Sonic CD's R31D.

# Credits

- MDTravis - Main programmer + Custom artist + Hardware verification (NTSC-U Model 1 VA6.5) + everything else not listed below
- Katsushimi - Original disassembly + Secondary programmer + General support
- Devon - Initial MD port code reference + Un-hardcoded chunks guide + General support
- VladikComper - DAC driver (MegaPCM v2.0) + MegaPCM2 debugging + Error handler
- SleekFlash-16 - MD arrangements of the CD-SONIC music
- Collision Chaos Radio - Music research assistance
- Filter - Z80 help
- RadiantNexus Team - General support
- BladeOfChaos - Title screen intro art (modified from the 1995 PC version)
- Naoto - Security
- Sega Classics Arcade Collection - Sega screen FMV

Special thanks to the public beta testers for finding anything I've missed.
