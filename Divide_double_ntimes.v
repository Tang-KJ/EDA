module Divide_double_ntimes(div,clk);
	output reg div;
	input clk;
	reg[17:0]cnt1;
	
	parameter ntimes = 18'b011000001101010000;
	
	always @(posedge clk)
	begin
		if(cnt1== ntimes )
			begin 
			div = ~div;
			cnt1 <= 0;
			end
		else
			begin cnt1<=cnt1+1;end
	end
endmodule