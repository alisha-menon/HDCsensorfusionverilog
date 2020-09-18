`include "const.vh"

module temporal_encoder_andy_tb;
	reg Clk, Reset;

	reg TemporalValid, STReady;
	wire TemporalReady, STValid;

	wire [`MODE_WIDTH-1:0] ModeIn;
	wire [`LABEL_WIDTH-1:0] LabelIn;
	wire [0:`HV_DIMENSION-1] HypervectorIn;

	wire [`MODE_WIDTH-1:0] ModeOut;
	wire [`LABEL_WIDTH-1:0] LabelOut;
	wire [0:`HV_DIMENSION-1] HypervectorOut;

	reg [(`MODE_WIDTH + `LABEL_WIDTH + `HV_DIMENSION)-1:0] vector;

	// instantiate temporal encoder
	temporal_encoder dut(
		.Clk_CI				(Clk),
		.Reset_RI			(Reset),
		.ValidIn_SI			(TemporalValid),
		.ReadyOut_SO		(TemporalReady),
		.ReadyIn_SI			(STReady),
		.ValidOut_SO		(STValid),
		.ModeIn_SI			(ModeIn),
		.LabelIn_DI			(LabelIn),
		.HypervectorIn_DI	(HypervectorIn),
		.ModeOut_SO			(ModeOut),
		.LabelOut_DO		(LabelOut),
		.HypervectorOut_DO	(HypervectorOut)
		);

	assign ModeIn = vector[`MODE_WIDTH-1+(`LABEL_WIDTH + `HV_DIMENSION):(`LABEL_WIDTH + `HV_DIMENSION)];
	assign LabelIn = vector[`LABEL_WIDTH-1+`HV_DIMENSION:`HV_DIMENSION];
	assign HypervectorIn = vector[`HV_DIMENSION-1:0];

	// instantiate the clock
	always
		#5 Clk = ~Clk;
	
	integer data_file, scan_file;
	initial begin
		data_file = $fopen("andy_vectors.txt","r");
		if (data_file == 0) begin
			$display("NULL data file");
			$finish;
		end
		Clk = 0;
		Reset = 0;
		TemporalValid = 0;
		STReady = 1;

		repeat (5) @(negedge Clk) Reset = 1;
		@(negedge Clk) Reset = 0;
		@(negedge Clk);

		while (1) begin
		  @(negedge Clk)
			scan_file = $fscanf(data_file, "%b\n", vector);
			TemporalValid = 1;
			@(posedge Clk);
			while (~TemporalReady) begin
				@(posedge Clk);
			end
			//@(negedge Clk) TemporalValid = 1;
			//@(negedge Clk) TemporalValid = 0;
			TemporalValid = 0;
			if ($feof(data_file))
			  $stop;
		end
	end
	

	integer f;
	initial begin
	  f = $fopen("temp_outputs.txt","w");
	end

	always @(posedge Clk) begin
		if (STValid)
			$fwrite(f,"%b\n",{ModeOut, LabelOut, HypervectorOut});
	end

endmodule

