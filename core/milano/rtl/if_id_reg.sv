module if_id_reg(
	input  logic clk_i,
	input  logic rst_ni,
    //input from instr ram
	input  logic [31:0]instr_rdata_i,
    //input from prefetch_reg
	input  logic [31:0]instr_addr_i,
    //output to ID
	output logic [31:0]instr_rdata_id_o,
	output logic [31:0]instr_addr_id_o
);

	always @(posedge clk_i or negedge rst_ni)begin
	    if(!rst_ni)begin
            instr_rdata_id_o <= 32'h0;
            instr_addr_id_o  <= 32'h0;
        end else begin
            instr_rdata_id_o <= instr_rdata_i;
            instr_addr_id_o  <= instr_addr_i;
        end
    end

endmodule	
