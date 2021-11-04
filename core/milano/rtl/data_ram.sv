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
    output  logic               data_rvalid_o,
    output  logic               wrtie_sucess

);
    // signals : logic/wire/reg

    reg     [31:0]  mem[2047:0];

    always_comb begin
        if(ce_i==1'b0)begin
            rdata_o = 32'h0;
        end else begin
            rdata_o = mem[addr_i[31:2]];
            data_rvalid_o = 1'b1;
        end
    end
    
    always_ff @(posedge clk_i, negedge rst_ni)begin
        if(!rst_ni)begin
            wrtie_sucess <= 1'b0;
            $readmemh("./test.vmem",mem);
        end else begin
            if(wr_en_i==1'b1 && ce_i==1'b1)begin
                wrtie_sucess <= 1'b1;
                if(sel_i==4'b0000)begin
                    mem[addr_i[31:2]] <= mem[addr_i[31:2]];
                end else begin
                    mem[addr_i[31:2]] <=wdata_i;
                end
                /*
                if(sel_i==4'b0001)begin
                    mem[addr_i[31:2]] <= {mem_data[31:8],wdata_i[7:0]};
                end
                if(sel_i==4'b0010)begin
                    mem[addr_i[31:2]] <= {mem_data[31:16],wdata_i[7:0],mem_data[7:0]};
                end
                if(sel_i==4'b0100)begin
                    mem[addr_i[31:2]] <= {mem_data[31:24],wdata_i[7:0],mem_data[15:0]};
                end
                if(sel_i==4'b1000)begin
                    mem[addr_i[31:2]] <= {wdata_i[7:0],mem_data[24:0]};
                end
                if(sel_i==4'b0011)begin
                    mem[addr_i[31:2]] <= {mem_data[31:16],wdata_i[15:0]};
                end
                if(sel_i==4'b0110)begin
                    mem[addr_i[31:2]] <= {mem_data[31:24],wdata_i[15:0],mem_data[7:0]};
                end
                if(sel_i==4'b1100)begin
                    mem[addr_i[31:2]] <= {wdata_i[15:0],mem_data[15:0]};
                end
                if(sel_i==4'b1111)begin
                    mem[addr_i[31:2]] <= wdata_i[31:0];
                end
                */
            end     
        end
    end
endmodule



