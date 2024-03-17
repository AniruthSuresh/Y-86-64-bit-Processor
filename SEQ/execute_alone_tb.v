

module execute_alone_tb();

    //Inputs 
    reg clk;
    reg [3:0] icode,ifun;
    reg [63:0] ValA,ValB,ValC;

    //Outputs 

    wire ZF,OF,SF,Cnd;
    wire signed [63:0] ValE;

    initial
    begin
        $dumpfile("execute_alone_tb.vcd");
        $dumpvars(0, execute_alone_tb);
    end

    execute test_exe_alone(clk, icode, ifun, ValA, ValB, ValC, ZF, SF, OF, Cnd, ValE);

    
    initial begin


        // CASE : 1 :halt 
        icode = 4'b0000;
        ifun = 4'b0000;


        #20
        // CASE : 2 : nop 
        icode = 4'b0001;
        ifun = 4'b0000;
        

        #20
        // CASE : 3 : OPq (subq) 
        // X is ValB second argu i.e it does x-y -> ValB-ValA
        icode = 4'b0110;
        ifun = 4'b0001; // subq
        ValA = 64'd800;
        ValB = 64'd600;
        

        #20
        // CASE : 4 : cmovXX (subq)  ( B less than A )
        icode = 4'b0010;
        ifun = 4'b0010; // cmovl 


        #20
        // CASE : 5 : irmovq
        icode = 4'b0011;
        ifun = 4'b0000;
        ValC = 64'd699;


        #20
        // CASE : 6 : mrmovq
        icode = 4'b0101;
        ifun = 4'b0000;
        ValC = 64'd100;
        ValB = 64'd120;
        

        #20
        // CASE : 7 : rmmovq
        icode = 4'b0100;
        ifun = 4'b0000;
        ValC = 64'd110;
        ValB = 64'd150;
        

        // CASE : 8 : addq
        #20
        icode = 4'b110;
        ifun = 4'b0000; 
        ValA = 64'd200;
        ValB = 64'd300;


        #20
        // CASE :9 : jmp always (70)
        icode = 4'b0111;
        ifun = 4'b0000; // jmp
        ValC = 64'd85;
 


        #20
        // CASE : 10 : call 
        icode = 4'b1000;
        ifun = 4'b0000;
        ValB = 64'd550;


        #20
        // CASE : 11 : ret 
        icode = 4'b1001;
        ifun = 4'b0000;
        ValB = 64'd450;


        #20
        // CASE : 12 : pushq 
        icode = 4'b1010;
        ifun = 4'b0000;
        ValB = 64'd500;

        #20
        // CASE : 13 : popq 
        icode = 4'b1011;
        ifun = 4'b0000;
        ValB = 64'd130;
    end

    initial begin
        $monitor("time = %0t\n\nicode = %d\nifun = %d\nValC = %d\nValA = %d\nValB = %d\nCnd = %d\nValE = %d\nZF = %d\nOF = %d\nSF = %d\n",$time, icode, ifun, ValC, ValA, ValB, Cnd, ValE, ZF, OF, SF); 
    end

endmodule
