`include "adder.v"
`include "subtractor.v"
`include "and.v"
`include "xor.v"


module ALU(a,b,control,result,carry,of);

input signed [63:0] a,b;
input signed [1:0] control;


output reg signed [63:0] result;
output reg of;
wire signed [63:0] Sum , Diff , and_op , xor_op;
wire sum_carry , borrow_carry;
output reg carry;

add_64_bit add(a,b,Sum,sum_carry);
sub_64_bit sub(a,b,Diff,borrow_carry);
and_64_bits and_alu(a,b,and_op);
xor_64_bits xor_alu(a,b,xor_op);

always@(*) begin

    case(control)

    2'b00:  //adder call 
    begin 
    result <= Sum;
    carry <= sum_carry;

    begin
        of = 1'b0;
        if(((a<0) == (b<0)) && ((result<0) != (a<0)))begin
            of = 1;
        end

    end

    end

    2'b01:  //sub call 
    begin
    result <= Diff;
    carry <= borrow_carry;

    begin
        of = 1'b0;
        if(((a<0) == (b>0)) && ((result<0) != (a<0)))begin
            of = 1;
        end
    end

    end

    2'b10:  //and call 
    begin
    result <= and_op;
    carry <= 0;
    end

    2'b11:  //xor call 
    begin
    result <= xor_op;
    carry  <= 0;
    end


    endcase


end


endmodule