
module fetch_tb;

    reg clk;
    reg [63:0] PC;
    
    wire [3:0] icode , ifun , rA, rB;
    wire [63:0] ValP , ValC;

    wire instr_valid , imem_error , halt ;

    reg [7:0] inst_memory [0:1023];
    reg [0:79] instr;

    
    initial
    begin
        clk = 1'b0;
        $dumpfile("fetch_tb.vcd");
        $dumpvars(0, fetch_tb);
        PC = 64'd0;
       
    end

    // Remember to reverse the ValC value ! 

    // Setting up the instruction memory 
    initial begin

        //CASE - 1 : nop 
        inst_memory[0]  = 8'h10; 

        // CASE - 2: cmovxx
        inst_memory[1] = 8'h22;  // cmovl - 22
        inst_memory[2] = 8'hBC;  // r11 to r12

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
        inst_memory[44] = 8'h80;  
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


    
    fetch test_fetch(icode, ifun, rA, rB, ValC, ValP, inst_valid, imem_error, halt,clk,PC,instr);

    //Stitching the instr together from the instruction memory
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


    //Display at the posedge of the clock 

    always @(posedge clk) begin
        $display("time = %0t\nPC = %4d\nicode = %d\nifun = %d\nrA = %d\nrB = %d\nValC = %6d\nValP = %8d\ninst_valid = %d\nimem_error = %d\nhalt = %d\n\n",
        $time, PC, icode, ifun, rA, rB, ValC, ValP, inst_valid, imem_error, halt);
    end


    
    


//         //Setting up the Instruction Memory 
//     initial begin

//     // CASE -1 : Halt     
//     inst_memory[0] = 8'b00000000;

//     // CASE -2 : nop
//     inst_memory[10] = 8'b00010000;

//    // CASE -3 : cmovxx
//     inst_memory[20] = 8'b00100110; // 26 -> cmovg (greater)
//     inst_memory[21] = 8'b00100011; // (2 -> 3) %rdx -> %rbx

    
//     // CASE -4 : irmovq ( moving 252 to %r9)
//     inst_memory[30] = 8'b00110000;
//     inst_memory[31] = 8'b11111001;  //(%ra = F= 15)
//     inst_memory[32] = 8'b00000000;
//     inst_memory[33] = 8'b00000000;
//     inst_memory[34] = 8'b00000000;
//     inst_memory[35] = 8'b00000000;
//     inst_memory[36] = 8'b00000000;
//     inst_memory[37] = 8'b00000000;
//     inst_memory[38] = 8'b00000000;
//     inst_memory[39] = 8'b11111100;
    

//     // CASE -5 : rmmovq (Displacement = 171)
//     inst_memory[40] = 8'b01000000;
//     inst_memory[41] = 8'b10001001; // %r8 to 171(%r9)
//     inst_memory[42] = 8'b00000000;
//     inst_memory[43] = 8'b00000000;
//     inst_memory[44] = 8'b00000000;
//     inst_memory[45] = 8'b00000000;
//     inst_memory[46] = 8'b00000000;
//     inst_memory[47] = 8'b00000000;
//     inst_memory[48] = 8'b00000000;
//     inst_memory[49] = 8'b10101011;
    
//     // CASE -6 : mrmovq D(rB) , rA
//     inst_memory[50] = 8'b01010000;
//     inst_memory[51] = 8'b10001001; // 171(%r8) to %r9
//     inst_memory[52] = 8'b00000000;
//     inst_memory[53] = 8'b00000000;
//     inst_memory[54] = 8'b00000000;
//     inst_memory[55] = 8'b00000000;
//     inst_memory[56] = 8'b00000000;
//     inst_memory[57] = 8'b00000000;
//     inst_memory[58] = 8'b00000000;
//     inst_memory[59] = 8'b10101011;
    
//     // CASE -7 : OPq
//     inst_memory[60] = 8'b01100011;  // 63 - xorq 
//     inst_memory[61] = 8'b10001001;  // xor %r8 and %r9 

    
//     // CASE -8 : jXX (jump to 427)
//     inst_memory[70] = 8'b01110010; //72 -> jl 
//     inst_memory[71] = 8'b00000000; 
//     inst_memory[72] = 8'b00000000;
//     inst_memory[73] = 8'b00000000;
//     inst_memory[74] = 8'b00000000;
//     inst_memory[75] = 8'b00000000;
//     inst_memory[76] = 8'b00000000;
//     inst_memory[77] = 8'b00000001;
//     inst_memory[78] = 8'b10101011;
    
//     // CASE -9 : call ( func at 978)
//     inst_memory[80] = 8'b10000000;
//     inst_memory[81] = 8'b00000000; 
//     inst_memory[82] = 8'b00000000;
//     inst_memory[83] = 8'b00000000;
//     inst_memory[84] = 8'b00000000;
//     inst_memory[85] = 8'b00000000;
//     inst_memory[86] = 8'b00000000;
//     inst_memory[87] = 8'b00000011;
//     inst_memory[88] = 8'b11010010;
    
//     // CASE -10 : ret 
//     inst_memory[90] = 8'b10010000;

//     // CASE -11 : pushq (Value in %rbx into the stack )
//     inst_memory[100] = 8'b10100000;
//     inst_memory[101] = 8'b00111111; // (rB = F)
    
//     // CASE -12 : popq ( Pop from stack into %rdx )
//     inst_memory[110] = 8'b10110000;
//     inst_memory[111] = 8'b00101111; // (rB = F)

//     end



endmodule


