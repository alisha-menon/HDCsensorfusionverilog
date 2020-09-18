`timescale 1ns/100ps

`include "const.vh"
`define CLK_PERIOD 50
`define CLK_PER_SAMPLE 10

module feature_encoder_tb();
	reg Clk = 0;
	reg Reset = 0;
	reg ValidIn = 0;
	reg ReadyIn = 0;
	reg [`MODE_WIDTH-1:0] ModeIn = {`MODE_WIDTH{1'b0}};
	reg [`LABEL_WIDTH-1:0] LabelIn = {`LABEL_WIDTH{1'b0}};
	reg [`RAW_WIDTH*`INPUT_CHANNELS-1:0] Raw = {`RAW_WIDTH*`INPUT_CHANNELS{1'b0}};
	wire ReadyOut, ValidOut;
	wire [`MODE_WIDTH-1:0] ModeOut;
	wire [`LABEL_WIDTH-1:0] LabelOut;
	wire [`CHANNEL_WIDTH*`INPUT_CHANNELS-1:0] ChannelsOut;
	reg [`ceilLog2(`CLK_PER_SAMPLE)-1:0] ClkCntr = 0;

	feature_encoder dut (
		.Clk_CI(Clk),
		.Reset_RI(Reset),
		.ValidIn_SI(ValidIn), 
		.ReadyIn_SI(ReadyIn),
		.ReadyOut_SO(ReadyOut), 
		.ValidOut_SO(ValidOut),
		.ModeIn_SI(ModeIn),
		.LabelIn_DI(LabelIn),
		.Raw_DI(Raw),
		.ModeOut_SO(ModeOut),
		.LabelOut_DO(LabelOut),
		.ChannelsOut_DO(ChannelsOut)
	);

	always #(`CLK_PERIOD/2) Clk <= ~Clk;

	// display values
	initial begin
		$display("\t\tTime,\tClk,\tReset,\tRaw,\t,ChannelsOut");
		$monitor("%d,\t%b,\t%b,\t%b,\t%b",$time,Clk,Reset,Raw,ChannelsOut);
	end
		
	// initial begin
	//	#1000 $finish;

	// end
		
	initial begin
		repeat (5) @ (negedge Clk)
		Reset = 1;
		repeat (5) @ (negedge Clk)
		Reset = 0;
		
		ReadyIn = 1;
		ModeIn = 1;
		LabelIn = 2;
		
	end

	always @(posedge Clk) begin    		if (Reset) begin
			ClkCntr = 0;
			Raw = 0;
		end
		else begin
			ClkCntr = ClkCntr + 1;
			ValidIn = 0;
			if (ClkCntr == `CLK_PER_SAMPLE) begin
				ClkCntr = 0;
				Raw = Raw + 1;
				ValidIn = 1;
			end
		end
	end

endmodule
