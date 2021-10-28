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
    input   logic           clk_i               ,
    input   logic           rst_ni              ,
    //stall from ctrl
    input   logic           stall_from_ctrl_i   ,
    //refresh from ctrl
    input   logic           refresh_pip_i       ,
    input   logic   [31:0]  boot_addr_i         ,
	//input form ram
	input   logic   [31:0]  instr_rdata_i       ,
	//outputs to instr ram/ID
	output  logic   [31:0]  instr_addr_o        ,
    output  logic           fetch_enable_o      ,
	//outputs to ID
	output  logic   [31:0]  instr_rdata_id_o    ,
    output  logic   [31:0]  instr_addr_id_o     ,
    //from ex
    input   logic           jump_flag_i         ,
    input   logic   [31:0]  jump_addr_i         ,     
    //from ctrl
    input   logic           ctrl_jump_flag_i    ,
    input   logic   [31:0]  ctrl_jump_addr_i
);


/************	prefetch_reg inst	******************/

prefetch_reg u_prefetch_reg(
    .clk_i		        ( clk_i	            ),
    .rst_ni		        ( rst_ni	        ),
    .stall_from_ctrl_i  ( stall_from_ctrl_i ),
    .refresh_pip_i      ( refresh_pip_i     ),
    .boot_addr_i	    ( boot_addr_i       ),		//from boot address sel
    .instr_addr_o 	    ( instr_addr_o      ),		//to instr ram
    .fetch_enable_o     ( fetch_enable_o    ),
    .jump_flag_i        ( jump_flag_i       ),
    .jump_addr_i        ( jump_addr_i       ),
    .ctrl_jump_flag_i   ( ctrl_jump_flag_i  ),
    .ctrl_jump_addr_i   ( ctrl_jump_addr_i  )
);

/************	if_id_reg inst	******************/   

if_id_reg u_if_id_reg(
	.clk_i			    ( clk_i             ),
	.rst_ni			    ( rst_ni            ),
    .stall_from_ctrl_i  ( stall_from_ctrl_i ),
    .refresh_pip_i      ( refresh_pip_i     ),
	.instr_rdata_i		( instr_rdata_i     ),
	.instr_addr_i		( instr_addr_o      ),
	.instr_rdata_id_o	( instr_rdata_id_o  ),
	.instr_addr_id_o	( instr_addr_id_o   )
);
endmodule

`default_nettype wire
