module carry_select(
 A,
 B,
 Ci,
 CO,
 SUM);
input [3:0] A,B;
input Ci;
output reg CO;
output reg [3:0] SUM;
/**internal carry and sum**/
wire CI_0[3:0],S_0[3:0];
wire CI_1[3:0],S_1[3:0];
/**assume ci = 0**/
com_32 com_01(.a(A[0]),.b(B[0]),.c(1'b0),.co(CI_0[0]),.sum(S_0[0]));
com_32 com_02(.a(A[1]),.b(B[1]),.c(CI_0[0]),.co(CI_0[1]),.sum(S_0[1]));
com_32 com_03(.a(A[2]),.b(B[2]),.c(CI_0[1]),.co(CI_0[2]),.sum(S_0[2]));
com_32 com_04(.a(A[3]),.b(B[3]),.c(CI_0[2]),.co(CI_0[3]),.sum(S_0[3]));

/**assume ci = 1**/
com_32 com_11(.a(A[0]),.b(B[0]),.c(1'b1),.co(CI_1[0]),.sum(S_1[0]));
com_32 com_12(.a(A[1]),.b(B[1]),.c(CI_1[0]),.co(CI_1[1]),.sum(S_1[1]));
com_32 com_13(.a(A[2]),.b(B[2]),.c(CI_1[1]),.co(CI_1[2]),.sum(S_1[2]));
com_32 com_14(.a(A[3]),.b(B[3]),.c(CI_1[2]),.co(CI_1[3]),.sum(S_1[3]));

/**CO output MUX**/
always@(*)begin
if(Ci)begin
CO=CI_1[3];
end else
CO=CI_0[3];
end

/**SUM Output MUX**/
always@(*)begin
if(Ci)begin
SUM[0]=S_1[0];
SUM[1]=S_1[1];
SUM[2]=S_1[2];
SUM[3]=S_1[3];
end else
SUM[0]=S_0[0];
SUM[1]=S_0[1];
SUM[2]=S_0[2];
SUM[3]=S_0[3];
end
endmodule