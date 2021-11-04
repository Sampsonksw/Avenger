/***************************************
#
#			Filename:ex_stage.sv
#
#			Developer:ske
#			Description:---
#			CreatTime:2021-10-21 10:46:26
#
***************************************/

`default_nettype none



module ctrl(
    input   logic               clk_i               ,
    input   logic               rst_ni              ,

    input   logic               stallreq_from_ex_i  ,

    output  logic               stall_o             ,
    // from ex_stage
    input   logic   [31:0]      instr_addr_i        ,
    input   logic   [31:0]      instr_data_i        ,
    input   logic               ecall_exce_i        ,
    input   logic               ebreak_exce_i       ,
    input   logic               ex_jump_flag_i      ,
    // from csr_reg
    input   logic   [31:0]      csr_mstatus         ,
    input   logic   [31:0]      csr_mepc            ,
    input   logic   [31:0]      csr_mtvec           ,
    input   logic   [31:0]      csr_mie             ,
    input   logic   [31:0]      csr_mip             ,

    // to if stage
    output  logic   [31:0]      exce_jump_addr_o    ,
    output  logic               exce_jump_en_o      ,

    // from timer
    //input   logic               timer_irq_i
    // csr reg interface
    output  logic               csr_we_o            ,
    output  logic   [11:0]      csr_waddr_o         ,
    output  logic   [31:0]      csr_wdata_o         ,

    output  logic               refresh_pip_o   
);
    import milano_pkg::*;
    //mie csr reg
    logic   mtie,msie;
    assign  mtie = csr_mie[7];              // local timer interrupt enable
    assign  msie = csr_mie[3];              // local software interrupt enable

    //mip csr reg
    logic   mtip,msip;                      
    assign  mtip = csr_mip[7];              // local timer interrupt pending
    assign  msip = csr_mip[3];              // local software interrupt pending
    
    // mstatus csr reg
    logic   mstatus_mie;
    assign  mstatus_mie = csr_mstatus[3];   // global interrupt enable

    // logic define
    logic   interrupt;                      
    logic   [1:0]   exception;              
    logic   timer_int;                      // timer interrupt
    assign  timer_int = mtip & mtie;
    logic   software_int;                   // software interrupt 
    assign  software_int= msip & msie;     
    logic   [1:0]   local_int;
    logic           external_int;
    assign          external_int = 1'b0;
    logic   [2:0]   cause;                  //00:timer interrupt,01:software inter,10: ecall, 11:ebreak
    logic   [31:0]  exce_instr_reg;

    logic           idle2exce, exce2handle, exec2idle;
    logic           save_site_done;// restore_site_done;
    exce_hand_state_e exce_hand_state_c, exce_hand_state_n;
    csr_ctrl_state_e csr_ctrl_state_c, csr_ctrl_state_n;

    assign  local_int = {software_int,timer_int};
    assign  interrupt = ((|local_int) || external_int) & mstatus_mie;
    assign  exception = {ecall_exce_i, ebreak_exce_i};
    assign  refresh_pip_o = idle2exce || exce_hand_state_c== EXCE || exec2idle || ex_jump_flag_i;



    always_ff @(posedge clk_i, negedge rst_ni)begin
        if(!rst_ni)begin
            exce_instr_reg <= 32'h0;
        end else if (idle2exce) begin
            exce_instr_reg <= instr_addr_i;
        end else begin
            exce_instr_reg <= exce_instr_reg;
        end
    end

    always_comb begin
        if(!rst_ni)begin
            stall_o = 1'b0;
        end else if(stallreq_from_ex_i)begin
            stall_o = 1'b1;
        end else begin
            stall_o = 1'b0;
        end
    end



    always_ff @(posedge clk_i, negedge rst_ni)begin
        if(!rst_ni)begin
            exce_hand_state_c <= IDLE;
        end else begin
            exce_hand_state_c <= exce_hand_state_n;
        end
    end


    always_comb begin

        unique case (exce_hand_state_c)
            IDLE : begin 
                    if (idle2exce)begin
                        exce_hand_state_n = EXCE;
                    end else begin
                        exce_hand_state_n = IDLE;
                    end
            end
            EXCE : begin
                    if(exce2handle)begin
                        exce_hand_state_n = HANDLE;
                    end else  begin
                        exce_hand_state_n = EXCE;
                    end
            end
            HANDLE : begin
                    if(exec2idle)begin
                        exce_hand_state_n = IDLE;
                    end else begin
                        exce_hand_state_n = HANDLE;
                    end
            end/*
            QUIT : begin
                    if(quit2idle)begin
                        exce_hand_state_n = IDLE;
                    end else begin
                        exce_hand_state_n = QUIT;
                    end
            end
            */
            default: ;
        endcase
    end
                    
    assign  idle2exce = interrupt || (|exception);
    assign  exce2handle = save_site_done;
    assign  exec2idle = instr_data_i==32'h30200073; // MRET
    //assign  quit2idle = restore_site_done;
    //assign  restore_site_done = exec2idle && (exce_jump_en_o==1'b1) && (exce_jump_addr_o==csr_mepc);
/*
    always_ff @(posedge clk_i, negedge rst_ni)begin
        if (!rst_ni)begin
            exce_jump_addr_o    <= 'h0;
            exce_jump_en_o      <= 'h0;
        //end else if (exce_hand_state_c == HANDLE)begin
        end else if (exce2handle)begin
            exce_jump_addr_o    <= csr_mtvec;
            exce_jump_en_o      <= 1'h1;
        //end else if (exce_hand_state_c == QUIT)begin
        end else if (exec2idle)begin
            exce_jump_addr_o    <= csr_mepc;
            exce_jump_en_o      <= 1'h1;
        end else begin
            exce_jump_addr_o    <= 32'h0;
            exce_jump_en_o      <= 1'h0;
        end
    end
*/
    always_comb begin
        if(!rst_ni)begin
            exce_jump_addr_o    = 'h0;
            exce_jump_en_o      = 'h0;
        end else if(exce2handle)begin
            exce_jump_addr_o    = csr_mtvec;
            exce_jump_en_o      = 1'h1;
        end else if (exec2idle)begin
            exce_jump_addr_o    = csr_mepc;
            exce_jump_en_o      = 1'h1;
        end else begin
            exce_jump_addr_o    = 32'h0;
            exce_jump_en_o      = 1'h0;
        end
    end


    always_ff @(posedge clk_i, negedge rst_ni)begin
        if(!rst_ni)begin
            cause   <=  2'h0;
        end else if(timer_int)begin
            cause   <=  2'h0;   //00:timer interrupt
        end else if(software_int)begin
            cause   <=  2'h1;   //01:software interrupt
        end else if(ecall_exce_i)begin
            cause   <=  2'h2;   //10:ecall
        end else if(ebreak_exce_i)begin
            cause   <=  2'h3;   //11:ebreak
        end else if(save_site_done)begin
            cause   <=  2'h0;
        end
    end

//CSR WRITE FSM
    always_ff @(posedge clk_i, negedge rst_ni)begin
        if(!rst_ni)begin
            csr_ctrl_state_c <= WR_IDLE;
        end else begin
            csr_ctrl_state_c <= csr_ctrl_state_n;
        end
    end

    always_comb begin

        unique case (csr_ctrl_state_c)
            WR_IDLE : begin 
                    if (exce_hand_state_c == EXCE)begin
                        csr_ctrl_state_n = WR_MCAUSE;
                    end else begin
                        csr_ctrl_state_n = WR_IDLE;
                    end
            end
            WR_MCAUSE : begin
                    csr_ctrl_state_n = WR_MEPC;
            end
            WR_MEPC : begin
                    csr_ctrl_state_n = WR_MTVAL;
            end
            WR_MTVAL : begin
                    csr_ctrl_state_n = WR_MSTATUS;
            end
            WR_MSTATUS: begin
                    csr_ctrl_state_n = WR_IDLE;
            end
            
            default: ;
            
        endcase
    end

    always_ff @(posedge clk_i, negedge rst_ni)begin
        if(!rst_ni)begin
            csr_we_o <= 1'h0;
            csr_waddr_o <= 12'h0;
            csr_wdata_o <= 32'h0;
        end else if(csr_ctrl_state_c==WR_MCAUSE)begin
            csr_we_o <= 1'b1;
            csr_waddr_o <= CSR_MCAUSE;
            csr_wdata_o <= (cause==2'h0 ? 32'h80000007 : (cause==2'h1 ? 32'h80000007 : (cause==2'h2 ? 32'd11 : (cause==2'h3 ? 32'd3 : 32'd10))));
        end else if (csr_ctrl_state_c==WR_MEPC) begin    
            csr_we_o <= 1'b1;
            csr_waddr_o <= CSR_MEPC;
            csr_wdata_o <= (cause==2'h0 || cause == 2'h1 || cause == 2'h2 || cause == 2'h3) ? exce_instr_reg + 3'h4 : exce_instr_reg;
        end else if (csr_ctrl_state_c==WR_MTVAL) begin
            csr_we_o <= 1'b1;
            csr_waddr_o <= CSR_MTVAL;
            csr_wdata_o <= cause==2'h3 ? exce_instr_reg : 32'h0;
        end else if (csr_ctrl_state_c==WR_MSTATUS) begin
            csr_we_o <= 1'b1;
            csr_waddr_o <= CSR_MSTATUS;
            csr_wdata_o <= {csr_mstatus[31:8], csr_mstatus[3], csr_mstatus[6:4], 1'b0, csr_mstatus[2:0]};
        end else if (exec2idle)begin//exce_hand_state_c == QUIT
            csr_we_o            <= 1'b1;
            csr_waddr_o         <= CSR_MSTATUS;
            csr_wdata_o         <= {csr_mstatus[31:8], 1'b1, csr_mstatus[6:4], csr_mstatus[7], csr_mstatus[2:0]};
        end else begin
            csr_we_o <= 1'h0;
            csr_waddr_o <= 12'h0;
            csr_wdata_o <= 32'h0;
        end

    end

    assign save_site_done = (csr_ctrl_state_c inside {WR_MSTATUS}) && (csr_ctrl_state_n inside {IDLE});

endmodule


`default_nettype wire
