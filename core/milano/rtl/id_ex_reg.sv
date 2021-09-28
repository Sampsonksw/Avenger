/***************************************
#
#			Filename:id_ex_reg.sv
#
#			Developer:ske
#			Description:---
#			CreatTime:2021-09-27 22:15:35
#
***************************************/
module id_ex_reg(
    input  logic clk_i,
    input  logic rst_ni,
    input  logic [31:0] instr_i,
    output logic [31:0] instr_o
);

    always_ff @(posedge clk_i,negedge rst_ni)begin
        if (!rst_ni)begin
            instr_o<= 32'h0;
        end else begin
            instr_o<=instr_i;
        end
    end

endmodule

