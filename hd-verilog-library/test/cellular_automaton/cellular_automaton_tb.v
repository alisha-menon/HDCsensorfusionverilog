`include "const.vh"

module cellular_automaton_tb;
	reg Clk, Reset, Enable, Clear;
	wire [0:`HV_DIMENSION-1] HypervectorOut;

	// instantiate spatial accumulator
	cellular_automaton dut (
		.Clk_CI				(Clk),
		.Reset_RI			(Reset),
		.Enable_SI			(Enable),
		.Clear_SI			(Clear),
		.CellValueOut_DO  	(HypervectorOut)
		);

	// reset the input signals
	initial begin
		Clk = 0;
		Reset = 0;
		Enable = 0;
		Clear = 0;
	end

	// instantiate the clock
	always
		#5 Clk = ~Clk;

	// display values
	initial begin
		$display("\t\tTime,\tClk,\tReset,\tEnable,\tClear");
		$monitor("%d,\t%b,\t%b,\t%b,\t%b",$time,Clk,Reset,Enable,Clear);
	end
		
	initial begin
	  @ (negedge Clk)
	  Reset = 1;
	  @ (negedge Clk)
	  Reset = 0;
	  Enable = 1;
	  Clear = 1;
	  @ (negedge Clk)
	  Clear = 0;
	  repeat (64) begin
	   @ (negedge Clk);
	  end
	  @ (negedge Clk)
	  Clear = 1;
	  @ (negedge Clk)
	  Clear = 0;
	  repeat (64) begin
	   @ (negedge Clk);
	  end
	  $finish;
	end
	
	integer f;
	initial begin
	  f = $fopen("ca_out2.txt","w");
	end
	
  always @ (negedge Clk) begin
    $fwrite(f,"%b\n",HypervectorOut);
  end
    
endmodule

