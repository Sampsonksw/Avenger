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
logic [31:0]    boot_addr_i;
logic [31:0]    instr_rdata_i;
logic [31:0]    instr_addr_o;
logic           fetch_enable_o;

milano dut(
        .clk_i(clk_i),
        .rst_ni(rst_ni),
        //input from boot sel
        .boot_addr_i(boot_addr_i),
        //output to system bus
        .instr_addr_o(instr_addr_o),
        //from eflash
        .instr_rdata_i(instr_rdata_i),
        .fetch_enable_o(fetch_enable_o)
            );

instr_rom u_instr_rom(
    .addr(instr_addr_o),
    .en(fetch_enable_o),
    .instr(instr_rdata_i)
);

initial begin
    clk_i = 'b0;
    rst_ni = 'b0;
    boot_addr_i= 'b0;
   // instr_rdata_i ='b0;
    //instr_addr_o <='b0;
    #100 rst_ni = 1'b1;
    // instr_rdata_i = 32'b0000000_00001_00000_000_00010_0110011;
    //                     funct7   rs2    rs1  fun3   rd   opcode
    // #30;
    //                     0000000_00010_00001_000_00011_0110011
    //                     0000000_00011_00010_000_00100_0110011
    //                     0000000_00100_00011_000_00101_0110011
    //                     0000000_00101_00100_000_00110_0110011
    //               sub   0100000_00011_00001_000_00010_0110011
    //               xor   0000000_00010_00001_100_00011_0110011
    //               or    0000000_00000_00001_110_00011_0110011
    //               and   0000000_00000_00001_111_00010_0110011
    //               sll   0000000_00010_00001_001_00011_0110011
    //               srl   0000000_00010_00001_101_00011_0110011
    //               sra   0100000_00010_00001_101_00011_0110011
    //               slt   0000000_00010_00001_010_00011_0110011
    //               sltu  0000000_00010_00001_011_00011_0110011
    //                          imm      rs1  fun3  rd  opcode
    //               addi  000000000001_00000_000_00001_0010011
    //               xori  000000000010_00000_100_00001_0010011
    //               ori   000000000100_00000_110_00001_0010011
    //               andi  000000001000_00000_111_00001_0010011
    //               slli  000000000001_00001_001_00001_0010011
    //               srli  000000000001_00001_101_00001_0010011
    //               srai  010000000001_00001_101_00001_0010011
    //               slti  000000000001_00001_010_00001_0010011
    //               sltiu 000000000001_00001_011_00001_0010011
    //
    //
    //
    //
    #1000 $finish;
end

initial begin
    forever begin
        #5 clk_i <= ~clk_i;
    end
end

initial begin
    $readmemh("./regs.data",testbench.dut.u_id_stage.u_regs_file.regs);
end

initial begin
    $fsdbDumpfile("testbench");
    $fsdbDumpvars("+parameter,+struct");
    $fsdbDumpvars("+all");
    //$fsdbDumpvars(0, top);
end
endmodule

