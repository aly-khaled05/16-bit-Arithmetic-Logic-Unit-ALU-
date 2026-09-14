module MUX_3_to_1(I1,I2,I3,sel,Out);  //parameterzied mux for both results(16-bits) and status(6-bits) 
parameter data_size=16;               //default data size
input [data_size-1:0] I1,I2,I3;
input [1:0] sel;
output reg [data_size-1:0] Out;
always @(*) begin
  case(sel)
  2'b00:Out=I1;
  2'b01:Out=I2;
  2'b10:Out=I3;
  default:Out=0;
  endcase
end
endmodule
//Arithmetic Block
module Arithmetic_block (X,Y,Cin,control_lines,OUT,C,Z,N,V,P,A);
input [15:0] X,Y;
input Cin;
input [2:0] control_lines;
output reg [15:0] OUT;
output reg  C,Z,N,V,P,A;
reg [16:0] out_with_carry;
reg [15:0] carryout14_bus;                       //The least significant 14 bits to compute a carry-out (carry-into MSB) to compute The overflow flag(V).
reg carryout_of_bit_14;                          //carry-into the MSB.
reg [4:0] summation_first_4bits_with_carry;      //The least significant 4 bits used to compute the Auxillary flag(A).
reg [4:0] subtraction_first_4bits;               //The least significant 4 bits used to compute the Auxillary flag(A).
//Arithmetic block
always @(*) begin              
    case(control_lines)
    3'b001: begin              //Increment operation 
        OUT=X+1;
        C=&X;                 
        Z=~|OUT;              
        N=OUT[15];             
        V=OUT[15]^X[15];       
        P=~^OUT;               
        A=&X[3:0];              
    end
    3'b011: begin             //Decrement operation
        OUT=X-1;
        C=~|X;
        Z=~|OUT;
        N=OUT[15];
        V=OUT[15]^X[15];
        P=~^OUT;
        A=~|X[3:0];
    end
    3'b100: begin             //ADD operation
        out_with_carry={1'b0,X[15:0]} + {1'b0,Y[15:0]};
        OUT=out_with_carry[15:0];
        C=out_with_carry[16];
        carryout14_bus={1'b0,X[14:0]}+ {1'b0,Y[14:0]};
        carryout_of_bit_14=carryout14_bus[15];
        Z=~|OUT;
        N=OUT[15];
        V=carryout_of_bit_14 ^ C;
        P=~^OUT;
        summation_first_4bits_with_carry={1'b0,X[3:0]} +{1'b0,Y[3:0]};
        A=summation_first_4bits_with_carry[4]; 
    end
    3'b101: begin             //ADD With Carry operation
        out_with_carry={1'b0,X[15:0]} + {1'b0,Y[15:0]} + Cin;
        OUT=out_with_carry[15:0];
        C=out_with_carry[16];
        Z=~|OUT;
        N=OUT[15];
        carryout14_bus={1'b0,X[14:0]}+ {1'b0,Y[14:0]};
        carryout_of_bit_14=carryout14_bus[15];
        V=carryout_of_bit_14 ^ C;
        P=~^OUT;
        summation_first_4bits_with_carry={1'b0,X[3:0]} +{1'b0,Y[3:0]}+ Cin;
        A=summation_first_4bits_with_carry[4]; 
    end
    3'b110: begin            //SUB
        out_with_carry={1'b0,X[15:0]}-{1'b0,Y[15:0]};
        OUT=out_with_carry[15:0];
        C=out_with_carry[16];
        carryout14_bus={1'b0,X[14:0]} - {1'b0,Y[14:0]};
        carryout_of_bit_14=carryout14_bus[15];
        Z=~|OUT;
        N=OUT[15];
        V=carryout_of_bit_14 ^ C;
        P=~^OUT;
        subtraction_first_4bits={1'b0,X[3:0]}-{1'b0,Y[3:0]};
        A=subtraction_first_4bits[4]; 
    end
    3'b111: begin           //SUB_BORROW
        out_with_carry={1'b0,X[15:0]}-{1'b0,Y[15:0]} - Cin;
        OUT=out_with_carry[15:0];
        C=out_with_carry[16];
        carryout14_bus={1'b0,X[14:0]} - {1'b0,Y[14:0]} - Cin;
        carryout_of_bit_14=carryout14_bus[15];
        Z=~|OUT;
        N=OUT[15];
        V=carryout_of_bit_14 ^ C;
        P=~^OUT;
        subtraction_first_4bits={1'b0,X[3:0]}-{1'b0,Y[3:0]} - Cin;
        A=subtraction_first_4bits[4]; 
    end
    endcase
