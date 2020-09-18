`include "const.vh"

module temporal_encoder_predict_tb;
	reg Clk, Reset;

	reg TemporalValid, STReady;
	wire TemporalReady, STValid;

	wire [`MODE_WIDTH-1:0] ModeIn;
	wire [`LABEL_WIDTH-1:0] LabelIn;
	wire [0:`HV_DIMENSION-1] HypervectorIn;

	wire [`MODE_WIDTH-1:0] ModeOut;
	wire [`LABEL_WIDTH-1:0] LabelOut;
	wire [0:`HV_DIMENSION-1] HypervectorOut;

	wire [`MODE_WIDTH-1:0] ExpModeOut;
	wire [`LABEL_WIDTH-1:0] ExpLabelOut;
	wire [0:`HV_DIMENSION-1] ExpHypervectorOut;

	reg [(`MODE_WIDTH + `LABEL_WIDTH + `HV_DIMENSION + `MODE_WIDTH + `LABEL_WIDTH + `HV_DIMENSION)-1:0] vector;

	integer i, y, train_counter, test_counter;
	localparam num_tests = 822;
	localparam mode_train = 0;
	localparam mode_update = 2;
	localparam mode_predict = 1;
	reg pass = 1;

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

	assign ModeIn = vector[`MODE_WIDTH-1+(`LABEL_WIDTH + `HV_DIMENSION+ `MODE_WIDTH + `LABEL_WIDTH + `HV_DIMENSION):(`LABEL_WIDTH + `HV_DIMENSION + `MODE_WIDTH + `LABEL_WIDTH + `HV_DIMENSION)];
	assign LabelIn = vector[`LABEL_WIDTH-1+(`HV_DIMENSION + `MODE_WIDTH + `LABEL_WIDTH + `HV_DIMENSION):(`HV_DIMENSION + `MODE_WIDTH + `LABEL_WIDTH + `HV_DIMENSION)];
	assign HypervectorIn = vector[`HV_DIMENSION-1+(`MODE_WIDTH + `LABEL_WIDTH + `HV_DIMENSION):(`MODE_WIDTH + `LABEL_WIDTH + `HV_DIMENSION)];
	assign ExpModeOut = vector[`MODE_WIDTH-1+(`LABEL_WIDTH + `HV_DIMENSION):(`LABEL_WIDTH + `HV_DIMENSION)];
	assign ExpLabelOut = vector[`LABEL_WIDTH-1+`HV_DIMENSION:`HV_DIMENSION];
	assign ExpHypervectorOut = vector[`HV_DIMENSION-1:0];

	// instantiate the clock
	always
		#5 Clk = ~Clk;
	
	integer data_file, scan_file;
	initial begin
		data_file = $fopen("temporal_encoder_vectors.txt","r");
		if (data_file == 0) begin
			$display("NULL data file");
			$finish;
		end
		Clk = 0;
		Reset = 0;
		TemporalValid = 0;
		STReady = 0;
		test_counter = 0;
		//reset
		repeat (5) @(negedge Clk) Reset = 1;
		@(negedge Clk) Reset = 0;
		@(negedge Clk);
		//train_counter = 0;
		//for (i=0; i<num_tests; i=i+1) begin
			// scan vector in
		while (~TemporalReady) begin
			@(negedge Clk) Reset = 0;
		end


		//first vector
		scan_file = $fscanf(data_file, "%b\n", vector);
		test_counter = test_counter + 1;
			//if ($feof(data_file)) begin
			//	if (pass)
			//		$display("All tests passed!");
			//	else
			//		$display("All tests failed...");
			//	$finish;
			//end
			//wait for temporal encoder to be ready
			//provide input valid signal
		TemporalValid = 1;

		//Prediction mode testing
		for (i=0; i<64; i=i+1) begin
			@(negedge Clk);
				TemporalValid = 0;
				STReady = 1;
				if ({ModeOut, LabelOut, HypervectorOut} == {ExpModeOut, ExpLabelOut, ExpHypervectorOut}) begin
					$display("\tTest %d passed!", test_counter);
				end else begin
					$display("\tTest %d failed!, output should be %d but is %d", test_counter, ExpHypervectorOut, HypervectorOut);
					pass = 0;
				end
			@(negedge Clk);
				STReady = 0; 
				scan_file = $fscanf(data_file, "%b\n", vector);
				test_counter = test_counter + 1;
				TemporalValid = 1;
		end

		//training mode testing w/change of mode
		for (y=0; y<4; y=y+1) begin
			//train
			for (i=0; i<75; i=i+1) begin
				@(negedge Clk);
					if ({ModeOut, LabelOut, HypervectorOut} == {ExpModeOut, ExpLabelOut, ExpHypervectorOut}) begin
						$display("\tTest %d passed!", test_counter);
					end else begin
						$display("\tTest %d failed!, output should be %d but is %d", test_counter, ExpHypervectorOut, HypervectorOut);
						pass = 0;
					end
					scan_file = $fscanf(data_file, "%b\n", vector);
					test_counter = test_counter + 1;

			end
			//change to predict mode
			@(negedge Clk);
					if ({ModeOut, LabelOut, HypervectorOut} == {ExpModeOut, ExpLabelOut, ExpHypervectorOut}) begin
						$display("\tTest %d passed!", test_counter);
					end else begin
						$display("\tTest %d failed!, output should be %d but is %d", test_counter, ExpHypervectorOut, HypervectorOut);
						pass = 0;
					end
					scan_file = $fscanf(data_file, "%b\n", vector);
					test_counter = test_counter + 1;
					STReady = 1;
			//change back to train mode
			@(negedge Clk);
					STReady = 0;
					if ({ModeOut, LabelOut, HypervectorOut} == {ExpModeOut, ExpLabelOut, ExpHypervectorOut}) begin
						$display("\tTest %d passed!", test_counter);
					end else begin
						$display("\tTest %d failed!, output should be %d but is %d", test_counter, ExpHypervectorOut, HypervectorOut);
						pass = 0;
					end
					scan_file = $fscanf(data_file, "%b\n", vector);
					test_counter = test_counter + 1;
		end

		//training mode testing w/change of label
		for (y=0; y<4; y=y+1) begin
			//train
			for (i=0; i<75; i=i+1) begin
				@(negedge Clk);
					if ({ModeOut, LabelOut, HypervectorOut} == {ExpModeOut, ExpLabelOut, ExpHypervectorOut}) begin
						$display("\tTest %d passed!", test_counter);
					end else begin
						$display("\tTest %d failed!, output should be %d but is %d", test_counter, ExpHypervectorOut, HypervectorOut);
						pass = 0;
					end
					scan_file = $fscanf(data_file, "%b\n", vector);
					test_counter = test_counter + 1;
			end
			//change label
			@(negedge Clk);
					if ({ModeOut, LabelOut, HypervectorOut} == {ExpModeOut, ExpLabelOut, ExpHypervectorOut}) begin
						$display("\tTest %d passed!", test_counter);
					end else begin
						$display("\tTest %d failed!, output should be %d but is %d", test_counter, ExpHypervectorOut, HypervectorOut);
						pass = 0;
					end
					scan_file = $fscanf(data_file, "%b\n", vector);
					test_counter = test_counter + 1;
					STReady = 1;
			//change back to train mode
			@(negedge Clk);
					STReady = 0;
					if ({ModeOut, LabelOut, HypervectorOut} == {ExpModeOut, ExpLabelOut, ExpHypervectorOut}) begin
						$display("\tTest %d passed!", test_counter);
					end else begin
						$display("\tTest %d failed!, output should be %d but is %d", test_counter, ExpHypervectorOut, HypervectorOut);
						pass = 0;
					end
					scan_file = $fscanf(data_file, "%b\n", vector);
					test_counter = test_counter + 1;
		end

		for (i=0; i<64; i=i+1) begin
			@(negedge Clk);
				TemporalValid = 0;
				STReady = 1;
				if ({ModeOut, LabelOut, HypervectorOut} == {ExpModeOut, ExpLabelOut, ExpHypervectorOut}) begin
					$display("\tTest %d passed!", test_counter);
				end else begin
					$display("\tTest %d failed!, output should be %d but is %d", test_counter, ExpHypervectorOut, HypervectorOut);
					pass = 0;
				end
			@(negedge Clk);
				STReady = 0; 
				scan_file = $fscanf(data_file, "%b\n", vector);
				test_counter = test_counter + 1;
				TemporalValid = 1;
		end
		for (i=0; i<76; i=i+1) begin
			@(negedge Clk);
				if ({ModeOut, LabelOut, HypervectorOut} == {ExpModeOut, ExpLabelOut, ExpHypervectorOut}) begin
					$display("\tTest %d passed!", test_counter);
				end else begin
					$display("\tTest %d failed!, output should be %d but is %d", test_counter, ExpHypervectorOut, HypervectorOut);
					pass = 0;
				end
				scan_file = $fscanf(data_file, "%b\n", vector);
				test_counter = test_counter + 1;
		end
		@(negedge Clk);
			STReady = 1;
			if ({ModeOut, LabelOut, HypervectorOut} == {ExpModeOut, ExpLabelOut, ExpHypervectorOut}) begin
				$display("\tTest %d passed!", test_counter);
			end else begin
				$display("\tTest %d failed!, output should be %d but is %d", test_counter, ExpHypervectorOut, HypervectorOut);
				pass = 0;
			end
		@(negedge Clk);
			STReady = 0;


			// @(negedge Clk);
			// TemporalValid = 0;
			// if (ModeIn != `MODE_TRAIN) begin
			// 	while (~STValid) begin
			// 		@(negedge Clk);
			// 	end
			// 	if (i < num_tests) begin
			// 		if ({ModeOut, LabelOut, HypervectorOut} == {ExpModeOut, ExpLabelOut, ExpHypervectorOut}) begin
			// 			$display("\tTest %d passed!", i+1);
			// 		end else begin
			// 			$display("\tTest %d failed!, output should be %d but is %d", i+1, ExpHypervectorOut, HypervectorOut);
			// 			pass = 0;
			// 		end
			// 	end
			// 	@(negedge Clk);
			// 	STReady = 1;
			// 	@(negedge Clk);
			// 	STReady = 0;
			// 	@(negedge Clk);
			// end
			// else begin
			// 	if (train_counter<`MAX_BUNDLE_CYCLES-4) begin // if still training 76 times
			// 		if (i < num_tests) begin // while less than num_tests, print pass or fail
			// 			if ({ModeOut, LabelOut, HypervectorOut} == {ExpModeOut, ExpLabelOut, ExpHypervectorOut}) begin
			// 				$display("\tTest %d passed!", i+1);
			// 			end else begin
			// 				$display("\tTest %d failed!, output should be %d but is %d", i+1, ExpHypervectorOut, HypervectorOut);
			// 				pass = 0;
			// 			end
			// 		end
			// 		train_counter = train_counter+1;
			// 	end
			// 	else begin
			// 		if (i < num_tests) begin
			// 			if ({ModeOut, LabelOut, HypervectorOut} == {ExpModeOut, ExpLabelOut, ExpHypervectorOut}) begin
			// 				$display("\tTest %d passed!", i+1);
			// 			end 
			// 			else begin
			// 				$display("\tTest %d failed!, output should be %d but is %d", i+1, ExpHypervectorOut, HypervectorOut);
			// 				pass = 0;
			// 			end
			// 		end
			// 		train_counter = 0; // once done with training, trigger ready signal
			// 		@(negedge Clk);
			// 		STReady = 1;
			// 		@(negedge Clk);
			// 		STReady = 0;
			// 		@(negedge Clk);
			// 	end
			//end
			
		//end
		if (pass)
	     	$display("All tests passed!");
	    else
	    	$display("Tests failed...");
		$finish;
	end

endmodule

