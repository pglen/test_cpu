`default_nettype none

module uart_top(
	input                        clk,
	input                        rst_n,
	input                        uart_rx,
	output                       uart_tx,
    //output         [1:0]       led
    output                       trig
);

parameter                        CLK_FRE  = 27;         // Mhz
parameter                        UART_FRE = 115200;     // Baud
localparam                       IDLE =  0;
localparam                       SEND =  1;         // Send
localparam                       WAIT =  2;         // Wait 1 second and send uart received data
reg[7:0]                         tx_data;
reg[7:0]
tx_str;
reg                              tx_data_valid;
wire                             tx_data_ready;
reg[7:0]                         tx_cnt;
wire[7:0]                        rx_data;
wire                             rx_data_valid;
wire                             rx_data_ready;
reg[31:0]                        wait_cnt;
reg[3:0]                         state;

assign rx_data_ready = 1'b1;    //always allow receive data,

always@(posedge clk or negedge rst_n)
begin
	if(rst_n == 1'b0)
	begin
		wait_cnt <= 32'd0;
		tx_data <= 8'd0;
		state <= IDLE;
		tx_cnt <= 8'd0;
		tx_data_valid <= 1'b0;
	end
	else
	case(state)
		IDLE:
			state <= SEND;
		SEND:
		begin
			wait_cnt <= 32'd0;
			tx_data <= tx_str;

			if(tx_data_valid == 1'b1 && tx_data_ready == 1'b1 && tx_cnt < DATA_NUM - 1)//Send 12 bytes data
			begin
				tx_cnt <= tx_cnt + 8'd1; // Send data counter
			end
			else if(tx_data_valid && tx_data_ready) // last byte sent is complete
			begin
				tx_cnt <= 8'd0;
				tx_data_valid <= 1'b0;
				state <= WAIT;
			end
			else if(~tx_data_valid)
			begin
				tx_data_valid <= 1'b1;
			end
		end
		WAIT:
		begin
			wait_cnt <= wait_cnt + 32'd1;

			if(rx_data_valid == 1'b1)
			begin
				tx_data_valid <= 1'b1;
				tx_data <= rx_data;   // send uart received data
			end
			else if(tx_data_valid && tx_data_ready)
			begin
				tx_data_valid <= 1'b0;
			end
			else if(wait_cnt >= CLK_FRE * 1000_000) // wait for 1 second
				state <= SEND;
		end
		default:
			state <= IDLE;
	endcase
end

parameter 	ENG_NUM  = 18 + 1;
parameter 	DATA_NUM = ENG_NUM + 1;

//wire [ DATA_NUM * 8 - 1:0] send_data = {"Hello Tang Nano 9K",16'h0d0a};
//reg [ DATA_NUM * 8 - 1:0] send_data = {"Hello Tang Nano 9K",16'h0d0a};
reg [ DATA_NUM * 8 - 1:0] mystr =  {"hello tang nano 9K\r\n"};
//reg [7:0] mystr [0 : DATA_NUM] =  {"hello tang nano 9K\r\n"};

reg [7:0] buffer [64:0] ;

reg done = 0;

always@(*) begin
    //if (done == 1'b0) begin
        tx_str <= 8'b0;
        //tx_str <= send_data[(DATA_NUM - 1 - tx_cnt) * 8 +: 8];
        //tx_str <= mystr[(DATA_NUM - 1 - tx_cnt) * 8 +: 8];
        //tx_str <= mystr[tx_cnt];
    //    done <= 1'b1;
    //end
end

// -----------------------------------------------------------------------

uart_rx#
(
	.CLK_FRE(CLK_FRE),
	.BAUD_RATE(UART_FRE)
) uart_rx_inst
(
	.clk                        (clk                      ),
	.rst_n                      (rst_n                    ),
	.rx_data                    (rx_data                  ),
	.rx_data_valid              (rx_data_valid            ),
	.rx_data_ready              (rx_data_ready            ),
	.rx_pin                     (uart_rx                  ),
    .led_out                    (trig                     )
);

uart_tx#
(
	.CLK_FRE(CLK_FRE),
	.BAUD_RATE(UART_FRE)
) uart_tx_inst
(
	.clk                        (clk                      ),
	.rst_n                      (rst_n                    ),
	.tx_data                    (tx_data                  ),
	.tx_data_valid              (tx_data_valid            ),
	.tx_data_ready              (tx_data_ready            ),
	.tx_pin                     (uart_tx                  )
);
endmodule