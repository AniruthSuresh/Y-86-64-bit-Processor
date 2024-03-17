`include "fetch.v"
`include "execute.v"
`include "memory.v"
`include "decode_wb.v"

`include "reg_decode.v"
`include "reg_execute.v"
`include "reg_memory.v"
`include "reg_writeback.v"

`include "pipeline_control.v"


module processor_pipe();

    reg clk;
    reg [63:0] F_Pred_PC;


    wire [63:0] f_PC;

    wire [63:0] predict_PC;
 
    wire imem_error;

    wire ZF,SF,OF;


    wire [3:0]D_stat;
    wire [3:0]D_icode; 
    wire [3:0]D_ifun; 
    wire [3:0]d_dstE;
    wire [3:0]d_dstM;
    wire [3:0]d_srcA;
    wire [3:0]d_srcB;
    wire signed [63:0]d_ValA;
    wire signed[63:0]d_ValB;
    wire signed [63:0]D_ValC;
    wire [3:0] E_stat;
    wire [3:0] E_icode; 
    wire [3:0] E_ifun;
    wire [3:0] E_dstE;
    wire [3:0] E_dstM;
    wire [3:0] E_srcA;
    wire [3:0] E_srcB;
    wire signed[63:0] E_ValC;
    wire signed[63:0] E_ValA;
    wire signed[63:0] E_ValB;

    wire [3:0]f_stat;
    wire [3:0]f_icode; 
    wire [3:0]f_ifun; 
    wire [3:0]f_rA;
    wire [3:0]f_rB;
    wire signed[63:0]f_ValC;
    wire [63:0]f_ValP;

    wire [3:0] D_rA;
    wire [3:0] D_rB;
    wire [63:0] D_ValP;

    wire [3:0]W_dstE;
    wire [3:0]W_dstM;

    wire signed [63:0] W_ValE;
    wire signed[63:0] W_ValM;

    wire signed[63:0] d_rValA;
    wire signed[63:0] d_rValB;

    
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


    wire dmem_err;
    


    wire F_stall;
    wire D_stall;
    wire D_bubble;
    wire E_bubble;
    wire M_bubble;
    wire W_stall;

    wire [3:0] stat;

	wire [3:0] e_dstE;
	wire [3:0] M_dstM;
	wire [3:0] M_dstE;

	wire signed[63:0] m_ValM;


    wire [3:0]m_stat;
    wire signed[63:0]m_ValA; 

    wire signed[63:0]M_ValE;
    wire signed[63:0] M_ValA;

    wire [3:0] W_stat;
    wire [3:0] W_icode; 

    wire e_Cnd; 

    wire [3:0]e_dstM;
    wire signed[63:0]e_ValE;
    wire [3:0] M_stat;
    wire [3:0] M_icode; 
    wire M_Cnd;



    reg [7:0] inst_memory[0:255];//memory that contains all the instructions
    reg [7:0] temp_inst_memory[0:255];//memory that contains all the instructions
    integer i;
    
    reg [0:79] instr; //instruction with 10bytes


    fetch pipe_fetch(clk,instr,M_icode,W_icode, M_ValA, W_ValM, F_Pred_PC,M_Cnd,f_PC,predict_PC,f_icode,f_ifun,f_rA,f_rB,f_ValC,f_ValP,f_stat);

    reg_decode write_dec(clk,D_bubble ,D_stall ,f_stat ,f_icode ,f_ifun,f_rA, f_rB,f_ValC ,f_ValP,D_stat,D_icode,D_ifun ,D_rA, D_rB,D_ValC ,D_ValP);
    decode_wb write_dec_wb(e_ValE,m_ValM,M_ValE,D_icode,D_rA,D_rB,W_dstE,D_ValP,W_dstM,d_srcA,d_rValA, d_rValB,d_srcB,W_ValE,W_ValM,d_ValA,d_ValB,rax,rcx,rdx,rbx,rsp,rbp,rsi,rdi,r8,r9,r10,r11,r12,r13,r14,clk,stat,e_dstE, M_dstM, M_dstE, W_dstE, W_dstM,d_dstE,d_dstM,W_stat);
    reg_writeback write_writeback(clk,W_stall,m_stat,M_icode,M_ValE,m_ValM,M_dstE,M_dstM,W_stat,W_icode,W_ValE,W_ValM,W_dstE,W_dstM);


    reg_execute write_exe(clk, E_bubble,D_stat,D_icode,D_ifun,d_ValA,d_ValB,D_ValC,d_dstE,d_dstM,d_srcA,d_srcB,E_stat,E_icode,E_ifun,E_ValC,E_ValA,E_ValB,E_dstE,E_dstM,E_srcA,E_srcB,e_Cnd, M_icode);
    execute fetch_exe(clk, E_icode, E_ifun, E_ValA, E_ValB, E_ValC, E_dstE, ZF, SF, OF, e_Cnd, e_ValE,e_dstE,m_stat,W_stat);


    reg_memory write_mem(clk,M_bubble,E_stat,E_icode,e_Cnd,e_ValE, E_ValA,e_dstE,E_dstM, M_stat,M_icode,M_Cnd,M_ValE, M_ValA,M_dstE ,M_dstM);
    memory fetch_mem(M_icode, M_ValA, M_ValE,M_stat, m_ValM,m_stat ,clk,dmem_err);

   
    pipeline_control pline_ctrl(F_stall,D_stall,D_bubble,E_bubble,M_bubble,W_stall,D_icode,d_srcA,d_srcB,E_icode,E_dstM,e_Cnd,M_icode,m_stat,W_stat);


    initial
    begin

        $dumpfile("processor_pipe_dump.vcd");
        $dumpvars(0, processor_pipe);
        
        clk = 1'b0; // start from 0 
        F_Pred_PC = 64'd0; // we increase by 1 later 

    end

    //Setting clock 
    initial begin
        repeat (90) #10 clk = ~clk;
    end




    // Writing into Fetch pipeline Register - Reg "F"
    always @(posedge clk)
      begin    

          if(F_stall==1)
          begin
            F_Pred_PC <= F_Pred_PC; 
          end

          else 
          begin
            F_Pred_PC <= predict_PC;
          end

      end

      
    // loading into another memory and skipping the first clock cycle 
    initial begin 
        // #10

        // Check binary or hexadecimal !!
        $readmemb("/home/aniruth/Desktop/Pipeline_Mine/Test_Cases/kmp1_call.txt", temp_inst_memory);
        // $readmemb("/home/aniruth/Desktop/Courses/IPA/Project/Project_Us/SEQ/1.txt", inst_memory);
    end

    initial begin

        inst_memory[0] = 8'h10; // nop operation (SKIP THE FIRST CLOCK )

        for (i = 1; i <= 256; i = i + 1) begin
            inst_memory[i] = temp_inst_memory[i-1];
        end
    end



     always @(*) begin // try to change to f_PC and try later if this doesnt work 
        instr = {inst_memory[f_PC],inst_memory[f_PC+1],inst_memory[f_PC+2],
                inst_memory[f_PC+3],inst_memory[f_PC+4],inst_memory[f_PC+5],
                inst_memory[f_PC+6],inst_memory[f_PC+7],inst_memory[f_PC+8],
                inst_memory[f_PC+9]};  
    end


    always@(*) begin  //  halt should be recognised at the writeback stage and halted 
        if(W_stat == 4)begin
            $display("Given instruction is invalid at PC = %5d\n",f_PC);            
            // PC = PC +1;
            // $display("Updated PC =%5d\n\n",PC);
            #20;
            $finish;
        end
    end



    always@(*) begin 
        if(W_stat == 3)begin 
            $display("Accessing an data mem error in the Instruction Mem at PC =%d \n",f_PC);
            #20;
            $finish;
        end
    end

    always@(*) begin 
        if(W_stat== 2)begin 
            $display("Accessing an inst invalid in the Instruction Mem PC=%d\n",f_PC);
            #20;
            $finish;
        end
    end




 always @(posedge clk) // use gtkwave 
   begin

    $display("F_PC=%d,inst = %b,d_icode= %b,bubble = %d,stall = %d",f_PC,instr,D_icode,D_bubble,D_stall);

    end

endmodule


