module prefetch_reg(
        input  logic clk_i,
        input  logic rst_ni,
        input  logic boot_addr_i,		        //from boot address sel
        output logic [31:0] instr_addr_o,     	//to instr ram
        output logic fetch_enable_o
);

// prefetch address logic
    always_ff @(posedge clk_i,negedge rst_ni)begin
        if(!rst_ni)begin
            fetch_enable_o  <= 1'b0;
        end else begin
            fetch_enable_o  <= 1'b1;
        end
    end

    always_ff @(posedge clk_i,negedge rst_ni)begin
        if(!rst_ni)begin
            instr_addr_o <= boot_addr_i;
        end else if(!fetch_enable_o) begin
            instr_addr_o <= boot_addr_i;
        end else begin
            instr_addr_o <= instr_addr_o + 4;
        end
    end

endmodule
