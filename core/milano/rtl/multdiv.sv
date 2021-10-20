// +FHDR------------------------------------------------------------------------
//                                                                              
//  Copyright(c)2021, ZGOO                                                      
//  All rights reserved                                                         
//                                                                              
//  File name   : multdiv.sv
//  Module name : multdiv                                                   
//  Author      : ske
//  Description : 
//                                                                              

/***************************************
#
#			Filename:ex_stage.sv
#
#			Developer:ske
#			Description:---
#			CreatTime:2021-09-28 23:16:45
#
***************************************/

`default_nettype none


module multdiv(
    input   logic                   clk_i           ,
    input   logic                   rst_ni          ,

    input   logic   [4:0]           rd_addr_i       ,
    input   logic                   rd_we_i         ,
    input   milano_pkg::md_opt_e    md_operate_i    ,
    input   logic   [31:0]          md_operand_a_i  ,
    input   logic   [31:0]          md_operand_b_i  ,
    // rd register wirte interface
    output  logic                   md_rd_we_o      ,
    output  logic   [4:0]           md_rd_waddr_o   ,
    output  logic   [31:0]          md_rd_wdata_o       


);
    // parameters

    // signals : logic/wire/reg
    logic   [31:0]  dividend;
    logic   [31:0]  divisor;
    logic   [31:0]  quotient;
    logic   [31:0]  remainder;
    logic           div_done;
    logic           div_start;

    logic   [63:0]  mul_op_a_op_b;
    logic   [63:0]  rev_mul_op_a_op_b;
    logic   [31:0]  rev_md_operand_a_i;
    logic   [31:0]  rev_md_operand_b_i;
    assign          rev_md_operand_a_i = ~md_operand_a_i+1;
    assign          rev_md_operand_b_i = ~md_operand_b_i+1;
    assign          mul_op_a_op_b = md_operate_i == MD_OP_MULSU ?   (md_operand_a_i[31] ? rev_md_operand_a_i * md_operand_b_i : md_operand_a_i * md_operand_b_i) :
                                    md_operate_i == MD_OP_MULHU ?   md_operand_a_i * md_operand_b_i : 
                                                                    (({md_operand_a_i[31], md_operand_b_i[31]} == 2'b00)  ?   md_operand_a_i * md_operand_b_i     :
                                                                     ({md_operand_a_i[31], md_operand_b_i[31]} == 2'b01)  ?   md_operand_a_i * rev_md_operand_b_i : 
                                                                     ({md_operand_a_i[31], md_operand_b_i[31]} == 2'b10)  ?   rev_md_operand_a_i*md_operand_b_i   : 
                                                                     ({md_operand_a_i[31], md_operand_b_i[31]} == 2'b10)  ?   rev_md_operand_a_i * rev_md_operand_b_i : 64'h0);

    assign          rev_mul_op_a_op_b = ~mul_op_a_op_b + 1'b1;

    // combinational logic


    always_comb begin
        if(!rst_ni) begin
            md_rd_we_o = 1'h0;
            md_rd_waddr_o = 5'h0;
            md_rd_wdata_o = 32'h0;
        end else begin
            md_rd_waddr_o = rd_addr_i;
            md_rd_we_o    = rd_we_i;
            unique case (md_operate_i)
                MD_OP_MUL : begin
                    unique case (md_operand_a_i[31]^md_operand_b_i[31])
                        1'b0    :   md_rd_wdata_o = mul_op_a_op_b[31:0];
                        1'b1    :   md_rd_wdata_o = rev_mul_op_a_op_b[31:0];
                        default: ;
                    endcase
                end
                MD_OP_MULH: begin 
                    unique case (md_operand_a_i[31]^md_operand_b_i[31])
                        1'b0    :   md_rd_wdata_o = mul_op_a_op_b[63:32];
                        1'b1    :   md_rd_wdata_o = rev_mul_op_a_op_b[63:32];
                        default: ;
                    endcase
                end
                MD_OP_MULSU:begin
                    unique case (md_operand_a_i[31])
                        1'b0    :   md_rd_wdata_o = mul_op_a_op_b[63:32];
                        1'b1    :   md_rd_wdata_o = rev_mul_op_a_op_b[63:32];
                        default: ;
                    endcase
                end
                MD_OP_MULHU:    md_rd_wdata_o = mul_op_a_op_b[63:32];
                MD_OP_DIV : begin
                    unique case (md_operand_a_i[31]^md_operand_b_i[31])
                        1'b0    :   begin 
                                        if (div_done)begin
                                            if(md_operand_b_i==32'h0) md_rd_wdata_o = 32'hffffffff;
                                            else md_rd_wdata_o = ~quotient+1'b1;
                                        end else
                                            md_rd_wdata_o = 32'h0;
                                    end
                        1'b1    :   begin
                                        if (div_done)begin
                                            if(md_operand_b_i==32'h0) md_rd_wdata_o = 32'hffffffff;                                        
                                            else md_rd_wdata_o = quotient;
                                        end else
                                            md_rd_wdata_o = 32'h0;
                                    end
                        default: ;
                    endcase
                end
                MD_OP_DIVU:     md_rd_wdata_o = quotient;
                MD_OP_REM:  begin
                    unique case (md_operand_a_i[31]^md_operand_b_i[31])
                        1'b0    :   md_rd_wdata_o = ~remainde+1'b1;
                        1'b1    :   md_rd_wdata_o = remainde;
                        default: ;
                    endcase
                end
                MD_OP_REMU:     md_rd_wdata_o = remainde;            
                default: md_rd_wdata_o = 32'h0;
            endcase
        end
    end
    
    assign  dividend = md_operate_i ==  (MD_OP_DIV || MD_OP_REM) ? (md_operand_a_i[31] ? rev_md_operand_a_i : md_operand_a_i) : md_operand_a_i;
    assign  divisor  = md_operate_i ==  (MD_OP_DIV || MD_OP_REM) ? (md_operand_b_i[31] ? rev_md_operand_b_i : md_operand_b_i) : md_operand_b_i;

    assign  div_start = md_operate_i == MD_OP_DIV || MD_OP_DIVU || MD_OP_REM || MD_OP_REMU;

    div u_div(
        .clk_i      ( clk_i     ),
        .rst_ni     ( rst_ni    ),
        .div_star   ( div_star  ),
        .dividend   ( dividend  ),
        .divisor    ( divisor   ),
        .quotient   ( quotient  ),
        .remainde   ( remainde  ),
        .div_done   ( div_done  )
);
endmodule


`default_nettype wire

