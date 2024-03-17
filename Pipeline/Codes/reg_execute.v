module reg_execute(clk, E_bubble,D_stat,D_icode,D_ifun,d_ValA,d_ValB,D_ValC,d_dstE,d_dstM,d_srcA,d_srcB,E_stat,E_icode,E_ifun,E_ValC,E_ValA,E_ValB,E_dstE,E_dstM,E_srcA,E_srcB,e_Cnd, M_icode);

    //Inputs 
    input clk;
    input E_bubble;

    // Into the pipeline reg 
    input [3:0]D_stat;
    input [3:0]D_icode,D_ifun, M_icode;
    input [63:0]d_ValA,d_ValB,D_ValC;
    input [3:0]d_dstE,d_dstM;
    input [3:0]d_srcA,d_srcB;
    input e_Cnd;


    // Values in the "E" reg  
    output reg [3:0] E_stat;
    output reg [3:0] E_icode,E_ifun; 
    output reg [63:0]E_ValC,E_ValA,E_ValB;
    output reg [3:0]E_dstE,E_dstM;
    output reg [3:0]E_srcA,E_srcB;



    always @(posedge(clk)) begin
        
        if (E_bubble == 1)
        begin
            E_icode <= 4'h1;
            E_ifun <= 4'h0;
			E_dstE <= 4'hF;
			E_dstM <= 4'hF;
            E_srcA <= 4'hF;
            E_srcB <= 4'hF;
        end

        else 
        begin
            
            // When the inst following the jump is a invalid one\halt \ dmme error -> dont raise an error basically
            if(M_icode==7 && e_Cnd==0 && ((D_stat==2) || (D_stat==3) || (D_stat==4))) begin
                E_stat <=4'h1;
            end

            else begin
            E_stat <= D_stat;
            end
            E_icode <= D_icode;
            E_ifun <= D_ifun;
            E_ValC <= D_ValC;
            E_ValA <= d_ValA;
            E_ValB <= d_ValB;
            E_dstE <= d_dstE;
            E_dstM <= d_dstM;
            E_srcA <= d_srcA;
            E_srcB <= d_srcB;
        end

    end


endmodule