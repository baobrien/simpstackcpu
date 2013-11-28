module tb_mem(
	input [15:0] din,
	input [9:0] addr,
	input wr,
	input clk,
	output [15:0] dout
);

reg [15:0] data [511:0];
reg [15:0] datout;
assign dout = datout;

initial begin
	$readmemh("ctest.hex",data);
end

always @ (posedge clk) begin
	if(wr) begin
		data[addr] <= din;	
	end else begin
		datout <= data[addr];
	end
end

endmodule
