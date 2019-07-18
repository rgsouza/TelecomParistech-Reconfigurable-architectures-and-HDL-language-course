// Auteur: Rayanne Souza

module resynchronisation #( parameter outRST = 1'b0 )( input CLK, input RST_IN, output logic RST_OUT );

	logic flip_flop;
	
	always_ff @( posedge CLK or negedge RST_IN )
	begin
		if ( !RST_IN )
		begin
			flip_flop <= outRST;
			RST_OUT <= outRST;
		end
		else
		begin
			flip_flop <= !outRST;
			RST_OUT <= flip_flop;
			

		end
		
	end

endmodule
