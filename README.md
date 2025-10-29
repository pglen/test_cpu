# GOWIN open source tool test

  This is a makefile based FPGA design example for the gowin FPGA
that is on borar of the tang nano 9k.

## The tools used:

    GWPACK=gowin_pack
    NEXPR=nextpnr-himbaechel
    LOADER=openFPGALoader
    YOSYS=yosys

 The makefile include (make.mk) contains the macros of the FPGA program names.
The installation of the tools are not trivial, I had to spend quite a bit of
time installing dependencies, some of which I compiled from source.
(the program pytrellis was compiled from source and difficult to install)

### Make targets:

    list        -   List 'v' files
    syn         -   Synthesize
    clean       -   Clean intermediaries
    git         -   Check in to git (for my installation, yours may vary)
    load        -   Load to chip memory
    loadflash   -   Load to chip flash

## Make detils:

 I elected to include the wildcard feature of the makefile. This grabs
all the .v files in the ource directory. If a .v file is to be excluded,
add it to the "EXCLUDE=" line. (note the wild card here is '%')

## The power of open source.

 Creating a new FPGA fabric can be as simple as typing 'make'

 ## Refernces:

    https://learn.lushaylabs.com/tang-nano-series/
    https://wiki.sipeed.com/hardware/en/tang/Tang-Nano-9K/examples/picorv
