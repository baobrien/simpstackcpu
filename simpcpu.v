`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:03:23 11/19/2013 
// Design Name: 
// Module Name:    simpcpu 
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
module simpcpu(
		input clk,
		input rst,
		input [15:0] datain,
		output [15:0] dataout,
		output [15:0] addrout,
		output datacs,
		output datawrite,
		input hold,
		output halted
    );

localparam	F_1    = 5'd0,
		F_2    = 5'd1,
		LIT_1  = 5'd2,
		LIT_2  = 5'd3,
		ALU_1  = 5'd4,
		DIN_1  = 5'd5,
		DIN_2  = 5'd6,
		DOUT_1 = 5'd7,
		DOUT_2 = 5'd8,
		CRET_1  = 5'd9,
		CALL_1 = 5'd10,
		RET_1  = 5'd11,
		HLT_1  = 5'd12,
		NOP_1  = 5'd13,
		JMPN_1 = 5'd14,
		PLS_1  = 5'd15,
		CST_1  = 5'd16;
				
localparam	OP_NOP = 4'd0,		//Nop
				OP_LIT = 4'd1,		//Literal
				OP_RD  = 4'd2,		//Read
				OP_WR  = 4'd3,		//Write
				OP_ALU = 4'd4,		//ALU Operation
				OP_CRT = 4'd5,		//Conditional Return
				OP_JMN = 4'd6,		//Nonconditional Jump
				OP_CAL = 4'd7,		//Call
				OP_RET = 4'd8,		//Return
				OP_HLT = 4'd9,		//Halt
				OP_PLS = 4'd10,		//Push loop start
				OP_CST = 4'd11;		//callstack transfer

reg [4:0] state_d,state_q;							//state machine state
reg [15:0] ip_d,ip_q;								//instruction pointer
reg [15:0] op_d,op_q,op_src;							//opcode register
reg [15:0] d0in,d1in,c0in;							//stack inputs
reg [2:0] csmode;										//call stack mode
reg [2:0] dsmode;										//data stack mode
reg [15:0] dout;										//data out to bus
reg [15:0] aout;										//address out to bus
reg wr;													//wr bit to the bus
reg hlt;													//is this thing halted?

wire [15:0] d0out,d1out,c0out,a0out,a1out;	//stack/alu outputs

wire [4:0] aluop;										//part of operator for ALU
wire [3:0] mainop;									//main part of operator
wire [2:0] stackop;
wire [2:0] stackd1;									//part of operator for the stack

assign dataout = dout;
assign addrout = aout;
assign datawrite = wr;
assign halted = hlt;
assign datacs = 1'b1;

assign mainop = op_src[3:0];
assign aluop  = op_src[8:4];
assign stackop = op_src[11:9];
assign stackd1 = op_src[14:12];
astack datstack (
	.r0in(d0in),
	.r1in(d1in),
	.r0out(d0out),
	.r1out(d1out),
	.clk(clk),
	.mode(dsmode),
	.cs(~hold),
	.dsel(stackd1),
	.rst(rst)
);

astack callstack (
	.r0in(c0in),
	.r0out(c0out),
	.clk(clk),
	.mode(csmode),
	.cs(~hold),
	.dsel(3'd1),
	.rst(rst)
);

alu thealu (
	.in0(d0out),
	.in1(d1out),
	.out0(a0out),
	.out1(a1out),
	.op(aluop)
);
	
defparam callstack.D=16;

/*always @ (state_d) begin
	$monitor("state_d is %h and ip is %H",state_d,ip_d);
end*/
always @ (*) begin
	case (state_q)
	F_1:begin //Fetch part 1 -- setup memory to get inst.
		state_d = F_2;
		op_d = op_q;
		aout = ip_q;
		dout = 16'd0;
		wr = 1'b0;
		hlt = 1'b0;
		dsmode = 3'd0;
		csmode = 3'd0;
		d0in = 16'd0;
		d1in = 16'd0;
		c0in = 16'd0;
		op_src = op_q;
		ip_d = ip_q;
	end
	F_2:begin //Fetch part 2 -- setup to save into op register
		//state_d = F_2;
		op_src = datain;
		case(mainop)
		OP_NOP:begin
			state_d = F_2;
			op_d = 16'd0;
			aout = ip_q+1;
			dout = 16'd0;
			wr = 1'd0;
			hlt = 1'd0;
			dsmode = 3'd0;
			csmode = 3'd0;
			d0in = 16'd0;
			d1in = 16'd0;
			c0in = 16'd0;
			ip_d = ip_q+1;
		end
		OP_LIT:begin
			state_d = LIT_2;
			op_d = datain;
			aout = ip_q + 1;
			dout = 16'd0;
			wr = 1'b0;
			hlt = 1'b0;
			dsmode = 3'd0;
			csmode = 3'd0;
			d0in = 16'd0;
			d1in = 16'd0;
			c0in = 16'd0;
			ip_d = ip_q + 1;
		end
		OP_RD:begin
			state_d = DIN_2;
			op_d = datain;
			aout = d0out;
			dout = 16'd0;
			wr = 1'b0;
			hlt = 1'b0;
			dsmode = 3'd0;
			csmode = 3'd0;
			d0in = datain;
			d1in = 16'd0;
			c0in = 16'd0;
			ip_d = ip_q + 1;
		end
		OP_WR:begin
			state_d = DOUT_2;
			op_d = datain;
			aout = d0out;
			dout = d1out;
			wr = 1'b1;
			hlt = 1'b0;
			dsmode = 3'd0;
			csmode = 3'd0;
			d0in = 16'd0;
			d1in = 16'd0;
			c0in = 16'd0;
			ip_d = ip_q;
		end
		OP_ALU:begin
			state_d = F_2;
			op_d = op_q;
			aout = ip_q + 1;
			dout = 16'd0;
			wr = 1'b0;
			hlt = 1'b0;
			dsmode = stackop;
			csmode = 3'd0;
			d0in = a0out;
			d1in = a1out;
			c0in = 16'd0;
			ip_d = ip_q + 1;
		end
		OP_CRT:begin
			state_d = F_2;
			op_d = op_q;
			aout=(a0out!=16'd0)?c0out:ip_q+1;
			dout = 16'd0;
			wr = 1'b0;
			hlt = 1'b0;
			dsmode = stackop;
			csmode = 3'd2;
			d0in = a0out;
			d1in = a1out;
			c0in = 16'd0;
			ip_d = (a0out!=16'd0)?c0out:ip_q+1;
		end
		OP_CAL:begin
			state_d = F_2;
			op_d = op_q;
			aout=d0out;
			dout = 16'd0;
			wr = 1'b0;
			hlt = 1'b0;
			dsmode = stackop;
			csmode = 3'd1;
			d0in = a0out;
			d1in = a1out;
			c0in = ip_q+1;
			ip_d = d0out;
		end
		OP_RET:begin
			state_d = F_2;
			op_d = op_q;
			aout=c0out;
			dout = 16'd0;
			wr = 1'b0;
			hlt = 1'b0;
			dsmode = stackop;
			csmode = 3'd2;
			d0in = a0out;
			d1in = a1out;
			c0in = 16'd0;
			ip_d =c0out;
		end
		OP_HLT:begin
			state_d = HLT_1;
			dout = 16'd0;
			ip_d = ip_q;
			aout = ip_q;
		end
		OP_JMN:begin
			state_d = F_2;
			op_d = op_q;
			aout=d0out;
			dout = 16'd0;
			wr = 1'b0;
			hlt = 1'b0;
			dsmode = stackop;
			csmode = 3'd0;
			d0in = a0out;
			d1in = a1out;
			c0in = 16'd0;
			ip_d = d0out;
		end
		OP_CST:begin
			state_d = F_2;
			op_d = op_q;
			aout=ip_q+1;
			dout = 16'd0;
			wr = 1'b0;
			hlt = 1'b0;
			dsmode = stackop;
			csmode = aluop[1:0];
			d0in = c0out;
			d1in = 16'd0;
			c0in = 16'd0;
			ip_d = ip_q+1;
		end
		OP_PLS:begin
			state_d = F_2;
			op_d = op_q;
			aout= ip_q+1;
			dout = 16'd0;
			wr = 1'b0;
			hlt = 1'b0;
			dsmode = stackop;
			csmode = 3'd1;
			d0in = a0out;
			d1in = a1out;
			c0in = ip_q;
			ip_d = ip_q+1;
		end		
		default:begin
			state_d = F_2;
			op_d = 16'd0;
			aout = ip_q+1;
			dout = 16'd0;
			wr = 1'd0;
			hlt = 1'd0;
			dsmode = 3'd0;
			csmode = 3'd0;
			d0in = 16'd0;
			d1in = 16'd0;
			c0in = 16'd0;
			ip_d = ip_q+1;
		end
		endcase
		/*op_d = datain;
		aout = ip_q;
		dout = 16'd0;
		wr = 1'b0;
		hlt = 1'b0;
		dsmode = 3'd0;
		csmode = 3'd0;
		d0in = 16'd0;
		d1in = 16'd0;
		c0in = 16'd0;
		ip_d = ip_q;*/
	end
	LIT_2:begin //Literal, part 2
		state_d = F_2;
		op_d = op_q;
		aout=ip_q+1;
		dout = 16'd0;
		wr = 1'b0;
		hlt = 1'b0;
		dsmode = stackop;
		csmode = 3'd0;
		d0in = datain;
		d1in = 16'd0;
		c0in = 16'd0;
		op_src = op_q;
		ip_d = ip_q + 1;
	end
	DIN_2:begin //Read, part 2
		state_d = F_2;
		op_d = op_q;
		aout=ip_q + 1;
		dout = 16'd0;
		wr = 1'b0;
		hlt = 1'b0;
		dsmode = stackop;
		csmode = 3'd0;
		d0in = 16'd0;
		d1in = 16'd0;
		c0in = 16'd0;
		op_src = op_q;
		ip_d = ip_q + 1;
	end
	DOUT_2:begin //Write, part 2
		state_d = F_1;
		op_d = op_q;
		aout = d0out;
		dout = d1out;
		wr = 1'b1;
		hlt = 1'b0;
		dsmode = stackop;
		csmode = 3'd0;
		d0in = 16'd0;
		d1in = 16'd0;
		c0in = 16'd0;
		op_src = op_q;
		ip_d = ip_q + 1;
	end
	
	HLT_1:begin	//Halt part 1
		state_d = HLT_1;
		op_d = op_q;
		aout=ip_q;
		dout = 16'd0;
		wr = 1'b0;
		hlt = 1'b1;
		dsmode = stackop;
		csmode = 3'd0;
		d0in = 16'd0;
		d1in = 16'd0;
		c0in = 16'd0;
		op_src = op_q;
		ip_d = ip_q;
	end
	default:begin	
		op_src = datain;
		state_d = F_2;
		op_d = 16'd0;
		aout = ip_q+1;
		dout = 16'd0;
		wr = 1'd0;
		hlt = 1'd0;
		dsmode = 3'd0;
		csmode = 3'd0;
		d0in = 16'd0;
		d1in = 16'd0;
		c0in = 16'd0;
		ip_d = ip_q+1;
	end
	endcase
end

always @ (posedge clk) begin
	//$display("State_q is %h",state_q);

	if(!hold) begin
		state_q <= state_d;
		op_q <= op_d;
		ip_q <= ip_d;
	end
	if(rst) begin
		state_q <= F_1;
		op_q <= 0;
		ip_q <= 0;
	end
end

endmodule











