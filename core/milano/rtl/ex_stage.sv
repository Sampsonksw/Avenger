module ex_stage(
    input logic         clk_i,
    input logic         rst_ni,
        
);




alu u_alu(
    .operator_i,
    .operand_a_i,
    .operand_b_i,
    .rd_addr_o,
    .reg_we_i,
    .wr_addr_o
);

endmodule
