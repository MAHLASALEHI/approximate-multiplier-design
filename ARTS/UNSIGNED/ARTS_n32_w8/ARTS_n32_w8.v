// n=32 w=8               


module APPR (AH,AL,BH,BL,PP1,carry);
	input [7:0]AH,BH,AL,BL;
	output [6:0]PP1;
	output carry;
	wire P0,P1,P2,P3,P4,P5,P6,P7,O0,O1,O2,O3,O4,O5,O6,O7;

	assign P0=(BL[1]&AH[7])|(BL[2]&AH[6])|(BL[3]&AH[5])|(BL[4]&AH[4])|(BL[5]&AH[3])|(BL[6]&AH[2])|(BL[7]&AH[1]);
	assign P1=(BL[2]&AH[7])|(BL[3]&AH[6])|(BL[4]&AH[5])|(BL[5]&AH[4])|(BL[6]&AH[3])|(BL[7]&AH[2]);
	assign P2=(BL[3]&AH[7])|(BL[4]&AH[6])|(BL[5]&AH[5])|(BL[6]&AH[4])|(BL[7]&AH[3]);
	assign P3=(BL[4]&AH[7])|(BL[5]&AH[6])|(BL[6]&AH[5])|(BL[7]&AH[4]);
	assign P4=(BL[5]&AH[7])|(BL[6]&AH[6])|(BL[7]&AH[5]);
	assign P5=(BL[6]&AH[7])|(BL[7]&AH[6]);
	assign P6=(BL[7]&AH[7]);
	assign P7=P6&P5;
	assign O0=(AL[1]&BH[7])|(AL[2]&BH[6])|(AL[3]&BH[5])|(AL[4]&BH[4])|(AL[5]&BH[3])|(AL[6]&BH[2])|(AL[7]&BH[1]);
	assign O1=(AL[2]&BH[7])|(AL[3]&BH[6])|(AL[4]&BH[5])|(AL[5]&BH[4])|(AL[6]&BH[3])|(AL[7]&BH[2]);
	assign O2=(AL[3]&BH[7])|(AL[4]&BH[6])|(AL[5]&BH[5])|(AL[6]&BH[4])|(AL[7]&BH[3]);
	assign O3=(AL[4]&BH[7])|(AL[5]&BH[6])|(AL[6]&BH[5])|(AL[7]&BH[4]);
	assign O4=(AL[5]&BH[7])|(AL[6]&BH[6])|(AL[7]&BH[5]);
	assign O5=(AL[6]&BH[7])|(AL[7]&BH[6]);
	assign O6=(AL[7]&BH[7]);
	assign O7=O6&O5;
	assign PP1[0]=P0|O0;
	assign PP1[1]=P1|O1;
	assign PP1[2]=P2|O2;
	assign PP1[3]=P3|O3;
	assign PP1[4]=P4|O4;
	assign PP1[5]=P5|O5;
	assign PP1[6]=P6|O6;
	assign carry= P7|O7;
endmodule

