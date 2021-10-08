module alu(
    input  milano_pkg::alu_opt_e    operator_i,
    input  logic [31:0]             operand_a_i,
    input  logic [31:0]             operand_b_i,
    input  logic [31:0]             rd_addr_o,
    output logic                    reg_we_i,
    output logic                    wr_addr_o
);
    logic [31:0] reslut;
    always @(*)begin
        reg_we_i = 1'b0;
        case(operator_i)
            ALU_ADD: begin
                reslut = operand_a_i + operand_b_i;
                reg_we_i = 1'b1;
                wr_addr_o=rd_addr_o;
            end
            ALU_SUB: begin
                reslut = operand_a_i - operand_b_i;
                reg_we_i = 1'b1;
                wr_addr_o=rd_addr_o;
            end
            default:;
        endcase
    end
endmodule
