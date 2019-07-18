// Module MCE

module MCE( A, B, MAX, MIN );

	parameter WIDTH = 8;
	
	input [WIDTH-1 : 0] A;
	input [WIDTH-1 : 0] B;
	output [WIDTH-1 : 0] MAX;
	output [WIDTH-1 : 0] MIN;

	assign MAX = ( A < B ) ? B : A;
	assign MIN = ( A < B ) ? A : B;

endmodule
