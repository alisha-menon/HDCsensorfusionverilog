`timescale 1ns/100ps

`include "const.vh"
`define CLK_PERIOD 50
`define CLK_PER_SAMPLE 10

module feature_encoder_text_tb();
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
	reg [`CHANNEL_WIDTH*`INPUT_CHANNELS-1:0] FeatExpected = {`CHANNEL_WIDTH*`INPUT_CHANNELS{1'b0}};

	integer raw_file;
	integer feat_file;
	integer raw_file_data;
	integer feat_file_data;
	integer fails = 0;
	integer TestNum = 0;

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
		
	initial begin
	raw_file = $fopen("raw_input_vec.txt","r");
	feat_file = $fopen("feat_output_vec.txt","r");
	if (raw_file == 0 || feat_file == 0) begin
		$display("data_file handle was NULL");
		$finish;
	end
	end
		
	initial begin
		repeat (5) @ (negedge Clk)
		Reset = 1;
		repeat (5) @ (negedge Clk)
		Reset = 0;
		
		ReadyIn = 1;
		ModeIn = 1;
		LabelIn = 2;
		
	end

	always @(negedge Clk) begin
    		if (Reset) begin
			ClkCntr = 0;
			Raw = 0;
		end
		else begin
			ClkCntr = ClkCntr + 1;
			ValidIn = 0;
			if (ClkCntr == `CLK_PER_SAMPLE) begin
				ClkCntr = 0;				
				raw_file_data = $fscanf(raw_file, "%b\n", Raw);
				TestNum = TestNum + 1;				
				ValidIn = 1; 
				if ($feof(raw_file)) begin
					$display("Test finished with %d fails!", fails);
					$fclose(raw_file);
					$fclose(feat_file);				
					$finish;
				end
			end
		end
	end

	always @(posedge ValidOut) begin
		feat_file_data = $fscanf(feat_file, "%b\n", LabelIn);	
		feat_file_data = $fscanf(feat_file, "%b\n", FeatExpected);
		if (FeatExpected == ChannelsOut) begin
			// $display("Pass\n");
		end
		else begin
			$display("Fail: Expected = %d FeatureOut = %d\n", FeatExpected, ChannelsOut);
						
			fails = fails + 1;
		end
		ReadyIn = 1;
	end


endmodule
