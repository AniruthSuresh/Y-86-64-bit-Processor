`include "fetch.v"
`include "decode_wb.v"
`include "execute.v"
`include "pc_update.v"
// `include "memory.v"
// Instead of separate testbench for memory file , we run the entire processor file !


module memory_tb();

    //Inputs
    reg clk;
    reg [63:0]PC;

    //Outputs
    wire[3:0] icode,ifun,rA,rB;
    wire signed[63:0] ValC;
    wire  [63:0]ValP;
    wire signed [63:0]ValA,ValB,ValE;
    wire signed [63:0]ValM;
    wire [63:0]PC_next; // From PC update 
    wire ZF,OF,SF,Cnd; 
    wire instr_valid , imem_error ,halt ,dmem_err; //dmmem_error is added here 


    reg [7:0] inst_memory[0:255];//memory that contains all the instructions
    // reg [7:0] temp_inst_memory[0:255];//memory that contains all the instructions
    integer i;
    
    reg [0:79] instr; //instruction with 10bytes


    //Register File 

    wire signed [63:0] rax;  
    wire signed [63:0] rcx;
    wire signed [63:0] rdx;
    wire signed [63:0] rbx;
    wire signed [63:0] rsp;
    wire signed [63:0] rbp;
    wire signed [63:0] rsi;
    wire signed [63:0] rdi;
    wire signed [63:0] r8;
    wire signed [63:0] r9;
    wire signed [63:0] r10;
    wire signed [63:0] r11;
    wire signed [63:0] r12;
    wire signed [63:0] r13;
    wire signed [63:0] r14;    

    // initial begin
    //     clk = 0;
    //     #10;
    // end


    fetch fetch_call(icode , ifun , rA, rB, ValC, ValP, instr_valid,imem_error,halt,clk,PC,instr);


    decode_wb decode_call(icode,rA,rB,ValA,ValB,rax,rcx,rdx,rbx,rsp,rbp,rsi,rdi,r8,r9,r10,r11,r12,r13,r14,clk,ValM,ValE,Cnd);


    execute execute_call(clk, icode, ifun, ValA, ValB, ValC, ZF, SF, OF, Cnd, ValE);


    PC_update pc_upd_test(icode , Cnd , ValC , ValM , ValP , PC_next , clk);


    memory mem_test(icode, ValA, ValB, ValE, ValP, ValM ,clk,dmem_err);



    always @(PC) begin
        instr = {inst_memory[PC],inst_memory[PC+1],inst_memory[PC+2],
                inst_memory[PC+3],inst_memory[PC+4],inst_memory[PC+5],
                inst_memory[PC+6],inst_memory[PC+7],inst_memory[PC+8],
                inst_memory[PC+9]};  
    end

    // initial begin
    //     clk = 1;
    //     #10;
    // end

    initial begin
        repeat (35) #10 clk = ~clk;
    end

    always @(posedge clk) begin
        PC <=PC_next;
    end


    //Displaying Error bits 

    always@(instr_valid) begin 
        if(instr_valid == 0)begin
            $display("Given instruction is invalid at PC = %5d\n",PC);            
            // PC = PC +1;
            // $display("Updated PC =%5d\n\n",PC);
            $finish;
            
        end
    end


    always@(icode) begin 
        if(halt == 1)begin
            $display("Program ended at PC = %5d as halt = 1\n",PC);
            $finish;
        end
    end

    always@(imem_error) begin 
        if(imem_error == 1)begin 
            $display("Accessing an invalid address in the Instruction Mem\n");
            $finish;
        end
    end

    
    always @(posedge clk) begin
        if (dmem_err == 1) begin
            $display("Data Memory Error occurred at PC = %5d\n", PC);
            // PC<= PC_next;
        end
    end


    initial begin
        $dumpfile("memory_tb.vcd");
        $dumpvars(0, memory_tb);
        clk = 0;
        // change to 1 when manual input is given 
        PC = 64'd1; // starts from 0 

    end



    always @(posedge clk)

    begin 
        $display("time = %5d\nPC=%5d\nclk=%d\nicode=%d\nifun=%d\nrA=%d\nrB=%d\nValC=%d\nValP=%d\nValA = %d\n ValB = %d\nValE = %d\nValM = %5d\nZF = %5d\nSF = %5d\n OF = %5d\n Cnd = %b\ndmem_err = %5d\n\n",$time,PC,clk,icode,ifun,rA,rB,ValC,ValP,ValA,ValB,ValE,ValM,ZF,SF,OF,Cnd,dmem_err);
    end 


    // initial begin
    //     inst_memory[1]  = 8'h10; //nop

    //     inst_memory[2] = 8'h20; //rrmovq
    //     inst_memory[3] = 8'h15;

    //     inst_memory[4] = 8'h30;//irmovq
    //     inst_memory[5] = 8'hFA;
    //     inst_memory[6] = 8'b00000100;
    //     inst_memory[7] = 8'h00;
    //     inst_memory[8] = 8'h00;
    //     inst_memory[9] = 8'h00;
    //     inst_memory[10] = 8'h00;
    //     inst_memory[11] = 8'h00;
    //     inst_memory[12] = 8'h00;
    //     inst_memory[13] = 8'b0;

    //     inst_memory[14] = 8'h40;//rmmovq
    //     inst_memory[15] = 8'h24;
    //     {inst_memory[23],inst_memory[22],inst_memory[21],inst_memory[20],inst_memory[19],inst_memory[18],inst_memory[17],inst_memory[16]} = 64'd1;

    //     inst_memory[24] = 8'h40;//rmmovq
    //     inst_memory[25] = 8'h53;
    //     {inst_memory[33],inst_memory[32],inst_memory[31],inst_memory[30],inst_memory[29],inst_memory[28],inst_memory[27],inst_memory[26]} = 64'd0;

    //     inst_memory[34] = 8'h50;//mrmovq
    //     inst_memory[35] = 8'h53;
    //     {inst_memory[43],inst_memory[42],inst_memory[41],inst_memory[40],inst_memory[39],inst_memory[38],inst_memory[37],inst_memory[36]} = 64'd0;

    //     inst_memory[44] = 8'h61;// subq
    //     inst_memory[45] = 8'h9A;

    //     inst_memory[46] = 8'h72;  //jl ( checks ValB is less than ValA)
    //     {inst_memory[54],inst_memory[53],inst_memory[52],inst_memory[51],inst_memory[50],inst_memory[49],inst_memory[48],inst_memory[47]} = 64'd56;

    //     inst_memory[55] = 8'h00; // skip the halt 

    //     inst_memory[56] = 8'hA0;  // pushq 
    //     inst_memory[57] = 8'h9F;

    //     inst_memory[58] = 8'hB0;  //popq 
    //     inst_memory[59] = 8'h9F;

    //     inst_memory[60] = 8'h80;  //call 
    //     {inst_memory[68],inst_memory[67],inst_memory[66],inst_memory[65],inst_memory[64],inst_memory[63],inst_memory[62],inst_memory[61]} = 64'd80;

    //     inst_memory[69] = 8'h60;  // addq (skipped cause of call)
    //     inst_memory[70] = 8'h56;

    //     inst_memory[71] = 8'h75;
    //     {inst_memory[79],inst_memory[78],inst_memory[77],inst_memory[76],inst_memory[75],inst_memory[74],inst_memory[73],inst_memory[72]} = 64'd46;

    //     inst_memory[80] = 8'h63; // xorq 
    //     inst_memory[81] = 8'hDE;
    //     // inst_memory[82] = 8'h10;
    //     inst_memory[82] = 8'h10;
        
    // end


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
        inst_memory[17] = 8'h34; // rbx into the memory displaced  -> mem[12] is occupied  -> mem[12] = 0
        {inst_memory[25],inst_memory[24],inst_memory[23],inst_memory[22],inst_memory[21],inst_memory[20],inst_memory[19],inst_memory[18]} = 64'd2;

        // CASE 6 : mrmovq
        inst_memory[26] = 8'h50;
        inst_memory[27] = 8'h27; // rb = rdi = 0 , so mem[12]= 0  is written into rdx=0  
        {inst_memory[35],inst_memory[34],inst_memory[33],inst_memory[32],inst_memory[31],inst_memory[30],inst_memory[29],inst_memory[28]} = 64'd12; // memory is connected yet 

        // CASE 7 : jxx 
        inst_memory[36] = 8'h70; // unconditional 
        {inst_memory[44],inst_memory[43],inst_memory[42],inst_memory[41],inst_memory[40],inst_memory[39],inst_memory[38],inst_memory[37]} = 64'd55; //  jump as PC_update is connected 

        // CASE 8 : Call  // skips this as jump is executed 
        inst_memory[45] = 8'h80;
        {inst_memory[53],inst_memory[52],inst_memory[51],inst_memory[50],inst_memory[49],inst_memory[48],inst_memory[47],inst_memory[46]} = 64'd55; //  jump as PC_update is  connected yet 

        // CASE 9 : ret  
        inst_memory[54] = 8'h90;   // doesnt raise error as memory is connected 

        // CASE 10 : pushq // gives dmem error as mem is not set already ! so crt only 
        inst_memory[55] = 8'hA0; 
        inst_memory[56] = 8'h3F; // rbx into the stack 

        // CASE 11 : popq
        inst_memory[57] = 8'hB0; 
        inst_memory[58] = 8'h5F; // push it into rbp 

        // CASE 12 : halt 
        inst_memory[59] = 8'h00;

    end



    // // loading into another memory and skipping the first clock cycle 
    // initial begin 
    //     // #10
    //     $readmemb("/home/aniruth/Desktop/Courses/IPA/Project/Project_Us/SEQ/1.txt", temp_inst_memory);
    //     // $readmemb("/home/aniruth/Desktop/Courses/IPA/Project/Project_Us/SEQ/1.txt", inst_memory);

    // end

    // initial begin

    //     inst_memory[0] = 8'h10; // nop operation

    //     for (i = 1; i <= 256; i = i + 1) begin
    //         inst_memory[i] = temp_inst_memory[i-1];
    //     end
    // end


endmodule   


