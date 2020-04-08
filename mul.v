
module mul(input [31:0] a,b,
                  input clk,
                  input  start,
                  input is_signed,
                  output mulfinish,
                  output reg[63:0] y);//mul_low and mul_h, where to store mflo and mfhi
/*always@(posedge clk)
  begin
if(start)
wire signed[31:0] signed_a = a;
wire signed[31:0] signed_b = b;
wire signed[63:0] signed_y = signed_a*signed_b;
assign y = (is_signed ==0)?a*b:signed_y;

else*/
reg [7:0]state=0;
reg cout1;
reg [63:0]sum1;
reg [63:0]sum2;

wire signed[63:0] signa;
assign signa=(a[31]&b[31])?{32'b0,~a}:(a[31])?{32'hffffffff,a}:{32'b0,a};//sign extention
wire signed[63:0] signb;
assign signb=(a[31]&b[31])?{32'b0,~b}:(b[31])?{32'hffffffff,b}:{32'b0,b};
wire mstart = start;

always@(start,posedge clk)//not sure the break point
  begin
  if(state == 8'b0)  
    muladder(((signb[0])?signa:64'b0,64'b0,1'b0,sum1,cout1);
  else
      begin
          shifter(is_signed,sum1,sum1);
          muladder((signb[state])?sum1:64'b0,sum2,cout1,sum2,cout1);
      end
if(state ==8'b11111)
    begin
      y <= sum2;
      mulfinish = 1'b1;
    end
eadder(state,8'b1,state);
end

endmodule 



module shifter(input sign,
               input [63:0]sin,
               output [63:0]q);

assign q = (sign)?{sin[63],sin[61:0],1'b0}:(sin<<1);//for keep sign/unsign
//q = {sin[62:0],1'b0};

endmodule


module muladder(
                  input [63:0]a,
                  input [63:0]b,
                  input cin,
                  output [63:0]sum,
                  output cout);
wire [64:0]result = a + b + cin;
assign sum = result[63:0];
assign cout = result[64];
endmodule

module eadder(//for increment
input  [7:0] a, b,
output [7:0] y);
assign y = a + b;
endmodule




/*
wire [31:0]pass = {b[1]&a[0],b[1]&a[1],b[1]&a[2],b[1]&a[3],b[1]&a[4],b[1]&a[5],b[1]&a[6],b[1]&a[7],
b[1]&a[8],b[1]&a[9],b[1]&a[10],b[1]&a[11],b[1]&a[12],b[1]&a[13],b[1]&a[14],b[1]&a[15],
b[1]&a[16],b[1]&a[17],b[1]&a[18],b[1]&a[19],b[1]&a[20],b[21]&a[0],b[1]&a[22],b[1]&a[23],
b[1]&a[24],b[1]&a[25],b[1]&a[26],b[1]&a[27],b[1]&a[28],b[1]&a[29],b[1]&a[30],b[1]&a[31]};



if(state == 0)
  begin
  fulladder(a[0],b[0],0,y[0],cout1[0]);//clk 1 is a special case output y0 this cout1 is not useful
  fulladder(b[0]&a[1],b[1]&a[0],0,y[1],cout1[0]);//output y1
  fulladder(b[0]&a[2],b[1]&a[1],cout1[0],sum1[0],cout1[1]);
  fulladder(b[0]&a[3],b[1]&a[2],cout1[1],sum1[1],cout1[2]);
  fulladder(b[0]&a[4],b[1]&a[3],cout1[2],sum1[2],cout1[3]);
  fulladder(b[0]&a[5],b[1]&a[4],cout1[3],sum1[3],cout1[4]);
  fulladder(b[0]&a[6],b[1]&a[5],cout1[4],sum1[4],cout1[5]);
  fulladder(b[0]&a[7],b[1]&a[6],cout1[5],sum1[5],cout1[6]);
  fulladder(b[0]&a[8],b[1]&a[7],cout1[6],sum1[6],cout1[7]);
  fulladder(b[0]&a[9],b[1]&a[8],cout1[7],sum1[7],cout1[8]);
  fulladder(b[0]&a[10],b[1]&a[9],cout1[8],sum1[8],cout1[9]);
  fulladder(b[0]&a[11],b[1]&a[10],cout1[9],sum1[9],cout1[10]);
  fulladder(b[0]&a[12],b[1]&a[11],cout1[10],sum1[10],cout1[11]);
  fulladder(b[0]&a[13],b[1]&a[12],cout1[11],sum1[11],cout1[12]);
  fulladder(b[0]&a[14],b[1]&a[13],cout1[12],sum1[12],cout1[13]);
  fulladder(b[0]&a[15],b[1]&a[14],cout1[13],sum1[13],cout1[14]);
  fulladder(b[0]&a[16],b[1]&a[15],cout1[14],sum1[14],cout1[15]);
  fulladder(b[0]&a[17],b[1]&a[16],cout1[15],sum1[15],cout1[16]);
  fulladder(b[0]&a[18],b[1]&a[17],cout1[16],sum1[16],cout1[17]);
  fulladder(b[0]&a[19],b[1]&a[18],cout1[17],sum1[17],cout1[18]);
  fulladder(b[0]&a[20],b[1]&a[19],cout1[18],sum1[18],cout1[19]);
  fulladder(b[0]&a[21],b[1]&a[20],cout1[19],sum1[19],cout1[20]);
  fulladder(b[0]&a[22],b[1]&a[21],cout1[20],sum1[20],cout1[21]);
  fulladder(b[0]&a[23],b[1]&a[22],cout1[21],sum1[21],cout1[22]);
  fulladder(b[0]&a[24],b[1]&a[23],cout1[22],sum1[22],cout1[23]);
  fulladder(b[0]&a[25],b[1]&a[24],cout1[23],sum1[23],cout1[24]);
  fulladder(b[0]&a[26],b[1]&a[25],cout1[24],sum1[24],cout1[25]);
  fulladder(b[0]&a[27],b[1]&a[26],cout1[25],sum1[25],cout1[26]);
  fulladder(b[0]&a[28],b[1]&a[27],cout1[26],sum1[26],cout1[27]);
  fulladder(b[0]&a[29],b[1]&a[28],cout1[27],sum1[27],cout1[28]);
  fulladder(b[0]&a[30],b[1]&a[29],cout1[28],sum1[28],cout1[29]);
  fulladder(b[0]&a[31],b[1]&a[30],cout1[29],sum1[29],cout1[30]);
  fulladder(0,b[1]&a[31],cout1[30],sum1[30],cout1[31]);
  state<=state+1;
  end
  if(state==31)//clk 31 is a special case
  begin
  fulladder(pass[0]&b[state],sum1[0],0,y[31],cout1[0]);//output y[state+1]
  fulladder(pass[1]&b[state],sum1[1],cout1[0],y[32],cout1[1]);//if output sum1[0] would affect y[state+1]
  fulladder(pass[2]&b[state],sum1[2],cout1[1],y[33],cout1[2]);
  fulladder(pass[3]&b[state],sum1[3],cout1[2],y[34],cout1[3]);
  fulladder(pass[4]&b[state],sum1[4],cout1[3],y[35],cout1[4]);
  fulladder(pass[5]&b[state],sum1[5],cout1[4],y[36],cout1[5]);
  fulladder(pass[6]&b[state],sum1[6],cout1[5],y[37],cout1[6]);
  fulladder(pass[7]&b[state],sum1[7],cout1[6],y[38],cout1[7]);
  fulladder(pass[8]&b[state],sum1[8],cout1[7],y[39],cout1[8]);
  fulladder(pass[9]&b[state],sum1[9],cout1[8],y[40],cout1[9]);
  fulladder(pass[10]&b[state],sum1[10],cout1[9],y[41],cout1[10]);
  fulladder(pass[11]&b[state],sum1[11],cout1[10],y[42],cout1[11]);
  fulladder(pass[12]&b[state],sum1[12],cout1[11],y[43],cout1[12]);
  fulladder(pass[13]&b[state],sum1[13],cout1[12],y[44],cout1[13]);
  fulladder(pass[14]&b[state],sum1[14],cout1[13],y[45],cout1[14]);
  fulladder(pass[15]&b[state],sum1[15],cout1[14],y[46],cout1[15]);
  fulladder(pass[16]&b[state],sum1[16],cout1[15],y[47],cout1[16]);
  fulladder(pass[17]&b[state],sum1[17],cout1[16],y[48],cout1[17]);
  fulladder(pass[18]&b[state],sum1[18],cout1[17],y[49],cout1[18]);
  fulladder(pass[19]&b[state],sum1[19],cout1[18],y[50],cout1[19]);
  fulladder(pass[20]&b[state],sum1[20],cout1[19],y[51],cout1[20]);
  fulladder(pass[21]&b[state],sum1[21],cout1[20],y[52],cout1[21]);
  fulladder(pass[22]&b[state],sum1[22],cout1[21],y[53],cout1[22]);
  fulladder(pass[23]&b[state],sum1[23],cout1[22],y[54],cout1[23]);
  fulladder(pass[24]&b[state],sum1[24],cout1[23],y[55],cout1[24]);
  fulladder(pass[25]&b[state],sum1[25],cout1[24],y[56],cout1[25]);
  fulladder(pass[26]&b[state],sum1[26],cout1[25],y[57],cout1[26]);
  fulladder(pass[27]&b[state],sum1[27],cout1[26],y[58],cout1[27]);
  fulladder(pass[28]&b[state],sum1[28],cout1[27],y[59],cout1[28]);
  fulladder(pass[29]&b[state],sum1[29],cout1[28],y[60],cout1[29]);
  fulladder(pass[30]&b[state],sum1[30],cout1[29],y[61],cout1[30]);
  fulladder(cout1[31],pass[31]&b[state],cout1[30],y[62],y[63]);//consider
  state<=state+1;
  end
  if((state%2==1)&&(state!=0)&&(state!=31))
  begin
  fulladder(pass[0]&b[state],sum1[0],0,y[state],cout1[0]);//output y[state+1]
  fulladder(pass[1]&b[state],sum1[1],cout1[0],sum2[0],cout1[1]);//if output sum1[0] would affect y[state+1]
  fulladder(pass[2]&b[state],sum1[2],cout1[1],sum2[1],cout1[2]);
  fulladder(pass[3]&b[state],sum1[3],cout1[2],sum2[2],cout1[3]);
  fulladder(pass[4]&b[state],sum1[4],cout1[3],sum2[3],cout1[4]);
  fulladder(pass[5]&b[state],sum1[5],cout1[4],sum2[4],cout1[5]);
  fulladder(pass[6]&b[state],sum1[6],cout1[5],sum2[5],cout1[6]);
  fulladder(pass[7]&b[state],sum1[7],cout1[6],sum2[6],cout1[7]);
  fulladder(pass[8]&b[state],sum1[8],cout1[7],sum2[7],cout1[8]);
  fulladder(pass[9]&b[state],sum1[9],cout1[8],sum2[8],cout1[9]);
  fulladder(pass[10]&b[state],sum1[10],cout1[9],sum2[9],cout1[10]);
  fulladder(pass[11]&b[state],sum1[11],cout1[10],sum2[10],cout1[11]);
  fulladder(pass[12]&b[state],sum1[12],cout1[11],sum2[11],cout1[12]);
  fulladder(pass[13]&b[state],sum1[13],cout1[12],sum2[12],cout1[13]);
  fulladder(pass[14]&b[state],sum1[14],cout1[13],sum2[13],cout1[14]);
  fulladder(pass[15]&b[state],sum1[15],cout1[14],sum2[14],cout1[15]);
  fulladder(pass[16]&b[state],sum1[16],cout1[15],sum2[15],cout1[16]);
  fulladder(pass[17]&b[state],sum1[17],cout1[16],sum2[16],cout1[17]);
  fulladder(pass[18]&b[state],sum1[18],cout1[17],sum2[17],cout1[18]);
  fulladder(pass[19]&b[state],sum1[19],cout1[18],sum2[18],cout1[19]);
  fulladder(pass[20]&b[state],sum1[20],cout1[19],sum2[19],cout1[20]);
  fulladder(pass[21]&b[state],sum1[21],cout1[20],sum2[20],cout1[21]);
  fulladder(pass[22]&b[state],sum1[22],cout1[21],sum2[21],cout1[22]);
  fulladder(pass[23]&b[state],sum1[23],cout1[22],sum2[22],cout1[23]);
  fulladder(pass[24]&b[state],sum1[24],cout1[23],sum2[23],cout1[24]);
  fulladder(pass[25]&b[state],sum1[25],cout1[24],sum2[24],cout1[25]);
  fulladder(pass[26]&b[state],sum1[26],cout1[25],sum2[25],cout1[26]);
  fulladder(pass[27]&b[state],sum1[27],cout1[26],sum2[26],cout1[27]);
  fulladder(pass[28]&b[state],sum1[28],cout1[27],sum2[27],cout1[28]);
  fulladder(pass[29]&b[state],sum1[29],cout1[28],sum2[28],cout1[29]);
  fulladder(pass[30]&b[state],sum1[30],cout1[29],sum2[29],cout1[30]);
  fulladder(cout1[31],pass[31]&b[state],cout1[30],sum2[30],cout1[31]);//consider
  state<=state+1;
  end


  if((state%2==0)&&(state!=0)&&(state!=31))
  begin
  fulladder(pass[0]&b[state],sum2[0],0,y[state],cout1[0]);//output y[state+1]
  fulladder(pass[0]&b[state],sum2[1],cout1[0],sum1[0],cout1[1]);//if output sum1[0] would affect y[state+1]
  fulladder(pass[2]&b[state],sum2[2],cout1[1],sum1[1],cout1[2]);
  fulladder(pass[3]&b[state],sum2[3],cout1[2],sum1[2],cout1[3]);
  fulladder(pass[4]&b[state],sum2[4],cout1[3],sum1[3],cout1[4]);
  fulladder(pass[5]&b[state],sum2[5],cout1[4],sum1[4],cout1[5]);
  fulladder(pass[6]&b[state],sum2[6],cout1[5],sum1[5],cout1[6]);
  fulladder(pass[7]&b[state],sum2[7],cout1[6],sum1[6],cout1[7]);
  fulladder(pass[8]&b[state],sum2[8],cout1[7],sum1[7],cout1[8]);
  fulladder(pass[9]&b[state],sum2[9],cout1[8],sum1[8],cout1[9]);
  fulladder(pass[10]&b[state],sum2[10],cout1[9],sum1[9],cout1[10]);
  fulladder(pass[11]&b[state],sum2[11],cout1[10],sum1[10],cout1[11]);
  fulladder(pass[12]&b[state],sum2[12],cout1[11],sum1[11],cout1[12]);
  fulladder(pass[13]&b[state],sum2[13],cout1[12],sum1[12],cout1[13]);
  fulladder(pass[14]&b[state],sum2[14],cout1[13],sum1[13],cout1[14]);
  fulladder(pass[15]&b[state],sum2[15],cout1[14],sum1[14],cout1[15]);
  fulladder(pass[16]&b[state],sum2[16],cout1[15],sum1[15],cout1[16]);
  fulladder(pass[17]&b[state],sum2[17],cout1[16],sum1[16],cout1[17]);
  fulladder(pass[18]&b[state],sum2[18],cout1[17],sum1[17],cout1[18]);
  fulladder(pass[19]&b[state],sum2[19],cout1[18],sum1[18],cout1[19]);
  fulladder(pass[20]&b[state],sum2[20],cout1[19],sum1[19],cout1[20]);
  fulladder(pass[21]&b[state],sum2[21],cout1[20],sum1[20],cout1[21]);
  fulladder(pass[22]&b[state],sum2[22],cout1[21],sum1[21],cout1[22]);
  fulladder(pass[23]&b[state],sum2[23],cout1[22],sum1[22],cout1[23]);
  fulladder(pass[24]&b[state],sum2[24],cout1[23],sum1[23],cout1[24]);
  fulladder(pass[25]&b[state],sum2[25],cout1[24],sum1[24],cout1[25]);
  fulladder(pass[26]&b[state],sum2[26],cout1[25],sum1[25],cout1[26]);
  fulladder(pass[27]&b[state],sum2[27],cout1[26],sum1[26],cout1[27]);
  fulladder(pass[28]&b[state],sum2[28],cout1[27],sum1[27],cout1[28]);
  fulladder(pass[29]&b[state],sum2[29],cout1[28],sum1[28],cout1[29]);
  fulladder(pass[30]&b[state],sum2[30],cout1[29],sum1[29],cout1[30]);
  fulladder(cout1[31],pass[31]&b[state],cout1[30],sum1[30],cout1[31]);//consider
  state<=state+1;
  end
end*/
