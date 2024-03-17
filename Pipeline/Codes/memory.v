module memory(M_icode, M_ValA, M_ValE,M_stat, m_ValM,m_stat ,clk,dmem_err);

    // Inputs 
    input clk;
    input [3:0] M_icode;
    input signed[63:0] M_ValA , M_ValE ; 
    input [3:0] M_stat;


    // Output 
    output reg signed[63:0] m_ValM;
    output reg [3:0] m_stat;
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

        if(M_icode == 4 || M_icode == 5 || M_icode == 8 || M_icode == 10) begin

            if((0 <= M_ValE) && (M_ValE < 1024)) begin
                dmem_err = 0;
                // $display("shit1 at PC = %d",M_ValE);

            end

            else begin
                dmem_err = 1; 
                // $display("shit2 at PC = %d",M_ValE);
            end
            

        end
        

        if(M_icode == 9 || M_icode == 11) begin

            if((0 <= M_ValA) && (M_ValA < 1024)) begin
                dmem_err = 0;
            end

            else begin
                dmem_err = 1; 
            end

        end

        // CASE 5 => rmmovq
        if (M_icode == 4 ) begin 

            if(dmem_err==0) begin
            data_mem[M_ValE] = M_ValA;
            end

            // if (M_ValE === 64'hx ) begin
            //     dmem_err = 1;
            // end


        end

        // CASE 6 => mrmovq
        else if (M_icode == 5 ) begin

            if(dmem_err==0) begin
            m_ValM = data_mem[M_ValE];
            end


            // if (m_ValM === 64'hx) begin // if it doesnt exist in memory -> then show doesnt exixt 
            //     dmem_err = 1;
            // end



        end
       
       // CASE 9 => call
        else if (M_icode == 8 ) begin
            
            if(dmem_err==0) begin
            data_mem[M_ValE] = M_ValA;  // ValM is stored in M_ValA
            end
        end


        // CASE 10 => ret
        else if (M_icode == 9 ) begin

            if(dmem_err==0) begin
            m_ValM = data_mem[M_ValA];
            end


            // if (m_ValM === 64'hx) begin
            //     dmem_err = 1;
            // end



        end

        // CASE 11 => pushq
        else if (M_icode == 10 ) begin

            // m_Val = data_mem[M_ValE];
            if(dmem_err==0) begin
            data_mem[M_ValE]= M_ValA;end


            // if (M_ValA == 64'hx ) begin
            //     dmem_err = 1;
            // end

  

        end

        // CASE 12 => popq
        else if (M_icode == 11) begin
            
            if(dmem_err==0) begin
            m_ValM = data_mem[M_ValA];end


            // if (m_ValM === 64'hx) begin
            //     dmem_err = 1;
            // end

     

        end

        // rest of the cases-> memory not used 
        else begin
            dmem_err = 0;
        end

    end

    // Setting the stat code 
    always @(*)
    begin

        if(dmem_err==1) begin 
            m_stat <= 4'h3;  // SADR 
        end

        else begin 
            m_stat <= M_stat;
        end

    end


endmodule

