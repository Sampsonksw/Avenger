/***************************************
#
#			Filename:ex_stage.sv
#
#			Developer:ske
#			Description:---
#			CreatTime:2021-10-21 10:46:26
#
***************************************/

`default_nettype none



module ctrl(
    input   logic               clk_i               ,
    input   logic               rst_ni              ,

    input   logic               stallreq_from_ex_i  ,

    output  logic               stall_o             
);
    // parameters

    // signals : logic/wire/reg

    // module instantiation


    // combinational logic
    always_comb begin
        if(!rst_ni)begin
            stall_o = 1'b0;
        end else if(stallreq_from_ex_i)begin
            stall_o = 1'b1;
        end else begin
            stall_o = 1'b0;
        end
    end
    
endmodule


`default_nettype wire
