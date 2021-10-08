/***************************************
#
#			Filename:decoder.sv
#
#			Developer:ske
#			Description:---
#			CreatTime:2021-09-27 22:22:20
#
***************************************/
module decoder(
    input logic clk_i,
    input logic rst_ni,
    // from IF-ID pipeline register
    input logic [31:0] instr_rdata_i,   //instr data 
    // from register file
    input logic [31:0] rs1_rdata_i,     //source reg1
    input logic [31:0] rs2_rdata_i,     //source reg2
    // output to register file
    output logic [4:0] rs1_addr_o,      //source reg1 addr
    output logic [4:0] rs2_addr_o,      //source reg2 addr
    // output to ID-EX pipeline register
    output logic [4:0] rd_addr_o,       //destination reg addr
    output logic [31:0]rs1_data,
    output logic [31:0]rs2_data,
    output logic       alu_operate_o
);
    import milano_pkg::*;
    //logic [31:0] instr =  instr_rdata_i;
    logic [31:0] instr;
    opcode_e    opcode;
    function_e   funct;
    assign opcode          = opcode_e'(instr[6:0]);
    assign funct           = function_e'({instr[31:25],instr[14:12]});
//    assign opcode       = instr_rdata_i[6:0];
//    assign rd_addr_o    = instr_rdata_i[11:7];
//    assign funct3       = instr_rdata_i[14:12];
//    assign rs1_addr_o   = instr_rdata_i[19:15];
//    assign rs2_addr_o   = instr_rdata_i[24:20];
//    assign funct7       = instr_rdata_i[31:25];  
    always_comb begin
        //opcode          = opcode_e'(instr[6:0]);
        //funct           = function_e'({instr[31:25],instr[14:12]});
        instr           = instr_rdata_i;
        rs1_addr_o      = instr[19:15];
        rs2_addr_o      = instr[24:20];
        rs1_data        = 'h0;
        rs2_data        = 'h0;
        alu_operate_o   = 'h0;
        rd_addr_o       = 'h0;
        case (opcode)
            OPCODE_OP : begin
                case (funct)
                    INST_ADD : begin
                        alu_operate_o = ALU_ADD;
                        rs1_data = rs1_rdata_i;
                        rs2_data = rs2_rdata_i;
                        rd_addr_o = instr[11:7];
                    end
                    INST_SUB : begin
                        alu_operate_o = ALU_SUB;
                        rs1_data = rs1_rdata_i;
                        rs2_data = rs2_rdata_i;

                    end
                    default: begin
                    end
                endcase
            end
            default: begin

            end

        endcase
    end
endmodule

