// Auteur: Rayanne Souza

module fpga #( parameter HDISP = 640, parameter VDISP = 480 ) ( input fpga_CLK, 
								input fpga_CLK_AUX, 
								output logic fpga_LEDR0, 
								output logic fpga_LEDR1, 
								output logic fpga_LEDR2,
								output logic fpga_LEDR3, 
								input fpga_SW0, 
								input fpga_SW1, 
								input fpga_NRST, 
								output fpga_SEL_CLK_AUX, 
								vga_if.master vga_ifm,
								sdram_if.master sdram_ifm );

assign fpga_LEDR0 = fpga_SW0;
assign fpga_SEL_CLK_AUX = fpga_SW1;
logic NRST, NRST_aux;
logic wshb_clk ;
logic wshb_rst ;
logic sdram_clk;
logic locked ;


// Instanciation de la PLL pour générer la clock wishbone et la clock sdram
wshb_pll pll( .refclk(fpga_CLK), .rst(!fpga_NRST), .outclk_0(wshb_clk), .outclk_1(sdram_clk), .locked(locked));

// génération du signal  wshb_rst.
resynchronisation #(.outRST( 1'b1 )) wshb_rst_resyn( .CLK( wshb_clk), .RST_IN( fpga_NRST ) , .RST_OUT( wshb_rst ));

// Instanciation d'un bush Wishbone 16 bits
wshb_if #(.DATA_BYTES(2)) wshb_if_0(wshb_clk,wshb_rst);


// Instanciation du controleur de sdram
wb16_sdram16 u_sdram_ctrl
  (
   // Wishbone 16 bits slave interface
   .wb_s(wshb_if_0.slave),
   // SDRAM master interface
   .sdram_m(sdram_ifm),
   // SDRAM clock
   .sdram_clk(sdram_clk)
  );

resynchronisation #(.outRST( 1'b0 ))I_resynchronisation( .CLK( fpga_CLK ), .RST_IN( fpga_NRST), .RST_OUT( NRST ) );
resynchronisation #(.outRST(1'b0 ) ) II_resynchronisation ( .CLK ( fpga_CLK_AUX), .RST_IN( fpga_NRST ), .RST_OUT ( NRST_aux ));

vga #(.HDISP( HDISP ), .VDISP( VDISP ) ) I_vga (.clk( fpga_CLK_AUX ), .nrst( fpga_NRST ) , .vga_ifm( vga_ifm ), .wshb_ifm( wshb_if_0.master ) );

logic  [24:0] count_LEDR1;
always  @( posedge fpga_CLK_AUX or  negedge NRST_aux )
begin
	if ( !NRST_aux )
		count_LEDR1 <= 0;
	else begin
		count_LEDR1 <= count_LEDR1 + 1'b1;
		fpga_LEDR1 <= count_LEDR1[ 24 ];         
	end
end


logic [25:0] count_LEDR2;
always  @ ( posedge fpga_CLK or negedge NRST )
begin
        if ( !NRST )
                count_LEDR2 <= 0;
        else begin
                count_LEDR2 <= count_LEDR2 + 1'b1;
                fpga_LEDR2 <= count_LEDR2[ 25 ];
        end
end

assign fpga_LEDR3 = fpga_NRST;

endmodule
