/***************************************
#
#			Filename:instr_rom.sv
#
#			Developer:ske
#			Description:---
#			CreatTime:2021-10-11 11:25:33
#
***************************************/

module instr_rom(
    input   logic [31:0]        addr,
    input   logic               en,
    output  logic [31:0]        instr

);
    
    reg [31:0] mem[31:0];
    
    initial begin
        $readmemh("inst_rom.data", mem );
    end

    always_comb begin
        if(en == 1'b0)begin
            instr = 'h0;
        end else begin
            instr = mem[addr[31:2]];
        end
    end
    
endmodule



