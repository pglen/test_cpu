`default_nettype none

module monost  #  (
    parameter WAIT_TIME   = 3500000
)
(
    input clk,
    input trigx,
    output led
);

reg [23:0] clockCounter = 0;
reg trig2 = 0;

always @(posedge clk) begin

    // Latch
    if (trigx == 1'b1) begin
        trig2 <= 1'b1;
        clockCounter <= 0;
    end
    // Count
    if (trig2 == 1'b1) begin
        clockCounter <= clockCounter + 1;
        if (clockCounter == WAIT_TIME) begin
            clockCounter <= 0;
            trig2 <= 1'b0;
        end
    end
end
assign led = ~trig2;
endmodule
