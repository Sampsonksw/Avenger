module regs_file(
    input  logic clk_i,
    input  logic rst_ni,

    // from ex
    ////write port w1
    input  logic we_i,
    input  logic [4:0] waddr_i,
    input  logic [31:0] wdata_i,

    // from id
    ////read port R1
    input  logic [4:0] raddr_a_i,
    output logic [31:0]rdata_a_o,
    ////reda port R2
    input  logic [4:0] raddr_b_i,
    output logic [31:0]rdata_b_o

);

    reg [31:0]regs[31:0];

    always @ (posedge clk_i) begin
        if (rst_ni) begin
            if ((we_i == 1'b1) && (waddr_i != 5'h0)) begin
                regs[waddr_i] <= wdata_i;
            end
        end
    end

    always @ (*) begin
        if (raddr_a_i == 5'h0) begin
            rdata_a_o = 32'h0;
        end else if (raddr_a_i == waddr_i && we_i == 1'b1) begin
            rdata_a_o = wdata_i;
        end else begin
            rdata_a_o = regs[raddr_a_i];
        end
    end

    always @ (*) begin
        if (raddr_b_i == 5'h0) begin
            rdata_b_o = 32'h0;
        end else if (raddr_b_i == waddr_i && we_i == 1'b1) begin
            rdata_b_o = wdata_i;
        end else begin
            rdata_b_o = regs[raddr_b_i];
        end
    end
    
endmodule
