module reg_memory(clk,M_bubble,E_stat,E_icode,e_Cnd,e_ValE, E_ValA,e_dstE,E_dstM, M_stat,M_icode,M_Cnd,M_ValE, M_ValA,M_dstE ,M_dstM);

	// Inputs 
	input clk;
	input M_bubble;

	// Values into the pipeline 
	input [3:0] E_stat;
	input [3:0] E_icode ;
	input e_Cnd;
	input [63:0] e_ValE, E_ValA;
	input [3:0] e_dstE,E_dstM;


	// Output reg - into the pipeline 
	output reg [3:0] M_stat;
	output reg [3:0] M_icode; 
	output reg M_Cnd;
	output reg [63:0]M_ValE, M_ValA;
	output reg [3:0]M_dstE ,M_dstM;


	always @(posedge(clk)) begin

	    if (M_bubble==1) begin   // bubbling - just set it to some fixed configuration (user defined )
			M_icode  <= 4'h1;
			M_dstE <= 4'hF;
			M_dstM <= 4'hF;
		end

		else begin
				
			M_icode <= E_icode;
			M_Cnd <= e_Cnd;
			M_ValE <= e_ValE;
			M_ValA <= E_ValA;
			M_dstE <= e_dstE;
			M_dstM <= E_dstM;
			M_stat <= E_stat;

		end
	end

endmodule

