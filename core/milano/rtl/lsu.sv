/***************************************
#
#			Filename:lsu.sv
#
#			Developer:ske
#			Description:---
#			CreatTime:2021-10-13 14:00:30
#
***************************************/

`default_nettype none


module lsu(
    input   logic                   clk_i           ,
    input   logic                   rst_ni          ,
    // data interface
    output  logic                   data_req_o      ,
    input   logic                   data_gnt_i      ,
    input   logic                   data_rvalid_i   ,
    output  logic   [31:0]          data_addr_o     ,
    output  logic                   data_we_o       ,
    output  logic   [3:0]           data_be_o       ,
    output  logic   [31:0]          data_wdata_o    ,
    input   logic   [31:0]          data_rdata_i    ,
    // from ID-EX pipeline register
    input   logic                   lsu_mem_we_i    ,
    input   logic                   lsu_mem_req_i   ,
    input   milano_pkg::lsu_opt_e   lsu_operate_i   ,
    input   logic   [4:0]           rd_addr_i       ,
    input   logic                   rd_we_i         ,
    // from alu
    input   logic   [31:0]          lsu_mem_addr_i  ,
    //Write back, to MEM/regs
    output  logic                   lsu_rd_we_o     ,
    output  logic    [4:0]          lsu_rd_waddr_o  ,
    output  logic    [31:0]         lsu_rd_wdata_o      
);

    // signals : logic/wire/reg
    logic [1:0]     data_offset; 
    logic           lw_addr_misaligned, lh_addr_misaligned;

    assign data_offset  = lsu_mem_addr_i[1:0];
    assign data_addr_o  = lsu_mem_addr_i;
    assign data_req_o   = lsu_mem_req_i;
    assign data_we_o    = lsu_mem_we_i;
    // combinational logic
    always_comb begin
        if(!rst_ni)begin
            data_be_o           =  4'h0;
            lsu_rd_we_o         =  1'b0;
            lsu_rd_waddr_o      =  5'h0;
            lsu_rd_wdata_o      = 32'h0;
            lw_addr_misaligned  =  1'h0;
            lh_addr_misaligned  =  1'h0;
        end else begin
            data_be_o           =  4'h0;
            lsu_rd_we_o         =  1'b0;
            lsu_rd_waddr_o      =  5'h0;
            lsu_rd_wdata_o      = 32'h0;            
            unique case (lsu_operate_i[1:0])
                2'b00: begin        //LW
                    unique case (data_offset)
                        2'b00:   begin 
                                    data_be_o = 4'b1111;
                                    if(data_rvalid_i) begin 
                                        lsu_rd_wdata_o  = data_rdata_i;
                                        lsu_rd_we_o     =  rd_we_i;
                                        lsu_rd_waddr_o  =  rd_addr_i;
                                    end
                        end
                        2'b01:   lw_addr_misaligned = 1'b1;//data_be_o = 4'b1110;
                        2'b10:   lw_addr_misaligned = 1'b1;//data_be_o = 4'b1100;
                        2'b11:   lw_addr_misaligned = 1'b1;//data_be_0 = 4'b1000;
                        default: data_be_o = 4'b1111;
                    endcase
                end
                2'b01: begin        //LH
                    unique case (data_offset)
                        2'b00:  begin 
                                    data_be_o = 4'b0011;
                                    if(data_rvalid_i)begin
                                        lsu_rd_we_o     =  rd_we_i;
                                        lsu_rd_waddr_o  =  rd_addr_i;                                
                                        if(!lsu_operate_i[2]) lsu_rd_wdata_o = {{16{data_rdata_i[15]}}, data_rdata_i[15:0]};   //
                                        else lsu_rd_wdata_o = {{16{1'b0}}, data_rdata_i[15:0]};                                //Unsigned
                                    end else begin
                                        lsu_rd_wdata_o = 32'h0;
                                    end
                        end
                        2'b01:  begin
                                    data_be_o = 4'b0110;
                                    lh_addr_misaligned = 1'b1;//data_be_o = 4'b0110;
                                    if(data_rvalid_i)begin
                                        lsu_rd_we_o     =  rd_we_i;
                                        lsu_rd_waddr_o  =  rd_addr_i;
                                        if(!lsu_operate_i[2]) lsu_rd_wdata_o = {{16{data_rdata_i[23]}}, data_rdata_i[23:8]};
                                        else lsu_rd_wdata_o = {{16{1'b0}}, data_rdata_i[23:8]};                                //Unsigned
                                    end else begin
                                        lsu_rd_wdata_o = 32'h0;
                                    end

                        end
                        2'b10:  begin 
                                    data_be_o = 4'b1100;
                                    if(data_rvalid_i)begin
                                        lsu_rd_we_o     =  rd_we_i;
                                        lsu_rd_waddr_o  =  rd_addr_i;
                                        if(!lsu_operate_i[2]) lsu_rd_wdata_o = {{16{data_rdata_i[31]}}, data_rdata_i[31:16]};
                                        else lsu_rd_wdata_o = {{16{1'b0}}, data_rdata_i[31:16]};                                //Unsigned
                                    end else begin
                                        lsu_rd_wdata_o = 32'h0;
                                    end

                        end
                        2'b11:   lh_addr_misaligned = 1'b1;//data_be_0 = 4'b1000;
                        default: data_be_o = 4'b1111;
                    endcase
                end
                2'b10: begin        //LB
                    unique case (data_offset)
                        2'b00:  begin 
                                    data_be_o = 4'b0001;
                                    if(data_rvalid_i)begin
                                        lsu_rd_we_o     =  rd_we_i;
                                        lsu_rd_waddr_o  =  rd_addr_i;
                                        if(!lsu_operate_i[2]) lsu_rd_wdata_o = {{24{data_rdata_i[7]}}, data_rdata_i[7:0]};
                                        else lsu_rd_wdata_o = {{24{1'b0}}, data_rdata_i[7:0]};                                //Unsigned
                                    end else begin
                                        lsu_rd_wdata_o = 32'h0;
                                    end
                        end
                        2'b01:  begin
                                    data_be_o = 4'b0010;
                                    if(data_rvalid_i)begin
                                        lsu_rd_we_o     =  rd_we_i;
                                        lsu_rd_waddr_o  =  rd_addr_i;
                                        if(!lsu_operate_i[2]) lsu_rd_wdata_o = {{24{data_rdata_i[15]}}, data_rdata_i[15:8]};
                                        else lsu_rd_wdata_o = {{24{1'b0}}, data_rdata_i[15:8]};                                //Unsigned
                                    end else begin
                                        lsu_rd_wdata_o = 32'h0;
                                    end
                        end
                        2'b10:  begin
                                    data_be_o = 4'b0100;
                                    if(data_rvalid_i)begin
                                        lsu_rd_we_o     =  rd_we_i;
                                        lsu_rd_waddr_o  =  rd_addr_i;
                                        if(!lsu_operate_i[2]) lsu_rd_wdata_o = {{24{data_rdata_i[23]}}, data_rdata_i[23:16]};
                                        else lsu_rd_wdata_o = {{24{1'b0}}, data_rdata_i[23:16]};                                //Unsigned
                                    end else begin
                                        lsu_rd_wdata_o = 32'h0;
                                    end

                        end
                        2'b11:  begin
                                    data_be_o = 4'b1000;
                                    if(data_rvalid_i)begin
                                        lsu_rd_we_o     =  rd_we_i;
                                        lsu_rd_waddr_o  =  rd_addr_i;
                                        if(!lsu_operate_i[2]) lsu_rd_wdata_o = {{24{data_rdata_i[31]}}, data_rdata_i[31:24]};
                                        else lsu_rd_wdata_o = {{24{1'b0}}, data_rdata_i[31:24]};                                //Unsigned
                                    end else begin
                                        lsu_rd_wdata_o = 32'h0;
                                    end
                        end
                        default: data_be_o = 4'b1111;
                    endcase
                end

                default: data_be_o = 4'b1111;
            endcase
        end
    end

endmodule



