// n=16 w=4               


module APPR (AH,AL,BH,BL,PP1,carry);
	input [3:0]AH,BH,AL,BL;
	output [2:0]PP1;
	output carry;
	wire P4,P5,P6,P7,O4,O5,O6,O7;

	assign P4=(BL[1]&AH[3])|(BL[2]&AH[2])|(BL[3]&AH[1]);
	assign P5=(BL[2]&AH[3])|(BL[3]&AH[2]);
	assign P6=(BL[3]&AH[3]);
	assign P7=P6&P5;
	assign O4=(AL[1]&BH[3])|(AL[2]&BH[2])|(AL[3]&BH[1]);
	assign O5=(AL[2]&BH[3])|(AL[3]&BH[2]);
	assign O6=(AL[3]&BH[3]);
	assign O7=O6&O5;
	assign PP1[0]=P4|O4;
	assign PP1[1]=P5|O5;
	assign PP1[2]=P6|O6;
	assign carry= P7|O7;
endmodule

//******************* LSD ***************************
module LSD_n16_ss4(X,Kx,XH,XL);
	input [15:0]X;
	output [1:0]Kx;
	output [3:0]XH;
	output [3:0]XL;
	assign Kx=(X[15] | X[14] | X[13] | X[12]) ? 2'b11:
	(X[11] | X[10] | X[9] | X[8]) ? 2'b10:
	(X[7] | X[6] | X[5] | X[4]) ? 2'b01: 2'b00;

	assign XH=(Kx==2'b11) ? X[15:12]:
	(Kx==2'b10) ? X[11:8]:
	(Kx==2'b01) ? X[7:4]: X[3:0];

	assign XL= (Kx==2'b11) ? X[11:8]:
	(Kx==2'b10) ? X[7:4]:
	(Kx==2'b01) ? X[3:0] : 4'b0000;
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
module wallace_with_carry(A,B,carry,FinalOut_MSB,FinalOut_LSB);
input [3:0]A,B;
input carry;
output [4:0]FinalOut_MSB;
output [2:0]FinalOut_LSB;
wire [7:0] FinalOut;
wire A1B0,A0B1,A2B0,A1B1,A0B2,A3B0,A2B1,A1B2,A0B3,A3B1,A2B2,A1B3,A3B2,A2B3,A3B3;
wire s0,s1,s2,s3,s4,s5,s6,s7,s8,s9,s10,s11,s12,s13;
wire c0,c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13;
//**************************************Generating PPs**************
assign FinalOut[0]=A[0] & B[0];
assign A1B0= A[1] & B[0];
assign A0B1= A[0] & B[1];
assign A2B0= A[2] & B[0];
assign A1B1= A[1] & B[1];
assign A0B2= A[0] & B[2];
//************************for (n-1)th Column*************
assign A3B0= A[3] & B[0];
assign A2B1= A[2] & B[1];
assign A1B2= A[1] & B[2];
assign A0B3= A[0] & B[3];
//************************for (n)th Column*************
assign A3B1= A[3] & B[1];
assign A2B2= A[2] & B[2];
assign A1B3= A[1] & B[3];
//******************************for the rest of Columns except for the last one************
assign A3B2= A[3] & B[2];
assign A2B3= A[2] & B[3];
//*******************************for the last column of PPS*****************
assign A3B3= A[3] & B[3];
	HA aa0 (A0B1,A1B0,s0,c0);
	FA aa1 (A2B0,A1B1,A0B2,s1,c1);
	FA aa2 (A2B1,A1B2,A0B3,s2,c2);
	FA aa3 (A3B1,A2B2,A1B3,s3,c3);
	HA aa4 (A3B2,A2B3,s4,c4);

assign FinalOut[1]=s0;
	HA aa5 (s1,c0,s5,c5);
	FA aa6 (s2,A3B0,c1,s6,c6);
	HA aa7 (s3,c2,s7,c7);
	HA aa8 (s4,c3,s8,c8);
	HA aa9 (A3B3,c4,s9,c9);
assign FinalOut[2]=s5;
	FA aa10 (s6,c5,carry,s10,c10);
	FA aa12 (s7,c6,c10,s11,c11);
	FA aa13 (s8,c7,c11,s12,c12);
	FA aa14 (s9,c8,c12,s13,c13);
assign FinalOut[3]=s10;
assign FinalOut[4]=s11;
assign FinalOut[5]=s12;
assign FinalOut[6]=s13;
assign FinalOut[7]=c13|c9;
assign FinalOut_MSB=FinalOut[7:3];
assign FinalOut_LSB=FinalOut[2:0];
endmodule



module ARTS_n16_w4(A,B,OUT);
input [15:0]A,B;
output reg[31:0]OUT;
//******************* wires ****************************

	wire [1:0]Ka,Kb;
	wire [3:0]AH,BH;
	wire [3:0]AL,BL;
	wire [2:0]PP1;
	wire carry;
	wire [4:0]Mult_MSB;
	wire [2:0]Mult_LSB;
	wire [2:0]middle_part;
	wire orout1,orout2,z;

	LSD_n16_ss4  S1 (A,Ka,AH,AL);
	LSD_n16_ss4  S2 (B,Kb,BH,BL);
	APPR  S3 (AH,AL,BH,BL,PP1,carry);
	wallace_with_carry mult1 (AH,BH,carry,Mult_MSB,Mult_LSB);
	assign middle_part= Mult_LSB | PP1;
   	assign orout1=AH[0]|AH[1]|AH[2]|AH[3];
	assign orout2=BH[0]|BH[1]|BH[2]|BH[3];
	assign z= orout1 & orout2;
	
	wire [2:0] my_case;
	assign my_case= (z==1'b0) ? 3'd0:
	     (Ka==2'b11 & Kb==2'b11) ? 3'd1 :
		 ((Ka==2'b11 & Kb==2'b10)|(Ka==2'b10 & Kb==2'b11)) ? 3'd2 :
		 ((Ka==2'b11 & Kb==2'b01)|(Ka==2'b01 & Kb==2'b11)|(Ka==2'b10 & Kb==2'b10)|(Ka==2'b10 & Kb==2'b10)) ? 3'd3:
		 ((Ka==2'b11 & Kb==2'b00)|(Ka==2'b00 & Kb==2'b11)|(Ka==2'b10 & Kb==2'b01)|(Ka==2'b01 & Kb==2'b10)) ? 3'd4:
		 ((Ka==2'b10 & Kb==2'b00)|(Ka==2'b00 & Kb==2'b10)|(Ka==2'b01 & Kb==2'b01)|(Ka==2'b01 & Kb==2'b01)) ? 3'd5:
		 ((Ka==2'b01 & Kb==2'b00)|(Ka==2'b00 & Kb==2'b01)) ? 3'd6:3'd7;
	always@(my_case, Mult_MSB, middle_part)begin
	case (my_case)
		3'd0: OUT= 32'b0;
	    3'd1: OUT= {Mult_MSB,middle_part,24'b111111111111111111111111} ;
		3'd2: OUT= {4'b0,Mult_MSB,middle_part,20'b11111111111111111111};
		3'd3: OUT= {8'b0,Mult_MSB,middle_part,16'b1111111111111111} ;
		3'd4: OUT= {12'b0,Mult_MSB,middle_part,12'b111111111111} ;
		3'd5: OUT= {16'b0,Mult_MSB,middle_part,8'b11111111} ;
		3'd6: OUT= {20'b0,Mult_MSB,middle_part,4'b1111} ;
		3'd7: OUT= {24'd0,Mult_MSB,middle_part};		 
		endcase
	end
endmodule

