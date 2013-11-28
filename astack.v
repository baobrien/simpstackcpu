`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:30:33 11/20/2013 
// Design Name: 
// Module Name:    astack 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module astack( 

		input clk,
		input cs,
		input rst,
		input [W-1:0] r0in,
		input [W-1:0] r1in,
		input [2:0] dsel,
		output [W-1:0] r0out,
		output [W-1:0] r1out,
		input [2:0] mode
    );
localparam NONE = 0,
	 PUSH = 1,
	POP = 2,
        REP1 = 3,
	REP2 = 4,
	POPREP = 5,
	BUB = 6;
parameter W = 16;
parameter D = 16;
			  
reg [W-1:0] vals [D-1:0];
reg [W-1:0] vals_new [D-1:0];
assign r0out = vals[0];
assign r1out = vals[dsel];
integer cur;
/*always @ (mode)
	$monitor("Mode changed to %h",mode);
*/
always @ (*)
	case(mode)
		NONE:begin
			for(cur=0;cur<D;cur=cur+1) begin
				vals_new[cur] = vals[cur];
			end
		end
		REP1:begin
			for(cur=1;cur<D;cur=cur+1) begin
				vals_new[cur] = vals[cur];
			end
			vals_new[0]=r0in;
		end
		REP2:begin
			for(cur=2;cur<D;cur=cur+1) begin
				vals_new[cur] = vals[cur];
			end
			vals_new[0]=r0in;
			vals_new[1]=r1in;
		end
		POPREP:begin
			vals_new[0] = r0in;
			for(cur=1;cur<D-1;cur=cur+1) begin
				vals_new[cur] = vals[cur+1];
			end
		end
		POP:begin
			for(cur=0;cur<D-1;cur=cur+1) begin
				vals_new[cur] = vals[cur+1];
			end
		end
		PUSH:begin
			vals_new[0] = r0in;
			for(cur=1;cur<D;cur=cur+1) begin
				vals_new[cur] = vals[cur-1];
			end
		end
		BUB:begin
			vals_new[0] = r0in;
			for(cur=1;cur<D;cur=cur+1) begin
				vals_new[cur] = vals[cur>dsel?cur:cur-1];
			end
		end
		default:begin
			for(cur=0;cur<D;cur=cur+1) begin
				vals_new[cur] = vals[cur];
			end
		end
	endcase

always @ (posedge clk) begin
	if (rst) begin
		for(cur=0;cur<D;cur=cur+1) begin
			vals[cur] <=0;
		end
	end else if (cs) begin
		for(cur=0;cur<D;cur=cur+1) begin
			vals[cur] <= vals_new[cur];
		end
	end
	//$display("r0:%h r1:%h r2:%h r3:%h r4:%h r5:%h r6:%h r7:%h mode:%h",vals[0],vals[1],vals[2],vals[3],vals[4],vals[5],vals[6],vals[7],mode);
end
	
endmodule

