module tb_main();

wire [15:0] cpuadrout;
wire [15:0] cpudatout;
wire [15:0] cpudatin;
wire cpudatwr;
reg clk = 0;
reg rst = 0;

initial begin
	$dumpfile("test.vcd");
	$dumpvars;
	#1 rst = 1;
	#2 rst = 0;
end


always @ (posedge clk) begin
	//$monitor ("addr is %h, hlt is %h, dout is %h, wr is %h",cpuadrout,hltout,cpudatout,cpudatwr);
	if(cpuadrout==16'h1000)
		$display("addr is %h, d is %h",cpuadrout,cpudatout);
	if(hltout)
		$finish;
	//$monitor ("hlt is %h",hltout);
end

always #1 clk = !clk;

wire hltout;

simpcpu thecpu (
	.clk(clk),
	.rst(rst),
	.datain(cpudatin),
	.dataout(cpudatout),
	.addrout(cpuadrout),
	.datawrite(cpudatwr),
	.hold(1'b0),
	.halted(hltout)
);

tb_mem somemem (
	.clk(clk),
	.din(cpudatout),
	.dout(cpudatin),
	.addr(cpuadrout[9:0]),
	.wr(cpudatwr)
);

endmodule
