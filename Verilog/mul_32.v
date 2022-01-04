//created by Daiyuan at 2021.11.11
// An baugh-waley multiplier	
module mul_32(
		 clk,
		 reset,

		 A_in,
		 B_in,

		 C
	);

parameter mul_size = 32;
input clk;
input reset;
input [mul_size-1:0] A_in;
input [mul_size-1:0] B_in;
output reg[2*mul_size-1:0] C;
reg [mul_size-1:0] A;
reg [mul_size-1:0] B;
wire [mul_size-1:0] CO [mul_size:0];
wire [mul_size-1:0] SUM [mul_size:0];
wire [mul_size-1:0] CI [mul_size:0];
wire [mul_size-1:0] SI [mul_size:0];
genvar i,j,k,l;
wire [mul_size-1:0] PP [mul_size-1:0];
reg signed [2*mul_size-1:0] C_temp;
/*****input**********/
always@(posedge clk or negedge reset)begin
    if(!reset)begin
	    A<=0;
		 B<=0;
	 end
	 else begin
	 A<=A_in;
	 B<=B_in;
	 end
end
//array is (y,x)
/****and array****/
generate
for(k=0;k<(mul_size-1);k=k+1)begin: a1
for(i=0;i<(mul_size-1);i=i+1)begin: a2
 assign PP[k][i] = A[i]&B[k];
   end
end
endgenerate
/****nand array****/
generate
for(j=0;j<(mul_size-1);j=j+1)begin:a3
 assign PP[j][mul_size-1] = (~(A[mul_size-1]&B[j]));
end
endgenerate
/****nand array****/
generate
for(l=0;l<(mul_size-1);l=l+1)begin:a4
 assign PP[mul_size-1][l] = (~(A[l]&B[mul_size-1]));
end
endgenerate
/*******sign bit*******/
assign PP[mul_size-1][mul_size-1] = A[mul_size-1]& B[mul_size-1];
//generate ci
genvar i1,j1;
generate
    for(i1=0;i1<=mul_size;i1=i1+1)begin: out
    for(j1=0;j1<(mul_size);j1=j1+1)begin: in
     if(i1==0)begin
	 assign CO[i1][j1]= 1'b0;//y = 0,first row
	  end
	  else begin
	  assign CO[i1][j1]=CI[i1-1][j1];
	  end
    end
 end
endgenerate
//generate si
genvar i2,j2;
generate
 for(i2=0;i2<=mul_size;i2=i2+1)begin: siout
    for(j2=0;j2<(mul_size);j2=j2+1)begin: siin
     if((i2==0)||(j2==(mul_size-1)))begin
	 assign SUM[i2][j2]= 1'b0;//y = 0,first row
	  end
	  else begin
	 assign SUM[i2][j2]=SI[i2-1][j2+1];
	  end
    end
 end
endgenerate
/*****adder****/
genvar ii,jj;
generate 
   for(ii=0;ii<(mul_size);ii=ii+1)begin: adderin
   for(jj=0;jj<(mul_size);jj=jj+1)begin: adderout 
      com_32 inst00_i(.a(PP[ii][jj]),.b(CO[ii][jj]),.c(SUM[ii][jj]),.co(CI[ii][jj]),.sum(SI[ii][jj]));
		end
   end	
endgenerate
/*****last row adder******/
/**generate the valid ci first**/
genvar ll;
generate
   for(ll=0;ll<(4);ll=ll+1)begin:laste
   if(ll==0)begin
   com_32 inst00_ll(.a(1'b1),.b(CO[mul_size][ll]),.c(SUM[mul_size][ll]),.co(CI[mul_size][ll]),.sum(SI[mul_size][ll]));
   end
   else begin
   com_32 inst00_ll(.a(CO[mul_size][ll]),.b(CI[mul_size][ll-1]),.c(SUM[mul_size][ll]),.co(CI[mul_size][ll]),.sum(SI[mul_size][ll]));
   end 
   end
endgenerate

/**using carry select adder**/
genvar cc;
generate
   for(cc=1;cc<(mul_size/4);cc=cc+1)begin:carry
	if(cc+1==(mul_size/4))begin
	carry_select inst_cc(.A({1'b1,SUM[mul_size][mul_size-2:mul_size-4]}),.B(CO[mul_size][mul_size-1:mul_size-4]),.Ci(CI[mul_size][cc*4-1]),.CO(CI[mul_size][mul_size-1]),.SUM(SI[mul_size][mul_size-1:mul_size-4]));
	end 
	else begin
   carry_select inst_cc(.A(SUM[mul_size][cc*4+3:cc*4]),.B(CO[mul_size][cc*4+3:cc*4]),.Ci(CI[mul_size][cc*4-1]),.CO(CI[mul_size][4*(cc+1)-1]),.SUM(SI[mul_size][cc*4+3:cc*4]));
   end
   end	
endgenerate
/************assign to the output*******/
integer i3,j3;
always@(*)begin
for(i3=0;i3<=(mul_size);i3=i3+1)begin
	C_temp[i3] = SI[i3][0];
	end
for(j3=1;j3<=(mul_size-1);j3=j3+1)begin
   C_temp[j3+mul_size] = SI[mul_size][j3];
   end
end
/**Output**/
always@(posedge clk or negedge reset)begin
if(!reset)begin
C<=0;
end else
C<=C_temp[2*mul_size-1:0];
end
endmodule
