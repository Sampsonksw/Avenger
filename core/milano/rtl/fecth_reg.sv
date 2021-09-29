module prefetch_reg(
        input  logic clk_i,
        input  logic rst_ni,
        input  logic boot_addr_i,		        //from boot address sel
        output logic [31:0] instr_addr_o     	//to instr ram
);

// prefetch address logic
    always_ff @(posedge clk_i,negedge rst_ni)begin
        if(!rst_ni)begin
            instr_addr_o <= boot_addr_i;
        end else begin
            instr_addr_o <= instr_addr_o + 4;
        end
    end

endmodule
