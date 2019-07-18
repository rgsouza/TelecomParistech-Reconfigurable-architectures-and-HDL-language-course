//-----------------------------------------------------------------
// Wishbone BlockRAM
//-----------------------------------------------------------------
//
// Le paramètre mem_adr_width doit permettre de déterminer le nombre 
// de mots de la mémoire : (2048 pour mem_adr_width=11)

module wb_bram #(parameter mem_adr_width = 11) (
	// Wishbone interface
	wshb_if.slave wb_s
	);

	parameter size_mem = 32;
	logic ack_write;
	logic ack_read;
	logic [31 : 0] address;
	logic [31:0] addr;
	logic burst, read_mode;

	logic [ size_mem -1 : 0] memory [0 : 2**mem_adr_width - 1];

	assign wb_s.err = 1'b0;
	assign wb_s.rty = 1'b0;
	assign read_mode = !wb_s.we & wb_s.stb;
	

	enum logic [1:0] { CLASSIC, INC_BURST } state, next_state;

	always_ff @( posedge wb_s.clk )
	begin
		if ( wb_s.stb )
		begin
			if ( wb_s.we )
			begin
			for( int i = 0; i <= 3; i++ )
				if( wb_s.sel[i] )
						memory[ address[ mem_adr_width+1:2 ] ][ (i*8)+:8 ] <= wb_s.dat_ms [ (i*8)+:8 ];
			
			end	
		
			wb_s.dat_sm <= memory[ address[ mem_adr_width+1:2 ] ];
		end		
	end
				  		
                    
	logic i;

	// Acquittement de la lecture 
	always @ ( posedge wb_s.clk or posedge wb_s.rst )
	begin	
		if ( wb_s.rst )
		begin
			ack_read <= 0;
			state <= CLASSIC;
			addr <= 0;
			i <= 0;
		end

		else 
		begin 
			state <= next_state;
		
			if  ( read_mode & !burst  ) begin 
				if ( !i  )
					begin
						i <= 1;
						ack_read <= 1;
					end
				else 
					begin
						i <= 0;
						ack_read <= 0;
					end	
			end	

			else if ( read_mode & burst )	ack_read <= 1'b0;
			
			if ( state == CLASSIC )  addr <= wb_s.adr + 4;

                        else if ( state == INC_BURST) 
                                if ( wb_s.stb )	addr <= addr + 4;
                                

		end
	end

	always_comb
        begin
                if ( wb_s.we & wb_s.stb )       ack_write = 1;
                else ack_write = 0;

                if ( ack_write | ack_read | burst )     wb_s.ack = 1;
                else    wb_s.ack = 0;
        end 


	always@ (*)
	begin
		
		if ( read_mode & wb_s.cti == 3'b010 & wb_s.bte == 2'b00 & ( state == INC_BURST || state == CLASSIC ) )	next_state = INC_BURST;
		else if ( state == CLASSIC ) next_state = CLASSIC;

		if ( read_mode & wb_s.cti == 3'b111 & wb_s.bte == 2'b00 & state == INC_BURST  )	next_state = CLASSIC;

		else if ( state == INC_BURST ) next_state = INC_BURST;

	end	
	
	// Mise a jour de la valeur d'adresse memoire.
	always @(*)
	begin
		case ( state )
	
		CLASSIC:	begin
				address = wb_s.adr;
				burst = 1'b0;
				end

		INC_BURST:	begin
				address = addr;	
				burst = 1'b1;
				end
	
		endcase
	end
	

endmodule

	

