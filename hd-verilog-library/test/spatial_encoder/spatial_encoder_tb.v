`include "const.vh"

module spatial_encoder_tb;
	reg Clk, Reset;

	reg FeatValid, HVReady;
	wire FeatReady, HVValid;

	wire [`MODE_WIDTH-1:0] ModeIn;
	wire [`LABEL_WIDTH-1:0] LabelIn;
	wire [`CHANNEL_WIDTH*`INPUT_CHANNELS-1:0] ChannelsIn;

	wire [`MODE_WIDTH-1:0] ModeOut;
	wire [`LABEL_WIDTH-1:0] LabelOut;
	wire [0:`HV_DIMENSION-1] HypervectorOut;

	wire [`MODE_WIDTH-1:0] ExpModeOut;
	wire [`LABEL_WIDTH-1:0] ExpLabelOut;
	wire [0:`HV_DIMENSION-1] ExpHypervectorOut;

	reg [(`MODE_WIDTH + `LABEL_WIDTH + (`CHANNEL_WIDTH*`INPUT_CHANNELS) + `MODE_WIDTH + `LABEL_WIDTH + `HV_DIMENSION)-1:0] vector;

	integer i;
	localparam num_tests = 100;
	reg pass = 1;

	// instantiate spatial encoder
	spatial_encoder_ping_pong dut (
		.Clk_CI				(Clk),
		.Reset_RI			(Reset),
		.ValidIn_SI			(FeatValid),
		.ReadyOut_SO		(FeatReady),
		.ReadyIn_SI			(HVReady),
		.ValidOut_SO		(HVValid),
		.ModeIn_SI			(ModeIn),
		.LabelIn_DI			(LabelIn),
		.ChannelsIn_DI		(ChannelsIn),
		.ModeOut_SO			(ModeOut),
		.LabelOut_DO		(LabelOut),
		.HypervectorOut_DO	(HypervectorOut)
		);

	assign ModeIn = vector[`MODE_WIDTH-1+(`LABEL_WIDTH + (`CHANNEL_WIDTH*`INPUT_CHANNELS) + `MODE_WIDTH + `LABEL_WIDTH + `HV_DIMENSION):(`LABEL_WIDTH + (`CHANNEL_WIDTH*`INPUT_CHANNELS) + `MODE_WIDTH + `LABEL_WIDTH + `HV_DIMENSION)];
	assign LabelIn = vector[`LABEL_WIDTH-1+((`CHANNEL_WIDTH*`INPUT_CHANNELS) + `MODE_WIDTH + `LABEL_WIDTH + `HV_DIMENSION):((`CHANNEL_WIDTH*`INPUT_CHANNELS) + `MODE_WIDTH + `LABEL_WIDTH + `HV_DIMENSION)];
	assign ChannelsIn = vector[(`CHANNEL_WIDTH*`INPUT_CHANNELS)-1+(`MODE_WIDTH + `LABEL_WIDTH + `HV_DIMENSION):(`MODE_WIDTH + `LABEL_WIDTH + `HV_DIMENSION)];
	assign ExpModeOut = vector[`MODE_WIDTH-1+(`LABEL_WIDTH + `HV_DIMENSION):(`LABEL_WIDTH + `HV_DIMENSION)];
	assign ExpLabelOut = vector[`LABEL_WIDTH-1+`HV_DIMENSION:`HV_DIMENSION];
	
	genvar j;
	generate
	  for (j=0; j<`HV_DIMENSION; j=j+1) begin
	   assign ExpHypervectorOut[`HV_DIMENSION-j-1] = vector[`HV_DIMENSION-j-1];
	  end
	endgenerate

	// instantiate the clock
	always
		#5 Clk = ~Clk;
	
	integer data_file, scan_file;
	initial begin
		data_file = $fopen("spatial_encoder_vectors.txt","r");
		if (data_file == 0) begin
			$display("NULL data file");
			$finish;
		end
		Clk = 0;
		Reset = 0;
		FeatValid = 0;
		HVReady = 1;

		repeat (5) @(negedge Clk) Reset = 1;
		@(negedge Clk) Reset = 0;
		@(negedge Clk);

		for (i=0; i<num_tests; i=i+1) begin
			@(negedge Clk);
			scan_file = $fscanf(data_file, "%b\n", vector);
			if ($feof(data_file)) begin
				if (pass)
					$display("All tests passed!");
				else
					$display("All tests failed...");
				$finish;
			end
			FeatValid = 1;
			@(posedge Clk);
			while (~FeatReady) begin
				@(posedge Clk) Reset = 0;
			end
			FeatValid = 0;
			
			while (~HVValid) begin
				@(negedge Clk);
			end

			if ({ModeOut, LabelOut, HypervectorOut} == {ExpModeOut, ExpLabelOut, ExpHypervectorOut}) begin
				$display("\tTest %d passed!", i+1);
			end else begin
				$display("\tTest %d failed!", i+1);
				pass = 0;
			end
		end
		if (pass)
	    	$display("All tests passed!");
	    else
	    	$display("Tests failed...");
		$finish;
	end

endmodule

