#Atari ST CPM68K Port
This is a port of the CPM68K operating system to the Atari ST computer series. It's based on the Digital Research CP/M 68K sources plus the following components:

- A bootloader that does a minimal initialization of the hardware: screen resolution, colors,... and loads the CP/M binary that is expected to be included in the system tracks, right after the boot sector.
- A CP/M BIOS implementation that relies on the Atari ST BIOS and XBIOS.

#Project organization
- src. The source code. So far only the bootsector and bios code are available, so you will need to download the CP/M 68K sources if you want to build the CP/M 68K operating system for the Atari St yourself.
- cpmtools. Some useful cpmtool disk definitions.
- tools. Some handy utilities to build st images or manipulate them
- artifacts. The binaries for bootsector and CP/M that must be included in the disk images.

#Current status
The Atari ST should boot and since we are using BIOS/XBIOS to interact with the hardware, it should work on most models. Disk read and writing is allegedly working fine, at least with the last version I didn't suffer corruption problems.
Memory management is still an ongoing topic. So far the TPA is fixed and CPM is copied below the screen in a 520ST (relocated to $70000). This will be probably changed to relocate CPM to the lowest available RAM and so be able to have a bigger TPA between the end of CPM and the screen. BIOS routines to check available memory will be used instead of the fixed approach we have now.
Most of 68K executables you may find around won't work. Seems to be because they are expected to be loaded into a lower TPA than available (around $400 or $600) and BDOS fails to load them. REL executables may work or also 68K executables you generate after them using the RELOC utility (I normally relocate to $A900)

#Building it yourself
TODO

#Changelog
- 0.4. Should support 360K and 720K disks dynamically, based on the media descriptor in the bootsector ($F0 for 720K disks and $F1 for 360K disks). The media descriptor can be found at position 21 of the bootsector.
- 0.3. Disk caching system refactored to cache a complete track. Seems to be faster.
- 0.2. Some experiments with disk sector interleaving. TPA shifted to $a84e to avoid collisions with BIOS/XBIOS data (needs confirmation).
- 0.1. Proof of concept. First booting version.

