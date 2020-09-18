`include "const.vh"

module hdc_top_tb;
	reg Clk, Reset;

	reg RawValid, ResultReady;
	wire RawReady, ResultValid;

	wire [`MODE_WIDTH-1:0] ModeIn;
	wire [`LABEL_WIDTH-1:0] LabelIn;
	wire [`RAW_WIDTH*`INPUT_CHANNELS-1:0] Raw;
	wire [1023:0] Raw_Datapath;

	wire [`LABEL_WIDTH-1:0] LabelOut;
	wire [`DISTANCE_WIDTH-1:0] DistanceOut;

	reg [(`MODE_WIDTH + `LABEL_WIDTH + `RAW_WIDTH*`INPUT_CHANNELS)-1:0] vector;

	// instantiate top level hdc
	hdc_top dut(
		.Clk_CI        (Clk),
		.Reset_RI      (Reset),
		.ValidIn_SI    (RawValid),
		.ReadyOut_SO   (RawReady),
		.ReadyIn_SI    (ResultReady),
		.ValidOut_SO   (ResultValid),
		.ModeIn_SI     (ModeIn),
		.LabelIn_DI    (LabelIn),
		.Raw_DI        (Raw_Datapath),
		.LabelOut_DO   (LabelOut),
		.DistanceOut_DO(DistanceOut)
	);

	assign ModeIn = vector[`MODE_WIDTH-1+(`LABEL_WIDTH + `RAW_WIDTH*`INPUT_CHANNELS):(`LABEL_WIDTH + `RAW_WIDTH*`INPUT_CHANNELS)];
	assign LabelIn = vector[`LABEL_WIDTH-1+`RAW_WIDTH*`INPUT_CHANNELS:`RAW_WIDTH*`INPUT_CHANNELS];
	assign Raw = vector[`RAW_WIDTH*`INPUT_CHANNELS-1:0];
	
	generate
    genvar j;
    for (j=0; j < `INPUT_CHANNELS; j=j+1) begin
      assign Raw_Datapath[(j+1)*16-2:j*16] = Raw[(j+1)*15-1:j*15];
      assign Raw_Datapath[(j+1)*16-1] = 1'b0;
    end
  endgenerate
	

	// instantiate the clock
	always
		#5 Clk = ~Clk;
	
	integer data_file, scan_file;
	initial begin
		data_file = $fopen("top_raw_vectors.txt","r");
		if (data_file == 0) begin
			$display("NULL data file");
			$finish;
		end
		Clk = 0;
		Reset = 1;
		RawValid = 0;
		ResultReady = 1;

		repeat (5) @(negedge Clk) Reset = 0;
		@(negedge Clk) Reset = 1;
		@(negedge Clk);

		while (1) begin
			@(negedge Clk);
			scan_file = $fscanf(data_file, "%b\n", vector);
			RawValid = 1;
			@(posedge Clk);
			while (~RawReady) begin
				@(posedge Clk);
			end
			RawValid = 0;
			repeat (150) @(negedge Clk);
			if ($feof(data_file))
			  $stop;
		end
	end
	
	integer result_file;
	initial begin
	  result_file = $fopen("hdc_top_outputs.txt","w");
	end

	always @(posedge Clk) begin
		if (ResultValid)
			$fwrite(result_file,"%d\t %d\n",LabelOut, DistanceOut);
	end

endmodule

