module full_adder (x,y,z,sum,carry);

    input x, y, z;
    output sum, carry;

    wire w1, w2, w3;

    xor x1(w1, x, y);
    and a1(w2, x, y);
    xor x2(sum, w1, z);  // sum part = x + y + z

    and a2(w3, w1, z);
    or o2(carry, w3, w2);

endmodule



module add_64_bit (a,b,S,C);

    input [63:0] a, b;
    output [63:0] S;
    output C;

    wire [64:0] int_carry;

    genvar i, j;

    assign int_carry[0] = 0; 

    generate

        for (i = 0; i < 64; i = i + 1) begin
            
            full_adder f1(a[i],b[i],int_carry[i],S[i],int_carry[i+1]);
            // assign int_carry[i+1] = C[i];
        end

    endgenerate

    assign C = int_carry[64];

endmodule