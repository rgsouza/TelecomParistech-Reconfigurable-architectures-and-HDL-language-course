// Auteur Rayanne Souza

module tb_fpga;

logic fpga_CLK, fpga_CLK_AUX, CLK_AUX, fpga_NRST, fpga_SEL_CLK_AUX, fpga_SW0, fpga_SW1;
wire fpga_LEDR0, fpga_LEDR1, fpga_LEDR2, fpga_LEDR3;


// Horloge à 50MHz
always #10ns fpga_CLK = ~fpga_CLK;

always #18.5ns CLK_AUX = ~CLK_AUX;

// Horloge à 27MHz

assign fpga_CLK_AUX = ( fpga_SEL_CLK_AUX == 1 ) ? CLK_AUX : 0;
	
	vga_if I_vgaif();
	sdram_if sdram_if0();

	screen #(.mode( 0 ), .X( 160 ), .Y( 90 ) ) SCREEN0( .vga_ifs(I_vgaif ));

	fpga #(.HDISP( 160 ), .VDISP( 90 ) ) I_fpga( .fpga_CLK( fpga_CLK ), .fpga_CLK_AUX( fpga_CLK_AUX ), 
			.fpga_LEDR0( fpga_LEDR0 ), .fpga_LEDR1( fpga_LEDR1 ), 
		     	.fpga_LEDR2( fpga_LEDR2 ), .fpga_LEDR3( fpga_LEDR3 ), 
		     	.fpga_SW0( fpga_SW0 ), .fpga_SW1( fpga_SW1 ),
			.fpga_NRST( fpga_NRST ), .fpga_SEL_CLK_AUX( fpga_SEL_CLK_AUX ), .vga_ifm( I_vgaif ), .sdram_ifm(sdram_if0)); 
	
	sdr #(.Debug(0)) SDRAM
  	(
                  .Clk    (sdram_if0.clk     ),
                  .Cke    (sdram_if0.cke     ),
                  .Cs_n   (sdram_if0.cs_n    ),
                  .Ras_n  (sdram_if0.ras_n   ),
                  .Cas_n  (sdram_if0.cas_n   ),
                  .We_n   (sdram_if0.we_n    ),
                  .Addr   (sdram_if0.sAddr   ),
                  .Ba     (sdram_if0.ba      ),
                  .Dq     (sdram_if0.sDQ     ),
                  .Dqm    (sdram_if0.dqm     )
 	) ;


initial begin

	fpga_CLK = 0;
	CLK_AUX = 0;
	fpga_NRST = 0;
	fpga_SW0 = 0;
	fpga_SW1 = 1;
	
	#300ns
	fpga_NRST = 1;
	#10ms
	$finish;

end
endmodule 
