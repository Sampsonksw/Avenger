/***************************************
#
#			Filename:prefetch_reg.sv
#
#			Developer:ske
#			Description:---
#			CreatTime:2021-09-25 16:22:20
#
***************************************/

`default_nettype none


module prefetch_reg(
    input   logic               clk_i               ,
    input   logic               rst_ni              ,
    input   logic               stall_from_ctrl_i   ,
    input   logic               refresh_pip_i       ,
    input   logic   [31:0]      boot_addr_i         ,		        //from boot address sel
    output  logic   [31:0]      instr_addr_o        ,     	        //to instr ram
    output  logic               fetch_enable_o      ,
    //from ex 
    input   logic               jump_flag_i         ,
    input   logic   [31:0]      jump_addr_i         ,
    //from ctrl
    input   logic               ctrl_jump_flag_i    ,
    input   logic   [31:0]      ctrl_jump_addr_i
);

// prefetch address logic
    always_ff @(posedge clk_i,negedge rst_ni)begin
        if(!rst_ni)begin
            fetch_enable_o  <= 1'b0;
        end else begin
            fetch_enable_o  <= 1'b1;
        end
    end

    always_ff @(posedge clk_i,negedge rst_ni)begin
        if(!rst_ni)begin
            instr_addr_o <= boot_addr_i;
        end else if(!fetch_enable_o) begin
            instr_addr_o <= boot_addr_i;
        end else if(ctrl_jump_flag_i)begin
            instr_addr_o <= ctrl_jump_addr_i;
        end else if(jump_flag_i)begin
            instr_addr_o <= jump_addr_i;
        end else if(refresh_pip_i)begin
            instr_addr_o <= instr_addr_o;
        end else if(stall_from_ctrl_i)begin
            instr_addr_o <= instr_addr_o;
        end else begin
            instr_addr_o <= instr_addr_o + 4;
        end
    end

endmodule
