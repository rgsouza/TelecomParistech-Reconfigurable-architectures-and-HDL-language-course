// Auteur: Rayanne Souza

module wshb_intercon( wshb_if.slave wshb_ifs_mire, wshb_if.slave wshb_ifs_vga, wshb_if.master wshb_ifm );

logic is_vga;

always_ff@( posedge wshb_ifm.clk or posedge wshb_ifm.rst ) 
begin
	if( wshb_ifm.rst )
	begin
		is_vga <= 0;
	end
	else
	begin
		//Si le mode mire est en cours, on attend qui l'écriture soit faite.
		if( wshb_ifs_vga.cyc )
		begin	
			if ( !is_vga )
				if( wshb_ifs_mire.ack )
					is_vga <= 1'b1;
		end
		else	
			is_vga <= 1'b0;			
			
	end
end
	

always_comb
begin
	if ( is_vga == 0 )
	begin
		// Connection  Master - slave
		wshb_ifm.cyc = wshb_ifs_mire.cyc;
                wshb_ifm.sel = wshb_ifs_mire.sel;
                wshb_ifm.we = wshb_ifs_mire.we ;
                wshb_ifm.cti = wshb_ifs_mire.cti;
                wshb_ifm.bte = wshb_ifs_mire.bte;
		wshb_ifm.dat_ms = wshb_ifs_mire.dat_ms;
		wshb_ifm.adr = wshb_ifs_mire.adr;
		wshb_ifm.stb = wshb_ifs_mire.stb;
	
		// Connection Slave - Master
		wshb_ifs_mire.err = wshb_ifm.err;
                wshb_ifs_mire.rty = wshb_ifm.rty;
                wshb_ifs_mire.ack = wshb_ifm.ack;
                wshb_ifs_mire.dat_sm = wshb_ifm.dat_sm;
		
		// Esclave de l'interface vga wshb_if_vga ne pas communiquée au Master
		wshb_ifs_vga.err = '0;
                wshb_ifs_vga.rty = '0;
                wshb_ifs_vga.ack = '0;
                wshb_ifs_vga.dat_sm = '0;
	
	
	end
	else
	begin
		// Connection Master- Slave
                wshb_ifm.cyc = wshb_ifs_vga.cyc;
                wshb_ifm.sel = wshb_ifs_vga.sel;
                wshb_ifm.we = wshb_ifs_vga.we ;
                wshb_ifm.cti = wshb_ifs_vga.cti;
                wshb_ifm.bte = wshb_ifs_vga.bte;
		wshb_ifm.dat_ms = wshb_ifs_vga.dat_ms;
		wshb_ifm.adr = wshb_ifs_vga.adr;
                wshb_ifm.stb = wshb_ifs_vga.stb;

                // Connection Slave - Master
		wshb_ifs_vga.err = wshb_ifm.err;
                wshb_ifs_vga.rty = wshb_ifm.rty;
                wshb_ifs_vga.ack = wshb_ifm.ack;
                wshb_ifs_vga.dat_sm = wshb_ifm.dat_sm;

		// Esclave de l'interface mire ne pas communiquée au Master.
		wshb_ifs_mire.err = '0;
                wshb_ifs_mire.rty = '0;
                wshb_ifs_mire.ack = '0;
		wshb_ifs_mire.dat_sm = '0;
	end
end

endmodule


