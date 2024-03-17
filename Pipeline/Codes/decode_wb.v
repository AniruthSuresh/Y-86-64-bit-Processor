// We get the value of d_valA , d_valB using the values rA , D_rB 

module decode_wb(e_ValE,m_ValM,M_ValE,D_icode,D_rA,D_rB,W_dstE,D_ValP,W_dstM,d_srcA,d_rValA, d_rValB,d_srcB,W_ValE,W_ValM,d_ValA,d_ValB,rax,rcx,rdx,rbx,rsp,rbp,rsi,rdi,r8,r9,r10,r11,r12,r13,r14,clk,stat,e_dstE, M_dstM, M_dstE, W_dstE, W_dstM,d_dstE,d_dstM,W_stat);

    //Input Reg
    input clk ; 
    input [3:0] D_icode ,D_rA,D_rB;
    input [3:0] W_stat;


    output reg [3:0]d_srcA,d_srcB;

    output reg[3:0] stat ; // dummy stat 

    output reg [3:0] d_dstE,d_dstM;


    input [63:0] W_ValE,W_ValM,D_ValP;

    input [63:0] e_ValE,m_ValM,M_ValE;

    // forwarding input 
    input [3:0] e_dstE, M_dstM, M_dstE, W_dstE, W_dstM;


    //Output reg 
    output reg [63:0] d_ValA , d_ValB;
    output reg [63:0] d_rValA, d_rValB;
    



    //Register File 
    output reg [63:0] rax;  
    output reg [63:0] rcx;
    output reg [63:0] rdx;
    output reg [63:0] rbx;
    output reg [63:0] rsp;
    output reg [63:0] rbp;
    output reg [63:0] rsi;
    output reg [63:0] rdi;
    output reg [63:0] r8;
    output reg [63:0] r9;
    output reg [63:0] r10;
    output reg [63:0] r11;
    output reg [63:0] r12;
    output reg [63:0] r13;
    output reg [63:0] r14;

    //Register Memory - just for testing
    reg signed [63:0] reg_mem[0:14]; // 15 registers each of 64 bits 
    
    initial begin
        reg_mem[0] = 64'd12;
        reg_mem[1] = 64'd100;
        reg_mem[2] = 64'd7;
        reg_mem[3] = 64'd0;
        reg_mem[4] = 64'd256;
        reg_mem[5] = 64'd4;
        reg_mem[6] = 64'd13;
        reg_mem[7] = 64'd257;
        reg_mem[8] = 64'd1009;
        reg_mem[9] = 64'd567;
        reg_mem[10] = 64'd342;
        reg_mem[11] = 64'd2;
        reg_mem[12] = 64'd0;
        reg_mem[13] = 64'd1;
        reg_mem[14] = 64'd12;
    end

    always @(*) begin
        rax = reg_mem[0];
        rcx = reg_mem[1];
        rdx = reg_mem[2];
        rbx = reg_mem[3];
        rsp = reg_mem[4];
        rbp = reg_mem[5];
        rsi = reg_mem[6];
        rdi = reg_mem[7];
        r8 = reg_mem[8];
        r9 = reg_mem[9];
        r10 = reg_mem[10];
        r11 = reg_mem[11];
        r12 = reg_mem[12];
        r13 = reg_mem[13];
        r14 = reg_mem[14];
    end



    // x implies either the register is not used (OR) its not present 

    always @(*) begin  // change here to i_code if deosnt work 

        if(D_icode == 4'h7 || D_icode == 4'h8) // jump and call 
        begin 
            d_ValA <= D_ValP;
        end


        else if (d_srcA != 15) begin   // if srcA = 15 , dont get value 
            // Forwarding logic 

            if(d_srcA == e_dstE) 
            begin
                 d_ValA <= e_ValE;
            end

            else if (d_srcA == M_dstM )
            begin
                d_ValA <= m_ValM;
            end

            else if (d_srcA == M_dstE )
            begin
                d_ValA <= M_ValE;
            end

            else if (d_srcA == W_dstM )
            begin
                d_ValA <= W_ValM;
            end

            else if (d_srcA == W_dstE)
            begin
                d_ValA <= W_ValE;
            end

            else 
            begin
                d_ValA <= d_rValA;
            end


        end

        if (d_srcB != 15) begin // alwways change 

            if(d_srcB == e_dstE) 
            begin
                d_ValB <= e_ValE;
            end

            else if (d_srcB == M_dstM )
            begin
                d_ValB <= m_ValM;
            end

            else if (d_srcB == M_dstE )
            begin
                d_ValB <= M_ValE;
            end

            else if (d_srcB == W_dstM )
            begin
                d_ValB <= W_ValM;
            end

            else if (d_srcB == W_dstE)
            begin
                d_ValB <= W_ValE;
            end

            else 
            begin
                d_ValB <= d_rValB;
            end

        end

    end


    // Getting the register values 
    always @(*) begin

        if (d_srcA != 4'd15) begin
            d_rValA <= reg_mem[d_srcA];
            
        end

        if (d_srcB != 4'd15) begin
            d_rValB <= reg_mem[d_srcB];
        end
        
    end


    // srcA logic 
    always @(D_icode, D_rA) begin
      

        if(D_icode == 4'h2  || D_icode == 4'h3 || D_icode == 4'h4 || D_icode == 4'h5 || D_icode == 4'h6 || D_icode == 4'hA)
        begin
            d_srcA <= D_rA;
        end

        else if ( D_icode == 4'h9  || D_icode == 4'hB )
        begin
            d_srcA <= 4'h4;
        end

        else 
        begin
            d_srcA <= 4'hF;
        end

    end


    // srcB logic 
    always @(D_icode, D_rB) begin
      

        if(D_icode == 4'h4  || D_icode == 4'h5 || D_icode == 4'h6 )
        begin
            d_srcB <= D_rB;
        end

        else if ( D_icode == 4'h8 || D_icode == 4'h9 || D_icode == 4'hA  || D_icode == 4'hB )
        begin
            d_srcB <= 4'h4;
        end

        else 
        begin
            d_srcB <= 4'hF;
        end
    end



    // DstE logic block
    always @(*) begin

 

        if(D_icode == 4'h2  || D_icode == 4'h3 || D_icode == 4'h6 )
        begin
            d_dstE <= D_rB;
        end

        else if ( D_icode == 4'h8 || D_icode == 4'h9 || D_icode == 4'hA  || D_icode == 4'hB )
        begin
            d_dstE <= 4'h4;
        end

        else 
        begin
            d_dstE <= 4'hF;
        end

        
	end


    // DstM logic block
    always @(D_icode,D_rA) begin


         if(D_icode == 4'h5  || D_icode == 4'hB )
        begin
            d_dstM <= D_rA;
        end


        else 
        begin
            d_dstM <= 4'hF;
        end
	
    end


    // Writeback logic 
    always @(posedge clk) 
    begin

        if(W_dstE != 4'd15) begin
            reg_mem[W_dstE] <= W_ValE;
        end

        if(W_dstM != 4'd15) begin
            reg_mem[W_dstM] <= W_ValM;
        end
	
    end


    //setting the status code 
    always @(*) 
    begin 
        stat <= W_stat;
    end



endmodule