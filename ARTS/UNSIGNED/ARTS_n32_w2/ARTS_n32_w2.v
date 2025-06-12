// n=32 w=2              


module APPR (AH,AL,BH,BL,PP1,carry);
	input [1:0]AH,BH,AL,BL;
	output PP1;
	output carry;
	wire P6,O6,P7,O7;

	assign P6=(BL[1]&AH[1]);
	assign P7=P6;

	assign O6=(AL[1]&BH[1]);
	assign O7=O6;

	assign PP1=P6|O6;
	assign carry= P7|O7;
endmodule

//******************* LSD ***************************
module LSD_n32_ss2(X,Kx,XH,XL);
input [31:0] X;
output [3:0] Kx;
output [1:0] XH;
output [1:0] XL;

assign Kx = (X[31] | X[30]) ? 4'b1111 :
(X[29] | X[28]) ? 4'b1110 :
(X[27] | X[26]) ? 4'b1101 :
(X[25] | X[24]) ? 4'b1100 :
(X[23] | X[22]) ? 4'b1011 :
(X[21] | X[20]) ? 4'b1010 :
(X[19] | X[18]) ? 4'b1001 :
(X[17] | X[16]) ? 4'b1000 :
(X[15] | X[14]) ? 4'b0111 :
(X[13] | X[12]) ? 4'b0110 :
(X[11] | X[10]) ? 4'b0101 :
(X[9]  | X[8])  ? 4'b0100 :
(X[7]  | X[6])  ? 4'b0011 :
(X[5]  | X[4])  ? 4'b0010 :
(X[3]  | X[2])  ? 4'b0001 : 4'b0000;

