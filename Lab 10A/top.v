`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:52:36 04/01/2024 
// Design Name: 
// Module Name:    top 
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
`define OUTPUT_REG 2
`define MAX_PC 14

module top(clk,led);
input clk;
output wire [7:0]led;
reg [7:0] outled;
reg [31:0]imem[0:13];
reg [7:0]dmem[0:10];
reg [7:0]reg_file[0:31];
reg [7:0] PC;
reg [3:0]state=0;
initial begin
	imem[0] = 32'b001001_00000_00010_0000_0000_0000_0000;
	imem[1] = 32'b001001_00000_00011_0000_0000_0000_0000;
	imem[2] = 32'b000000_00011_00001_00100_00000_101010;
	imem[3] = 32'b000100_00000_00100_0000_0000_0000_1000;
	imem[4] = 32'b001001_00000_00101_0000_0000_0000_1010;
	imem[5] = 32'b000100_00101_00011_0000_0000_0000_0110;
	imem[6] = 32'b100011_00011_00110_0000_0000_0000_0000;
	imem[7] = 32'b000000_00010_00110_00010_00000_100001;
	imem[8] = 32'b001001_00011_00011_0000_0000_0000_0001;
	imem[9] = 32'b000000_00011_00001_00100_00000_101010;
	imem[10] = 32'b000101_00000_00100_1111_1111_1111_1011;
	imem[11] = 32'b000000_11111_00000_00000_00000_001000;
	imem[12] = 32'b100011_00000_00001_0000_0000_0000_1010;
	imem[13] = 32'b000011_000000_0000_0000_0000_0000_0000;
	
	dmem[0] = 8'd1;
	dmem[1] = 8'd2;
	dmem[2] = 8'd3;
	dmem[3] = 8'd4;
	dmem[4] = 8'd5;
	dmem[5] = 8'd6;
	dmem[6] = 8'd7;
	dmem[7] = 8'd8;
	dmem[8] = 8'd2;
	dmem[9] = 8'd9;
	dmem[10] = 8'd8;
	
	reg_file[0] = 8'd0; reg_file[8] = 8'd0; reg_file[16] = 8'd0; reg_file[24] = 8'd0;
	reg_file[1] = 8'd0; reg_file[9] = 8'd0; reg_file[17] = 8'd0; reg_file[25] = 8'd0;
	reg_file[2] = 8'd0; reg_file[10] = 8'd0; reg_file[18] = 8'd0; reg_file[26] = 8'd0;
	reg_file[3] = 8'd0; reg_file[11] = 8'd0; reg_file[19] = 8'd0; reg_file[27] = 8'd0;
	reg_file[4] = 8'd0; reg_file[12] = 8'd0; reg_file[20] = 8'd0; reg_file[28] = 8'd0;
	reg_file[5] = 8'd0; reg_file[13] = 8'd0; reg_file[21] = 8'd0; reg_file[29] = 8'd0;
	reg_file[6] = 8'd0; reg_file[14] = 8'd0; reg_file[22] = 8'd0; reg_file[30] = 8'd0;
	reg_file[7] = 8'd0; reg_file[15] = 8'd0; reg_file[23] = 8'd0; reg_file[31] = 8'd0;
	
	PC = 8'd12;
end
reg [31:0] inst;
reg [4:0] rs;
reg [4:0] rt;
reg [4:0] rd;
reg [5:0] func;
reg [15:0] immd;
reg [25:0] jtarg;
reg [7:0] s;
reg [7:0] t;
reg [7:0] d; 
reg [7:0] result;
reg [5:0] opcode;
reg valid;
reg [4:0]addr;
always @(posedge clk) begin
	if(state == 0) begin
		inst[31:0] = imem[PC];
		state = 1;
	end
	else if(state == 1) begin
		opcode[5:0] = inst[31:26];
		rs[4:0] = inst[25:21];
		rt[4:0] = inst[20:16];
		rd[4:0] = inst[15:11];
		func[5:0] = inst[5:0];
		jtarg[25:0] = inst[25:0];
		immd[15:0] = inst[15:0];
		state = 2;
	end
	else if(state == 2) begin
		s[7:0] = reg_file[rs];
		t[7:0] = reg_file[rt];
		state = 3;
	end
	else if(state == 3) begin
		if(opcode == 6'h0) begin  //R format
			if(func[5:0] == 6'h2a) begin   //slt
				result = ($signed(s) < $signed(t)) ? 8'd1 : 8'd0;
				PC = PC + 1;
				valid = 1;
			end
			else if(func[5:0] == 6'h21) begin  //addu
				result = s + t;
				PC = PC + 1;
				valid = 1;
			end
			else if(func[5:0] == 6'h8) begin    //jr
				valid = 0;
				PC = s;
			end
			else begin
				valid = 0;
				PC = PC + 1;
			end
		end
		else if(opcode == 6'h9) begin    //addiu
			result[7:0] = s[7:0] + immd[7:0];
			valid = 1;
			PC = PC + 1;
		end
		else if(opcode == 6'h4) begin  //beq
			PC = PC + ((s == t) ? immd[7:0] : 1);
			valid = 0;
		end
		else if(opcode == 6'h23) begin   //lw
			addr = immd[4:0]+s[4:0];
			PC = PC + 1;
			valid = 1;
		end
		else if(opcode == 6'h3) begin   //jal
			reg_file[31] = PC + 1;
			PC = jtarg[7:0];
			valid = 0;
		end
		else if(opcode == 6'h5) begin //bne
			PC = PC + ((s == t) ? 1 : immd[7:0]);
			valid = 0;
		end
		else begin
			valid = 0;
			PC = PC + 1;
		end
		state = 4;
	end
	else if(state == 4) begin     //lw
		if(opcode == 6'h23) begin
			result[7:0] = dmem[addr];
			//valid=1;
		end
		state = 5;
	end
	else if(state == 5) begin
		if(valid==1) begin
			if(opcode == 6'h0 && rd!=0) begin   //R format
				reg_file[rd] = result;
			end
			else if (rt!=0) begin
				reg_file[rt] = result;
			end
		end
		if(PC < `MAX_PC) begin
			state=0;
		end
		else begin
			state = 6;
		end
	end
	else if(state == 6) begin
		outled[7:0] = reg_file[`OUTPUT_REG];
	end
	//state = state + 1;
end
assign led = outled;

endmodule