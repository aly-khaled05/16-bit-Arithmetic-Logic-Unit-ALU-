module ALU_tb();
reg [15:0] A_tb,B_tb;
reg Cin_tb;
reg [4:0] F_tb;
reg [15:0] result_expected;
reg [5:0] status_expected;
wire [15:0] result_dut;
wire [5:0] status_dut;

ALU  DUT (A_tb,B_tb,F_tb,Cin_tb,result_dut,status_dut);
initial begin
    //Testing Arithmetic block
    //Testing Increment operation
    A_tb=16'b0001_1110_0001_0011;
    F_tb=5'b00001;
    #10;
    result_expected=16'b0001_1110_0001_0100;
    status_expected=6'b000010;
    if((result_expected==result_dut) && (status_expected==status_dut)) begin
        $display("CORRECT OUTPUT,INCREMENT operation is working well");
    end
    else begin
        $display("ERROR-INCORRECT OUTPUT,INCREMENT operation failed.");
        $stop;
    end
    //Testing Decrement operation
    A_tb=16'b1101_0110_0101_0011;
    F_tb=5'b00011;
    #10;
    result_expected=16'b1101_0110_0101_0010;
    status_expected=6'b001010;
    if((result_expected==result_dut) && (status_expected==status_dut)) begin
        $display("CORRECT OUTPUT,DECREMENT operation is working well");
    end
    else begin
        $display("ERROR-INCORRECT OUTPUT,DECREMENT operation failed.");
        $stop;
    end
    //Testing ADD operation
    A_tb=16'b1111_1111_1111_1100;
    B_tb=16'b1111_1111_1111_0111;
    F_tb=5'b00100;
    #10;
    result_expected=16'b1111_1111_1111_0011;
    status_expected=6'b101011;
    if((result_expected==result_dut) && (status_expected==status_dut)) begin
        $display("CORRECT OUTPUT,ADD operation is working well");
    end
    else begin
        $display("ERROR-INCORRECT OUTPUT,ADD operation failed.");
        $stop;
    end
    //Testing ADD WITH CARRYIN operation
    A_tb=16'b1001_1111_0011_0101;
    B_tb=16'b0110_0001_1111_0111;
    F_tb=5'b00101;
    Cin_tb=1;
    #10;
    result_expected=16'b0000_0001_0010_1101;
    status_expected=6'b100000;
    if((result_expected==result_dut) && (status_expected==status_dut)) begin
        $display("CORRECT OUTPUT,ADD_CARRY operation is working well");
    end
    else begin
        $display("ERROR-INCORRECT OUTPUT,ADD_CARRY operation failed.");
        $stop;
    end
    //Testing SUB operation
    A_tb=16'b0001_1100_1101_0010;
    B_tb=16'b1011_1001_0000_1110;
    F_tb=5'b00110;
    #10;
    result_expected=16'b0110_0011_1100_0100;
    status_expected=6'b100001;
    if((result_expected==result_dut) && (status_expected==status_dut)) begin
        $display("CORRECT OUTPUT,SUB operation is working well");
    end
    else begin
        $display("ERROR-INCORRECT OUTPUT,SUB operation failed.");
        $stop;
    end
    //Testing SUB WITH BORROW operation
    A_tb=16'b0001_1100_0001_0011;
    B_tb=16'b1011_1001_1111_0010;
    F_tb=5'b00111;
    Cin_tb=1;
    #10;
    result_expected=16'b0110_0010_0010_0000;
    status_expected=6'b100010;
    if((result_expected==result_dut) && (status_expected==status_dut))  begin
        $display("CORRECT OUTPUT,SUB_BORROW operation is working well");
    end
    else begin
        $display("ERROR-INCORRECT OUTPUT,SUB_BORROW operation failed.");
        $stop;
    end
    //Testing logic block
    //Testing AND operation
    A_tb=16'b0001_1100_1101_0010;
    B_tb=16'b1011_1001_0000_1110;
    F_tb=5'b01000;
    #10;
    result_expected=16'b0001_1000_0000_0010;
    status_expected[4]=0; status_expected[3]=0; status_expected[1]=0;
    if((result_dut==result_expected) && (status_expected[4]==status_dut[4]) && (status_expected[3]==status_dut[3]) && (status_expected[1]==status_dut[1])) begin
        $display("CORRECT OUTPUT,AND operation is working well.");
    end
    else begin
        $display("ERROR-INCORRECT OUTPUT,AND operation failed.");
        $stop;
    end
    //Testing OR operation
    A_tb=16'b1010_1111_0001_1001;
    B_tb=16'b0101_0101_1111_0010;
    F_tb=5'b01001;
    #10;
    result_expected=16'b1111_1111_1111_1011;
    status_expected[4]=0; status_expected[3]=1; status_expected[1]=0;
    if((result_dut==result_expected) && (status_expected[4]==status_dut[4]) && (status_expected[3]==status_dut[3]) && (status_expected[1]==status_dut[1])) begin
        $display("CORRECT OUTPUT,OR operation is working well.");
    end
    else begin
        $display("ERROR-INCORRECT OUTPUT,OR operation failed.");
        $stop;
    end
    //Testing XOR operation
    A_tb=16'b0101_1000_1001_1010;
    B_tb=16'b1001_1011_1000_1110;
    F_tb=5'b01010;
    #10;
    result_expected=16'b1100_0011_0001_0100;
    status_expected[4]=0; status_expected[3]=1; status_expected[1]=1;
    if((result_dut==result_expected) && (status_expected[4]==status_dut[4]) && (status_expected[3]==status_dut[3]) && (status_expected[1]==status_dut[1])) begin
        $display("CORRECT OUTPUT,XOR operation is working well.");
    end
    else begin
        $display("ERROR-INCORRECT OUTPUT,XOR operation failed.");
        $stop;
    end
    //Testing NOT operation
    A_tb=16'b0111_1011_1001_0010;
    F_tb=5'b01011;
    #10;
    result_expected=16'b1000_0100_0110_1101;
    status_expected[4]=0; status_expected[3]=1; status_expected[1]=0;
    if((result_dut==result_expected) && (status_expected[4]==status_dut[4]) && (status_expected[3]==status_dut[3]) && (status_expected[1]==status_dut[1])) begin
        $display("CORRECT OUTPUT,NOT operation is working well.");
    end
    else begin
        $display("ERROR-INCORRECT OUTPUT,NOT operation failed.");
        $stop;
    end
    //Testing Shift Block
    //Testing SHL
    A_tb=16'b0011_0100_1111_0010;
    F_tb=5'b10000;
    #10;
    result_expected=16'b0110_1001_1110_0100;
    status_expected[5]=0; status_expected[4]=0; status_expected[3]=0; status_expected[1]=1; 
    if((result_dut==result_expected) && (status_expected[5]==status_dut[5]) && (status_expected[4]==status_dut[4]) && (status_expected[3]==status_dut[3]) && (status_expected[1]==status_dut[1])) begin
        $display("CORRECT OUTPUT,SHL operation is working well");
    end
    else begin
        $display("ERROR-INCORRECT OUTPUT,SHL operation failed.");
        $stop;
    end
    //Testing SHR
    A_tb=16'b1011_1001_1011_0011;
    F_tb=5'b10001;
    #10;
    result_expected=16'b0101_1100_1101_1001;
    status_expected[5]=1; status_expected[4]=0; status_expected[3]=0; status_expected[1]=0; 
    if((result_dut==result_expected) && (status_expected[5]==status_dut[5]) && (status_expected[4]==status_dut[4]) && (status_expected[3]==status_dut[3]) && (status_expected[1]==status_dut[1]))begin
        $display("CORRECT OUTPUT,SHR operation is working well");
    end
    else begin
        $display("ERROR-INCORRECT OUTPUT,SHR operation failed.");
        $stop;
    end
    //Testing SAL
    A_tb=16'b1010_1101_0011_0000;
    F_tb=5'b10010;
    #10;
    result_expected=16'b0101_1010_0110_0000;
    status_expected[5]=1; status_expected[4]=0; status_expected[3]=0; status_expected[1]=1; 
    if((result_dut==result_expected) && (status_expected[5]==status_dut[5]) && (status_expected[4]==status_dut[4]) && (status_expected[3]==status_dut[3]) && (status_expected[1]==status_dut[1])) begin
        $display("CORRECT OUTPUT,SAL operation is working well");
    end
    else begin
        $display("ERROR-INCORRECT OUTPUT,SAL operation failed.");
        $stop;
    end
    //Testing SAR
    A_tb=16'b1010_0001_1011_0100;
    F_tb=5'b10011;
    #10;
    result_expected=16'b1101_0000_1101_1010;
    status_expected[5]=0; status_expected[4]=0; status_expected[3]=1; status_expected[1]=1; 
    if((result_dut==result_expected) && (status_expected[5]==status_dut[5]) && (status_expected[4]==status_dut[4]) && (status_expected[3]==status_dut[3]) && (status_expected[1]==status_dut[1])) begin
        $display("CORRECT OUTPUT,SAR operation is working well");
    end
    else begin
        $display("ERROR-INCORRECT OUTPUT,SAR operation failed.");
        $stop;
    end
    //Testing ROL
    A_tb=16'b0010_1111_1010_0101;
    F_tb=5'b10100;
    #10;
    result_expected=16'b0101_1111_0100_1010;
    status_expected[5]=0; status_expected[4]=0; status_expected[3]=0; status_expected[1]=0; 
    if((result_dut==result_expected) && (status_expected[5]==status_dut[5]) && (status_expected[4]==status_dut[4]) && (status_expected[3]==status_dut[3]) && (status_expected[1]==status_dut[1])) begin
        $display("CORRECT OUTPUT,ROL operation is working well");
    end
    else begin
        $display("ERROR-INCORRECT OUTPUT,ROL operation failed.");
        $stop;
    end
    //Testing ROR
    A_tb=16'b1011_1100_0011_1000;
    F_tb=5'b10101;
    #10;
    result_expected=16'b0101_1110_0001_1100;
    status_expected[5]=0; status_expected[4]=0; status_expected[3]=0; status_expected[1]=1; 
    if((result_dut==result_expected) && (status_expected[5]==status_dut[5]) && (status_expected[4]==status_dut[4]) && (status_expected[3]==status_dut[3]) && (status_expected[1]==status_dut[1])) begin
        $display("CORRECT OUTPUT,ROR operation is working well");
    end
    else begin
        $display("ERROR-INCORRECT OUTPUT,ROR operation failed.");
        $stop;
    end
    //Testing RCL
    A_tb=16'b1000_0000_0000_0000;
    F_tb=5'b10110;
    Cin_tb=0;
    #10;
    result_expected=16'b0000_0000_0000_0000;
    status_expected[5]=1; status_expected[4]=1; status_expected[3]=0; status_expected[1]=1; 
    if((result_dut==result_expected) && (status_expected[5]==status_dut[5]) && (status_expected[4]==status_dut[4]) && (status_expected[3]==status_dut[3]) && (status_expected[1]==status_dut[1])) begin
        $display("CORRECT OUTPUT,RCL operation is working well");
    end
    else begin
        $display("ERROR-INCORRECT OUTPUT,RCL operation failed.");
        $stop;
    end
    //Testing RCR
    A_tb=16'b1000_0110_0000_0001;
    F_tb=5'b10111;
    Cin_tb=1;
    #10;
    result_expected=16'b1100_0011_0000_0000;
    status_expected[5]=1; status_expected[4]=0; status_expected[3]=1; status_expected[1]=1; 
    if((result_dut==result_expected) && (status_expected[5]==status_dut[5]) && (status_expected[4]==status_dut[4]) && (status_expected[3]==status_dut[3]) && (status_expected[1]==status_dut[1])) begin
        $display("CORRECT OUTPUT,RCR operation is working well");
    end
    else begin
        $display("ERROR-INCORRECT OUTPUT,RCR operation failed.");
        $stop;
    end
    $display("Your ALU is ready!!!");
    $stop;
end
endmodule