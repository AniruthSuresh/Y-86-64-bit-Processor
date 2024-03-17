module pipeline_control(F_stall,D_stall,D_bubble,E_bubble,M_bubble,W_stall,D_icode,d_srcA,d_srcB,E_icode,E_dstM,e_Cnd,M_icode,m_stat,W_stat);

    //  inputs 
    input [3:0] D_icode,M_icode;
    input [3:0] d_srcA,d_srcB;
    input [3:0] E_icode,E_dstM;
    input [3:0] m_stat,W_stat;
    input e_Cnd;

    // Output reg 
    output reg F_stall,D_stall,D_bubble,E_bubble,M_bubble,W_stall;

    initial 
    begin
        F_stall <= 1'b0;
        D_stall <= 1'b0; 
        D_bubble <= 1'b0;
        E_bubble <= 1'b0;
        M_bubble <= 1'b0;
        W_stall <= 1'b0; 
    end


    always @(*) begin

        // load/use and return case 
	    F_stall <= ( ((E_icode == 4'h5 || E_icode == 4'hB) && (E_dstM == d_srcA || E_dstM == d_srcB)) || (D_icode == 4'h9 || E_icode == 4'h9 || M_icode == 4'h9));

        // Mispredicted Jump || (! load/use but ret)
        D_bubble <= (( E_icode == 4'h7 && !e_Cnd ) || (!((E_icode == 4'h5 || E_icode == 4'hB)  && (E_dstM == d_srcA || E_dstM == d_srcB)) && (D_icode == 4'h9 || E_icode == 4'h9 || M_icode == 4'h9)) );
        // D_bubble <= (( E_icode == 4'h7 && !e_Cnd ) || (!((E_icode == 4'h5 || E_icode == 4'hB)  && (E_dstM == d_srcA || E_dstM == d_srcB)) && (D_icode == 4'h9 || E_icode == 4'h9 || M_icode == 4'h9)));
        // D_bubble <=1'b1;
        // Load/ Use hazard 
        D_stall <= (E_icode == 4'h5 || E_icode == 4'hB) && (E_dstM == d_srcA || E_dstM == d_srcB);

        // $display("E_icode = %b, E_dstM = %b, d_srcA = %b, d_srcB = %b, D_icode = %b, M_icode = %b, e_Cnd = %b", E_icode, E_dstM, d_srcA, d_srcB, D_icode, M_icode, e_Cnd);

        // Jump and load/use hazard 
        E_bubble <= (( E_icode == 4'h7 && !e_Cnd ) || ((E_icode == 4'h5 || E_icode == 4'hB)  && (E_dstM == d_srcA || E_dstM== d_srcB)));

        // When there is a error , dont access the mem -> set Bubble in memory and writeback 
        M_bubble <= (m_stat == 4'h2 ||  m_stat == 4'h3 || m_stat == 4'h4) || (W_stat == 4'h2 ||  W_stat == 4'h3 || W_stat == 4'h4 );
        // M_bubble <= ((m_stat == 4'h2 ||  m_stat == 4'h3 || m_stat == 4'h4) || (W_stat == 4'h2 ||  W_stat == 4'h3 || W_stat == 4'h4 )) && (e_Cnd == 1);
        // W_stall <= (W_stat == 4'h2 ||  W_stat == 4'h3 || W_stat == 4'h4);
        W_stall <= (W_stat == 4'h2 ||  W_stat == 4'h3 || W_stat == 4'h4) ;

        

    end


endmodule