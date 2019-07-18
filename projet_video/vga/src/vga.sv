// Auteur: Rayanne Souza

module vga #( parameter HDISP = 640, parameter VDISP = 480) ( input clk, input nrst, vga_if.master vga_ifm , wshb_if.master wshb_ifm );

logic locked;
logic vga_clk;
logic rst;


// Definition de constantes
localparam HFP = 16;		// Horizontal Front Porch	  
localparam HPULSE = 96;		// Largeur de la synchro ligne
localparam HBP = 48;		// Horizontal Back Porch
localparam VFP = 11;		// Vertical Front Porch
localparam VPULSE = 2;		// Largeur de la sync image
localparam VBP = 31;		// Vertical Back Porch

// Définition de la valeur de reference finale pour le compteur horizontale et le compteur verticale
localparam h_end = HDISP + HFP + HPULSE + HBP;
localparam v_end = VDISP + VFP + VPULSE + VBP;

// Compteurs horizontale et verticale
logic [$clog2( h_end ) - 1 : 0] h_count;
logic [$clog2( v_end ) - 1 : 0] v_count;


// Signaux pour le controle de la FIFO
logic read, rempty, wfull, fifo_read;
logic full;
logic [15 : 0] rdata;

// Ce signal vaut 1 si a été FULL au moins une fois. C'est un signal dans le domaine vga_clk.
logic full_to_vga;

vga_pll I_vga_pll ( .refclk ( clk ), .rst ( !nrst ), .outclk_0 ( vga_clk ), .locked ( locked )  );

resynchronisation #( .outRST ( 1'b1)) resync ( .CLK ( vga_clk ), .RST_IN( nrst ) , .RST_OUT ( rst ) );

fifo_async #( .DATA_WIDTH(16) , .DEPTH_WIDTH(8) ) I_fifo ( .rst( rst ), 
				.rclk( vga_clk ), 
				.read( fifo_read ), 
				.rdata( rdata ), 
				.rempty( rempty ), 
				.wclk( wshb_ifm.clk ), 
				.wdata( wshb_ifm.dat_sm ), 
				.write( wshb_ifm.ack ), 
				.wfull( wfull ) ); 

assign vga_ifm.VGA_SYNC = 0;
assign vga_ifm.VGA_CLK = ~vga_clk;

// Controle des signaux wishbone.
assign wshb_ifm.sel = 2'b11;
assign wshb_ifm.we = 1'b0;
assign wshb_ifm.cti = '0;
assign wshb_ifm.bte = '0;
assign wshb_ifm.dat_ms = '0;

// Si la fifo est pleine on attend pour l'écriture.
assign wshb_ifm.stb = ~wfull;
assign wshb_ifm.cyc = 1'b1;
assign fifo_read = read && vga_ifm.VGA_BLANK;

// Mise à jour du compteur de ligne et du compteur horizontale de pixels.
always_ff@( posedge vga_clk or posedge rst )
begin
	if( rst )
	begin
		h_count <= 0;
		v_count <= 0;
		read <= '0;
	end

	else
	begin
		if( locked && full_to_vga )
		begin
			if ( h_count < h_end - 1 ) 
				h_count <= h_count + 1'b1;
			else 
			begin 
				h_count <= 0;
				if ( v_count < v_end - 1 ) 
					v_count <= v_count + 1'b1;
				else 
					v_count <= 0;
			end

			if( h_count >= HDISP + HFP && h_count <  HDISP + HFP + HPULSE )	
				vga_ifm.VGA_HS <= 1'b0;
			else 
				vga_ifm.VGA_HS <= 1'b1;
		
			if( v_count < VDISP + VFP  || v_count >= VDISP + VFP + VPULSE )	
				vga_ifm.VGA_VS <= 1'b1;
                        else    
				vga_ifm.VGA_VS <= 1'b0;

			
			if( h_count < HDISP  && v_count < VDISP )
			begin
				if ( v_count  == 0 )
					read <= 1'b1;
		      
			  	vga_ifm.VGA_BLANK <= 1'b1;
					
				vga_ifm.VGA_R <= {rdata[11 +: 5], 3'b000};
           			vga_ifm.VGA_G <= {rdata[5 +:  6], 2'b00};
            			vga_ifm.VGA_B <= {rdata[0 +: 5], 3'b000};

			end
	      		else
			begin 
				vga_ifm.VGA_BLANK <= 1'b0;
			end
		end
	end
end

// Determination de l'adresse d'accèss.
always_ff@( posedge wshb_ifm.clk or posedge wshb_ifm.rst )
begin
	if( wshb_ifm.rst )
	begin
		full <= 0;
		wshb_ifm.adr <= '0;
	end

	else
	begin
		if ( !wfull )
		begin
			if( wshb_ifm.ack )
			begin
				if( wshb_ifm.adr == 2*(VDISP*HDISP - 1)  )
					wshb_ifm.adr <= 'd0;
				else
					wshb_ifm.adr <= wshb_ifm.adr + 2;
					
			end
		end
		else
			full <= 1;
	
	end
end


// Changement de domaine d'horloge wshb_clk vers le domaine vga_clk.
logic d;
always_ff@( posedge vga_clk )
begin
        d <= full;
        full_to_vga <= d;

end


endmodule
