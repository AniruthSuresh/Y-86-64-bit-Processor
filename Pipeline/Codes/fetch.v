// Instead of passing the entire inst memory , pass each inst into the fetch block 

// No bubble in case of fetch , only stall is possible ( return and load/use hazard ) -> taken care in the processor file 

module fetch(clk,instr,M_icode,W_icode, M_ValA, W_ValM, F_Pred_PC,M_Cnd,f_PC,predict_PC,f_icode,f_ifun,f_rA,f_rB,f_ValC,f_ValP,f_stat);

    //Input reg 
    input clk;
    input [0:79] instr; // each instr is of max length 80 bits 
    input [3:0] M_icode , W_icode ; // for jump and ret check in prev inst 
    input [63:0] M_ValA , W_ValM ;  // for jump and ret -> ValP and ValM value (ValA has ValP stored along with it)
    input [63:0] F_Pred_PC; // input from the Fetch pipeline register 
    input M_Cnd ; // to check for jump instruction execution 


    output reg [63:0]f_PC ; // inside the block itself (output of select PC block ) 
    output reg [63:0] predict_PC; 



    //One - bit codes
    reg instr_valid , imem_error ,halt ; // error codes 
    output reg [3:0] f_icode,f_ifun,f_rA,f_rB;

    reg need_regids, need_ValC ;
    output reg [63:0]f_ValC,f_ValP;
    output reg [3:0] f_stat;



    // SELECT PC Block 
    always @(*) 
    begin

        if( W_icode == 4'h9 )  // Return - next inst PC = ValM 
            f_PC <= W_ValM; // assign to happen in future ( let other operation happens simultanously)

        else if((M_icode == 4'h7) && (M_Cnd==0))  // Jump when mispredicted 
            f_PC <= M_ValA;

        else
            f_PC <= F_Pred_PC;
    end


    always@(*) 
    begin

        //set halt to 0
        halt = 1'b0 ;
         
        //set up the inst_memory_error 
        if((0 <= f_PC) && (f_PC < 1024)) begin
            imem_error = 0 ;
        end

        else begin
            imem_error = 1;
        end

        // Split - icode and ifun 
        f_icode = instr[0:3];
        f_ifun = instr[4:7];
        // $display("Instr = %b", f_ifun);


        //set up the inst_valid 
        if(((0 <= f_icode) && (f_icode < 12)) && ((0 <= f_ifun) && (f_ifun < 7))) begin
            instr_valid = 1;
        end

        else begin
            // instr_valid = 0;
        end

        //Setting need_regid code 
        if ((2 <= f_icode) && (f_icode <=6) || ((10 <= f_icode) && (f_icode <=11))) begin
            need_regids = 1;
        end

        else begin
            need_regids = 0;
        end

        //Setting need_ValC code 
        if ((3 <= f_icode) && (f_icode <= 5) || ((7 <= f_icode) && (f_icode <= 8))) begin
            need_ValC = 1;
        end

        else begin
            need_ValC = 0;
        end

        // Fetch Instructions 

        // CASE -1 : Halt 
        if(f_icode == 0) begin  
            halt = 1;
            f_rA = 4'hx;
            f_rB = 4'hx;
            f_ValC = 64'hx;
        end

        // CASE -2 : nop
        else if(f_icode == 1) begin
            f_rA = 4'hx;
            f_rB = 4'hx;
            f_ValC = 64'hx;
        end

        // CASE -3 : cmovxx
        else if(f_icode == 2) begin
            f_rA = instr[8:11];
            f_rB = instr[12:15];
            f_ValC = 64'hx;
        end

        // CASE -4 : irmovq
        else if(f_icode == 3) begin
            //f_rA is intermediate (F)
            f_rA = instr[8:11];
            f_rB = instr[12:15];            
            f_ValC = {instr[72:79], instr[64:71], instr[56:63], instr[48:55], instr[40:47], instr[32:39], instr[24:31], instr[16:23]};
        end

        // CASE -5 : rmmovq 
        else if(f_icode == 4) begin
            f_rA = instr[8:11];
            f_rB = instr[12:15];            
            f_ValC = {instr[72:79], instr[64:71], instr[56:63], instr[48:55], instr[40:47], instr[32:39], instr[24:31], instr[16:23]};
        end

        // CASE -6 : mrmovq // move into f_rA 
        else if(f_icode == 5) begin
            f_rA = instr[8:11];
            f_rB = instr[12:15];            
            f_ValC = {instr[72:79], instr[64:71], instr[56:63], instr[48:55], instr[40:47], instr[32:39], instr[24:31], instr[16:23]};
        end

         // CASE -7 : OPq
        else if(f_icode == 6) begin
            f_rA = instr[8:11];
            f_rB = instr[12:15];
            f_ValC = 64'hx;
        end

        // CASE -8 : jXX
        else if(f_icode == 7) begin
            f_rA = 4'hx;
            f_rB = 4'hx;
            f_ValC = {instr[64:71], instr[56:63], instr[48:55], instr[40:47], instr[32:39], instr[24:31], instr[16:23],instr[8:15]}+64'h1; // pc gets updated !
        end

        // CASE -9 : call
        else if(f_icode == 8) begin
            f_rA = 4'hx;
            f_rB = 4'hx;
            f_ValC = {instr[64:71], instr[56:63], instr[48:55], instr[40:47], instr[32:39], instr[24:31], instr[16:23],instr[8:15]}+64'h1; // no reg involved 
        end

        // CASE -10 : ret 
        else if(f_icode == 9) begin
            f_rA = 4'hx;
            f_rB = 4'hx;
            f_ValC = 64'hx;
        end

        // CASE -11 : pushq
        else if(f_icode == 10) begin  //f_rB iS F
            f_rA = instr[8:11];
            f_rB = instr[12:15];
            f_ValC = 64'hx;
        end

        // CASE -12 : popq
        else if(f_icode == 11) begin   //f_rB iS F
            f_rA = instr[8:11];
            f_rB = instr[12:15];
            f_ValC = 64'hx;
        end

        else begin
            instr_valid = 0 ;
        end

        // Set up valP value 
        f_ValP = f_PC + 1 + need_regids + (8*need_ValC);
        // $display("Instr = %h", f_ValC);

    end


    // Predicting the PC for next inst 
    always @(*) begin 

        if(f_icode == 4'h7 || f_icode == 4'h8) // for jump and call
        begin
            predict_PC <= f_ValC;
        end

        else 
        begin
            predict_PC <= f_ValP;
        end

    end


    // Assigning stat codes 
    always @(*) begin  // bubble is set to reset conf = 0 
        
        if(instr_valid==0)  // SINS
        begin
            f_stat <= 4'h2;
        end

        else if(imem_error==1) //SADR 
        begin
            f_stat <= 4'h3;
        end

        else if (halt == 1)  // SHLT
        begin
            f_stat <= 4'h4;
        end

        else                 // SAOK 
        begin
            f_stat <= 4'h1; 
        end

    end



endmodule



