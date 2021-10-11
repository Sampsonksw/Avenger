/***************************************
#
#			Filename:if_stage.sv
#
#			Developer:ske
#			Description:---
#			CreatTime:2021-09-27 22:10:11
#
***************************************/
`default_nettype none
module if_stage(
        input  logic        clk_i,
        input  logic        rst_ni,
        input  logic [31:0] boot_addr_i,
	    //input form ram
	    input  logic [31:0] instr_rdata_i,
	    //outputs to instr ram/ID
	    output logic [31:0] instr_addr_o,
        output logic        fetch_enable_o,
	    //outputs to ID
	    output logic [31:0] instr_rdata_id_o,
        output logic [31:0] instr_addr_id_o
        //output logic [31:0] pc_id_o
);


/************	prefetch_reg inst	******************/

prefetch_reg u_prefetch_reg(
        .clk_i		    (clk_i	     ),
        .rst_ni		    (rst_ni	     ),
        .boot_addr_i	(boot_addr_i ),		//from boot address sel
        .instr_addr_o 	(instr_addr_o),		//to instr ram
        .fetch_enable_o (fetch_enable_o)
);

/************	if_id_reg inst	******************/   

if_id_reg u_if_id_reg(
	.clk_i			    (clk_i),
	.rst_ni			    (rst_ni),
	.instr_rdata_i		(instr_rdata_i),
	.instr_addr_i		(instr_addr_o),
	.instr_rdata_id_o	(instr_rdata_id_o),
	.instr_addr_id_o	(instr_addr_id_o)
);
endmodule

