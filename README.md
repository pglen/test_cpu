# FPGA open source tool test for Tang Nano 9k

  This is a makefile based FPGA design example for the gowin FPGA
that is on board of the Tang Nano 9k.

## The tools used:

    GWPACK = gowin_pack
    NEXPR = nextpnr-himbaechel
    LOADER = openFPGALoader
    YOSYS = yosys

 The Makefile include (make.mk) contains the macros of the FPGA program names.
The installation of the tools are not trivial, I had to spend quite a bit of
time installing dependencies, some of which I compiled from source.
(in particular the program pytrellis was compiled from source and
was difficult to install)

### Make targets:

    list        -   List 'v' files
    syn         -   Synthesize
    clean       -   Clean intermediaries
    git         -   Check in to git (for my installation, yours may vary)
    load        -   Load to chip memory
    loadflash   -   Load to chip flash

## Make detils:

 I elected to include the wild card feature of the Makefile. This grabs
all the .v files in the source (src/) directory. If a .v file is to
be excluded, add it to the "EXCLUDE=" line. (note the wild card here is '%')

## Sample session:

This is a copy of one FPGA build session.

    yosys -q -p  "read_verilog src/counter.v src/cpu.v src/flash.v src/miniclock.v src/monost.v src/screen.v src/text.v src/top.v src/uart_rx.v src/uart_top.v src/uart_tx.v; \
                    synth_gowin -json cpu.json ; "
    Warning: reg '\led' is assigned in a continuous assignment at src/uart_rx.v:35.8-35.27.
    Warning: Wire top.\led [3] is used but has no driver.
    Warning: define gw1n not used in the library.
    nextpnr-himbaechel -q --json cpu.json --freq 27 --write cpu_pnr.json \
    --device GW1NR-LV9QN88PC6/I5 --vopt family=GW1N-9C --vopt cst=tangnano9k.cst
    gowin_pack -d GW1N-9C -o cpu.fs cpu_pnr.json

## Example code description:

  There are a couple of simple subsystems within the code. A counter driving
the buttom 4 LEDs, resulting in the typical count pattern. Also a 10 Hz
oscillator driving LED 6, which results in a nice flicker. The UART driver
outputs a string every second. Also echos the incoming character. The UART input
is attached to a monostable, which triggers with every character and
flashes LED 4 briefly. While this is not a complex system, it contains
building blocks that can be useful in any project.

 ## References:

    [1.](https://learn.lushaylabs.com/tang-nano-series/)
    [2.](https://wiki.sipeed.com/hardware/en/tang/Tang-Nano-9K/examples/picorv)

## The power of open source.

 Creating a new FPGA fabric can be as simple as typing 'make'

## Copying:

 This code is declared open source.

// # EOF
