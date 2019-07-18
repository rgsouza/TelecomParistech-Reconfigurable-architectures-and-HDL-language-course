// Module MED


module MED(DI, DSI, BYP, CLK, DO);

	parameter pixels = 9;	
	input [7:0] DI;
	input DSI, CLK, BYP;
	output logic [7:0] DO;
	logic [7:0] MAX; 
	logic [7:0] MIN;
	logic[7:0] shiftReg[0:7];
		

        always_ff @( posedge CLK )
	begin
		if ( DSI ) shiftReg [0] <= DI;
                else shiftReg [0] <= MIN;

		for( int i = 1; i < pixels-1; i = i +1)
			shiftReg[i] <= shiftReg[ i - 1];
	
		if ( BYP ) DO <= shiftReg[7];
                else DO <= MAX;
	end			


	MCE I_MCE(.A( DO ), .B( shiftReg[7] ), .MAX(MAX), .MIN(MIN));
	  
	  
endmodule
