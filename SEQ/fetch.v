// Instead of passing the entire inst memory , pass each inst into the fetch block 

module fetch(icode , ifun , rA, rB, ValC, ValP, instr_valid,imem_error,halt,clk,PC,instr);

    //Input reg 
    input clk;
    input [63:0] PC;
    input [0:79] instr; // each instr is of max length 80 bits 

    //Output reg 
    output reg [3:0] icode , ifun , rA, rB;
    output reg signed[63:0] ValP , ValC;

    //One - bit codes
    output reg instr_valid , imem_error ,halt ; 

    //Intermediate Codes 
    output reg need_regids, need_ValC ;

    always@(*) 
    begin

        //set halt to 0
        halt = 1'b0 ;
         
        //set up the inst_memory_error 
        if((0 <= PC) && (PC < 1024)) begin
            imem_error = 0 ;
        end

        else begin
            imem_error = 1;
        end

        // Split - icode and ifun 
        icode = instr[0:3];
        ifun = instr[4:7];


        //set up the inst_valid 
        if(((0 <= icode) && (icode < 12)) && ((0 <= ifun) && (ifun < 7))) begin
            instr_valid = 1;
        end

        else begin
            instr_valid = 0;
        end

        //Setting need_regid code 
        if ((2 <= icode) && (icode <=6) || ((10 <= icode) && (icode <=11))) begin
            need_regids = 1;
        end

        else begin
            need_regids = 0;
        end

        //Setting need_ValC code 
        if ((3 <= icode) && (icode <= 5) || ((7 <= icode) && (icode <= 8))) begin
            need_ValC = 1;
        end

        else begin
            need_ValC = 0;
        end

        // Fetch Instructions 

        // CASE -1 : Halt 
        if(icode == 0) begin  
            halt = 1;
            rA = 4'hx;
            rB = 4'hx;
            ValC = 64'hx;
        end

        // CASE -2 : nop
        else if(icode == 1) begin
            rA = 4'hx;
            rB = 4'hx;
            ValC = 64'hx;
        end

        // CASE -3 : cmovxx
        else if(icode == 2) begin
            rA = instr[8:11];
            rB = instr[12:15];
            ValC = 64'hx;
        end

        // CASE -4 : irmovq
        else if(icode == 3) begin
            //rA is intermediate (F)
            rA = instr[8:11];
            rB = instr[12:15];            
            ValC = {instr[72:79], instr[64:71], instr[56:63], instr[48:55], instr[40:47], instr[32:39], instr[24:31], instr[16:23]};
        end

        // CASE -5 : rmmovq 
        else if(icode == 4) begin
            rA = instr[8:11];
            rB = instr[12:15];            
            ValC = {instr[72:79], instr[64:71], instr[56:63], instr[48:55], instr[40:47], instr[32:39], instr[24:31], instr[16:23]};
        end

        // CASE -6 : mrmovq
        else if(icode == 5) begin
            rA = instr[8:11];
            rB = instr[12:15];            
            ValC = {instr[72:79], instr[64:71], instr[56:63], instr[48:55], instr[40:47], instr[32:39], instr[24:31], instr[16:23]};
        end

         // CASE -7 : OPq
        else if(icode == 6) begin
            rA = instr[8:11];
            rB = instr[12:15];
            ValC = 64'hx;
        end

        // CASE -8 : jXX
        else if(icode == 7) begin
            rA = 4'hx;
            rB = 4'hx;
            ValC = {instr[64:71], instr[56:63], instr[48:55], instr[40:47], instr[32:39], instr[24:31], instr[16:23],instr[8:15]}+64'h1; // pc gets updated !
        end

        // CASE -9 : call
        else if(icode == 8) begin
            rA = 4'hx;
            rB = 4'hx;
            ValC = {instr[64:71], instr[56:63], instr[48:55], instr[40:47], instr[32:39], instr[24:31], instr[16:23],instr[8:15]}+64'h1; // no reg involved 
        end

        // CASE -10 : ret 
        else if(icode == 9) begin
            rA = 4'hx;
            rB = 4'hx;
            ValC = 64'hx;
        end

        // CASE -11 : pushq
        else if(icode == 10) begin  //rB iS F
            rA = instr[8:11];
            rB = instr[12:15];
            ValC = 64'hx;
        end

        // CASE -12 : popq
        else if(icode == 11) begin   //rB iS F
            rA = instr[8:11];
            rB = instr[12:15];
            ValC = 64'hx;
        end

        else begin
            instr_valid = 0 ;
        end

        // Set up valP value 
        ValP = PC + 1 + need_regids + (8*need_ValC);

    end


endmodule

