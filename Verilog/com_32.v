module com_32(a,b,c,co,sum);
input a,b,c;
output co,sum;
assign co = (a&b)|(c&(a|b));
assign sum = a^b^c;
endmodule
