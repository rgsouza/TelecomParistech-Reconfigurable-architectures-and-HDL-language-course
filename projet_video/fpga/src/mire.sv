// Auteur: Rayanne Souza

module mire #( parameter HDISP = 640, parameter VDISP = 480 )( wshb_if.master wshb_ifm_mire  );

logic [ $clog2(HDISP) - 1 : 0] h_count;
logic [ $clog2(VDISP) - 1 : 0] v_count;

assign wshb_ifm_mire.sel = 2'b11;
assign wshb_ifm_mire.we = 1'b1;
assign wshb_ifm_mire.cti = '0;
assign wshb_ifm_mire.bte = '0;
assign wshb_ifm_mire.cyc = '1;
assign wshb_ifm_mire.stb = '1;  


always_ff@( posedge wshb_ifm_mire.clk or posedge wshb_ifm_mire.rst)
begin
	if( wshb_ifm_mire.rst )
	begin
		h_count <= 0;
		v_count <= 0;
		wshb_ifm_mire.adr <= '0;
	end
	else
	begin
		if ( wshb_ifm_mire.ack  )
		begin	
			if( h_count < HDISP - 1 )
				h_count <= h_count + 1'b1;
			else
			begin
				h_count <= 0;
				if ( v_count < VDISP - 1 )
					v_count <= v_count + 1'b1;
				else
					v_count <= 0;

			end
	
			if( (h_count % 16 ) == 0 || (v_count % 16 ) == 0 )
				wshb_ifm_mire.dat_ms = '1;
			else 
				wshb_ifm_mire.dat_ms = '0;	

			if( wshb_ifm_mire.adr == 2*(VDISP*HDISP - 1)  )
                                        wshb_ifm_mire.adr <= 'd0;
                                else
                                        wshb_ifm_mire.adr <= wshb_ifm_mire.adr + 2;
				
		end
	end	
end
endmodule 