assign XH = (Kx == 4'b1111) ? X[31:30] :
(Kx == 4'b1110) ? X[29:28] :
(Kx == 4'b1101) ? X[27:26] :
(Kx == 4'b1100) ? X[25:24] :
(Kx == 4'b1011) ? X[23:22] :
(Kx == 4'b1010) ? X[21:20] :
(Kx == 4'b1001) ? X[19:18] :
(Kx == 4'b1000) ? X[17:16] :
(Kx == 4'b0111) ? X[15:14] :
(Kx == 4'b0110) ? X[13:12] :
(Kx == 4'b0101) ? X[11:10] :
(Kx == 4'b0100) ? X[9:8]   :
(Kx == 4'b0011) ? X[7:6]   :
(Kx == 4'b0010) ? X[5:4]   :
(Kx == 4'b0001) ? X[3:2]   : X[1:0];

assign XL = (Kx == 4'b1111) ? X[29:28] :
(Kx == 4'b1110) ? X[27:26] :
(Kx == 4'b1101) ? X[25:24] :
(Kx == 4'b1100) ? X[23:22] :
(Kx == 4'b1011) ? X[21:20] :
(Kx == 4'b1010) ? X[19:18] :
(Kx == 4'b1001) ? X[17:16] :
(Kx == 4'b1000) ? X[15:14] :
(Kx == 4'b0111) ? X[13:12] :
(Kx == 4'b0110) ? X[11:10] :
(Kx == 4'b0101) ? X[9:8]   :
(Kx == 4'b0100) ? X[7:6]   :
(Kx == 4'b0011) ? X[5:4]   :
(Kx == 4'b0010) ? X[3:2]   : 2'b00;

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

//******************* wallace 2 ***************************
module wallace_with_carry(A,B,carry,FinalOut_MSB,FinalOut_LSB);
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



module ARTS_n32_ss2(A,B,OUT);
input [31:0]A,B;
output reg[63:0]OUT;
//******************* wires ****************************

	wire [3:0]Ka,Kb;
	wire [1:0]AH,BH,AL,BL;
	wire PP1;
	wire carry;
	wire [2:0]Mult_MSB;
	wire Mult_LSB;
	wire middle_part;
	wire orout1,orout2,z;

	LSD_n32_ss2  S1 (A,Ka,AH,AL);
	LSD_n32_ss2  S2 (B,Kb,BH,BL);
	APPR  S3 (AH,AL,BH,BL,PP1,carry);
	wallace_with_carry mult1 (AH,BH,carry,Mult_MSB,Mult_LSB);
	assign middle_part= Mult_LSB | PP1;
   	assign orout1=AH[0]|AH[1];
	assign orout2=BH[0]|BH[1];
	assign z= orout1 & orout2;
	
	wire [4:0] my_case;
	assign my_case = (z == 1'b0) ? 5'd0 :
((Ka==4'd15 && Kb==4'd15)) ? 5'd1:
((Ka==4'd15 && Kb==4'd14)||(Ka== 4'd14 && Kb==4'd15)) ? 5'd2:
((Ka==4'd15 && Kb==4'd13)||(Ka== 4'd14 && Kb==4'd14)||(Ka== 4'd13 && Kb==4'd15)) ? 5'd3:
((Ka==4'd15 && Kb==4'd12)||(Ka== 4'd14 && Kb==4'd13)||(Ka== 4'd13 && Kb==4'd14)||(Ka== 4'd12 && Kb==4'd15)) ? 5'd4:
((Ka==4'd15 && Kb==4'd11)||(Ka== 4'd14 && Kb==4'd12)||(Ka== 4'd13 && Kb==4'd13)||(Ka== 4'd12 && Kb==4'd14)||(Ka== 4'd11 && Kb==4'd15)) ? 5'd5:
((Ka==4'd15 && Kb==4'd10)||(Ka== 4'd14 && Kb==4'd11)||(Ka== 4'd13 && Kb==4'd12)||(Ka== 4'd12 && Kb==4'd13)||(Ka== 4'd11 && Kb==4'd14)||(Ka== 4'd10 && Kb==4'd15)) ? 5'd6:
((Ka==4'd15 && Kb==4'd9)||(Ka== 4'd14 && Kb==4'd10)||(Ka== 4'd13 && Kb==4'd11)||(Ka== 4'd12 && Kb==4'd12)||(Ka== 4'd11 && Kb==4'd13)||(Ka== 4'd10 && Kb==4'd14)||(Ka== 4'd9 && Kb==4'd15)) ? 5'd7:
((Ka==4'd15 && Kb==4'd8)||(Ka== 4'd14 && Kb==4'd9)||(Ka== 4'd13 && Kb==4'd10)||(Ka== 4'd12 && Kb==4'd11)||(Ka== 4'd11 && Kb==4'd12)||(Ka== 4'd10 && Kb==4'd13)||(Ka== 4'd9 && Kb==4'd14)||(Ka== 4'd8 && Kb==4'd15)) ? 5'd8:
((Ka==4'd15 && Kb==4'd7)||(Ka== 4'd14 && Kb==4'd8)||(Ka== 4'd13 && Kb==4'd9)||(Ka== 4'd12 && Kb==4'd10)||(Ka== 4'd11 && Kb==4'd11)||(Ka== 4'd10 && Kb==4'd12)||(Ka== 4'd9 && Kb==4'd13)||(Ka== 4'd8 && Kb==4'd14)||(Ka== 4'd7 && Kb==4'd15)) ? 5'd9:
((Ka==4'd15 && Kb==4'd6)||(Ka== 4'd14 && Kb==4'd7)||(Ka== 4'd13 && Kb==4'd8)||(Ka== 4'd12 && Kb==4'd9)||(Ka== 4'd11 && Kb==4'd10)||(Ka== 4'd10 && Kb==4'd11)||(Ka== 4'd9 && Kb==4'd12)||(Ka== 4'd8 && Kb==4'd13)||(Ka== 4'd7 && Kb==4'd14)||(Ka== 4'd6 && Kb==4'd15)) ? 5'd10:
((Ka==4'd15 && Kb==4'd5)||(Ka== 4'd14 && Kb==4'd6)||(Ka== 4'd13 && Kb==4'd7)||(Ka== 4'd12 && Kb==4'd8)||(Ka== 4'd11 && Kb==4'd9)||(Ka== 4'd10 && Kb==4'd10)||(Ka== 4'd9 && Kb==4'd11)||(Ka== 4'd8 && Kb==4'd12)||(Ka== 4'd7 && Kb==4'd13)||(Ka== 4'd6 && Kb==4'd14)||(Ka== 4'd5 && Kb==4'd15)) ? 5'd11:
((Ka==4'd15 && Kb==4'd4)||(Ka== 4'd14 && Kb==4'd5)||(Ka== 4'd13 && Kb==4'd6)||(Ka== 4'd12 && Kb==4'd7)||(Ka== 4'd11 && Kb==4'd8)||(Ka== 4'd10 && Kb==4'd9)||(Ka== 4'd9 && Kb==4'd10)||(Ka== 4'd8 && Kb==4'd11)||(Ka== 4'd7 && Kb==4'd12)||(Ka== 4'd6 && Kb==4'd13)||(Ka== 4'd5 && Kb==4'd14)||(Ka== 4'd4 && Kb==4'd15)) ? 5'd12:
((Ka==4'd15 && Kb==4'd3)||(Ka== 4'd14 && Kb==4'd4)||(Ka== 4'd13 && Kb==4'd5)||(Ka== 4'd12 && Kb==4'd6)||(Ka== 4'd11 && Kb==4'd7)||(Ka== 4'd10 && Kb==4'd8)||(Ka== 4'd9 && Kb==4'd9)||(Ka== 4'd8 && Kb==4'd10)||(Ka== 4'd7 && Kb==4'd11)||(Ka== 4'd6 && Kb==4'd12)||(Ka== 4'd5 && Kb==4'd13)||(Ka== 4'd4 && Kb==4'd14)||(Ka== 4'd3 && Kb==4'd15)) ? 5'd13:
((Ka==4'd15 && Kb==4'd2)||(Ka== 4'd14 && Kb==4'd3)||(Ka== 4'd13 && Kb==4'd4)||(Ka== 4'd12 && Kb==4'd5)||(Ka== 4'd11 && Kb==4'd6)||(Ka== 4'd10 && Kb==4'd7)||(Ka== 4'd9 && Kb==4'd8)||(Ka== 4'd8 && Kb==4'd9)||(Ka== 4'd7 && Kb==4'd10)||(Ka== 4'd6 && Kb==4'd11)||(Ka== 4'd5 && Kb==4'd12)||(Ka== 4'd4 && Kb==4'd13)||(Ka== 4'd3 && Kb==4'd14)||(Ka== 4'd2 && Kb==4'd15)) ? 5'd14:
((Ka==4'd15 && Kb==4'd1)||(Ka== 4'd14 && Kb==4'd2)||(Ka== 4'd13 && Kb==4'd3)||(Ka== 4'd12 && Kb==4'd4)||(Ka== 4'd11 && Kb==4'd5)||(Ka== 4'd10 && Kb==4'd6)||(Ka== 4'd9 && Kb==4'd7)||(Ka== 4'd8 && Kb==4'd8)||(Ka== 4'd7 && Kb==4'd9)||(Ka== 4'd6 && Kb==4'd10)||(Ka== 4'd5 && Kb==4'd11)||(Ka== 4'd4 && Kb==4'd12)||(Ka== 4'd3 && Kb==4'd13)||(Ka== 4'd2 && Kb==4'd14)||(Ka== 4'd1 && Kb==4'd15)) ? 5'd15:
((Ka==4'd15 && Kb==4'd0)||(Ka== 4'd14 && Kb==4'd1)||(Ka== 4'd13 && Kb==4'd2)||(Ka== 4'd12 && Kb==4'd3)||(Ka== 4'd11 && Kb==4'd4)||(Ka== 4'd10 && Kb==4'd5)||(Ka== 4'd9 && Kb==4'd6)||(Ka== 4'd8 && Kb==4'd7)||(Ka== 4'd7 && Kb==4'd8)||(Ka== 4'd6 && Kb==4'd9)||(Ka== 4'd5 && Kb==4'd10)||(Ka== 4'd4 && Kb==4'd11)||(Ka== 4'd3 && Kb==4'd12)||(Ka== 4'd2 && Kb==4'd13)||(Ka== 4'd1 && Kb==4'd14)||(Ka== 4'd0 && Kb==4'd15)) ? 5'd16:
((Ka==4'd14 && Kb==4'd0)||(Ka== 4'd13 && Kb==4'd1)||(Ka== 4'd12 && Kb==4'd2)||(Ka== 4'd11 && Kb==4'd3)||(Ka== 4'd10 && Kb==4'd4)||(Ka== 4'd9 && Kb==4'd5)||(Ka== 4'd8 && Kb==4'd6)||(Ka== 4'd7 && Kb==4'd7)||(Ka== 4'd6 && Kb==4'd8)||(Ka== 4'd5 && Kb==4'd9)||(Ka== 4'd4 && Kb==4'd10)||(Ka== 4'd3 && Kb==4'd11)||(Ka== 4'd2 && Kb==4'd12)||(Ka== 4'd1 && Kb==4'd13)||(Ka== 4'd0 && Kb==4'd14)) ? 5'd17:
((Ka==4'd13 && Kb==4'd0)||(Ka== 4'd12 && Kb==4'd1)||(Ka== 4'd11 && Kb==4'd2)||(Ka== 4'd10 && Kb==4'd3)||(Ka== 4'd9 && Kb==4'd4)||(Ka== 4'd8 && Kb==4'd5)||(Ka== 4'd7 && Kb==4'd6)||(Ka== 4'd6 && Kb==4'd7)||(Ka== 4'd5 && Kb==4'd8)||(Ka== 4'd4 && Kb==4'd9)||(Ka== 4'd3 && Kb==4'd10)||(Ka== 4'd2 && Kb==4'd11)||(Ka== 4'd1 && Kb==4'd12)||(Ka== 4'd0 && Kb==4'd13)) ? 5'd18:
((Ka==4'd12 && Kb==4'd0)||(Ka== 4'd11 && Kb==4'd1)||(Ka== 4'd10 && Kb==4'd2)||(Ka== 4'd9 && Kb==4'd3)||(Ka== 4'd8 && Kb==4'd4)||(Ka== 4'd7 && Kb==4'd5)||(Ka== 4'd6 && Kb==4'd6)||(Ka== 4'd5 && Kb==4'd7)||(Ka== 4'd4 && Kb==4'd8)||(Ka== 4'd3 && Kb==4'd9)||(Ka== 4'd2 && Kb==4'd10)||(Ka== 4'd1 && Kb==4'd11)||(Ka== 4'd0 && Kb==4'd12)) ? 5'd19:
((Ka==4'd11 && Kb==4'd0)||(Ka== 4'd10 && Kb==4'd1)||(Ka== 4'd9 && Kb==4'd2)||(Ka== 4'd8 && Kb==4'd3)||(Ka== 4'd7 && Kb==4'd4)||(Ka== 4'd6 && Kb==4'd5)||(Ka== 4'd5 && Kb==4'd6)||(Ka== 4'd4 && Kb==4'd7)||(Ka== 4'd3 && Kb==4'd8)||(Ka== 4'd2 && Kb==4'd9)||(Ka== 4'd1 && Kb==4'd10)||(Ka== 4'd0 && Kb==4'd11)) ? 5'd20:
((Ka==4'd10 && Kb==4'd0)||(Ka== 4'd9 && Kb==4'd1)||(Ka== 4'd8 && Kb==4'd2)||(Ka== 4'd7 && Kb==4'd3)||(Ka== 4'd6 && Kb==4'd4)||(Ka== 4'd5 && Kb==4'd5)||(Ka== 4'd4 && Kb==4'd6)||(Ka== 4'd3 && Kb==4'd7)||(Ka== 4'd2 && Kb==4'd8)||(Ka== 4'd1 && Kb==4'd9)||(Ka== 4'd0 && Kb==4'd10)) ? 5'd21:
((Ka==4'd9 && Kb==4'd0)||(Ka== 4'd8 && Kb==4'd1)||(Ka== 4'd7 && Kb==4'd2)||(Ka== 4'd6 && Kb==4'd3)||(Ka== 4'd5 && Kb==4'd4)||(Ka== 4'd4 && Kb==4'd5)||(Ka== 4'd3 && Kb==4'd6)||(Ka== 4'd2 && Kb==4'd7)||(Ka== 4'd1 && Kb==4'd8)||(Ka== 4'd0 && Kb==4'd9)) ? 5'd22:
((Ka==4'd8 && Kb==4'd0)||(Ka== 4'd7 && Kb==4'd1)||(Ka== 4'd6 && Kb==4'd2)||(Ka== 4'd5 && Kb==4'd3)||(Ka== 4'd4 && Kb==4'd4)||(Ka== 4'd3 && Kb==4'd5)||(Ka== 4'd2 && Kb==4'd6)||(Ka== 4'd1 && Kb==4'd7)||(Ka== 4'd0 && Kb==4'd8)) ? 5'd23:
((Ka==4'd7 && Kb==4'd0)||(Ka== 4'd6 && Kb==4'd1)||(Ka== 4'd5 && Kb==4'd2)||(Ka== 4'd4 && Kb==4'd3)||(Ka== 4'd3 && Kb==4'd4)||(Ka== 4'd2 && Kb==4'd5)||(Ka== 4'd1 && Kb==4'd6)||(Ka== 4'd0 && Kb==4'd7)) ? 5'd24:
((Ka==4'd6 && Kb==4'd0)||(Ka== 4'd5 && Kb==4'd1)||(Ka== 4'd4 && Kb==4'd2)||(Ka== 4'd3 && Kb==4'd3)||(Ka== 4'd2 && Kb==4'd4)||(Ka== 4'd1 && Kb==4'd5)||(Ka== 4'd0 && Kb==4'd6)) ? 5'd25:
((Ka==4'd5 && Kb==4'd0)||(Ka== 4'd4 && Kb==4'd1)||(Ka== 4'd3 && Kb==4'd2)||(Ka== 4'd2 && Kb==4'd3)||(Ka== 4'd1 && Kb==4'd4)||(Ka== 4'd0 && Kb==4'd5)) ? 5'd26:
((Ka==4'd4 && Kb==4'd0)||(Ka== 4'd3 && Kb==4'd1)||(Ka== 4'd2 && Kb==4'd2)||(Ka== 4'd1 && Kb==4'd3)||(Ka== 4'd0 && Kb==4'd4)) ? 5'd27:
((Ka==4'd3 && Kb==4'd0)||(Ka== 4'd2 && Kb==4'd1)||(Ka== 4'd1 && Kb==4'd2)||(Ka== 4'd0 && Kb==4'd3)) ? 5'd28:
((Ka==4'd2 && Kb==4'd0)||(Ka== 4'd1 && Kb==4'd1)||(Ka== 4'd0 && Kb==4'd2)) ? 5'd29:
((Ka==4'd1 && Kb==4'd0)||(Ka== 4'd0 && Kb==4'd1)) ? 5'd30:5'd31;

	always@(my_case, Mult_MSB, middle_part)begin
	case (my_case)
5'd0: OUT =64'b0 ;
5'd1: OUT ={Mult_MSB, middle_part,60'd1152921504606846975};
5'd2: OUT ={2'b0, Mult_MSB, middle_part,58'd288230376151711743};
5'd3: OUT ={4'b0, Mult_MSB, middle_part,56'd72057594037927935};
5'd4: OUT ={6'b0, Mult_MSB, middle_part,54'd18014398509481983};
5'd5: OUT ={8'b0, Mult_MSB, middle_part,52'd4503599627370495};
5'd6: OUT ={10'b0, Mult_MSB, middle_part,50'd1125899906842623};
5'd7: OUT ={12'b0, Mult_MSB, middle_part,48'd281474976710655};
5'd8: OUT ={14'b0, Mult_MSB, middle_part,46'd70368744177663};
5'd9: OUT ={16'b0, Mult_MSB, middle_part,44'd17592186044415};
5'd10: OUT ={18'b0, Mult_MSB, middle_part,42'd4398046511103};
5'd11: OUT ={20'b0, Mult_MSB, middle_part,40'd1099511627775};
5'd12: OUT ={22'b0, Mult_MSB, middle_part,38'd274877906943};
5'd13: OUT ={24'b0, Mult_MSB, middle_part,36'd68719476735};
5'd14: OUT ={26'b0, Mult_MSB, middle_part,34'd17179869183};
5'd15: OUT ={28'b0, Mult_MSB, middle_part,32'd4294967295};
5'd16: OUT ={30'b0, Mult_MSB, middle_part,30'd1073741823};
5'd17: OUT ={32'b0, Mult_MSB, middle_part,28'd268435455};
5'd18: OUT ={34'b0, Mult_MSB, middle_part,26'd67108863};
5'd19: OUT ={36'b0, Mult_MSB, middle_part,24'd16777215};
5'd20: OUT ={38'b0, Mult_MSB, middle_part,22'd4194303};
5'd21: OUT ={40'b0, Mult_MSB, middle_part,20'd1048575};
5'd22: OUT ={42'b0, Mult_MSB, middle_part,18'd262143};
5'd23: OUT ={44'b0, Mult_MSB, middle_part,16'd65535};
5'd24: OUT ={46'b0, Mult_MSB, middle_part,14'd16383};
5'd25: OUT ={48'b0, Mult_MSB, middle_part,12'd4095};
5'd26: OUT ={50'b0, Mult_MSB, middle_part,10'd1023};
5'd27: OUT ={52'b0, Mult_MSB, middle_part,8'd255};
5'd28: OUT ={54'b0, Mult_MSB, middle_part,6'd63};
5'd29: OUT ={56'b0, Mult_MSB, middle_part,4'd15};
5'd30: OUT ={58'b0, Mult_MSB, middle_part,2'd3};
5'd31: OUT ={60'b0, Mult_MSB, middle_part};
		 endcase
	end
endmodule

