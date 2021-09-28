/***************************************
#
#			Filename:if_stage.sv
#
#			Developer:ske
#			Description:---
#			CreatTime:2021-09-27 22:10:11
#
***************************************/
module if_stage(
        input  logic clk_i,
        input  logic rst_ni,
        input  logic boot_addr_i,
        output logic [128:0] pc_o 
);

    always_ff @(posedge clk_i,negedge rst_ni)begin
        if(!rst_ni)begin
            pc_o <= boot_addr_i;
        end else begin
            pc_o <= pc_o + 4;
        end
    end


endmodule

