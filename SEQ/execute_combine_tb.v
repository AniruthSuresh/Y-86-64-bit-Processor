`include "fetch.v"
`include "decode_wb.v"
// `include "execute_mine.v"


module execute_tb();

    //Inputs
    reg clk;
    reg [63:0]PC;

    //Outputs
    wire [3:0] icode,ifun,rA,rB;
    wire signed[63:0] ValC;
    wire  [63:0]ValP;
    wire signed [63:0]ValA,ValB,ValE;
    wire signed [63:0]ValM;
    wire ZF,OF,SF,Cnd; 
    wire instr_valid , imem_error ,halt ;


    reg [7:0] inst_memory[0:255];//memory that contains all the instructions
    reg [0:79] instr; //instruction with 10bytes


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


    // Combining all the modules till now 

    fetch fetch_call(icode , ifun , rA, rB, ValC, ValP, instr_valid,imem_error,halt,clk,PC,instr);


    decode_wb decode_call(icode,rA,rB,ValA,ValB,rax,rcx,rdx,rbx,rsp,rbp,rsi,rdi,r8,r9,r10,r11,r12,r13,r14,clk,ValM,ValE,Cnd);


    execute execute_call(clk, icode, ifun, ValA, ValB, ValC, ZF, SF, OF, Cnd, ValE);



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
            $display("Given instruction is invalid at PC = %5d\n",PC);            
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


    initial begin
        $dumpfile("execute_combine.vcd");
        $dumpvars(0, execute_tb);
        clk = 0;
        PC = 64'd1;

    end

    always @(posedge clk) begin 
        $display("time = %5d\nPC=%5d\nclk=%d\nicode=%h\nifun=%h\nrA=%d\nrB=%d\nValC=%d\nValP=%d\nValA = %d\n ValB = %d\nValE = %d\nZF = %5d\nSF = %5d\n OF = %5d\n Cnd = %b\n\n",$time,PC,clk,icode,ifun,rA,rB,ValC,ValP,ValA,ValB,ValE,ZF,SF,OF,Cnd); 
    end
 

    initial begin

        // CASE 1 : nop
        inst_memory[1]  = 8'h10;


        // CASE 2 : addq 
        inst_memory[2] = 8'h60; 
        inst_memory[3] = 8'h15; // rcx+rbp = 100+4 = 104

        // CASE 3 : cmovxx 
        inst_memory[4] = 8'h26; //cmovg 
        inst_memory[5] = 8'hAB; // r10 to r11 
        
        // CASE 4 : irmovq 
        inst_memory[6] = 8'h30;
        inst_memory[7] = 8'hF2; // rdx 
        {inst_memory[15],inst_memory[14],inst_memory[13],inst_memory[12],inst_memory[11],inst_memory[10],inst_memory[9],inst_memory[8]} = 64'd120;

        // CASE 5 : rmmovq 
        inst_memory[16] = 8'h40;//rmmovq
        inst_memory[17] = 8'h34; // rbx into the memory displaced  -> mem[2] is occupied 
        {inst_memory[25],inst_memory[24],inst_memory[23],inst_memory[22],inst_memory[21],inst_memory[20],inst_memory[19],inst_memory[18]} = 64'd2;

        // CASE 6 : mrmovq
        inst_memory[26] = 8'h50;
        inst_memory[27] = 8'h27; // rb = rdi = 0 , so mem[2] is written into rdx 
        {inst_memory[35],inst_memory[34],inst_memory[33],inst_memory[32],inst_memory[31],inst_memory[30],inst_memory[29],inst_memory[28]} = 64'd0; // memory is not connected yet ( so shows z )

        // CASE 7 : jxx 
        inst_memory[36] = 8'h70; // unconditional 
        {inst_memory[44],inst_memory[43],inst_memory[42],inst_memory[41],inst_memory[40],inst_memory[39],inst_memory[38],inst_memory[37]} = 64'd65; // no jump as PC_update is not connected yet 

        // CASE 8 : Call 
        inst_memory[45] = 8'h80;
        {inst_memory[53],inst_memory[52],inst_memory[51],inst_memory[50],inst_memory[49],inst_memory[48],inst_memory[47],inst_memory[46]} = 64'd54; // no jump as PC_update is not connected yet 

        // CASE 9 : ret  
        inst_memory[54] = 8'h90;  

        // CASE 10 : pushq
        inst_memory[55] = 8'hA0; 
        inst_memory[56] = 8'h3F; // rbx into the stack 

        // CASE 11 : popq
        inst_memory[57] = 8'hB0; 
        inst_memory[58] = 8'h5F; // push it into rbp 

        // CASE 12 : halt 
        inst_memory[59] = 8'h00;

    end



endmodule   