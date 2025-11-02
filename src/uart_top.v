//
// Study for Tang Nano
//      by Peter Glen on Fri 31.Oct.2025
//
//  Fri 31.Oct.2025     --  string crap

`default_nettype none

parameter                       CLK_FRE  = 27;         // Mhz
parameter                       UART_BAUD = 115200;     // Baud

module uart_top(
	input                       clk,
	input                       rst_n,
	input                       uart_rx,
	output                      uart_tx,
    output                      led,
    output                      led2
);

localparam                      IDLE =  0;
localparam                      SEND =  1;         // Send
localparam                      WAIT =  2;         // Wait 1 second and send uart received data
localparam                      DONE =  3;         // No more transmissions
localparam                      BUFF =  4;         // Push buffer out
localparam                      BUFF2 =  5;        // Char transmitting

reg [7:0] counter = 8'h0;
reg [7:0] ch1;
reg [7:0] ch2;

function [7:0] increment;
        input [7:0] val;
        begin
            increment = val + 1;
        end
endfunction

//reg cnt[7:0];

function [0:0] strcmp ;
        input [7:0] str1, str2,  maxlen;
        integer cnt;
        begin
        strcmp = 0;
        for (cnt = 0; cnt < maxlen; cnt = cnt + 1)
            begin
                //if (str1[[8*(cnt+1):8*cnt] !=
                //                str2[8*(cnt+1):8*cnt]) begin
                //    strcmp = 1 ;
                //end
            end
        end
endfunction

parameter 	DATA_NUM =   37;           // Length of buffer

reg [ DATA_NUM * 8 - 1:0] send_data = {"MCPU FPGA Build: 21 cnt=", ch2, ch1, 8'h0d};
reg [7:0]                       indexx;
reg [7:0]                       progx;
reg [512:0]                     buffer;

reg[7:0]                        rx_data;
reg                             rx_data_valid;
reg[7:0]                        tx_data;
reg[7:0]                        tx_str;
reg[7:0]                        tx_cnt;
reg[7:0]                        tx_old_cnt;
reg[31:0]                       wait_cnt;
reg[3:0]                        state;
reg                             tx_data_valid;
reg                             tx_data_ready;
reg                             inited = 0;

reg [7:0] aa;

always@(posedge clk or negedge rst_n)

begin
	if(rst_n == 1'b0)
	begin
        wait_cnt <= 32'd0;
		tx_data <= 8'd0;
 		state <= IDLE;
		tx_cnt <= 8'd0;
		tx_data_valid <= 1'b0;
        inited <= 0;
        counter <= 0;
        indexx <= 1'b0;
        progx <= 1'b0;

        for (aa = 0; aa < 512; aa = aa + 1)
            begin
                //buffer[ (aa+1)*8 : aa*8] <= rx_data;
                buffer[aa] = 1'b0;
            end
	end
	else
	case(state)
		IDLE:
            if (inited == 1'b0) begin
                state <= SEND;
                inited <= 1'b0;
                indexx = 1'b0;
                progx = 1'b0;
            end
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
			else if(tx_data_valid == 1'b0)
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
			else if(tx_data_valid) // && tx_data_ready)
			begin
				tx_data_valid <= 1'b0;
			end
			else if(wait_cnt >= CLK_FRE * 1000_000) // wait for 1 second
                begin
                if  ((counter & 4'b1111) > 9)
                    ch1 <= (counter & 4'b1111) + 8'h57 ;
                else
                    ch1 <= (counter & 4'b1111) + 8'h30 ;
                if  ((counter >> 4) > 9)
                    ch2 <= (counter >> 4) + 8'h57 ;
                else
                    ch2 <= (counter >> 4) + 8'h30 ;
                counter <= counter + 1 ;
                state <= DONE;
                end
		end
        DONE:
            begin
                if(rx_data_valid == 1'b1) // && tx_data_valid == 1'b0)
                    begin
                        if (indexx < 512/8) begin
                            buffer[(indexx+1)*8:(indexx*8)] <= rx_data;
                            indexx <= increment(indexx);
                        end

                        if (rx_data == `LF || rx_data == `CR)
                            begin
                            //tx_data_valid <= 1'b1;
                	        //tx_data = 8'h41;
                            //if (strcmp(buffer, "hello", 5) ) begin
                            //end
                            state <= BUFF;
                            end
                        else
                            begin
                            // echo uart received data
                            tx_data_valid <= 1'b1;
                	        tx_data <= rx_data;
                            end
                    end
                else begin
                        tx_data_valid <= 1'b0;
                    end
            end
        // ---------------------------------------------------------------
        BUFF2:
            // Only act if character done
            begin
                // Wait for character done
                if (tx_data_ready == 1'b1)
                    begin
                        tx_data_valid <= 1'b0;
                        state <= BUFF;
                    end
            end
        BUFF:
            begin
                if (progx >= indexx)
                    begin
                        //tx_data_valid <= 1'b0;
                        indexx <= 0;
                        progx <= 0;
                        state <= DONE;
                    end
                else
                    begin
                        tx_data = buffer[(progx+1)*8:(progx*8)];
                        //tx_data <= indexx + 8'h30;
                        tx_data_valid <= 1'b1;
                        progx <= progx + 1;
                        state = BUFF2;
                    end
              end
		default:
            begin
			    //state <= IDLE;
			    state <= DONE;
            end
	endcase
end

always@(posedge clk) begin
    if (tx_old_cnt != tx_cnt) begin
        tx_str <= send_data[(DATA_NUM - 1 - tx_cnt) * 8 +: 8];
        tx_old_cnt = tx_cnt;
    end
end

// -----------------------------------------------------------------------

uart_rx #(
	.CLK_FRE(CLK_FRE),
	.BAUD_RATE(UART_BAUD)
    ) uart_rx_inst
(
	.clk                        (clk                      ),
	.rst_n                      (rst_n                    ),
	.rx_data                    (rx_data                  ),
	.rx_data_valid              (rx_data_valid            ),
	.rx_pin                     (uart_rx                  ),
    .led_out                    (led                      )
);

monost  # (.WAIT_TIME(3500000)
        )
        st2 (clk, tx_data_valid, led2);

uart_tx # (
	.CLK_FRE(CLK_FRE),
	.BAUD_RATE(UART_BAUD)
    ) uart_tx_inst
(
	.clk                        (clk                      ),
	.rst_n                      (rst_n                    ),
	.tx_data                    (tx_data                  ),
	.tx_data_valid              (tx_data_valid            ),
	.tx_data_ready              (tx_data_ready            ),
	.tx_reg                     (uart_tx                  ),
);
endmodule

// EOF
