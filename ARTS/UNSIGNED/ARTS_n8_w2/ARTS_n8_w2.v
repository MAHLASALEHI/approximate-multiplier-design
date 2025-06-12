// n=8 w=2            


module APPR (AH,AL,BH,BL,APP,PC);
	input [1:0]AH,BH,AL,BL;
	output APP;
	output PC;
	wire P0,O0,P1,O1;

	assign P1=(BL[1]&AH[1]);
	assign P0=P1;
	assign O1=(AL[1]&BH[1]);
	assign O0=O1;
	assign APP=O1|P1;
	assign PC= P0|O0;
endmodule

//******************* LSD ***************************
module LSD_n8_ss2(X,Kx,XH,XL);
	input [7:0]X;
	output [1:0]Kx;
	output [1:0]XH;
	output [1:0]XL;

	assign Kx=(X[7] | X[6]) ? 2'b11 :
	(X[5] | X[4]) ? 2'b10 :
	(X[3] | X[2]) ? 2'b01 : 2'b00;
	assign XH=(X[7] | X[6]) ? X[7:6] :
	(X[5] | X[4]) ? X[5:4] :
	(X[3] | X[2]) ? X[3:2] : X[1:0];
	assign XL=(X[7] | X[6]) ? X[5:4] :
	(X[5] | X[4]) ? X[3:2] :
	(X[3] | X[2]) ? X[1:0] : 2'b00;
endmodule
//**********************HA and FA***********************
module HA(A,B,sum,carry);
    input A, B;
    output sum, carry;
	assign sum = A ^ B;   // XOR operation for sum
	assign carry = A & B; // AND operation for carry
endmodule


module FA (A,B,cin,sum,cout);
    input A, B, cin;
    output sum, cout;
	assign sum = A ^ B ^ cin;
	assign cout = (A & B) | (cin & (A ^ B));
endmodule

//******************* wallace 4 ***************************
module MM(A,B,carry,FinalOut_MSB,FinalOut_LSB);
input [1:0]A,B;
input carry;
output [2:0]FinalOut_MSB;
output FinalOut_LSB;
wire [3:0] FinalOut;
wire A1B0,A0B1,A2B0,A1B1,A0B2,A3B0,A2B1,A1B2,A0B3,A3B1,A2B2,A1B3,A3B2,A2B3,A3B3;
wire c0;
//**************************************Generating PPs**************
assign FinalOut[0]=A[0] & B[0];
assign A1B0= A[1] & B[0];
assign A0B1= A[0] & B[1];
assign A1B1= A[1] & B[1];

	FA aa0 (A0B1,A1B0,carry,FinalOut[1],c0);
	HA aa1 (A1B1,c0,FinalOut[2],FinalOut[3]);

assign FinalOut_MSB=FinalOut[3:1];
assign FinalOut_LSB=FinalOut[0];
endmodule



module ARTS_n8_ss2(A,B,OUT); //w=2 n=8
input [7:0]A,B;
output reg[15:0]OUT;
//******************* wires ****************************

	wire [1:0]Ka,Kb;
	wire [1:0]AH,BH,AL,BL;
	wire APP;
	wire PC;
	wire [2:0]Mult_MSB;
	wire Mult_LSB;
	wire middle_part;
	wire orout1,orout2,z;

	LSD_n8_ss2  S1 (A,Ka,AH,AL);
	LSD_n8_ss2  S2 (B,Kb,BH,BL);
	APPR  S3 (AH,AL,BH,BL,APP,PC);
	MM S4 (AH,BH,PC,Mult_MSB,Mult_LSB);
	assign middle_part= Mult_LSB | APP;
    assign orout1=AH[0]|AH[1];
	assign orout2=BH[0]|BH[1];
	assign z= orout1 & orout2;	
	
	wire [2:0] my_case;
	assign my_case = (z==1'b0) ? 3'b000:
	     (Ka==2'b11 & Kb==2'b11) ? 3'b001:
		 ((Ka==2'b11 & Kb==2'b10)|(Ka==2'b10 & Kb==2'b11)) ? 3'b010:
		 ((Ka==2'b11 & Kb==2'b01)|(Ka==2'b01 & Kb==2'b11)|(Ka==2'b10 & Kb==2'b10)|(Ka==2'b10 & Kb==2'b10)) ? 3'b011:
		 ((Ka==2'b11 & Kb==2'b00)|(Ka==2'b00 & Kb==2'b11)|(Ka==2'b10 & Kb==2'b01)|(Ka==2'b01 & Kb==2'b10)) ? 3'b100:
		 ((Ka==2'b10 & Kb==2'b00)|(Ka==2'b00 & Kb==2'b10)|(Ka==2'b01 & Kb==2'b01)|(Ka==2'b01 & Kb==2'b01)) ? 3'b101:
		 ((Ka==2'b01 & Kb==2'b00)|(Ka==2'b00 & Kb==2'b01)) ? 3'b110:3'b111;
	always@(my_case, Mult_MSB, middle_part)begin
		case (my_case)
		 3'b000: OUT=16'b0;
	     3'b001: OUT={Mult_MSB,middle_part,12'b111111111111};
		 3'b010: OUT={2'b0,Mult_MSB,middle_part,10'b1111111111};
		 3'b011: OUT={4'b0,Mult_MSB,middle_part,8'b11111111};
		 3'b100: OUT={6'b0,Mult_MSB,middle_part,6'b111111};
		 3'b101: OUT={8'b0,Mult_MSB,middle_part,4'b1111};
		 3'b110: OUT={10'b0,Mult_MSB,middle_part,2'b11};
		 3'b111: OUT={12'd0,Mult_MSB,middle_part};
		 endcase
	end
endmodule
