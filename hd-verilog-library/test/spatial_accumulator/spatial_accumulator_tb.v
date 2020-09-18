`include "const.vh"

module spatial_accumulator_tb;
	reg Clk, Reset, Enable, FirstHypervector;
	reg [0:`HV_DIMENSION-1] HypervectorIn;
	reg [`CHANNEL_WIDTH-1:0] FeatureIn;
	wire [0:`HV_DIMENSION-1] HypervectorOut;

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
		Reset = 0;
		Enable = 0;
		FirstHypervector = 0;
		HypervectorIn = `HV_DIMENSION'b1010101010;
		FeatureIn = 6'd1;
	end

	// instantiate the clock
	always
		#5 Clk = ~Clk;

	// display values
	initial begin
		$display("\t\tTime,\tClk,\tReset,\tEnable,\tFirstHypervector");
		$monitor("%d,\t%b,\t%b,\t%b,\t%b",$time,Clk,Reset,Enable,FirstHypervector);
	end

	initial
		#100 $finish;
		
	initial begin
	  @ (negedge Clk)
	  Reset = 1;
	  @ (negedge Clk)
	  Reset = 0;
	  Enable = 1;
	  FirstHypervector = 1;
	  @ (negedge Clk)
	  FirstHypervector = 0;
	  FeatureIn = FeatureIn + 1;
	  @ (negedge Clk)
	  FeatureIn = FeatureIn + 1;
    @ (negedge Clk)
    FeatureIn = FeatureIn + 1;
    @ (negedge Clk)
    FeatureIn = FeatureIn + 1;  
	end
	
	

endmodule

