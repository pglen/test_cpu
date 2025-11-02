`default_nettype none

// This will wiggle pulsex line with 10 Hz

localparam CPU_CLOCK     = 27_000_000;      // This is board specific
localparam DEF_WAIT_TIME = CPU_CLOCK / 20;  // Desired frequency * 2

module miniclock
#(
	parameter WAIT_TIME = DEF_WAIT_TIME
)
(
    input clk,
    input rst_n,
    output pulsex
);

reg [32:0] clockCounter = 0;
reg clockx = 1;

always @(posedge clk or negedge rst_n) begin

    if(rst_n == 1'b0)
		begin
			clockx <= 1'b1;
		end
	else if (clockCounter >= WAIT_TIME) begin
        clockCounter <= 0;
        clockx = ~clockx;
        end
    else begin
        clockCounter <= clockCounter + 1;
    end
end

assign pulsex = clockx;

endmodule

// EOF