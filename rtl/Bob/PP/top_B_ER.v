

`include "error_reconcilation_parameter.v"


module top_B_ER (
    input clk,                              //clk
    input rst_n,                            //reset

    input start_B_ER,             //start all frame error reconciliation

    output finish_B_ER,             //finish all frame error reconciliation

    input EVrandombit_full,                 //EV randombit from Alice is full
    output reset_er_parameter,           //

    input sifted_key_addr_index,                            //address index
                                                            //0:addr0 ~ addr16383
                                                            //1:addr16384 ~ addr32767


    output wire single_frame_error_verification_fail,       //error verification is fail


    // Bob sifted key BRAM (input)
    // width = 64 , depth = 32768
    // port B
    output wire Bsiftedkey_clkb,            
    output wire Bsiftedkey_enb,             //1'b1
    output wire Bsiftedkey_web,             //write enable , 1'b0
    output wire [14:0] Bsiftedkey_addrb,    //0~32767
    input wire [63:0] Bsiftedkey_doutb,

    // A2B ER FIFO (input)
    // width = 32 , depth = 2048
    output wire B_A2B_rd_clk,
    output wire B_A2B_rd_en,
    input wire [31:0] B_A2B_rd_dout,
    input wire B_A2B_empty,
    input wire B_A2B_rd_valid,


    //EV random bit BRAM (input)
    // width = 64 , depth = 16384
    // port B
    input wire [63:0] EVrandombit_doutb,            //EV random bit from AXI manager
    output wire [13:0] EVrandombit_addrb,            //0~16383
    output wire EVrandombit_clkb,
    output wire EVrandombit_enb,                    //1'b1
    output wire EVrandombit_rstb,                   //1'b0
    output wire [7:0] EVrandombit_web,              //8 bit write enable , 8'b0


    // B2A ER FIFO (output)
    // width = 32 , depth = 2048
    output wire B_B2A_wr_clk,
    output wire [31:0] B_B2A_wr_din,
    output wire B_B2A_wr_en,
    input wire B_B2A_full,
    input wire B_B2A_wr_ack,


    // reconciled key BRAM (output)
    // width = 64 , depth = 32768
    // port A
    output wire [14:0] reconciledkey_addra,          //0~32767
    output wire reconciledkey_clka,      
    output wire [63:0] reconciledkey_dina,
    output wire reconciledkey_ena,                       //1'b1
    output wire reconciledkey_rsta,                      //1'b0
    output wire reconciledkey_wea     
);


//****************************** DFF for bram output ******************************
    reg [`EV_W-1:0] EVrandombit_doutb_ff;
    always @(posedge clk ) begin
        if (~rst_n) begin
            EVrandombit_doutb_ff <= `EV_W'b0;
        end
        else begin
            EVrandombit_doutb_ff <= EVrandombit_doutb;
        end
    end
//****************************** DFF for bram output ******************************





//****************************** B er fsm ******************************
    // Input wires
    //wire clk;
    //wire rst_n;
    //wire start_B_ER;
    //wire EVrandombit_full;
    wire finish_all_frame_er;

    // Output registers
    wire start_all_frame_er;
    //wire reset_er_parameter;
    //wire finish_B_ER;

    // Output register for FSM state
    wire [3:0] B_er_state;



    B_er_fsm Ber_fsm (
        .clk(clk),                          // Clock signal
        .rst_n(rst_n),                      // Reset signal

        .start_B_ER(start_B_ER),            // Input signal to start B's error reconciliation
        .EVrandombit_full(EVrandombit_full),// Input signal indicating EV random bits are full
        .finish_all_frame_er(finish_all_frame_er), // Input signal indicating all frames error reconciliation is finished

        .start_all_frame_er(start_all_frame_er),   // Output signal to start all frame error reconciliation
        .reset_er_parameter(reset_er_parameter),   // Output signal to reset error reconciliation parameters
        .finish_B_ER(finish_B_ER),                 // Output signal indicating B's error reconciliation is finished

        .B_er_state(B_er_state)             // Output register for B's error reconciliation state
    );

//****************************** B er fsm ******************************






//****************************** B all frame ER ******************************


    all_frame_B_ER af_B_ER (
        .clk(clk),                                // Connect to clock
        .rst_n(rst_n),                            // Connect to reset

        .start_B_all_frame_ER(start_all_frame_er), // Start signal for all frame error reconciliation

        .finish_all_frame_ER(finish_all_frame_er),        //finish all frame error reconciliation

        .sifted_key_addr_index(sifted_key_addr_index),      //address index
                                                            //0:addr0 ~ addr16383
                                                            //1:addr16384 ~ addr32767


        .single_frame_error_verification_fail(single_frame_error_verification_fail), // Output for error verification status

        // Bob sifted key BRAM connections
        .Bsiftedkey_clkb(Bsiftedkey_clkb),            
        .Bsiftedkey_enb(Bsiftedkey_enb),             
        .Bsiftedkey_web(Bsiftedkey_web),             
        .Bsiftedkey_addrb(Bsiftedkey_addrb),    
        .Bsiftedkey_doutb(Bsiftedkey_doutb),

        // A2B ER FIFO connections
        .B_A2B_rd_clk(B_A2B_rd_clk),
        .B_A2B_rd_en(B_A2B_rd_en),
        .B_A2B_rd_dout(B_A2B_rd_dout),
        .B_A2B_empty(B_A2B_empty),
        .B_A2B_rd_valid(B_A2B_rd_valid),

        // EV random bit BRAM connections
        .EVrandombit_doutb(EVrandombit_doutb),
        .EVrandombit_addrb(EVrandombit_addrb),
        .EVrandombit_clkb(EVrandombit_clkb),
        .EVrandombit_enb(EVrandombit_enb),
        .EVrandombit_rstb(EVrandombit_rstb),
        .EVrandombit_web(EVrandombit_web),

        // B2A ER FIFO connections
        .B_B2A_wr_clk(B_B2A_wr_clk),
        .B_B2A_wr_din(B_B2A_wr_din),
        .B_B2A_wr_en(B_B2A_wr_en),
        .B_B2A_full(B_B2A_full),
        .B_B2A_wr_ack(B_B2A_wr_ack),

        // Reconciled key BRAM connections
        .reconciledkey_addra(reconciledkey_addra),
        .reconciledkey_clka(reconciledkey_clka),
        .reconciledkey_dina(reconciledkey_dina),
        .reconciledkey_ena(reconciledkey_ena),
        .reconciledkey_rsta(reconciledkey_rsta),
        .reconciledkey_wea(reconciledkey_wea)
    );

//****************************** B all frame ER ******************************



endmodule

















module B_er_fsm (
    input clk,
    input rst_n,

    input start_B_ER,
    input EVrandombit_full,
    input finish_all_frame_er,

    output reg start_all_frame_er,
    output reg reset_er_parameter,
    output reg finish_B_ER,

    output reg [3:0] B_er_state
);

    localparam ER_IDLE                                  = 4'd0;
    localparam ER_START                                 = 4'd1;
    localparam WAIT_EVRANDOMBIT                         = 4'd2;
    localparam PARANDOMBIT_FULL                         = 4'd3;
    localparam START_ALL_FRAME_ER                       = 4'd4;
    localparam ALL_FRAME_ER_BUSY                        = 4'd5;
    localparam ALL_FRAME_ER_END                         = 4'd6;
    localparam RESET_ER_PARAMETER                       = 4'd7;
    localparam ER_END                                   = 4'd8;




    reg [3:0] next_B_er_state;
    always @(posedge clk ) begin
        if (~rst_n) begin
            B_er_state <= ER_IDLE;
        end
        else begin
            B_er_state <= next_B_er_state;
        end
    end
    
    always @(*) begin
        case (B_er_state)
            ER_IDLE: begin
                if (start_B_ER) begin
                    next_B_er_state = ER_START;
                    start_all_frame_er = 1'b0;
                    reset_er_parameter = 1'b0;
                    finish_B_ER = 1'b0;
                end
                else begin
                    next_B_er_state = ER_IDLE;
                    start_all_frame_er = 1'b0;
                    reset_er_parameter = 1'b0;
                    finish_B_ER = 1'b0;
                end
            end



            ER_START: begin
                next_B_er_state = WAIT_EVRANDOMBIT;
                start_all_frame_er = 1'b0;
                reset_er_parameter = 1'b0;
                finish_B_ER = 1'b0;
            end



            WAIT_EVRANDOMBIT: begin
                if (EVrandombit_full ) begin
                    next_B_er_state = PARANDOMBIT_FULL;
                    start_all_frame_er = 1'b0;
                    reset_er_parameter = 1'b0;
                    finish_B_ER = 1'b0;
                end
                else begin
                    next_B_er_state = WAIT_EVRANDOMBIT;
                    start_all_frame_er = 1'b0;
                    reset_er_parameter = 1'b0;
                    finish_B_ER = 1'b0;
                end
            end




            PARANDOMBIT_FULL: begin
                next_B_er_state = START_ALL_FRAME_ER;
                start_all_frame_er = 1'b0;
                reset_er_parameter = 1'b0;
                finish_B_ER = 1'b0;
            end



            START_ALL_FRAME_ER: begin
                next_B_er_state = ALL_FRAME_ER_BUSY;
                start_all_frame_er = 1'b1;
                reset_er_parameter = 1'b0;
                finish_B_ER = 1'b0;
            end

            ALL_FRAME_ER_BUSY: begin
                if (finish_all_frame_er ) begin
                    next_B_er_state = ALL_FRAME_ER_END;
                    start_all_frame_er = 1'b0;
                    reset_er_parameter = 1'b0;
                    finish_B_ER = 1'b0;
                end
                else begin
                    next_B_er_state = ALL_FRAME_ER_BUSY;
                    start_all_frame_er = 1'b0;
                    reset_er_parameter = 1'b0;
                    finish_B_ER = 1'b0;
                end
            end

            ALL_FRAME_ER_END: begin
                next_B_er_state = RESET_ER_PARAMETER;
                start_all_frame_er = 1'b0;
                reset_er_parameter = 1'b0;
                finish_B_ER = 1'b0;
            end


            RESET_ER_PARAMETER: begin
                next_B_er_state = ER_END;
                start_all_frame_er = 1'b0;
                reset_er_parameter = 1'b1;
                finish_B_ER = 1'b0;
            end

            ER_END: begin
                next_B_er_state = ER_IDLE;
                start_all_frame_er = 1'b0;
                reset_er_parameter = 1'b0;
                finish_B_ER = 1'b1;
            end



            default: begin
                next_B_er_state = ER_IDLE;
                start_all_frame_er = 1'b0;
                reset_er_parameter = 1'b0;
                finish_B_ER = 1'b0;
            end
        endcase
    end


    
endmodule


