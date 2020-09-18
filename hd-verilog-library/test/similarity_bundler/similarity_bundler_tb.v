`include "const.vh"

module similarity_bundler_tb;
	reg Clk, Reset;
	reg BundleEnable, CycleEnable, CycleClear;
	reg [0:`HV_DIMENSION-1] HypervectorIn;
	wire [0:`HV_DIMENSION-1] HypervectorOut;

	reg pass;

	integer data_file;
	integer scan_file;
	integer Count;

	// instantiate spatial accumulator
	similarity_bundler dut (
		.Clk_CI                 (Clk),
		.Reset_RI               (Reset),
		.BundledHypervectorEN_SI(BundleEnable),
		.CycleShiftRegEN_SI     (CycleEnable),
		.CycleShiftRegCLR_SI    (CycleClear),
		.HypervectorIn_DI       (HypervectorIn),
		.HypervectorOut_DO      (HypervectorOut)
	);

	// instantiate the clock
	always
		#5 Clk = ~Clk;

	initial begin
		data_file = $fopen("similarity_bundler_vectors.txt","r");
		if (data_file == 0) begin
			$display("data_file handle was NULL");
			$stop;
		end
	end

	initial begin
		Clk = 0;
		Reset = 0;
		BundleEnable = 0;
		CycleEnable = 0;
		CycleClear = 0;
		Count = 0;

		@ (negedge Clk)
		Reset = 1;
		@ (negedge Clk)
		Reset = 0;
		@ (negedge Clk);
		@ (negedge Clk);
		@ (negedge Clk);

		while (1) begin
			scan_file = $fscanf(data_file, "%b\n", HypervectorIn);
			Count = Count + 1;
			BundleEnable = 1;
			CycleEnable = 1;
			@(negedge Clk);
			if ($feof(data_file))
			  $stop;
			if (Count == 76) begin
				Count = 0;
				BundleEnable = 0;
				CycleEnable = 0;
				@ (negedge Clk)
				CycleClear = 1;
				@ (negedge Clk)
				CycleClear = 0;
				@ (negedge Clk);
			end
		end
	end

	integer f;
	initial begin
	  f = $fopen("similarity_bundler_out.txt","w");
	end

	always @(negedge Clk) begin
		$fwrite(f,"%b\n",HypervectorOut);
	end
endmodule

