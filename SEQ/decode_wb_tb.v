`include "fetch.v"

module decode_wb_tb;

    //Input Reg
    reg clk ; 
    reg [63:0]PC;

    // Condition signal 
    wire Cnd=1; 
    wire instr_valid , imem_error , halt ;


    //Output 
    reg [63:0] ValM,ValE;
    
    wire signed[63:0] ValA, ValB,ValC;
    wire [3:0] icode,ifun,rA,rB;
    wire  [63:0]ValP;

    //Instr memory 
    reg [7:0] inst_memory[0:1023];
    

    //Each instr max length = 80 bits 
    reg [0:79] instr ;

    //Register File 
    wire [63:0] rax;  
    wire [63:0] rcx;
    wire [63:0] rdx;
    wire [63:0] rbx;
    wire [63:0] rsp;
    wire [63:0] rbp;
    wire [63:0] rsi;
    wire [63:0] rdi;
    wire [63:0] r8;
    wire [63:0] r9;
    wire [63:0] r10;
    wire [63:0] r11;
    wire [63:0] r12;
    wire [63:0] r13;
    wire [63:0] r14;

    initial

    begin
        $dumpfile("decode_wb_tb.vcd");
        $dumpvars(0, decode_wb_tb);
        clk = 1'b0;
        PC = 64'd0;
    end
    

    // Consider some random value of ValE , ValM for now 
    // Will be modified when Memory and Execute blocks are added 

    initial begin  
        ValE = 64'd99;
        ValM = 64'd299;
    end


    // Setting up the instruction memory 
    initial begin

        //CASE - 1 : nop 
        inst_memory[0]  = 8'h10; 

        // CASE - 2: cmovxx
        inst_memory[1] = 8'h22;  // cmovl - 22
        inst_memory[2] = 8'hBC;  // r11 to r12 ( Cnd is given as 1 )

        // CASE - 3 : irmovq 
        inst_memory[3] = 8'h30; 
        inst_memory[4] = 8'hF2;   // F to rdx 
        {inst_memory[12],inst_memory[11],inst_memory[10],inst_memory[9],inst_memory[8],inst_memory[7],
        inst_memory[6],inst_memory[5]} = 64'd145;  // Imm value is 145 

        // CASE - 4 : rmmovq  rA , D(rB)
        inst_memory[13] = 8'h40; 
        inst_memory[14] = 8'h31;   // rbx to rcx 
        {inst_memory[22],inst_memory[21],inst_memory[20],inst_memory[19],inst_memory[18],inst_memory[17],
        inst_memory[16],inst_memory[15]} = 64'd12;  // Displace it by 12 

        // CASE - 5 : mrmovq  D(rB), rA
        inst_memory[23] = 8'h50; 
        inst_memory[24] = 8'hCD;   // rA = r12 and rB = r13
        {inst_memory[32],inst_memory[31],inst_memory[30],inst_memory[29],inst_memory[28],inst_memory[27],
        inst_memory[26],inst_memory[25]} = 64'd18;  // Displace it by 18

        // CASE - 6: OPq
        inst_memory[33] = 8'h63;  //63 is xorq   
        inst_memory[34] = 8'h12;  // rcx to rdx 

        // CASE - 7 : jXX 
        inst_memory[35] = 8'h73;  //je
        {inst_memory[43],inst_memory[42],inst_memory[41],inst_memory[40],inst_memory[39],inst_memory[38],inst_memory[37],
        inst_memory[36]} = 64'd50;  // Jump destination is 50 

        // CASE - 8 : call
        inst_memory[44] = 8'h80;    // good test case ( ValB shoudl be 10 with clock syncing , else will be 99 )
        {inst_memory[52],inst_memory[51],inst_memory[50],inst_memory[49],inst_memory[48],inst_memory[47],inst_memory[46],
        inst_memory[45]} = 64'd60;  // Jump destination is 60

        // CASE - 9: ret 
        inst_memory[53] = 8'h90;

        // CASE - 10: pushq
        inst_memory[54] = 8'hA0; 
        inst_memory[55] = 8'h0F; // push into rax 

        // CASE - 11: popq
        inst_memory[56] = 8'hB0; 
        inst_memory[57] = 8'h5F; // push into rbp 

        // CASE - 12 : halt 
        inst_memory[58] = 8'h00; //halt   
    end




    // FETCH first
    fetch test_fetch(icode, ifun, rA, rB, ValC, ValP, inst_valid, imem_error, halt,clk,PC,instr);

    // Decode after fetching 
    decode_wb test_dec_wb(icode,rA,rB,ValA,ValB,rax,rcx,rdx,rbx,rsp,rbp,rsi,rdi,r8,r9,r10,r11,r12,r13,r14,clk,ValM,ValE,Cnd);
    


    always @(PC) begin
    instr = {inst_memory[PC],inst_memory[PC+1],inst_memory[PC+2],
            inst_memory[PC+3],inst_memory[PC+4],inst_memory[PC+5],
            inst_memory[PC+6],inst_memory[PC+7],inst_memory[PC+8],
            inst_memory[PC+9]};  
    end

    initial begin
        repeat (25) #10 clk = ~clk;
    end

    always @(posedge clk) begin
        PC <=ValP;
    end

    //Displaying Error bits 
    always@(instr_valid) begin 
        if(instr_valid == 0)begin
            $display("Given instruction is invalid at PC=%5d\n",PC);            
            // PC = PC +1;
            // $display("Updated PC =%5d\n\n",PC);
        end
    end


    always@(icode) begin 
        if(halt == 1)begin
            $display("Program ended at PC = %5d as halt = 1",PC);
            $finish;
        end
    end

    always@(imem_error) begin 
        if(imem_error == 1)begin 
            $display("Accessing an invalid address");
            $finish;
        end
    end


    //Display at the posedge of the clock 

    always @(posedge clk)begin 
        $display("time = %0t\n\nPC = %5d\nicode = %5d\nifun=%5d\nrA = %5d\nrB = %5d\nCnd = %5d\nValA = %5d\nValB = %5d\nValC = %5d\nValP = %5d\nrax = %5d\nrcx = %5d\nrdx = %5d\nrbx = %5d\nrsp = %5d\nrbp = %5d\nrsi = %5d\nrdi = %5d\nr8 = %5d\nr9 = %5d\nr10 = %5d\nr11 = %5d\nr12 = %5d\nr13 = %5d\nr14 = %5d\n\n",$time, PC,icode,ifun, rA, rB, Cnd, ValA, ValB, ValC,ValP,rax,rcx,rdx,rbx,rsp,rbp,rsi,rdi,r8,r9,r10,r11,r12,r13,r14); 
    end

    // $display("clk=%d icode=%h ifun=%h rA=%d rB=%d,valc=%d,valP=%d,valA = %d and valB = %d\n",clk,icode,ifun,rA,rB,ValC,ValP,ValA,ValB); end

    
    // initial begin
    //     //test cmovxx
        
    //     icode = 4'b0010;
    //     rA = 4'b0011; // register 3
    //     rB = 4'b1010; // register 10
    //     Cnd = 1'b1;
    //     ValE = 64'd101;
    //     ValM = 64'd102;
    //     #40
    //     // $display("time = %0t\n\nicode = %5d\nrA = %5d\nrB = %5d\nCnd = %5d\nValE =%5d\nValM = %5d\nValA = %5d\nValB = %5d\nrax = %5d\nrcx = %5d\nrdx = %5d\nrbx = %5d\nrsp = %5d\nrbp = %5d\nrsi = %5d\nrdi = %5d\nr8 = %5d\nr9 = %5d\nr10 = %5d\nr11 = %5d\nr12 = %5d\nr13 = %5d\nr14 = %5d\n\n",$time, icode, rA, rB, Cnd , ValE,ValM, ValA, ValB, rax,rcx,rdx,rbx,rsp,rbp,rsi,rdi,r8,r9,r10,r11,r12,r13,r14); 

        
        
    //     icode = 4'b0010;
    //     rA = 4'b1001; // register 9
    //     rB = 4'b1011; // register 11
    //     Cnd = 1'b0;
    //     ValE = 64'd103;
    //     ValM = 64'd104;
    //     #40
    //     // $display("time = %0t\n\nicode = %5d\nrA = %5d\nrB = %5d\nCnd = %5d\nValE =%5d\nValM = %5d\nValA = %5d\nValB = %5d\nrax = %5d\nrcx = %5d\nrdx = %5d\nrbx = %5d\nrsp = %5d\nrbp = %5d\nrsi = %5d\nrdi = %5d\nr8 = %5d\nr9 = %5d\nr10 = %5d\nr11 = %5d\nr12 = %5d\nr13 = %5d\nr14 = %5d\n\n",$time, icode, rA, rB, Cnd , ValE,ValM, ValA, ValB, rax,rcx,rdx,rbx,rsp,rbp,rsi,rdi,r8,r9,r10,r11,r12,r13,r14); 

        
    
    //     //test irmovq
    //     icode = 4'b0011;
    //     rA = 4'b0011; // register 3
    //     rB = 4'b1010; // register 10
    //     ValE = 64'd201;
    //     ValM = 64'd202;
    //     #40
    //     // $display("time = %0t\n\nicode = %5d\nrA = %5d\nrB = %5d\nCnd = %5d\nValE =%5d\nValM = %5d\nValA = %5d\nValB = %5d\nrax = %5d\nrcx = %5d\nrdx = %5d\nrbx = %5d\nrsp = %5d\nrbp = %5d\nrsi = %5d\nrdi = %5d\nr8 = %5d\nr9 = %5d\nr10 = %5d\nr11 = %5d\nr12 = %5d\nr13 = %5d\nr14 = %5d\n\n",$time, icode, rA, rB, Cnd , ValE,ValM, ValA, ValB, rax,rcx,rdx,rbx,rsp,rbp,rsi,rdi,r8,r9,r10,r11,r12,r13,r14); 

        
    //     //test rmmovq
    //     icode = 4'b0100;
    //     rA = 4'b1001; // register 9
    //     rB = 4'b1011; // register 11
    //     ValE = 64'd301;
    //     ValM = 64'd302;
    //     #40
    //     // $display("time = %0t\n\nicode = %5d\nrA = %5d\nrB = %5d\nCnd = %5d\nValE =%5d\nValM = %5d\nValA = %5d\nValB = %5d\nrax = %5d\nrcx = %5d\nrdx = %5d\nrbx = %5d\nrsp = %5d\nrbp = %5d\nrsi = %5d\nrdi = %5d\nr8 = %5d\nr9 = %5d\nr10 = %5d\nr11 = %5d\nr12 = %5d\nr13 = %5d\nr14 = %5d\n\n",$time, icode, rA, rB, Cnd , ValE,ValM, ValA, ValB, rax,rcx,rdx,rbx,rsp,rbp,rsi,rdi,r8,r9,r10,r11,r12,r13,r14); 


    
    //     //test mrmovq
    //     icode = 4'b0101;
    //     rA = 4'b0011; // register 3
    //     rB = 4'b1010; // register 10
    //     ValE = 64'd401;
    //     ValM = 64'd402;
    //     #40
    //     // $display("time = %0t\n\nicode = %5d\nrA = %5d\nrB = %5d\nCnd = %5d\nValE =%5d\nValM = %5d\nValA = %5d\nValB = %5d\nrax = %5d\nrcx = %5d\nrdx = %5d\nrbx = %5d\nrsp = %5d\nrbp = %5d\nrsi = %5d\nrdi = %5d\nr8 = %5d\nr9 = %5d\nr10 = %5d\nr11 = %5d\nr12 = %5d\nr13 = %5d\nr14 = %5d\n\n",$time, icode, rA, rB, Cnd , ValE,ValM, ValA, ValB, rax,rcx,rdx,rbx,rsp,rbp,rsi,rdi,r8,r9,r10,r11,r12,r13,r14); 

    
    //     //test opq
    //     icode = 4'b0110;
    //     rA = 4'b1001; // register 9
    //     rB = 4'b1011; // register 11
    //     ValE = 64'd501;
    //     ValM = 64'd502;
    //     #40
    //     // $display("time = %0t\n\nicode = %5d\nrA = %5d\nrB = %5d\nCnd = %5d\nValE =%5d\nValM = %5d\nValA = %5d\nValB = %5d\nrax = %5d\nrcx = %5d\nrdx = %5d\nrbx = %5d\nrsp = %5d\nrbp = %5d\nrsi = %5d\nrdi = %5d\nr8 = %5d\nr9 = %5d\nr10 = %5d\nr11 = %5d\nr12 = %5d\nr13 = %5d\nr14 = %5d\n\n",$time, icode, rA, rB, Cnd , ValE,ValM, ValA, ValB, rax,rcx,rdx,rbx,rsp,rbp,rsi,rdi,r8,r9,r10,r11,r12,r13,r14); 

    //     //test call
    //     icode = 4'b1000;
    //     rA = 4'b0011; // register 3
    //     rB = 4'b1010; // register 10
    //     ValE = 64'd601;
    //     ValM = 64'd602;
    //     #40
    //     // $display("time = %0t\n\nicode = %5d\nrA = %5d\nrB = %5d\nCnd = %5d\nValE =%5d\nValM = %5d\nValA = %5d\nValB = %5d\nrax = %5d\nrcx = %5d\nrdx = %5d\nrbx = %5d\nrsp = %5d\nrbp = %5d\nrsi = %5d\nrdi = %5d\nr8 = %5d\nr9 = %5d\nr10 = %5d\nr11 = %5d\nr12 = %5d\nr13 = %5d\nr14 = %5d\n\n",$time, icode, rA, rB, Cnd , ValE,ValM, ValA, ValB, rax,rcx,rdx,rbx,rsp,rbp,rsi,rdi,r8,r9,r10,r11,r12,r13,r14); 

    //     //test ret
    //     icode = 4'b1001;
    //     rA = 4'b1001; // register 9
    //     rB = 4'b1011; // register 11
    //     ValE = 64'd701;
    //     ValM = 64'd702;
    //     #40
    //     // $display("time = %0t\n\nicode = %5d\nrA = %5d\nrB = %5d\nCnd = %5d\nValE =%5d\nValM = %5d\nValA = %5d\nValB = %5d\nrax = %5d\nrcx = %5d\nrdx = %5d\nrbx = %5d\nrsp = %5d\nrbp = %5d\nrsi = %5d\nrdi = %5d\nr8 = %5d\nr9 = %5d\nr10 = %5d\nr11 = %5d\nr12 = %5d\nr13 = %5d\nr14 = %5d\n\n",$time, icode, rA, rB, Cnd , ValE,ValM, ValA, ValB, rax,rcx,rdx,rbx,rsp,rbp,rsi,rdi,r8,r9,r10,r11,r12,r13,r14); 

    //     // test pushq
    //     icode = 4'b1010;
    //     rA = 4'b0011; // register 3
    //     rB = 4'b1010; // register 10
    //     ValE = 64'd801;
    //     ValM = 64'd802;
    //     #40
    //     // $display("time = %0t\n\nicode = %5d\nrA = %5d\nrB = %5d\nCnd = %5d\nValE =%5d\nValM = %5d\nValA = %5d\nValB = %5d\nrax = %5d\nrcx = %5d\nrdx = %5d\nrbx = %5d\nrsp = %5d\nrbp = %5d\nrsi = %5d\nrdi = %5d\nr8 = %5d\nr9 = %5d\nr10 = %5d\nr11 = %5d\nr12 = %5d\nr13 = %5d\nr14 = %5d\n\n",$time, icode, rA, rB, Cnd , ValE,ValM, ValA, ValB, rax,rcx,rdx,rbx,rsp,rbp,rsi,rdi,r8,r9,r10,r11,r12,r13,r14); 


    //     //test popq
    //     icode = 4'b1011;
    //     rA = 4'b1001; // register 9
    //     rB = 4'b1011; // register 11
    //     ValE = 64'd899;
    //     ValM = 64'd902;
    //     // $display("time = %0t\n\nicode = %5d\nrA = %5d\nrB = %5d\nCnd = %5d\nValE =%5d\nValM = %5d\nValA = %5d\nValB = %5d\nrax = %5d\nrcx = %5d\nrdx = %5d\nrbx = %5d\nrsp = %5d\nrbp = %5d\nrsi = %5d\nrdi = %5d\nr8 = %5d\nr9 = %5d\nr10 = %5d\nr11 = %5d\nr12 = %5d\nr13 = %5d\nr14 = %5d\n\n",$time, icode, rA, rB, Cnd , ValE,ValM, ValA, ValB, rax,rcx,rdx,rbx,rsp,rbp,rsi,rdi,r8,r9,r10,r11,r12,r13,r14); 

    // end

    // // initial
    // //     $monitor("time = %0t\n\nicode = %5d\nrA = %5d\nrB = %5d\nCnd = %5d\nValE =%5d\nValM = %5d\nValA = %5d\nValB = %5d\nrax = %5d\nrcx = %5d\nrdx = %5d\nrbx = %5d\nrsp = %5d\nrbp = %5d\nrsi = %5d\nrdi = %5d\nr8 = %5d\nr9 = %5d\nr10 = %5d\nr11 = %5d\nr12 = %5d\nr13 = %5d\nr14 = %5d\n\n",$time, icode, rA, rB, Cnd , ValE,ValM, ValA, ValB, rax,rcx,rdx,rbx,rsp,rbp,rsi,rdi,r8,r9,r10,r11,r12,r13,r14); 


endmodule