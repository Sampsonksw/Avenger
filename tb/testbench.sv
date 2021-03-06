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

string casename;
logic               clk_i;
logic               rst_ni;
logic   [31:0]      boot_addr_i;
logic   [31:0]      instr_rdata_i;
logic   [31:0]      instr_addr_o;
logic               fetch_enable_o;
// data interface
logic               data_req_o;
logic               data_we_o;
logic   [3:0]       data_be_o;
logic   [31:0]      data_addr_o;
logic   [31:0]      data_rdata_i;
logic               data_rvalid_o;
logic   [31:0]      data_wdata_o;
logic               data_gnt_i;
logic               timer_irq_i;
milano dut(
        .clk_i          ( clk_i         ),
        .rst_ni         ( rst_ni        ),
        //input from boot sel
        .boot_addr_i    ( boot_addr_i   ),
        //output to system bus
        .instr_addr_o   ( instr_addr_o  ),
        //from eflash
        .instr_rdata_i  ( instr_rdata_i ),
        .fetch_enable_o ( fetch_enable_o),
        // data interface
        .data_req_o     ( data_req_o    ),
        .data_gnt_i     ( data_gnt_i    ),
        .data_rvalid_i  ( data_rvalid_o ),
        .data_addr_o    ( data_addr_o   ) ,
        .data_we_o      ( data_we_o     ) ,
        .data_be_o      ( data_be_o     ),
        .data_wdata_o   ( data_wdata_o  ),
        .data_rdata_i   ( data_rdata_i  ),
        //timer interrupt
        .timer_irq_i    ( timer_irq_i   )        
);

instr_rom u_instr_rom(
    .addr   ( instr_addr_o  ),
    .en     ( fetch_enable_o),
    .instr  ( instr_rdata_i )
);

data_ram u_data_ram(
    .clk_i          ( clk_i         ),
    .rst_ni         ( rst_ni        ),
    .ce_i           ( data_req_o    ),
    .wr_en_i        ( data_we_o     ),
    .sel_i          ( data_be_o     ),
    .addr_i         ( data_addr_o   ),
    .wdata_i        ( data_wdata_o  ),
    .rdata_o        ( data_rdata_i  ),
    .data_rvalid_o  ( data_rvalid_o ),
    .wrtie_sucess   (               )
);

