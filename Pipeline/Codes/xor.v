module xor_64_bits(a,b,fin);

    input [63:0] a,b;
    output [63:0] fin;

    genvar i;

    generate

        for(i=0;i<64;i=i+1) begin
            xor x1(fin[i],a[i],b[i]);
        end

    endgenerate

endmodule
