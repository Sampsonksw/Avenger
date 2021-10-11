`default_nettype none
module alu(
    input  logic                    rst_ni,
    input  milano_pkg::alu_opt_e    operator_i,
    input  logic [31:0]             operand_a_i,//s1
    input  logic [31:0]             operand_b_i,//s2
    input  logic [31:0]             rd_addr_i,
    input  logic                    rd_wr_en_i,
    output logic                    reg_we_o,
    output logic [4:0]              wr_addr_o,
    output logic [31:0]             rd_wdata_o
);
    import milano_pkg::*;
    logic [31:0] count_reslut;
    //assign rd_wdata_o = reslut;
    always_comb begin
        if(!rst_ni)begin
            reg_we_o = 1'b0;
            wr_addr_o = 'h0;
        end else begin
            case(operator_i)
                ALU_ADD: begin
                    count_reslut = operand_a_i + operand_b_i;
                    reg_we_o = rd_wr_en_i;
                    wr_addr_o=rd_addr_i;
                    rd_wdata_o = count_reslut;
                end
                ALU_SUB: begin
                    count_reslut = operand_a_i - operand_b_i;
                    reg_we_o = rd_wr_en_i;
                    wr_addr_o=rd_addr_i;
                    rd_wdata_o = count_reslut;
                end
                ALU_XOR: begin
                    count_reslut = operand_a_i ^ operand_b_i;
                    reg_we_o = rd_wr_en_i;
                    wr_addr_o=rd_addr_i;
                    rd_wdata_o = count_reslut;
                end
                ALU_OR:  begin
                    count_reslut = operand_a_i | operand_b_i;
                    reg_we_o = rd_wr_en_i;
                    wr_addr_o=rd_addr_i;
                    rd_wdata_o = count_reslut;
                end
                ALU_AND: begin
                    count_reslut = operand_a_i & operand_b_i;
                    reg_we_o = rd_wr_en_i;
                    wr_addr_o=rd_addr_i;
                    rd_wdata_o = count_reslut;
                end
                ALU_SLL: begin      // Shfit Left Logic
                    count_reslut = operand_a_i << operand_b_i;
                    reg_we_o = rd_wr_en_i;
                    wr_addr_o=rd_addr_i;
                    rd_wdata_o = count_reslut;
                end
                ALU_SRL: begin      // Shfit Right Logic
                    count_reslut = operand_a_i >> operand_b_i;
                    reg_we_o = rd_wr_en_i;
                    wr_addr_o=rd_addr_i;
                    rd_wdata_o = count_reslut;
                end
                ALU_SRA: begin      // Shfit Right Arithmatic
                    count_reslut = operand_a_i[31] ? ((operand_a_i >> operand_b_i)|(~((32'hffff)>>operand_b_i)&({32{operand_a_i[31]}}))) : operand_a_i >> operand_b_i;
                    reg_we_o = rd_wr_en_i;
                    wr_addr_o=rd_addr_i;
                    rd_wdata_o = count_reslut;
                end
                ALU_SLT: begin      // Set Less Than
                    count_reslut = (operand_a_i[31] ^ operand_b_i[31]) ? (operand_a_i[31] ? 32'h1 : 32'h0) : (operand_a_i < operand_b_i ? 32'h1 : 32'h0);
                    reg_we_o = rd_wr_en_i;
                    wr_addr_o=rd_addr_i;
                    rd_wdata_o = count_reslut;
                end
                ALU_SLTU: begin     // Set Less Than Unsigned
                    count_reslut = (operand_a_i < operand_b_i)? 32'h1 : 32'h0;
                    reg_we_o = rd_wr_en_i;
                    wr_addr_o=rd_addr_i;
                    rd_wdata_o = count_reslut;
                end
                default: begin 
                    count_reslut = 'h0;
                    reg_we_o = 'h0;
                    wr_addr_o = 'h0;
                    rd_wdata_o = 'h0;
                end
            endcase
        end
    end
endmodule