//******************* LSD ***************************
module LSD_n32_ss8(X,Kx,XH,XL);
	input [31:0]X;
	output [1:0]Kx;
	output [7:0]XH;
	output [7:0]XL;
	assign Kx=(X[31] | X[30] | X[29] | X[28] | X[27] | X[26] | X[25] | X[24]) ? 2'b11:
	(X[23] | X[22] | X[21] | X[20] | X[19] | X[18] | X[17] | X[16]) ? 2'b10:
	(X[15] | X[14] | X[13] | X[12] | X[11] | X[10] | X[9] | X[8])   ? 2'b01 : 2'b00;

	assign XH=(Kx==2'b11) ? X[31:24]:
	(Kx==2'b10) ? X[23:16]:
	(Kx==2'b01) ? X[15:8] : X[7:0];

	assign XL=(Kx==2'b11) ? X[23:16]:
	(Kx==2'b10) ? X[15:8]:
	(Kx==2'b01) ? X[7:0] : 8'b0;
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
input [7:0]A,B;
input carry;
output [8:0]FinalOut_MSB;
output [6:0]FinalOut_LSB;
wire [15:0] FinalOut;
//**************************************Generating PPs**************
assign FinalOut[0]=A[0] & B[0];
assign OL0X1C1= A[1] & B[0];
assign OL0X2C1= A[0] & B[1];
assign OL0X1C2= A[2] & B[0];
assign OL0X2C2= A[1] & B[1];
assign OL0X3C2= A[0] & B[2];
assign OL0X1C3= A[3] & B[0];
assign OL0X2C3= A[2] & B[1];
assign OL0X3C3= A[1] & B[2];
assign OL0X4C3= A[0] & B[3];
assign OL0X1C4= A[4] & B[0];
assign OL0X2C4= A[3] & B[1];
assign OL0X3C4= A[2] & B[2];
assign OL0X4C4= A[1] & B[3];
assign OL0X5C4= A[0] & B[4];
assign OL0X1C5= A[5] & B[0];
assign OL0X2C5= A[4] & B[1];
assign OL0X3C5= A[3] & B[2];
assign OL0X4C5= A[2] & B[3];
assign OL0X5C5= A[1] & B[4];
assign OL0X6C5= A[0] & B[5];
assign OL0X1C6= A[6] & B[0];
assign OL0X2C6= A[5] & B[1];
assign OL0X3C6= A[4] & B[2];
assign OL0X4C6= A[3] & B[3];
assign OL0X5C6= A[2] & B[4];
assign OL0X6C6= A[1] & B[5];
assign OL0X7C6= A[0] & B[6];
//************************for (n-1)th Column*************
assign OL0X1C7= A[7] & B[0];
assign OL0X2C7= A[6] & B[1];
assign OL0X3C7= A[5] & B[2];
assign OL0X4C7= A[4] & B[3];
assign OL0X5C7= A[3] & B[4];
assign OL0X6C7= A[2] & B[5];
assign OL0X7C7= A[1] & B[6];
assign OL0X8C7= A[0] & B[7];
//************************for (n)th Column*************
assign OL0X1C8= A[7] & B[1];
assign OL0X2C8= A[6] & B[2];
assign OL0X3C8= A[5] & B[3];
assign OL0X4C8= A[4] & B[4];
assign OL0X5C8= A[3] & B[5];
assign OL0X6C8= A[2] & B[6];
assign OL0X7C8= A[1] & B[7];
//******************************for the rest of Columns except for the last one************
assign OL0X1C9= A[7] & B[2];
assign OL0X2C9= A[6] & B[3];
assign OL0X3C9= A[5] & B[4];
assign OL0X4C9= A[4] & B[5];
assign OL0X5C9= A[3] & B[6];
assign OL0X6C9= A[2] & B[7];
assign OL0X1C10= A[7] & B[3];
assign OL0X2C10= A[6] & B[4];
assign OL0X3C10= A[5] & B[5];
assign OL0X4C10= A[4] & B[6];
assign OL0X5C10= A[3] & B[7];
assign OL0X1C11= A[7] & B[4];
assign OL0X2C11= A[6] & B[5];
assign OL0X3C11= A[5] & B[6];
assign OL0X4C11= A[4] & B[7];
assign OL0X1C12= A[7] & B[5];
assign OL0X2C12= A[6] & B[6];
assign OL0X3C12= A[5] & B[7];
assign OL0X1C13= A[7] & B[6];
assign OL0X2C13= A[6] & B[7];
//*******************************for the last column of PPS*****************
assign OL0X1C14= A[7] & B[7];
//*********************************************END of Generating Partial Products********************************************************
//***********************************Begin of Level 1 ************************************
assign {OL1X1C2,FinalOut[1]}=OL0X2C1+OL0X1C1;
assign {OL1X1C3,OL1X2C2}=OL0X3C2+OL0X2C2+OL0X1C2;
assign {OL1X1C4,OL1X2C3}=OL0X4C3+OL0X3C3+OL0X2C3;
assign {OL1X1C5,OL1X2C4}=OL0X5C4+OL0X4C4+OL0X3C4;
assign {OL1X2C5,OL1X3C4}=OL0X2C4+OL0X1C4;
assign {OL1X1C6,OL1X3C5}=OL0X6C5+OL0X5C5+OL0X4C5;
assign {OL1X2C6,OL1X4C5}=OL0X3C5+OL0X2C5+OL0X1C5;
assign {OL1X1C7,OL1X3C6}=OL0X7C6+OL0X6C6+OL0X5C6;
assign {OL1X2C7,OL1X4C6}=OL0X4C6+OL0X3C6+OL0X2C6;
assign {OL1X1C8,OL1X3C7}=OL0X8C7+OL0X7C7+OL0X6C7;
assign {OL1X2C8,OL1X4C7}=OL0X5C7+OL0X4C7+OL0X3C7;
assign {OL1X3C8,OL1X5C7}=OL0X2C7+OL0X1C7;
assign {OL1X1C9,OL1X4C8}=OL0X7C8+OL0X6C8+OL0X5C8;
assign {OL1X2C9,OL1X5C8}=OL0X4C8+OL0X3C8+OL0X2C8;
assign {OL1X1C10,OL1X3C9}=OL0X6C9+OL0X5C9+OL0X4C9;
assign {OL1X2C10,OL1X4C9}=OL0X3C9+OL0X2C9+OL0X1C9;
assign {OL1X1C11,OL1X3C10}=OL0X5C10+OL0X4C10+OL0X3C10;
assign {OL1X2C11,OL1X4C10}=OL0X2C10+OL0X1C10;
assign {OL1X1C12,OL1X3C11}=OL0X4C11+OL0X3C11+OL0X2C11;
assign {OL1X1C13,OL1X2C12}=OL0X3C12+OL0X2C12+OL0X1C12;
assign {OL1X1C14,OL1X2C13}=OL0X2C13+OL0X1C13;
//***********************************Begin of Level 2 ************************************
assign {OL2X1C3,FinalOut[2]}=OL1X2C2+OL1X1C2;
assign {OL2X1C4,OL2X2C3}=OL0X1C3+OL1X2C3+OL1X1C3;
assign {OL2X1C5,OL2X2C4}=OL1X3C4+OL1X2C4+OL1X1C4;
assign {OL2X1C6,OL2X2C5}=OL1X4C5+OL1X3C5+OL1X2C5;
assign {OL2X1C7,OL2X2C6}=OL0X1C6+OL1X4C6+OL1X3C6;
assign {OL2X2C7,OL2X3C6}=OL1X2C6+OL1X1C6;
assign {OL2X1C8,OL2X3C7}=OL1X5C7+OL1X4C7+OL1X3C7;
assign {OL2X2C8,OL2X4C7}=OL1X2C7+OL1X1C7;
assign {OL2X1C9,OL2X3C8}=OL0X1C8+OL1X5C8+OL1X4C8;
assign {OL2X2C9,OL2X4C8}=OL1X3C8+OL1X2C8+OL1X1C8;
assign {OL2X1C10,OL2X3C9}=OL1X4C9+OL1X3C9+OL1X2C9;
assign {OL2X1C11,OL2X2C10}=OL1X4C10+OL1X3C10+OL1X2C10;
assign {OL2X1C12,OL2X2C11}=OL0X1C11+OL1X3C11+OL1X2C11;
assign {OL2X1C13,OL2X2C12}=OL1X2C12+OL1X1C12;
assign {OL2X1C14,OL2X2C13}=OL1X2C13+OL1X1C13;
assign {OL2X1C15,OL2X2C14}=OL0X1C14+OL1X1C14;
//***********************************Begin of Level 3 ************************************
assign {OL3X1C4,FinalOut[3]}=OL2X2C3+OL2X1C3;
assign {OL3X1C5,OL3X2C4}=OL2X2C4+OL2X1C4;
assign {OL3X1C6,OL3X2C5}=OL1X1C5+OL2X2C5+OL2X1C5;
assign {OL3X1C7,OL3X2C6}=OL2X3C6+OL2X2C6+OL2X1C6;
assign {OL3X1C8,OL3X2C7}=OL2X4C7+OL2X3C7+OL2X2C7;
assign {OL3X1C9,OL3X2C8}=OL2X4C8+OL2X3C8+OL2X2C8;
assign {OL3X1C10,OL3X2C9}=OL1X1C9+OL2X3C9+OL2X2C9;
assign {OL3X1C11,OL3X2C10}=OL1X1C10+OL2X2C10+OL2X1C10;
assign {OL3X1C12,OL3X2C11}=OL1X1C11+OL2X2C11+OL2X1C11;
assign {OL3X1C13,OL3X2C12}=OL2X2C12+OL2X1C12;
assign {OL3X1C14,OL3X2C13}=OL2X2C13+OL2X1C13;
assign {OL3X1C15,OL3X2C14}=OL2X2C14+OL2X1C14;
//***********************************Begin of Level 4 ************************************
assign {OL4X1C5,FinalOut[4]}=OL3X2C4+OL3X1C4;
assign {OL4X1C6,OL4X2C5}=OL3X2C5+OL3X1C5;
assign {OL4X1C7,OL4X2C6}=OL3X2C6+OL3X1C6+carry;
assign {OL4X1C8,OL4X2C7}=OL2X1C7+OL3X2C7+OL3X1C7;
assign {OL4X1C9,OL4X2C8}=OL2X1C8+OL3X2C8+OL3X1C8;
assign {OL4X1C10,OL4X2C9}=OL2X1C9+OL3X2C9+OL3X1C9;
assign {OL4X1C11,OL4X2C10}=OL3X2C10+OL3X1C10;
assign {OL4X1C12,OL4X2C11}=OL3X2C11+OL3X1C11;
assign {OL4X1C13,OL4X2C12}=OL3X2C12+OL3X1C12;
assign {OL4X1C14,OL4X2C13}=OL3X2C13+OL3X1C13;
assign {OL4X1C15,OL4X2C14}=OL3X2C14+OL3X1C14;
assign {OL4X1C16,OL4X2C15}=OL2X1C15+OL3X1C15;
wire [10:0] O1,O2;
assign O1[0]=OL4X1C5;
assign O2[0]=OL4X2C5;
assign O1[1]=OL4X1C6;
assign O2[1]=OL4X2C6;
assign O1[2]=OL4X1C7;
assign O2[2]=OL4X2C7;
assign O1[3]=OL4X1C8;
assign O2[3]=OL4X2C8;
assign O1[4]=OL4X1C9;
assign O2[4]=OL4X2C9;
assign O1[5]=OL4X1C10;
assign O2[5]=OL4X2C10;
assign O1[6]=OL4X1C11;
assign O2[6]=OL4X2C11;
assign O1[7]=OL4X1C12;
assign O2[7]=OL4X2C12;
assign O1[8]=OL4X1C13;
assign O2[8]=OL4X2C13;
assign O1[9]=OL4X1C14;
assign O2[9]=OL4X2C14;
assign O1[10]=OL4X1C15;
assign O2[10]=OL4X2C15;
assign FinalOut[15:5]=O1+O2;
assign FinalOut_MSB=FinalOut[15:7];
assign FinalOut_LSB=FinalOut[6:0];
endmodule



module ARTS_n32_ss8(A,B,OUT);
input [31:0]A,B;
output reg[63:0]OUT;
//******************* wires ****************************

	wire [1:0]Ka,Kb;
	wire [7:0]AH,BH,AL,BL;
	wire [6:0]PP1;
	wire carry;
	wire [8:0]Mult_MSB;
	wire [6:0]Mult_LSB;
	wire [6:0]middle_part;
	wire orout1,orout2,z;

	LSD_n32_ss8  S1 (A,Ka,AH,AL);
	LSD_n32_ss8  S2 (B,Kb,BH,BL);
	APPR  S3 (AH,AL,BH,BL,PP1,carry);
	wallace_with_carry mult1 (AH,BH,carry,Mult_MSB,Mult_LSB);
	assign middle_part= Mult_LSB | PP1;
   	assign orout1=AH[0]|AH[1]|AH[2]|AH[3]|AH[4]|AH[5]|AH[6]|AH[7];
	assign orout2=BH[0]|BH[1]|BH[2]|BH[3]|BH[4]|BH[5]|BH[6]|BH[7];
	assign z= orout1 & orout2;
	wire [2:0] my_case;
	assign my_case = (z == 1'b0) ? 3'd0 :
		((Ka==2'd3 && Kb==2'd3)) ? 3'd1:
		((Ka==2'd3 && Kb==2'd2)||(Ka== 2'd2 && Kb==2'd3)) ? 3'd2:
		((Ka==2'd3 && Kb==2'd1)||(Ka== 2'd2 && Kb==2'd2)||(Ka== 2'd1 && Kb==2'd3)) ? 3'd3:
		((Ka==2'd3 && Kb==2'd0)||(Ka== 2'd2 && Kb==2'd1)||(Ka== 2'd1 && Kb==2'd2)||(Ka== 2'd0 && Kb==2'd3)) ? 3'd4:
		((Ka==2'd2 && Kb==2'd0)||(Ka== 2'd1 && Kb==2'd1)||(Ka== 2'd0 && Kb==2'd2)) ? 3'd5:
		((Ka==2'd1 && Kb==2'd0)||(Ka== 2'd0 && Kb==2'd1)) ? 3'd6:3'd7;
	always@(my_case, Mult_MSB, middle_part)begin
	case (my_case)
		3'd0: OUT = 64'b0 ;
		3'd1: OUT ={Mult_MSB, middle_part,48'd281474976710655};
		3'd2: OUT ={8'b0, Mult_MSB, middle_part,40'd1099511627775};
		3'd3: OUT ={16'b0, Mult_MSB, middle_part,32'd4294967295};
		3'd4: OUT = {24'b0, Mult_MSB, middle_part,24'd16777215};
		3'd5: OUT = {32'b0, Mult_MSB, middle_part,16'd65535};
		3'd6: OUT = {40'b0, Mult_MSB, middle_part,8'd255};
		3'd7: OUT ={48'b0, Mult_MSB, middle_part};
		endcase
	end
endmodule

