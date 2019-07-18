
module MEDIAN( DI, DO, CLK, DSI, nRST, DSO );

	input [7:0] DI;
	input CLK;
	input logic DSI, nRST;
	output logic[7:0] DO;
	output logic DSO;
	logic [7:0] o;
	logic BYP;
	logic reset;

	
	enum {INIT, S1, S1_2, S2, S2_2, S3, S3_2, S4, S4_2, S5 } state;


	MED I_MED (.DI(DI), .DSI(DSI), .BYP(BYP), .CLK(CLK), .DO(DO));

	always_ff@ ( posedge CLK or negedge reset )
		if( reset == 0 )	
			o <= 0;	
		else
			o <= o + 1;
	

	always_ff@ ( posedge CLK or negedge nRST )
	begin

	if ( !nRST )
	begin
		state <= INIT;
		DSO <= 1'b0;
	end
	
	else

	begin
			
		case (state)
 		INIT:	begin
			reset <= 1'b0;
			BYP <= 1'b0;
			state <= S1;
			end

		S1:	begin
			if ( o == 8 )
			begin
			BYP <= 1'b1;
			reset <= 1'b0;
			state <= S2;
			end
			else if ( reset == 0)
				reset <= 1;
			
			end

		S1_2:	begin
			if( o == 1 )
			begin
			reset <= 1'b0;
                        BYP <= 1'b0;
                        state <= S2;
			end
			else if ( reset == 0)
                        	reset <= 1;
			end
	
		S2:	begin
			if( o == 7 )
			begin
			reset <= 1'b0;
                        BYP <= 1'b1;
                        state <= S2_2;
			end

			else if ( reset == 0)
                        	reset <= 1;
			end
			
		S2_2:	begin
			if( o == 2 )
                       	begin
          	        reset <= 1'b0;
                        BYP <= 1'b0;
                        state <= S3;
                        end
			
			else if ( reset == 0 )
	                	reset <= 1;

			end

		S3:	begin
			if ( o == 6 )
                        begin
            		reset <= 1'b0;
                        BYP <= 1'b1;
                        state <= S3_2;
                        end

			else if ( reset == 0)
                        	reset <= 1;
			end

		S3_2:	begin	
			if ( o == 3 )
                        begin
                        reset <= 1'b0;
                        BYP <= 1'b0;
                        state <= S3_2;
                        end
			
			else if ( reset == 0)
				reset <= 1;
			end
	
		S4:	begin
			if ( o == 5 )
                       	begin
                        reset <= 1'b0;
                        BYP <= 1'b1;
                        state <= S4_2;
                        end

			else if ( reset == 0 )
				reset <= 1;
			end

		S4_2:	begin
			if ( o == 4 )
                   	begin   
                 	reset <= 1'b0;
                        BYP <= 1'b0;
                        state <= S5;
                        end

			else if ( reset == 0 )
				reset <= 1;
			end

		S5:	begin
			if ( o == 4 )
                     		state <= INIT;
			else if ( reset == 0 )
				reset <= 1;
			end
		endcase
		
		if ( state == INIT )
			DSO <= 1'b0;

		if ( state == S1 )
                        DSO <= 1'b0;

		if ( state == S1_2 )
                        DSO <= 1'b0;
                    
		if ( state == S2 )
                        DSO <= 1'b0;

                if ( state == S2_2 )
		        DSO <= 1'b0;

		if ( state == S3 )
                        DSO <= 1'b0;
           
		if ( state == S3_2 )
	        	DSO <= 1'b0;

		if ( state == S4 )
                        DSO <= 1'b0;

                if ( state == S4_2 )
		        DSO <= 1'b0;

		if ( state == S5 )
                        DSO <= 1'b1;

	end
	end
endmodule
