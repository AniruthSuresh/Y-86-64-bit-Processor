
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


module execute(clk, icode, ifun, ValA, ValB, ValC, ZF, SF, OF, Cnd, ValE);

    //Input 
    input clk;
    input [3:0] icode, ifun;
    input signed[63:0] ValA, ValB, ValC;

    // Output Reg 
    output reg ZF,SF,OF,Cnd;

    output reg signed[63:0] ValE;

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
    ALU Add_new_mem(ValB, ValC, 2'b00, new_mem,carry_1,of_1); //control = 0 -> add 

    // For OPq 
    ALU add_out(ValB, ValA,2'b00, add_op,carry_2,of_2);
    ALU sub_out(ValB, ValA,2'b01, sub_op,carry_3,of_3); // should compute B-A 
    ALU and_out(ValB, ValA,2'b10, and_op,carry_4,of_4);
    ALU xor_out(ValB, ValA,2'b11, xor_op,carry_5,of_5);


    // For pushq and popq 
    ALU add_stack(ValB, 64'd8, 2'b00, add_sp_8,carry_6,of_6);
    ALU sub_stack(ValB, 64'd8, 2'b01, sub_sp_8,carry_7,of_7);


    always @(*) begin
        // CASE 1 and CASE 2 => halt and nop do not have any execution to be done
        if(icode == 0 || icode ==1) begin
        end
        
        // CASE 3 => cmovxx
        if (icode == 2) begin
            ValE = ValA;
        end

        // CASE 4 => irmovq
        else if (icode == 3) begin
            ValE = ValC;
        end

        // CASE 5 => rmmovq
        else if (icode == 4) begin
            ValE = new_mem;
        end

        // CASE 6 => mrmovq
        else if (icode == 5) begin
            ValE = new_mem;
        end

        // CASE 7 => OPq has a different value of ValE for each operation
        else if (icode == 6) begin

            if(ifun == 0) begin // add
                ValE = add_op;
            end

            else if(ifun == 1) begin // sub
                ValE = sub_op;
            end

            else if(ifun == 2) begin // and
                ValE = and_op;
            end

            else if(ifun == 3) begin // xor
                ValE = xor_op;
            end

            // Set the conditional codes 

            // ZF = Zero flag
            if(ValE == 64'b0) begin
                ZF = 1;
            end
            else begin
                ZF = 0;
            end

            // Sign flag
            if(ValE[63] == 1'b1) begin
                SF = 1;
            end
            else begin
                SF = 0;
            end

            // Overflow flag

            if(ifun == 1) begin   // diff overflow cond for subt 
            if (((ValA[63] == 1'b1) == (ValB[63] == 1'b0)) && ((ValE[63] == 1'b1) != (ValA[63] == 1'b1))) begin
                // $display("here:%b\n",ValB);
                OF = 1;
            end

            else begin
                OF = 0;
            end
            
            end

            else begin 
            if (((ValA[63] == 1'b1) == (ValB[63] == 1'b1)) && ((ValE[63] == 1'b1) != (ValA[63] == 1'b1))) begin
                // $display("there\n");
                OF = 1;
            end

            else begin
                OF = 0;
            end
            end

        end

        // CASE 8 => jxx does not have a ValE
        else if(icode == 7) begin
            ValE = 64'hx;
        end

        // CASE 9 => call
        else if (icode == 8) begin
            ValE = sub_sp_8;
        end

        // CASE 10 => ret
        else if (icode == 9) begin
            ValE = add_sp_8;
        end

        // CASE 11 => pushq
        else if (icode == 10) begin
            ValE = sub_sp_8;
        end

        // CASE 12 => popq
        else if (icode == 11) begin
            ValE = add_sp_8;
        end


        if ((icode == 2) || (icode == 7)) begin

            if (ifun == 0) begin // rrmovq 
                Cnd = 1'b1; //Always jump -> Unconditional 
            end

            else if (ifun == 1) begin // cmovle , jle 
                Cnd = (SF ^ OF) | ZF ? 1'b1 : 1'b0; 
            end

            else if (ifun == 2) begin // cmovl , jl
                Cnd = (SF ^ OF) ? 1'b1 : 1'b0; 
            end

            else if (ifun == 3) begin // cmove , je
                Cnd = ZF ? 1'b1 : 1'b0;
            end

            else if (ifun == 4) begin // cmovne , jne 
                Cnd = ~ZF ? 1'b1 : 1'b0; 
            end
            
            else if (ifun == 5) begin // cmovge , jge
                Cnd = ~(SF ^ OF) ? 1'b1 : 1'b0; 
            end

            else if (ifun == 6) begin // cmovg , jg 
                Cnd = ~(SF ^ OF) & ~ZF ? 1'b1 : 1'b0; 
            end

            else begin
                Cnd = 0;
            end

        end

        else begin   // for rest of the cases , Cnd value doesnt matter so just put = 0
            Cnd = 0;
        end

    end

endmodule




