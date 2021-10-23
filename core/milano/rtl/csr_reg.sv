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
    input   logic               clk_i       ,
    input   logic               rst_ni      ,
    // ex access interface
    // write
    input   logic   [11:0]      ex_waddr_i  ,
    input   logic   [31:0]      ex_wdata_i  ,
    input   logic               ex_we_i     ,
    // id access interface
    // read
    input   logic   [11:0]      id_raddr_i  ,

    output  logic   [31:0]      id_rdata_o
);
    // parameters
    import milano_pkg::*;
    // signals : logic/wire/reg
    reg     [31:0]  mhartid;    // hart ID register
    reg     [31:0]  mstatus;    // machine status register
    reg     [31:0]  misa;       // machine ISA register
    reg     [31:0]  mie;        // machine interrupt enable register
    reg     [31:0]  mtvec;      // machine trap-vector base-address register
    reg     [31:0]  mscratch;   // machine srcatch register
    reg     [31:0]  mepc;       // machine exception program counter register
    reg     [31:0]  mcause;     // machine cause register
    reg     [31:0]  mtval;      // machine trap value register
    reg     [31:0]  mip;        // machine interrupt pending register
    reg     [31:0]  mcycle;     // lower 32bits of cycle counter register
    reg     [31:0]  minstret;   // lower 32bits of instruction-retired counter register
    reg     [31:0]  mcycleh;    // upper 32bits of cycle counter register
    reg     [31:0]  minstreth;  // upper 32bits of instruction-retired counter register

    csr_num_e csr_raddr;
    // module instantiation

    // combinational logic
    always_comb begin
        //id_raddr_i = 12'h0;
        if(ex_waddr_i==id_raddr_i && ex_we_i)begin
            id_rdata_o = ex_wdata_i;
        end else  begin
            csr_raddr = csr_num_e'(id_raddr_i);
            case (id_raddr_i)
                CSR_MHARTID     : id_rdata_o = 32'h0;
                CSR_MSTATUS     : id_rdata_o = mstatus;
                CSR_MISA        : id_rdata_o = misa;
                CSR_MIE         : id_rdata_o = mie;
                CSR_MTVEC       : id_rdata_o = mtvec;   
                CSR_MSCRATCH    : id_rdata_o = mscratch;   
                CSR_MEPC        : id_rdata_o = mepc;   
                CSR_MCAUSE      : id_rdata_o = mcause;   
                CSR_MTVAL       : id_rdata_o = mtval;   
                CSR_MIP         : id_rdata_o = mip;
                CSR_MCYCLE      : id_rdata_o = mcycle;   
                CSR_MINSTRET    : id_rdata_o = minstret;       
                CSR_MCYCLEH     : id_rdata_o = mcycleh;   
                CSR_MINSTRETH   : id_rdata_o = minstreth;
                default         : id_rdata_o = 32'h0;
            endcase
        end
    end
    
    // sequential logic

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (~rst_ni) begin
            mhartid     <= 'h0; 
            mstatus     <= 'h0; 
            misa        <= 'h0;    
            mie         <= 'h0;     
            mtvec       <= 'h0;   
            mscratch    <= 'h0;
            mepc        <= 'h0;    
            mcause      <= 'h0;  
            mtval       <= 'h0;   
            mip         <= 'h0;     
            mcycle      <= 'h0;  
            minstret    <= 'h0;
            mcycleh     <= 'h0; 
            minstreth   <= 'h0;
        end else if (ex_waddr_i)begin
            unique case(ex_waddr_i)
                CSR_MHARTID     : mhartid   <= ex_wdata_i;
                CSR_MSTATUS     : mstatus   <= ex_wdata_i;
                CSR_MISA        : misa      <= ex_wdata_i;
                CSR_MIE         : mie       <= ex_wdata_i;
                CSR_MTVEC       : mtvec     <= ex_wdata_i;   
                CSR_MSCRATCH    : mscratch  <= ex_wdata_i;   
                CSR_MEPC        : mepc      <= ex_wdata_i;   
                CSR_MCAUSE      : mcause    <= ex_wdata_i;   
                CSR_MTVAL       : mtval     <= ex_wdata_i;   
                CSR_MIP         : mip       <= ex_wdata_i;
                CSR_MCYCLE      : mcycle    <= ex_wdata_i;   
                CSR_MINSTRET    : minstret  <= ex_wdata_i;       
                CSR_MCYCLEH     : mcycleh   <= ex_wdata_i;   
                CSR_MINSTRETH   : minstreth <= ex_wdata_i;
                default         : ;
            endcase
        end 
    end

endmodule


`default_nettype wire
