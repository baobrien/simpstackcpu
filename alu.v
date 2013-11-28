`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:14:05 11/22/2013 
// Design Name: 
// Module Name:    alu 
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
module alu(
		input [4:0] op,
		input [W-1:0] in0,
		input [W-1:0] in1,
		output [W-1:0] out0,
		output [W-1:0] out1
    );
parameter W=16;
localparam	ZERO = 5'd0,
				ONE  = 5'd1,
				ADD  = 5'd2,
				SUB  = 5'd3,
				SHL  = 5'd4,
				SHR  = 5'd5,
				AND  = 5'd6,
				OR   = 5'd7,
				NOT  = 5'd8,
				XOR  = 5'd9,
				SWP  = 5'd10,
				DUP  = 5'd11,
				GZ   = 5'd12,
				GTH  = 5'd13,
				LTH  = 5'd14,
				ET   = 5'd15,
				DIR = 5'd16,
				INC = 5'd17,
				DEC = 5'd18;
reg [W-1:0] dout0,dout1;
assign out0=dout0;
assign out1=dout1;
always @ (*) begin
	case (op)
	ZERO:begin
		dout0 = 16'd0;
		dout1 = 16'd0;
	end
	ONE:begin
		dout0 = 16'd1;
		dout1 = 16'd1;
	end
	ADD:begin
		{dout1,dout0} = in0 + in1;
	end
	SUB:begin
		{dout1,dout0} = in0 - in1;
	end
	SHL:begin
		dout0 = in0 << in1;
		dout1 = 16'd0;
	end
	SHR:begin
		dout0 = in0 >> in1;
		dout1 = 16'd0;
	end
	AND:begin
		dout0 = in0 & in1;
		dout1 = 16'd0;
	end
	OR:begin
		dout0 = in0 | in1;
		dout1 = 16'd0;
	end
	XOR:begin
		dout0 = in0 ^ in1;
		dout1 = 16'd0;
	end
	NOT:begin
		dout0 = ~in0;
		dout1 = 16'd0;
	end
	SWP:begin
		dout0 = in1;
		dout1 = in0;
	end
	DUP:begin
		dout0 = in0;
		dout1 = in0;
	end
	GZ:begin
		dout0 = in0>0;
		dout1 = 16'd0;
	end
	GTH:begin
		dout0 = in0>in1;
		dout1 = 16'd0;
	end
	LTH:begin
		dout0 = in0==in1;
		dout1 = 16'd0;
	end
	ET:begin
		dout0 = in0==in1;
		dout1 = 16'd0;
	end
	DIR:begin
		dout0 = in0;
		dout1 = in1;
	end
	INC:begin
		dout0 = in0+1;
		dout1 = in0;
	end
	DEC:begin
		dout0 = in0-1;
		dout1 = in0;
	end
	ET:begin
		dout0 = in0-1;
		dout1 = in0;
	end
	default:begin
		dout0 = in0;
		dout1 = in1;
	end
	endcase
end
endmodule
