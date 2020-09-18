`include "const.vh"

module associative_memory_tb;
	reg Clk, Reset;

	reg InputValid, ResultReady;
	wire InputReady, ResultValid;

	reg [(`MODE_WIDTH + `LABEL_WIDTH + `HV_DIMENSION)-1:0] vector;
	wire [`MODE_WIDTH-1:0] ModeIn;
	wire [`LABEL_WIDTH-1:0] LabelIn;
	wire [0:`HV_DIMENSION-1] HypervectorIn;

	assign ModeIn = vector[`MODE_WIDTH-1+(`LABEL_WIDTH + `HV_DIMENSION):(`LABEL_WIDTH + `HV_DIMENSION)];
	assign LabelIn = vector[`LABEL_WIDTH-1+`HV_DIMENSION:`HV_DIMENSION];
	assign HypervectorIn = vector[`HV_DIMENSION-1:0];

	wire [`LABEL_WIDTH-1:0] LabelOut;
	wire [`DISTANCE_WIDTH-1:0] DistanceOut;
	
	integer i;

	// instantiate associative memory
	associative_memory_vs dut (
		.Clk_CI				(Clk),
		.Reset_RI			(Reset),
		.ValidIn_SI			(InputValid),
		.ReadyOut_SO		(InputReady),
		.ReadyIn_SI			(ResultReady),
		.ValidOut_SO		(ResultValid),
		.ModeIn_SI			(ModeIn),
		.LabelIn_DI			(LabelIn),
		.HypervectorIn_DI	(HypervectorIn),
		.LabelOut_DO		(LabelOut),
		.DistanceOut_DO		(DistanceOut)
		);

	// instantiate the clock
	always
		#5 Clk = ~Clk;
	
	integer data_file, scan_file, output_file;
	initial begin
		data_file = $fopen("associative_mem_vectors.txt","r");
		if (data_file == 0) begin
			$display("NULL data file");
			$stop;
		end
		output_file = $fopen("associative_mem_predictions.txt","w");
		Clk = 0;
		Reset = 0;
		InputValid = 0;
		ResultReady = 1;

		repeat (5) @(negedge Clk) Reset = 1;
		@(negedge Clk) Reset = 0;
		@(negedge Clk);

		while (1) begin
			@(negedge Clk);
			scan_file = $fscanf(data_file, "%b\n", vector);
			InputValid = 1;
			@(posedge Clk);
			while (~InputReady) begin
				@ (posedge Clk) Reset = 0;
			end
			InputValid = 0;
			if ($feof(data_file))
				$stop;
		end
	end

	always @(posedge Clk) begin
		if (ResultValid)
			$fwrite(output_file,"Label: %d \t Distance: %d \n",LabelOut,DistanceOut);
	end

endmodule

