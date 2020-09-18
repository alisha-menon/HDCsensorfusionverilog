`include "const.vh"

module hv_man_tb;
	wire [0:`MAX_BUNDLE_CYCLES-1] ManipulatorIn;
	wire [0:`HV_DIMENSION-1] HypervectorIn, HypervectorOut, ExpectedHypervectorOut;
	reg [(`HV_DIMENSION+`HV_DIMENSION+`MAX_BUNDLE_CYCLES)-1:0] vector;

	reg Clk;

	integer data_file, scan_file;
	reg pass;
	integer Count; 

	hypervector_manipulator dut (
		.HypervectorIn_DI		(HypervectorIn),
		.ManipulatorIn_DI		(ManipulatorIn),
		.HypervectorOut_DO		(HypervectorOut)
	);

	initial begin
		vector = 0;
		Clk = 0;
		pass = 1;
		Count = 0;
	end

	always
		#5 Clk = ~Clk;

	assign HypervectorIn = vector[`HV_DIMENSION-1+(`MAX_BUNDLE_CYCLES+`HV_DIMENSION):(`MAX_BUNDLE_CYCLES+`HV_DIMENSION)];
	assign ManipulatorIn = vector[`MAX_BUNDLE_CYCLES-1+`HV_DIMENSION:`HV_DIMENSION];
	assign ExpectedHypervectorOut = vector[`HV_DIMENSION-1:0];
		
	initial begin
		data_file = $fopen("hv_man_vectors.txt","r");
		if (data_file == 0) begin
			$display("data_file handle was NULL");
			$finish;
		end
	end

	always @(negedge Clk) begin
		scan_file = $fscanf(data_file, "%b\n", vector);
		Count = Count + 1;
		if ($feof(data_file)) begin
		  if (pass)
		    $display("Tests passed!");
		  else
		    $display("Tests failed...");
		  $finish;
		end
	end

	always @(posedge Clk) begin
		if (HypervectorOut != ExpectedHypervectorOut) begin
			$display("Error at %d", Count);
			pass = 0;
		end
	end
	
	integer f;
	initial begin
	  f = $fopen("hv_man_out.txt","w");
	end
	
	always @(posedge Clk) begin
	  $fwrite(f,"%b\n%b\n%b\n\n",HypervectorIn,ManipulatorIn,HypervectorOut);
	end
	  
    
endmodule

