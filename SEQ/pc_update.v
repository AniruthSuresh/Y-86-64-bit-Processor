// Only for jump , call and ret PC updates are diff , rest its all ValP

module PC_update(icode , Cnd , ValC , ValM , ValP , PC_next , clk);


    // Inputs 
    input clk ; 
    input [3:0] icode ;
    input Cnd ; // conditional Code ( to decide jump )
    input signed[63:0] ValC , ValM , ValP ; 


    // Outputs 
    output reg [63:0] PC_next;

    always @(*) begin 

        // Jump (check Cnd and then decide)
        if(icode == 7) begin

            if(Cnd ==1) begin
                PC_next = ValC;
            end
            
            else begin
                PC_next = ValP;
            end
        end

        // Call 
        else if(icode == 8) begin
            PC_next = ValC;
        end

        // Ret
        else if(icode == 9) begin
            PC_next = ValM;
        end


        // Rest of the cases 
        else begin
            PC_next = ValP;
        end

    end

endmodule

