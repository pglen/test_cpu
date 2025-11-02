//
// Study for Tang Nano
//      by Peter Glen on Fri 31.Oct.2025
//

`default_nettype none

localparam CPU_CLOCK     = 27_000_000;      // This is board specific

module top
#(
  parameter STARTUP_WAIT = 32'd10000000
)
(
    input clk,
    input btn1,
    input btn2,
    output ioSclk,
    output ioSdin,
    output ioCs,
    output ioDc,
    output ioReset,
    output flashClk,
    input flashMiso,
    output flashMosi,
    output flashCs,
    output [5:0] led,
    input   uart_rx,
    output  uart_tx,
);
    reg btn1Reg = 1, btn2Reg = 1;
    always @(negedge clk) begin
        btn1Reg <= btn1 ? 0 : 1;
        btn2Reg <= btn2 ? 0 : 1;
    end

    wire [5:0] led2;
    led_counter cnt (clk, btn1, led[2:0]);

    wire [9:0] pixelAddress;
    wire [7:0] textPixelData;
    wire [5:0] charAddress;
    reg [7:0]  charOutput = "A";

    screen #(STARTUP_WAIT) scr(
        clk,
        ioSclk,
        ioSdin,
        ioCs,
        ioDc,
        ioReset,
        pixelAddress,
        textPixelData
    );
    textEngine te(
        clk,
        pixelAddress,
        textPixelData,
        charAddress,
        charOutput
    );

    wire [10:0] flashReadAddr;
    wire [7:0] byteRead;
    wire enableFlash;
    wire flashDataReady;

    flash externalFlash(
        clk,
        flashClk,
        flashMiso,
        flashMosi,
        flashCs,
        flashReadAddr,
        byteRead,
        enableFlash,
        flashDataReady
    );
    wire [7:0] cpuChar;
    wire [5:0] cpuCharIndex;
    wire writeScreen;
    cpu c(
        clk,
        flashReadAddr,
        byteRead,
        enableFlash,
        flashDataReady,
        led2,
        cpuChar,
        cpuCharIndex,
        writeScreen,
        btn1Reg,
        btn2Reg
    );
    wire    [3:0]   reg_div_we;
    wire    [31:0]  reg_div_di;
    wire    [31:0]  reg_div_do;
    wire            reg_dat_we;
    wire            reg_dat_re;
    wire    [31:0]  reg_dat_di;
    wire    [31:0]  reg_dat_do;
    wire            reg_dat_wait;
    wire            trig;
    //wire            trig2;

miniclock mc (clk, btn1, led[5]);

monost  # (.WAIT_TIME(1500000)
        )
       st(clk, trig, led[4]);

uart_top ut (
	 clk,
	 btn1,
	 uart_rx,
	 uart_tx,
     trig,
     led[3]
    );

    reg [511:0] screenBuffer = 0;
    always @(posedge clk) begin
        if (writeScreen)
            screenBuffer[{cpuCharIndex, 3'b0}+:8] <= cpuChar;
        else
            charOutput <= screenBuffer[{charAddress, 3'b0}+:8];
    end
endmodule

// EOF
