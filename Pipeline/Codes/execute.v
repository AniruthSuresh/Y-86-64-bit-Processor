
// cmovxx,jmp doesnt compute the flags , the condition prior to the cmoxx , jmp sets the flag 


//Include the ALU folder and correspondingly all the files in it 
// `include "adder.v"
// `include "subtractor.v"
// `include "/home/aniruth/Desktop/Courses/IPA/Project/Project_Us/SEQ/ALU/alu.v"
// `include "ALU/adder.v"
// `include "ALU/subtractor.v"
// `include "ALU/and.v"
// `include "ALU/xor.v"

// `include "and.v"
// `include "xor.v"

`include "alu.v"


module execute(clk, E_icode, E_ifun, E_ValA, E_ValB, E_ValC, E_dstE, ZF, SF, OF, e_Cnd, e_ValE,e_dstE,m_stat,W_stat);

    //Input 
    input clk;
    input [3:0] E_icode, E_ifun;
    input signed[63:0] E_ValA, E_ValB, E_ValC;
    input [3:0] E_dstE;
    input [3:0] m_stat, W_stat ; // update only in case of normal oper (the prev two inst)


    // Output reg - to be written into "M" reg 
    output reg signed[63:0] e_ValE;
    output reg e_Cnd;
    output reg [3:0] e_dstE;

    // Output Reg 
    output reg ZF,SF,OF;
    reg old_ZF,old_SF,old_OF;


    // for updation of address in rmmovq and mrmovq 
    wire signed[63:0] new_mem; 
    
    //For OPq 
    wire signed [63:0] add_op;
    wire signed [63:0] sub_op;
    wire signed [63:0] and_op;
    wire signed [63:0] xor_op;

    // Stack pointer inc and dec 
    wire signed [63:0] add_sp_8;
    wire signed [63:0] sub_sp_8;

    // Check overflow and carry for alu ( never used again )
    wire of_1,of_2,of_3,of_4,of_5,of_6,of_7;
    wire carry_1,carry_2,carry_3,carry_4,carry_5,carry_6,carry_7;
    // the above values don't matter ( dont served as dummy inputs to get an output from ALU)


    // For rmmovq and mrmovq 
    ALU Add_new_mem(E_ValB, E_ValC, 2'b00, new_mem,carry_1,of_1); //control = 0 -> add 

    // For OPq 
    ALU add_out(E_ValB, E_ValA,2'b00, add_op,carry_2,of_2);
    ALU sub_out(E_ValB, E_ValA,2'b01, sub_op,carry_3,of_3); // should compute B-A 
    ALU and_out(E_ValB, E_ValA,2'b10, and_op,carry_4,of_4);
    ALU xor_out(E_ValB, E_ValA,2'b11, xor_op,carry_5,of_5);


    // For pushq and popq 
    ALU add_stack(E_ValB, 64'd8, 2'b00, add_sp_8,carry_6,of_6);
    ALU sub_stack(E_ValB, 64'd8, 2'b01, sub_sp_8,carry_7,of_7);


    always @(*) begin

        if(E_icode == 2) begin  // only for cmovxx we check ( rest all assign to E_dstE ( comes from d_dstE))

            if(e_Cnd == 1) begin
                e_dstE <= E_dstE;
            end

            else begin  // if cond fails -> then don't move 
                e_dstE = 4'hF ; // assign to 15 ( r15 doesnt exist)
            end

        end

        else begin 
            e_dstE <= E_dstE;
        end

    end



    always @(*) begin
        // CASE 1 and CASE 2 => halt and nop do not have any execution to be done
        if(E_icode == 0 || E_icode ==1) begin
        end
        
        // CASE 3 => cmovxx
        if (E_icode == 2) begin
            e_ValE <= E_ValA;
        end

        // CASE 4 => irmovq
        else if (E_icode == 3) begin
            e_ValE <= E_ValC;
        end

        // CASE 5 => rmmovq
        else if (E_icode == 4) begin
            e_ValE<= new_mem;
        end

        // CASE 6 => mrmovq
        else if (E_icode == 5) begin
            e_ValE <= new_mem;  /// index after address mode 
        end

        

        // CASE 7 => OPq has a different value of e_ValE for each operation
        else if (E_icode == 6) 
        begin

            //                                begin
            //         $display("%d %d %d %d",OF,ZF,SF,m_stat);
            // end

            if(E_ifun == 0) begin // add
                e_ValE <= add_op;
            end

            else if(E_ifun == 1) begin // sub
                e_ValE <= sub_op;
            end

            else if(E_ifun == 2) begin // and
                e_ValE <= and_op;
            end

            else if(E_ifun == 3) begin // xor
                e_ValE <= xor_op;
            end



            // Set the conditional codes 

            // Update the CC based on the values of m_stat and W_stat 

            // if((m_stat==4'h2 || m_stat == 4'h3 || m_stat==4'h4) && !(W_stat==4'h2 || W_stat == 4'h3 || W_stat==4'h4) ) begin 
            //     $display("yesss %d at",m_stat) ;
            //     $display("%d %d %d",OF,ZF,SF);
            //     OF<=OF;
            //     ZF<=ZF;
            //     SF<=SF;
            // end
            
            // if(!(m_stat==4'h2 || m_stat == 4'h3 || m_stat==4'h4) && !(W_stat==4'h2 || W_stat == 4'h3 || W_stat==4'h4) ) begin 
            //      $display("%d %d %d",OF,ZF,SF);
            //     $display("nooooo %d at",m_stat);end




            if(!(m_stat==4'h2 || m_stat == 4'h3 || m_stat==4'h4) && !(W_stat==4'h2 || W_stat == 4'h3 || W_stat==4'h4) ) begin 

                // ZF = Zero flag
                if(e_ValE == 64'b0) begin
                    ZF <= 1;
                    old_ZF = ZF;
                end

                else begin
                    ZF <= 0;
                    old_ZF = ZF;
                end

                // Sign flag
                if(e_ValE[63] == 1'b1) begin
                    SF <= 1;
                    old_SF = SF;
                end
                else begin
                    SF <= 0;
                    old_SF = SF;
                end

                // Overflow flag

                if(E_ifun == 1) begin   // diff overflow cond for subt 
                if (((E_ValA[63] == 1'b1) == (E_ValB[63] == 1'b0)) && ((e_ValE[63] == 1'b1) != (E_ValA[63] == 1'b1))) begin
                    // $display("here:%b\n",E_ValB);
                                    // $display("mstst babay a %d , %d",m_stat,e_ValE);

                    OF <= 1;
                    old_OF = OF;
                end

                else begin
                    OF <= 0;
                    old_OF = OF;
                end
                
                end

                else begin 
                if (((E_ValA[63] == 1'b1) == (E_ValB[63] == 1'b1)) && ((e_ValE[63] == 1'b1) != (E_ValA[63] == 1'b1))) begin
                    // $display("there\n");
                    // $display("mstst babay a %d , %d %d",m_stat,e_ValE,W_stat);

                    OF <= 1;
                    old_OF = OF;
                end

                else begin
                    OF <= 0;
                    old_OF = OF;
                end
            end


        end

        else begin // used when the inst following the jump is not valid 
            ZF = old_ZF;
            SF = old_SF;
            OF = old_OF;
        end



        end

        // CASE 8 => jxx does not have a e_ValE
        else if(E_icode == 7) begin
            e_ValE = 64'hx;
        end

        // CASE 9 => call
        else if (E_icode == 8) begin
            e_ValE <= sub_sp_8;
        end

        // CASE 10 => ret
        else if (E_icode == 9) begin
            e_ValE <= add_sp_8;

        end

        // CASE 11 => pushq
        else if (E_icode == 10) begin
            e_ValE <= sub_sp_8;
                 
        end

        // CASE 12 => popq
        else if (E_icode == 11) begin
            e_ValE <= add_sp_8;
        end


        if ((E_icode == 2) || (E_icode == 7)) begin

            if (E_ifun == 0) begin // rrmovq 
                e_Cnd = 1'b1; //Always jump -> Unconditional 
            end

            else if (E_ifun == 1) begin // cmovle , jle 
                e_Cnd = (SF ^ OF) | ZF ? 1'b1 : 1'b0; 
            end

            else if (E_ifun == 2) begin // cmovl , jl
                e_Cnd = (SF ^ OF) ? 1'b1 : 1'b0; 
            end

            else if (E_ifun == 3) begin // cmove , je
                e_Cnd = ZF ? 1'b1 : 1'b0;
            end

            else if (E_ifun == 4) begin // cmovne , jne 
                e_Cnd = ~ZF ? 1'b1 : 1'b0; 
            end
            
            else if (E_ifun == 5) begin // cmovge , jge
                e_Cnd = ~(SF ^ OF) ? 1'b1 : 1'b0; 
            end

            else if (E_ifun == 6) begin // cmovg , jg 
                e_Cnd = ~(SF ^ OF) & ~ZF ? 1'b1 : 1'b0; 
            end

            else begin
                e_Cnd = 0;
            end

        end

        else begin   // for rest of the cases , e_Cnd value doesnt matter so just put = 0
            e_Cnd = 0;
        end

    end


endmodule




