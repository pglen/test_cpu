`default_nettype none

module miniclock
(
    input clk,
    output pulsex
);

localparam CPU_CLOCK = 27_000_000;      // This is board specific
localparam WAIT_TIME = CPU_CLOCK / 20;  // Desired frequency * 2

reg [32:0] clockCounter = 0;
reg clockx = 1;

always @(posedge clk) begin
    if (clockCounter >= WAIT_TIME) begin
        clockCounter <= 0;
        clockx = ~clockx;
        end
    else begin
        clockCounter <= clockCounter + 1;
    end
end

assign pulsex = clockx;

endmodule
