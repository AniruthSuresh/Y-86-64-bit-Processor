module reg_writeback(clk,W_stall,m_stat,M_icode,M_ValE,m_ValM,M_dstE,M_dstM,W_stat,W_icode,W_ValE,W_ValM,W_dstE,W_dstM);


    // Inputs 
    input clk;
    input W_stall;

    // Into the pipeline 
    input [3:0]m_stat;
    input [3:0]M_icode; 
    input [63:0]m_ValM,M_ValE; 
    input [3:0]M_dstE,M_dstM;


    // Pipeline update values 
    output reg [3:0] W_stat;
    output reg [3:0] W_icode; 
    output reg [3:0] W_dstE,W_dstM;
    output reg [63:0] W_ValE,W_ValM;


    always @(posedge(clk)) begin

        if (W_stall==1) 
        begin
            W_stat <= W_stat;
            W_icode <= W_icode;
            W_ValE <= W_ValE;
            W_ValM <= W_ValM;
            W_dstE <= W_dstE;
            W_dstM <= W_dstM;
        end

        else 
        begin
            W_stat <= m_stat;
            W_icode <= M_icode;
            W_ValE <= M_ValE;
            W_ValM <= m_ValM;
            W_dstE <= M_dstE;
            W_dstM <= M_dstM;
        end
        
    end
    

endmodule