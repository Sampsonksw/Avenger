// +FHDR------------------------------------------------------------------------
//                                                                              
//  Copyright(c)2021, ZGOO                                                      
//  All rights reserved                                                         
//                                                                              
//  File name   : div.v
//  Module name : div                                                   
//  Author      : ske
//  Description : 
//                                                                              
//  Email       : ske@zgoo.com                                                 
//  Data        : 2021/10/20
//  Version     : v0.1                                                          
//  Abstract    :                                                               
//                                                                              
// -----------------------------------------------------------------------------
//  KEYWORDS    : div
// -----------------------------------------------------------------------------
//  Modification history                                                        
// -----------------------------------------------------------------------------
//  Version | Data       | Description                                          
//  v0.1    | 2021/10/20 | Initial add.                                         
// -FHDR------------------------------------------------------------------------

`default_nettype none

module div(    
    input   logic                   clk_i           ,
    input   logic                   rst_ni          ,
    
    input   logic                   div_start       ,
    input   logic   [31:0]          dividend        ,
    input   logic   [31:0]          divisor         ,
    
    output  logic   [31:0]          quotient        ,
    output  logic   [31:0]          remainder       ,
    output  logic                   div_done        ,
    output  logic                   div_busy        ,
    input   logic                   refresh_pip_i   
);


    typedef enum logic [1:0] {
        IDLE,
        START,
        CALC,
        DONE
    } state_e;

    state_e state_c,state_n;

    logic   [63:0]  extend_dividend;
    logic   [63:0]  extend_divisor;
    logic   [5:0]   leftshift_cnt;
    logic           idle2start,start2calc,calc2done,done2idle;

    assign  idle2start  =   div_start;
    assign  start2calc  =   1'b1;
    assign  calc2done   =   leftshift_cnt == 6'd31;
    assign  done2idle   =   1'b1;

    assign  div_busy    =   state_c !== IDLE;

    always_ff @(posedge clk_i, negedge rst_ni)begin
        if(!rst_ni || refresh_pip_i)begin
            state_c <= IDLE;
        end else begin
            state_c <= state_n;
        end
    end

    always_comb begin
        case(state_c)
            IDLE    :   begin
                            if(idle2start)  state_n = START;
                            else state_n = state_c;
                        end
            START   :   begin
                            if(start2calc)  state_n = CALC;
                            else state_n = state_c;
                        end
            CALC    :   begin
                            if(calc2done)   state_n = DONE;
                            else state_n = state_c;
                        end
            DONE    :   begin
                            if(done2idle)   state_n = IDLE;
                            else state_n = state_c;
                        end
            default :   state_n = IDLE;
        endcase
    end


    always_ff @(posedge clk_i,negedge rst_ni)begin
        if(!rst_ni)begin
            quotient        <= 32'h0;
            remainder       <= 32'h0;
            div_done        <= 32'h0;
            leftshift_cnt   <=  6'h0;
            extend_dividend <= 64'h0;
            extend_divisor  <= 64'h0;
        end else begin
            case (state_c)
                IDLE    :   begin
                                quotient        <= 32'h0;
                                remainder       <= 32'h0;
                                div_done        <= 32'h0;
                                leftshift_cnt   <=  6'h0;
                                extend_dividend <= 64'h0;
                                extend_divisor  <= 64'h0;
                            end
                START   :   begin
                                quotient        <= 32'h0;
                                remainder       <= 32'h0;
                                div_done        <= 32'h0;
                                leftshift_cnt   <=  6'h0;
                                extend_dividend <= {32'h0,dividend};
                                extend_divisor  <= {divisor,32'h0};
                            end
                CALC    :   begin
                                leftshift_cnt   <=  leftshift_cnt + 1'b1;
                                extend_dividend = {extend_dividend[62:0],1'b0};
                                
                                if(extend_dividend[63:32]>=divisor)begin
                                    extend_dividend = extend_dividend - extend_divisor +1'b1;
                                end else begin
                                    extend_dividend = extend_dividend;
                                end
                                
                            end
                DONE    :   begin
                                quotient    <=  extend_dividend[31:0];
                                remainder   <=  extend_dividend[63:32];
                                div_done    <=  1'b1;
                            end
                default :   begin
                                quotient        <= 32'h0;
                                remainder       <= 32'h0;
                                div_done        <= 32'h0;
                                leftshift_cnt   <=  6'h0;
                                extend_dividend <= 64'h0;
                                extend_divisor  <= 64'h0;
                            end
            endcase
        end
    end



endmodule



