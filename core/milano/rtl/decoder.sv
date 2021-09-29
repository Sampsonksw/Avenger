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
    // input from IF-ID pipeline register
    input logic [31:0]  instr_rdata_i,   //instr data
    // input from register file
    input logic [31:0]  rs1_rdata_i,
    input logic [31:0]  rs2_rdata_i,
    // output to register file
    output logic [4:0]  rs1_addr_o,      //source reg1 addr
    output logic [4:0]  rs2_addr_o,      //source reg2 addr
    // output to ID-EX pipeline register
    ////imm
    //output logic imm_o,
    ////opcode
    //output logic [6:0] opcode,
    ////func
    //output logic [2:0] funct3,          //fun3
    //output logic [6:0] funct7,          //fun7
    ////rs1,rs2 rdata
    output logic [31:0] rs1_data_o,
    output logic [31:0] rs2_data_o,
    ////rd
    output logic [4:0]  rd_addr_o,       //destination reg addr
    output logic        rd_we_o


);
    import milano_pkg::*;
    logic [31:0] instr =  instr_rdata_i;
    opcode_e    opcode;

    assign opcode       = instr_rdata_i[6:0];
    assign rd           = instr_rdata_i[11:7];
    assign funct3       = instr_rdata_i[14:12];
    assign rs1          = instr_rdata_i[19:15];
    assign rs2          = instr_rdata_i[24:20];
    assign funct7       = instr_rdata_i[25:31];
//  assign imm
    always_comb begin
        opcode          = opcode_e'(instr[6:0]);

        case (opcode)
            OPCODE_OP : begin
                case ({funct7,funct3})
                    {0x0,0x0} : begin
                            rd_we_o = 1'b1;
                            rd_waddr_o = rd;
                            rs1_data_o = rs1_rdata_i;
                            rs2_data_o = rs2_rdata_i;
                            rs1_addr_o = rs1;
                            rs2_addr_o = rs2;
                    end
                    default : begin
                            rd_we_o = 1'b0;
                            rd_waddr_o = 'h0;
                            rs1_data_o = 'h0;
                            rs2_data_o = 'h0;
                            rs1_addr_o = 'h0;
                            rs2_addr_o = 'h0;
                    end
                endcase
            //other instr type    
            default : begin
            end
        endcase
    end

endmodule