initial begin
    $value$plusargs("casename=%s", casename);
    clk_i = 'b0;
    rst_ni = 'b0;
    boot_addr_i= 'b0;
    timer_irq_i= 'b0;
   // instr_rdata_i ='b0;
    //instr_addr_o <='b0;
    #100 rst_ni = 1'b1;
    //testbench.dut.u_csr_reg.mie[31:0]=32'h80;
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
    //               lb    000000000001_00000_000_00001_0000011
    //               lh    000000000001_00000_001_00001_0000011
    //               lw    000000000000_00000_010_00001_0000011
    //                     imm[11:5] rs2  rs1  fun3 im[4:0] opcode
    //               sb    0000000_00011_00000_000_00001_0100011
    //               sh    0000000_00011_00000_001_00001_0100011
    //                     imm[12|10:15]  rs2   rs1  fun3 imm[4:1|11]   opcode
    //               beq   0000000_______00001_00001_000_00100_________1100011
    //               bne   0000000_______00001_00000_001_00100_________1100011
    //                     imm[20|10:1|11|19:12] rd    opcode
    //               jal   0 0000001000 000000000_00001_1101111
    //                     imm[11:0]     rs1   f3   rd   opcode
    //               jalr  000000000100_00001_000_00001_1100111
    //                            imm[19:0]       rd    opcode
    //                lui  0000000000_0000000001_00001_1110011
    //                      fun7    rs2   rs1  fun3  rd   opcode
    //               mul   0000001_00010_00001_000_00011_0110011
    //               mulh  0000001_00010_00001_001_00011_0110011
    //               mulsu 0000001_00010_00001_010_00011_0110011
    //               mulu  0000001_00010_00001_011_00011_0110011
    //               div   0000001_00010_00001_100_00011_0110011
    //               divu  0000001_00010_00001_101_00011_0110011
    //               rem   0000001_00010_00001_110_00011_0110011
    //               remu  0000001_00010_00001_111_00011_0110011
    //                          csr      rs1  fun3  rd   opcode
    //               csrrw 111100010100_00001_001_00010_1110011
    //               csrrs 111100010100_00001_010_00010_1110011
    //               csrrc 111100010100_00001_011_00010_1110011
    //              csrrwi 111100010100_00010_101_00010_1110011
    //              csrrsi 111100010100_00011_110_00010_1110011    
    //
    //
    //
    //
    //#300 timer_irq_i= 'b1;
    //#50 timer_irq_i= 'b0;
    //wait (testbench.dut.u_ctrl.exce_hand_state_c[3:0]==4'b0010);
    if(casename == 'b0)begin

    end else begin
        wait(testbench.dut.u_id_stage.u_regs_file.regs[26][31:0]==32'b1);
        $display("==========================================================================");
        #20 $display("test done!!");
        $display("==========================================================================");

        if(testbench.dut.u_id_stage.u_regs_file.regs[27][31:0] && testbench.dut.u_id_stage.u_regs_file.regs[26][31:0])begin
            $display("riscvtest_pass");
            $display("==========================================================================");
            $display("         ______          ___             ________        ________         ");
            $display("        / ____ \\ \\      / __ \\           / ______/       / ______///       ");
            $display("       / /   / / /     / /  \\ \\         / //            / //               ");
            $display("      / /___/ / /     / / /\\ \\ \\         \\ \\             \\ \\              ");
            $display("     / ______/ /     / / /  \\ \\ \\          \\ \\ __         \\ \\ __         "); 
            $display("    / /             / /  ````  \\ \\            / //            / //       ");
            $display("   / /             / /  ``````  \\ \\      ____ / //       ____ / //        ");
            $display("  /_/             / /            \\ \\    /______ //      /______ //         ");
            $display("==========================================================================");

        end else begin
            $display("riscvtest_fail");
            $display("==========================================================================");
            $display("         ________         ___                 __________        __           ");
            $display("        / ______//         / __ \\           / ________//      / //          ");
            $display("       / /              / /  \\ \\              / //          / //           ");
            $display("      / /___           / / /\\ \\ \\           / //          / //            ");
            $display("     / _____//        / / /  \\ \\ \\         / //          / //             "); 
            $display("    / /              / /  ````  \\ \\        / //          / //              ");
            $display("   / /              / /  ``````  \\ \\    __/ //____      / //_______        ");
            $display("  /_/             // /            \\ \\  /________ //     /____ _ ___//       ");
            $display("==========================================================================");
        end
    end
    #100 $finish;

end

initial begin
    forever begin
        #5 clk_i <= ~clk_i;
    end
end

initial begin
    $readmemh("./regs.data",testbench.dut.u_id_stage.u_regs_file.regs);
    //$readmemh("./../core/milano/tests/base-isa-old/generated/rv32ui-p-add.vmem",testbench.u_instr_rom.mem);
    //$readmemh("./../core/milano/tests/base-isa-old/generated/rv32ui-p-addi.vmem",testbench.u_instr_rom.mem);
    //$readmemh("./../core/milano/tests/base-isa-old/generated/rv32ui-p-and.vmem",testbench.u_instr_rom.mem);
    //$readmemh("./../core/milano/tests/base-isa-old/generated/rv32ui-p-and.vmem",testbench.u_instr_rom.mem);
    $readmemh("./test.vmem",testbench.u_instr_rom.mem);
end

initial begin:dump_wave
    
    if($value$plusargs("casename=%s", casename)) begin
        $fsdbDumpfile({casename, ".fsdb"});
        $display("hello");
    end else begin
        $fsdbDumpfile("testbench.fsdb");
    end
    //$fsdbDumpvars("+parameter,+struct");
    $fsdbDumpvars("+all");
    $fsdbDumpvars(0, testbench);
    $display("casename = %x",casename);
end


endmodule

