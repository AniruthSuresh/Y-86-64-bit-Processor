
module reg_decode(clk,D_bubble ,D_stall ,f_stat ,f_icode ,f_ifun,f_rA, f_rB,f_ValC ,f_ValP,D_stat,D_icode,D_ifun ,D_rA, D_rB,D_ValC ,D_ValP);

    //Output reg - into the pipeline 
    output reg [3:0] D_icode , D_ifun , D_rA, D_rB;
    output reg signed[63:0] D_ValC , D_ValP;
    output reg [3:0] D_stat=1;
    

    // Bubbling ( F and D ) the Stalling  (D)
    input clk;
    input D_bubble , D_stall ;
    input [3:0] f_stat ; 
    input [3:0] f_icode , f_ifun;
    input [3:0] f_rA, f_rB;
    input [63:0] f_ValC , f_ValP;


    //  Writing into the Decode register
    always @(posedge clk) begin 

        

        if(D_stall)  // Stall the decode ( so maintain all the prev states )
        begin

			D_icode <= D_icode;
			D_ifun <= D_ifun;
			D_rA <= D_rA;
			D_rB <= D_rB;
			D_ValC <= D_ValC;
			D_ValP <= D_ValP;
            D_stat <= D_stat;
            // $display("1st loop ");

        end

        // else if(D_stall == 0)
        else
        begin

            // if(D_bubble==0)  // Normal Case - write into D register in the posedge clock 
            // begin
                
            //     $display("ficode = %b", f_icode);
            //     D_icode <= f_icode;
            //     D_ifun <= f_ifun;
            //     D_rA <= f_rA;
            //     D_rB <= f_rB;
            //     D_ValC <= f_ValC;
            //     D_ValP <= f_ValP;
            //     D_stat <= f_stat;
            //     // $display("2st loop ");
            //     $display("D_icode= %b", D_icode);

            // end

            // else if(D_bubble==1) // bubble the decode - nop 
            if(D_bubble==1) 
            begin 
                D_icode  <= 4'h1;
                D_ifun  <= 4'h0;
                D_rA <= 4'hF;
                D_rB <= 4'hF;
        
                // $display("3st loop ");

            end

            else 
                begin
                
                // $display("ficode = %b", f_icode);
                D_icode <= f_icode;
                D_ifun <= f_ifun;
                D_rA <= f_rA;
                D_rB <= f_rB;
                D_ValC <= f_ValC;
                D_ValP <= f_ValP;
                D_stat <= f_stat;
                // $display("2st loop ");
                // $display("D_icode= %b", D_icode);

            end

            end


        end



endmodule

