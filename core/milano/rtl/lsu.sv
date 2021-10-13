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
    input   logic               clk_i           ,
    input   logic               rst_ni          ,
    // data interface
    output  logic               data_req_o      ,
    input   logic               data_gnt_i      ,
    input   logic               data_rvalid_i   ,
    output  logic   [31:0]      data_addr_o     ,
    output  logic               data_we_o       ,
    output  logic   [3:0]       data_be_o       ,
    output  logic   [31:0]      data_wdata_o    ,
    input   logic   [31:0]      data_rdata_i    ,
    // from ID-EX pipeline register
    input   logic               lsu_we_i        ,
    input   logic               lsu_req_i       ,
    input   logic   [2:0]       lsu_type_i      ,
    // from alu
    input   logic   [31:0]      lsu_addr_i      ,
    // to reg
    output  logic   [31:0]      lsu_rdata_o     
);

    // signals : logic/wire/reg
    logic [1:0]     data_offset; 
    logic           lw_addr_misaligned, lh_addr_misaligned;

    assign data_offset  = lsu_addr_i[1:0];
    assign data_addr_o  = lsu_addr_i;
    assign data_req_o   = lsu_req_i;
    assign data_we_o    = lsu_we_i;
    // combinational logic
    always_comb begin
        data_be_o = 4'b0000;
        lw_addr_misaligned = 1'b0;
        lh_addr_misaligned = 1'b0;
        unique case (lsu_type_i[1:0])
            2'b00: begin        //LW
                unique case (data_offset)
                    2'b00:   begin 
                                data_be_o = 4'b1111;
                                if(data_rvalid_i) lsu_rdata_o = data_rdata_i;
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
                                    if(!lsu_type_i[2]) lsu_rdata_o = {{16{data_rdata_i[15]}}, data_rdata_i[15:0]};   //
                                    else lsu_rdata_o = {{16{1'b0}}, data_rdata_i[15:0]};                                //Unsigned
                                end else begin
                                    lsu_rdata_o = 32'h0;
                                end
                    end
                    2'b01:  begin
                                data_be_o = 4'b0110;
                                lh_addr_misaligned = 1'b1;//data_be_o = 4'b0110;
                                if(data_rvalid_i)begin
                                    if(!lsu_type_i[2]) lsu_rdata_o = {{16{data_rdata_i[23]}}, data_rdata_i[23:8]};
                                    else lsu_rdata_o = {{16{1'b0}}, data_rdata_i[23:8]};                                //Unsigned
                                end else begin
                                    lsu_rdata_o = 32'h0;
                                end

                    end
                    2'b10:  begin 
                                data_be_o = 4'b1100;
                                if(data_rvalid_i)begin
                                    if(!lsu_type_i[2]) lsu_rdata_o = {{16{data_rdata_i[31]}}, data_rdata_i[31:16]};
                                    else lsu_rdata_o = {{16{1'b0}}, data_rdata_i[31:16]};                                //Unsigned
                                end else begin
                                    lsu_rdata_o = 32'h0;
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
                                    if(!lsu_type_i[2]) lsu_rdata_o = {{24{data_rdata_i[7]}}, data_rdata_i[7:0]};
                                    else lsu_rdata_o = {{24{1'b0}}, data_rdata_i[7:0]};                                //Unsigned
                                end else begin
                                    lsu_rdata_o = 32'h0;
                                end
                    end
                    2'b01:  begin
                                data_be_o = 4'b0010;
                                if(data_rvalid_i)begin
                                    if(!lsu_type_i[2]) lsu_rdata_o = {{24{data_rdata_i[15]}}, data_rdata_i[15:8]};
                                    else lsu_rdata_o = {{24{1'b0}}, data_rdata_i[15:8]};                                //Unsigned
                                end else begin
                                    lsu_rdata_o = 32'h0;
                                end
                    end
                    2'b10:  begin
                                data_be_o = 4'b0100;
                                if(data_rvalid_i)begin
                                    if(!lsu_type_i[2]) lsu_rdata_o = {{24{data_rdata_i[23]}}, data_rdata_i[23:16]};
                                    else lsu_rdata_o = {{24{1'b0}}, data_rdata_i[23:16]};                                //Unsigned
                                end else begin
                                    lsu_rdata_o = 32'h0;
                                end

                    end
                    2'b11:  begin
                                data_be_o = 4'b1000;
                                if(data_rvalid_i)begin
                                    if(!lsu_type_i[2]) lsu_rdata_o = {{24{data_rdata_i[31]}}, data_rdata_i[31:24]};
                                    else lsu_rdata_o = {{24{1'b0}}, data_rdata_i[31:24]};                                //Unsigned
                                end else begin
                                    lsu_rdata_o = 32'h0;
                                end
                    end
                    default: data_be_o = 4'b1111;
                endcase
            end

            default: data_be_o = 4'b1111;
        endcase

    end

endmodule



