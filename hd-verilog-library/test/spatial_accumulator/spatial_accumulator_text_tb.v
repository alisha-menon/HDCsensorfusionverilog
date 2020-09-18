`include "const.vh"

module spatial_accumulator_text_tb;
	reg [`HV_DIMENSION+`HV_DIMENSION+`CHANNEL_WIDTH+3-1:0] vector;
	reg Clk;
	wire Reset, Enable, FirstHypervector;
	wire [0:`HV_DIMENSION-1] HypervectorIn;
	wire [`CHANNEL_WIDTH-1:0] FeatureIn;
	wire [0:`HV_DIMENSION-1] HypervectorOut;
	wire [0:`HV_DIMENSION-1] ExpectedHV;

	reg pass;

	integer data_file;
	integer scan_file;
	integer Count;

	assign Reset = vector[`HV_DIMENSION+`HV_DIMENSION+`CHANNEL_WIDTH+2];
	assign Enable = vector[`HV_DIMENSION+`HV_DIMENSION+`CHANNEL_WIDTH+1];
	assign FirstHypervector = vector[`HV_DIMENSION+`HV_DIMENSION+`CHANNEL_WIDTH];
	assign FeatureIn = vector[`HV_DIMENSION+`HV_DIMENSION+`CHANNEL_WIDTH-1:`HV_DIMENSION+`HV_DIMENSION];
	assign HypervectorIn = vector[`HV_DIMENSION+`HV_DIMENSION-1:`HV_DIMENSION];
	assign ExpectedHV = vector[`HV_DIMENSION-1:0];

	// instantiate spatial accumulator
	spatial_accumulator dut (
		.Clk_CI				(Clk),
		.Reset_RI			(Reset),
		.Enable_SI			(Enable),
		.FirstHypervector_SI(FirstHypervector),
		.HypervectorIn_DI   (HypervectorIn),
		.FeatureIn_DI       (FeatureIn),
		.HypervectorOut_DO  (HypervectorOut)
		);

	// reset the input signals
	initial begin
		Clk = 0;
		vector = 0;
		pass = 1;
		Count = 0;
	end

	// instantiate the clock
	always
		#5 Clk = ~Clk;

	// display values
	initial begin
		$display("\t\tTime,\tClk,\tReset,\tEnable,\tFirstHypervector,\tFeature");
		$monitor("%d,\t%b,\t%b,\t%b,\t%b,\t%d",$time,Clk,Reset,Enable,FirstHypervector,FeatureIn);
	end

	initial begin
		data_file = $fopen("spatial_accumulator_vectors.txt","r");
		if (data_file == 0) begin
			$display("data_file handle was NULL");
			$finish;
		end
	end

	always @(negedge Clk) begin
	  Count = Count + 1;
		scan_file = $fscanf(data_file, "%b\n", vector);
		if ($feof(data_file)) begin
		  if (pass)
		    $display("Tests passed!");
		  else
		    $display("Tests failed...");
		  $finish;
		end
	end

	always @(negedge Clk) begin
		if (HypervectorOut != ExpectedHV) begin
		  $display("\t");
			$display("\tDUT error at vector %d", Count-1);
			$display("\tExpected");
			$display("\t%b", ExpectedHV);
			$display("\tGot");
			$display("\t%b", HypervectorOut);
			$display("\t");
			pass = 0;
		end
	end
endmodule