end
endmodule
//logic block
module logic_block(X,Y,control_lines,OUT,C,Z,N,V,P,A);
input [15:0] X,Y;
input [2:0] control_lines;
output reg [15:0] OUT;
output reg C,Z,N,V,P,A;
always @(*) begin
    C=1'bx;             //Unused flag
    V=1'bx;             //Unused flag
    A=1'bx;             //Unused flag
    case(control_lines)
    3'b000:OUT=X&Y;        //AND
    3'b001:OUT=X|Y;        //OR 
    3'b010:OUT=X^Y;        //XOR
    3'b011:OUT=~X;         //NOT
    default:OUT=16'b0;
    endcase
    Z=~|OUT;
    N=OUT[15];
    P=~^OUT;
end
endmodule
//shift block
module shift_block(X,control_lines,Cin,OUT,C,Z,N,V,P,A);
input [15:0] X;
input[2:0] control_lines;
input Cin;
output reg [15:0] OUT;
output reg C,Z,N,V,P,A;
reg MSB;
reg LSB;
always @(*) begin
    case(control_lines)
    3'b000: begin                 //SHL
        C=X[15];
        OUT={X[14:0],1'b0};
    end
    3'b001: begin                 //SHR
        C=X[0];  
        OUT={1'b0,X[15:1]};
    end
    3'b010: begin                 //SAL
        C=X[15]; 
        OUT={X[14:0],1'b0};
    end
    3'b011: begin                 //SAR
        C=X[0];   
        OUT={X[15],X[15:1]};
    end
    3'b100: begin                 //ROL
        C=X[15]; 
        OUT={X[14:0],X[15]};
    end
    3'b101: begin                 //ROR
        C=X[0];  
        OUT={X[0],X[15:1]};
    end
    3'b110: begin                 //RCL
        MSB=X[15]; 
        OUT={X[14:0],Cin}; 
        C= MSB;
    end
    3'b111: begin                 //RCR
        LSB=X[0];
        OUT={Cin,X[15:1]}; 
        C=LSB;
    end
    default: begin
        C=0; 
        OUT=16'b0;
    end
    endcase
    Z=~|OUT;
    N=OUT[15];
    P=~^OUT;
    V=1'bx;                      //Unused flag
    A=1'bx;                      //Unused flag
end
endmodule
module ALU (A,B,F,Cin,Result,Status);
//INPUTS
input [15:0] A,B;
input [4:0] F;
input Cin;
//OUTPUTS
output [15:0] Result;
output [5:0] Status;
//INTERNAL SIGNALS
wire [15:0] arithmetic_out;
wire [15:0] logic_out;
wire [15:0] shift_out;
wire [5:0] arithmetic_status;
wire [5:0] logic_status;
wire [5:0] shift_status;
//ALU BLOCKS 
Arithmetic_block Arithmetic (.X(A),.Y(B),.Cin(Cin),.control_lines(F[2:0]),.OUT(arithmetic_out),.C(arithmetic_status[5]),.Z(arithmetic_status[4]),.N(arithmetic_status[3]),.V(arithmetic_status[2]),.P(arithmetic_status[1]),.A(arithmetic_status[0]));
logic_block Logic (.X(A),.Y(B),.control_lines(F[2:0]),.OUT(logic_out),.C(logic_status[5]),.Z(logic_status[4]),.N(logic_status[3]),.V(logic_status[2]),.P(logic_status[1]),.A(logic_status[0]));
shift_block Shift (.X(A),.control_lines(F[2:0]),.Cin(Cin),.OUT(shift_out),.C(shift_status[5]),.Z(shift_status[4]),.N(shift_status[3]),.V(shift_status[2]),.P(shift_status[1]),.A(shift_status[0]));
MUX_3_to_1 mux_operation    (.I1(arithmetic_out),.I2(logic_out),.I3(shift_out),.sel(F[4:3]),.Out(Result));
MUX_3_to_1 #(6) mux_status       (.I1(arithmetic_status),.I2(logic_status),.I3(shift_status),.sel(F[4:3]),.Out(Status));
endmodule

    
    

        
        



        

        
       
        
    
    





