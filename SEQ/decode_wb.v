// We get the value of ValA , ValB using the values rA , rB 

module decode_wb(icode,rA,rB,ValA,ValB,rax,rcx,rdx,rbx,rsp,rbp,rsi,rdi,r8,r9,r10,r11,r12,r13,r14,clk,ValM,ValE,Cnd);

    //Input Reg
    input clk ; 
    input [3:0] icode ,rA,rB;
    input signed [63:0] ValM,ValE;
    input Cnd; // Condition signal 

    //Output reg 
    output reg signed[63:0] ValA , ValB;

    //Register File 
    output reg signed [63:0] rax;  
    output reg signed [63:0] rcx;
    output reg signed [63:0] rdx;
    output reg signed [63:0] rbx;
    output reg signed [63:0] rsp;
    output reg signed [63:0] rbp;
    output reg signed [63:0] rsi;
    output reg signed [63:0] rdi;
    output reg signed [63:0] r8;
    output reg signed [63:0] r9;
    output reg signed [63:0] r10;
    output reg signed [63:0] r11;
    output reg signed [63:0] r12;
    output reg signed [63:0] r13;
    output reg signed [63:0] r14;

    //Register Memory - just for testing
    reg signed [63:0] reg_mem[0:14]; // 15 registers each of 64 bits 
    

    initial begin
        reg_mem[0] = 64'd12;
        reg_mem[1] = 64'd100;
        reg_mem[2] = 64'd7;
        reg_mem[3] = 64'd0;
        reg_mem[4] = 64'd10;
        reg_mem[5] = 64'd4;
        reg_mem[6] = 64'd13;
        reg_mem[7] = 64'd0;
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




    always @(*) begin

        //CASE 1 and CASE 2 = halt and nop
        if(icode == 0 || icode == 1) begin 
            ValA = 64'hx ; 
            ValB = 64'hx ; 

        end

        // CASE 3 - cmovxx 
        else if(icode == 2) begin 
            ValA = reg_mem[rA];
            ValB = 64'hx ; 

        end

        // CASE 4 - irmovq 
        else if(icode == 3) begin 
            ValA = 64'hx ; 
            ValB = 64'hx ; 
        end

        // CASE 5 - rmmovq 
        else if(icode == 4) begin 
            ValA = reg_mem[rA];
            ValB = reg_mem[rB];
        end

        // CASE 6 - mrmovq 
        else if (icode == 5) begin
            ValA = 64'hx ; 
            ValB = reg_mem[rB];
        end

        // CASE 7 - OPq
        else if(icode == 6) begin
            ValA = reg_mem[rA];
            ValB = reg_mem[rB];
        end

        //CASE - 8 - jXX
        else if(icode == 7) begin
            ValA = 64'hx ; 
            ValB = 64'hx ; 
        end

        //CASE - 9 - call
        else if(icode == 8) begin
            ValA = 64'hx ; 
            ValB = reg_mem[4]; // rsp 
        end

        //CASE - 10 - ret
        else if(icode == 9) begin
            ValA = reg_mem[4]; // rsp 
            ValB = reg_mem[4]; // rsp 
        end

        //CASE - 11 - pushq 
        else if(icode == 10) begin
            ValA = reg_mem[rA];
            ValB = reg_mem[4]; // rsp 
        end


        //CASE - 12 - popq 
        else if(icode == 11) begin
            ValA = reg_mem[4]; // rsp 
            ValB = reg_mem[4]; // rsp 
        end

        else begin
        end

    end




    always @(posedge clk) begin

        //CASE 1 and CASE 2 = halt and nop
        if(icode == 0 || icode == 1) begin
            // check = 0;
        end

        // CASE 3 - cmovxx 
        else if((icode == 2) && (Cnd == 1)) begin 
                reg_mem[rB] = ValE;
                // check =1 ;
        end

        // CASE 4 - irmovq 
        else if(icode == 3) begin 
            reg_mem[rB] = ValE;
            // check = 1;
        end

        // CASE 5 - rmmovq 
        else if(icode == 4) begin 
            // check = 0;
        end

        // CASE 6 - mrmovq ( Reverse Convention )
        else if (icode == 5) begin
            reg_mem[rA] = ValM;
            // check = 1;
        end

        // CASE 7 - OPq
        else if(icode == 6) begin
            reg_mem[rB] = ValE;
            // check = 1;
        end

        //CASE - 8 - jXX
        else if(icode == 7) begin
            // check = 0 ;
        end

        //CASE - 9 - call
        else if(icode == 8) begin
            reg_mem[4] = ValE; // stack reg
            // check = 1;
        end

        //CASE - 10 - ret
        else if(icode == 9) begin
            reg_mem[4] = ValE; // stack reg
            // check = 1;
        end

        //CASE - 11 - pushq 
        else if(icode == 10) begin
            reg_mem[4] = ValE; // stack reg
            // check= 1;
        end

        //CASE - 12 - popq 
        else if(icode == 11) begin
            reg_mem[4] = ValE; // stack reg
            reg_mem[rA] = ValM;
            // check = 1;
        end

        else begin
        end

    end

endmodule



        




