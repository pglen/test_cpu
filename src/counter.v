`default_nettype none

module led_counter
(
    input clk,
    input rst_n,
    output [2:0] led
);

localparam WAIT_TIME = 13500000;
reg [2:0] ledCounter = 0;
reg [23:0] clockCounter = 0;

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)
		begin
            clockCounter <= 0;
            ledCounter <= 0;
		end
	else begin
        if (clockCounter < WAIT_TIME) begin
            clockCounter <= clockCounter + 1;
        end
        else begin
            clockCounter <= 0;
            ledCounter <= ledCounter + 1;
        end
    end
end

assign led = ~ledCounter;
endmodule
