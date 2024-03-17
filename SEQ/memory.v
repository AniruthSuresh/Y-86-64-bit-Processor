module memory(icode, ValA, ValB, ValE, ValP, ValM ,clk,dmem_err);

    // Inputs 
    input clk;
    input [3:0] icode;
    input signed[63:0] ValA ,ValB, ValE, ValP;


    // Output 
    output reg signed[63:0] ValM;
    output reg dmem_err;
    

    reg [63:0] data_mem[0:1023];


    integer i ;
    // Initialise all the mem value to index value ( just for verification )
    initial begin
        for (i = 0; i < 1024; i = i + 1) begin
            data_mem[i] = i;
        end
    end

    

    always@ (*) begin

        if(icode == 4 || icode == 5 || icode == 8 || icode == 10) begin

            if((0 <= ValE) && (ValE < 1024)) begin
                dmem_err = 0;
            end

            else begin
                dmem_err = 1; 
            end

        end
        

        if(icode == 9 || icode == 11) begin

            if((0 <= ValA) && (ValA < 1024)) begin
                dmem_err = 0;
            end

            else begin
                dmem_err = 1; 
            end

        end

        // CASE 5 => rmmovq
        if (icode == 4) begin 
            data_mem[ValE] = ValA;
        end

        // CASE 6 => mrmovq
        else if (icode == 5) begin
            ValM = data_mem[ValE];


            if (ValM === 64'hx) begin
                dmem_err = 1;
            end

            else begin
                dmem_err = 0;
            end



        end
       
       // CASE 9 => call
        else if (icode == 8) begin
            data_mem[ValE] = ValP;
        end

        // CASE 10 => ret
        else if (icode == 9) begin
            ValM = data_mem[ValA];


            if (ValM === 64'hx) begin
                dmem_err = 1;
            end

            else begin
                dmem_err = 0;
            end


        end

        // CASE 11 => pushq
        else if (icode == 10) begin

            // ValM = data_mem[ValE];
            data_mem[ValE]= ValA;


            if (ValM === 64'hx) begin
                dmem_err = 1;
            end

            else begin
                dmem_err = 0;
            end


        end

        // CASE 12 => popq
        else if (icode == 11) begin
            
            ValM = data_mem[ValA];


            if (ValM === 64'hx) begin
                dmem_err = 1;
            end

            else begin
                dmem_err = 0;
            end

        end

        // rest of the cases-> memory not used 
        else begin
            dmem_err = 0;
        end

    end



endmodule



