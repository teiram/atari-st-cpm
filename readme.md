# Atari ST CPM68K Port
This is a port of the CPM68K operating system to the Atari ST computer series. It's based on the Digital Research CP/M 68K sources plus the following components:

- A bootloader that does a minimal initialization of the hardware: screen resolution, colors,... and loads the CP/M binary that is expected to be included in the system tracks, right after the boot sector.
- A CP/M BIOS implementation that relies on the Atari ST BIOS and XBIOS.

# Project organization
- src. The source code. So far only the bootsector and bios code are available, so you will need to download the CP/M 68K sources if you want to build the CP/M 68K operating system for the Atari St yourself.
- cpmtools. Some useful cpmtool disk definitions.
- tools. Some handy utilities to build st images or manipulate them
- artifacts. The binaries for bootsector and CP/M that must be included in the disk images.

# Current status
The Atari ST should boot and since we are using BIOS/XBIOS to interact with the hardware, it should work on most models. Disk read and writing is allegedly working fine, at least with the last version I didn't suffer corruption problems.
Memory management is still an ongoing topic. So far the TPA is fixed and CPM is copied below the screen in a 520ST (relocated to $70000). This will be probably changed to relocate CPM to the lowest available RAM and so be able to have a bigger TPA between the end of CPM and the screen. BIOS routines to check available memory will be used instead of the fixed approach we have now.
Most of 68K executables you may find around won't work. Seems to be because they are expected to be loaded into a lower TPA than available (around $400 or $600) and BDOS fails to load them. REL executables may work or also 68K executables you generate after them using the RELOC utility (I normally relocate to $A900)

# Building it yourself
In order to build the bootsector and CP/M binaries you will need the CP/M sources as well as the development tools for CPM-68K. The easiest way I found was to use [cpmsim](http://davesrocketworks.com/electronics/cpm68/simulator.html) since it includes all the needed tools and some extras.
In order to inject and extract files from cpmsim simulated harddrive the cpmtools utilities and a cpmtools disk definition can be used. You can find the definition in the cpmtools folder of the sources or just copy and paste it from here:
```
diskdef em68k
  seclen 128
  tracks 512
  sectrk 256
  blocksize 2048
  maxdir 4096
  skew 0
  boottrk 1
  os 2.2
end
```
Upload the files in the source code folder to the user area 5 in the cpmsim simulated harddrive. This is where all the scripts and artifacts needed to build the CP/M binary are located.
```
cpmcp -f em68k <cpmsim>/diskc.cpm.fs <repo>/src 5:
```
Before proceeding with the generation of CP/M, there is a BDOS routine that overrides most of the Motorola 68000 trap handlers, including the ones to access BIOS and XBIOS. We need to patch this behavior to keep vectors for trap #13 and trap #14 untouched. Additionally we need an updated Makefile to built the CP/M library because the one distributed with cpmsim doesn't include BDOS objects:
```
cpmcp -f emu68k <cpmsim>/diskc.cpm.fs <repo>/bdos 3:
```
Start the cpmsim emulator, move to the user 3 and build CPMLIB as follows:
```
C>user 3
3C>make
```
Now you should go to the user area 5 and copy the newly generated CPMLIB:
```
5C>user 5
5C>pip cpmlib=cpmlib[3G]
```
you can build now the bootsector and the CPM
```
5C>makeboot
5C>makest
```
From your host computer you can now extract the two artifacts: bootsector and CP/M image:
```
cpmcp -f emu68k <cpmsim>/diskc.cpm.fs 5:cpm.sys .
cpmcp -f emu68k <cpmsim>/diskc.cpm.fs 5:bootsec.o .
```
You can use the included python script mkstdisk.py included in the tools folder to generate a disk very easily:
```
mkstdisk.py bootsec.o cpm.sys <destination-disk-name>
```
you can also use any other tool as far as you put the bootsector and the cpm.sys at the initial sectors of the disk. mkstdisk.py creates an empty disk by default but if you provide a folder, it will copy the files into the newly created disk (provided that cpmtools is available in your path) following these conventions:
- The files in the provided folder (option -u folder) are copied to the user area 0.
- If there are subfolders with names 1...15, the files inside those subfolders will be copied to the user areas 1...15

Take into account that the generated image is automatically interleaved as expected of a st double sided image, therefore it is not possible to modify it directly with cpmtools, which can only read/write images with the two sides one after the other. To workaround this issue, there are two scripts in the tools directory to flatten or interleave the image again, so that it can be manipulated with cpmtools and interleaved again afterwards. These tools are named interlace.py and deinterlace.py and the typical workflow would be:
- Deinterlace an existing image in order to inject or extract files with cpmtools: ```deinterlace.py image1.st working-copy.img```
- Manipulate the working copy using cpmtools (remenber to install the proper definitions, that are also included in the cpmtools folder)
- Interlace the image again: ```interlace.py working-copy.img image2.st```  
mkstdisk.py also allows to create single side images (option -s) but it's not yet manipulating the bootsector to instruct the BIOS to provide the proper DPB to the BDOS when such a disk is logged.  
In order to manipulate the image with cpmtools you need the disk definitions in the cpmtools folder:
```
diskdef st68k-360
  seclen 512
  tracks 80
  sectrk 9
  blocksize 2048
  maxdir 192
  boottrk 5
  os 2.2
end

diskdef st68k-720
  seclen 512
  tracks 160
  sectrk 9
  blocksize 2048
  maxdir 192
  boottrk 5
  os 2.2
end
```
# Changelog
- 0.4. Should support 360K and 720K disks dynamically, based on the media descriptor in the bootsector ($F0 for 720K disks and $F1 for 360K disks). The media descriptor can be found at position 21 of the bootsector.
- 0.3. Disk caching system refactored to cache a complete track. Seems to be faster.
- 0.2. Some experiments with disk sector interleaving. TPA shifted to $a84e to avoid collisions with BIOS/XBIOS data (needs confirmation).
- 0.1. Proof of concept. First booting version.

