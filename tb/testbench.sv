/***************************************
#
#			Filename:testbench.sv
#
#			Developer:ske
#			Description:---
#			CreatTime:2021-10-08 21:16:53
#
***************************************/
module testbench;


logic           clk_i;
logic           rst_ni;
logic           boot_addr_i;
logic [31:0]    instr_rdata_i;
logic           instr_addr_o;

milano dut(
        .clk_i(clk_i),
        .rst_ni(rst_ni),
        //input from boot sel
        .boot_addr_i(boot_addr_i),
        //output to system bus
        .instr_addr_o(instr_addr_o),
        //from eflash
        .instr_rdata_i(instr_rdata_i)       
            );
initial begin
    clk_i = 'b0;
    rst_ni = 'b0;
    boot_addr_i= 'b0;
    instr_rdata_i ='b0;
    //instr_addr_o <='b0;
    #100 rst_ni = 1'b1;
    instr_rdata_i = 32'b0000000_00011_00001_000_00010_0110011;
    #30;
    instr_rdata_i = 32'b0100000_00011_00001_000_00010_0110011;
    #20;
    instr_rdata_i = 'h0;
    #1000 $finish;
end

initial begin
    forever begin
        #5 clk_i <= ~clk_i;
    end
end

initial begin
    $readmemh("./data.txt",testbench.dut.u_id_stage.u_regs_file.regs);
end

initial begin
    $fsdbDumpfile("testbench");
    $fsdbDumpvars("+parameter,+struct");
    $fsdbDumpvars("+all");
    //$fsdbDumpvars(0, top);
end
endmodule

