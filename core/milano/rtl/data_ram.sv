/***************************************
#
#			Filename:prefetch_reg.sv
#
#			Developer:ske
#			Description:---
#			CreatTime:2021-09-25 16:22:20
#
***************************************/

`default_nettype none


module data_ram(
    input   logic               clk_i,
    input   logic               rst_ni,
    input   logic               ce_i,
    input   logic               wr_en_i,
    input   logic   [3:0]       sel_i,
    input   logic   [31:0]      addr_i,
    input   logic   [31:0]      wdata_i,
    output  logic   [31:0]      rdata_o,
    output  logic               data_rvalid_o

);
    // signals : logic/wire/reg

    logic   [31:0]  mem_data;
    reg     [31:0]  mem[31:0];

    initial begin
        $readmemh("./inst_rom.data",mem);
    end

    always_comb begin
        if(ce_i==1'b0)begin
            rdata_o = 32'h0;
            data_rvalid_o = 1'b0;
        end else if(wr_en_i==1'b0) begin
            if(sel_i==4'b0000) begin
                rdata_o = 32'h0;
                data_rvalid_o = 1'b1;
            end
            if(sel_i==4'b0001) begin
                rdata_o = {{24{1'b0}},mem_data[7:0]};
                data_rvalid_o = 1'b1;
            end
            if(sel_i==4'b0010) begin
                rdata_o = {{16{1'b0}},mem_data[15:8],{8{1'b0}}};
                data_rvalid_o = 1'b1;
            end
            if(sel_i==4'b0100) begin
                rdata_o = {{8{1'b0}},mem_data[23:16],{16{1'b0}}};
                data_rvalid_o = 1'b1;
            end
            if(sel_i==4'b1000) begin
                rdata_o = {mem_data[31:24],{24{1'b0}}};
                data_rvalid_o = 1'b1;
            end
            if(sel_i==4'b0011) begin
                rdata_o = {{16{1'b0}},mem_data[15:0]};
                data_rvalid_o = 1'b1;
            end
            if(sel_i==4'b0110) begin
                rdata_o = {{8{1'b0}},mem_data[23:8],{8{1'b0}}};
                data_rvalid_o = 1'b1;
            end
            if(sel_i==4'b1100) begin
                rdata_o = {mem_data[31:16],{16{1'b0}}};
                data_rvalid_o = 1'b1;
            end
            if(sel_i==4'b1111) begin
                rdata_o = mem_data;
                data_rvalid_o = 1'b1;
            end
        end
    end

    always_comb begin
        if(ce_i==1'b0)begin
            mem_data = 32'h0;
        end else if(wr_en_i==1'b0) begin
            mem_data = mem[addr_i[31:2]];
        end
    end
    
endmodule



