/***************************************
#
#			Filename:alu.sv
#
#			Developer:ske
#			Description:---
#			CreatTime:2021-10-01 15:09:11
#
***************************************/

`default_nettype none


module csr_reg(
    input   logic               clk_i,
    input   logic               rst_ni,
    // ex access interface
    // write
    input   logic   [31:0]      waddr_i,
    input   logic   [31:0]      wdata_i,
    input   logic               we_i,
    // read
    input   logic   [31:0]      raddr_i,

    output  logic   [31:0]      rdata_o
);
    // parameters

    // signals : logic/wire/reg
    reg     [31:0]  mhartid;
    reg     [31:0]  mstatus;
    reg     [31:0]  misa;
    reg     [31:0]  mie;
    reg     [31:0]  mtvec;
    reg     [31:0]  mscratch;
    reg     [31:0]  mepc;
    reg     [31:0]  mcause;
    reg     [31:0]  mtval;
    reg     [31:0]  mip;
    reg     [31:0]  mcycle;
    reg     [31:0]  minstret;
    reg     [31:0]  mcycleh;
    reg     [31:0]  minstreth;

    csr_num_e csr_raddr;
    // module instantiation

    // combinational logic
    always_comb begin
        csr_raddr = 12'h0;
        if(waddr_i==raddr_i && we_i)begin
            rdata_o = wdata_i;
        end else  begin
            csr_raddr = csr_num_e'(raddr_i)
            case (csr_raddr)
                CSR_MHARTID     : rdata_o = 32'h0;
                CSR_MSTATUS     : rdata_o = mstatus;
                CSR_MISA        : rdata_o = misa;
                CSR_MIE         : rdata_o = mie;
                CSR_MTVEC       : rdata_o = mtvec;   
                CSR_MSCRATCH    : rdata_o = mscratch;   
                CSR_MEPC        : rdata_o = mepc;   
                CSR_MCAUSE      : rdata_o = mcause;   
                CSR_MTVAL       : rdata_o = mtval;   
                CSR_MIP         : rdata_o = mip;
                CSR_MCYCLE      : rdata_o = mcycle;   
                CSR_MINSTRET    : rdata_o = minstret;       
                CSR_MCYCLEH     : rdata_o = mcycleh;   
                CSR_MINSTRETH   : rdata_o = minstreth;
                default         : rdata_o = 32'h0;
            endcase
        end
    end
    
    // sequential logic

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (~rst_ni) begin
            
        end 
        else begin

        end
    end

endmodule



