
`include "error_reconcilation_parameter.v"

module all_frame_B_ER (
    input clk,                              //clk
    input rst_n,                            //reset

    input start_B_all_frame_ER,             //start all frame error reconciliation

    output finish_all_frame_ER,             //finish all frame error reconciliation

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


//****************************** parameter ******************************
    reg [`FRAME_ROUND_WIDTH-1:0] frame_round;
    always @(posedge clk ) begin
        if (~rst_n) begin
            frame_round <= 0;
        end
        else if (reset_AF_ER_parameter) begin
            frame_round <= 0;
        end
        else if (finish_B_single_frame_ER) begin
            frame_round <= frame_round + 1;
        end
        else begin
            frame_round <= frame_round;
        end
    end

    assign last_frame = (frame_round==(`MAX_FRAME_ROUND))? 1'b1:1'b0;
//****************************** parameter ******************************



//****************************** all frame fsm ******************************

    // Wire declarations for B_all_frame_fsm module inputs
    //wire clk;                                  // Clock signal
    //wire rst_n;                                // Reset signal
    //wire start_B_all_frame_ER;                 // Start signal for all frame error reconciliation
    wire finish_B_single_frame_ER;             // Signal indicating single frame reconciliation completion
    wire last_frame;                           // Signal indicating the last frame for error reconciliation

    // Wire declarations for B_all_frame_fsm module outputs
    wire start_single_frame_ER;                // Output signal to start single frame error reconciliation
    //wire finish_all_frame_ER;                  // Output signal indicating completion of all frame error reconciliation
    wire reset_AF_ER_parameter;                // Output signal to reset all frame parameters
    wire [3:0] B_all_frame_state;              // Output wire for the current state of the FSM


    B_all_frame_fsm B_af_fsm (
        .clk(clk),                              // Connect to clock
        .rst_n(rst_n),                          // Connect to reset

        .start_B_all_frame_ER(start_B_all_frame_ER), // Input to start all frame error reconciliation
        .finish_B_single_frame_ER(finish_B_single_frame_ER), // Input indicating a single frame finish
        .last_frame(last_frame),                 // Input indicating the last frame for error reconciliation

        .start_single_frame_ER(start_single_frame_ER), // Output to start single frame error reconciliation
        .finish_all_frame_ER(finish_all_frame_ER),     // Output indicating all frame error reconciliation finish
        .reset_AF_ER_parameter(reset_AF_ER_parameter), // Output to reset all frame parameter
        .B_all_frame_state(B_all_frame_state)    // Output for current state of the FSM
    );

//****************************** all frame fsm ******************************


//****************************** B ER ******************************

    single_frame_B_ER sf_B_ER (
        .clk(clk),                                      // Clock signal
        .rst_n(rst_n),                                  // Reset signal

        .start_B_single_frame_ER(start_single_frame_ER), // Start signal for single frame error reconciliation
        .frame_round(frame_round),                      // Frame round number
        .sifted_key_addr_index(sifted_key_addr_index),  // Address index input

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
        .reconciledkey_wea(reconciledkey_wea),

        // Output signals
        .error_verification_fail(single_frame_error_verification_fail), // Error verification status
        .finish_error_reconciliation(finish_B_single_frame_ER) // Signal indicating completion of error reconciliation
    );


//****************************** B ER ******************************


endmodule
















module B_all_frame_fsm (
    input clk,
    input rst_n,
    input start_B_all_frame_ER,             //start all frame error reconciliation
    input finish_B_single_frame_ER,         //single frame finish
    input last_frame,                       //last frame for ER

    output reg start_single_frame_ER,           //start single frame error reconciliation
    output reg finish_all_frame_ER,             //finish all frame error reconciliation
    output reg reset_AF_ER_parameter,           //reset all frame parameter
    output reg [3:0] B_all_frame_state
);

    localparam IDLE                 = 4'd0;
    localparam START_AF_ER          = 4'd1;
    localparam START_SF_ER          = 4'd2;
    localparam SF_ER_BUSY           = 4'd3;
    localparam FINISH_SF_ER         = 4'd4;
    localparam RESET_AF_ER          = 4'd5;
    localparam AF_ER_END            = 4'd6;



    reg [3:0] next_B_all_frame_state;
    always @(posedge clk ) begin
        if (~rst_n) begin
            B_all_frame_state <= IDLE;
        end
        else begin
            B_all_frame_state <= next_B_all_frame_state;
        end
    end

    always @(*) begin
        case (B_all_frame_state)
            IDLE: begin
                if (start_B_all_frame_ER) begin
                    next_B_all_frame_state = START_AF_ER;
                    start_single_frame_ER = 1'b0;
                    finish_all_frame_ER = 1'b0;
                    reset_AF_ER_parameter = 1'b0;
                end
                else begin
                    next_B_all_frame_state = IDLE;
                    start_single_frame_ER = 1'b0;
                    finish_all_frame_ER = 1'b0;
                    reset_AF_ER_parameter = 1'b0;
                end
            end
            START_AF_ER: begin
                next_B_all_frame_state = START_SF_ER;
                start_single_frame_ER = 1'b0;
                finish_all_frame_ER = 1'b0;
                reset_AF_ER_parameter = 1'b0;
            end

            START_SF_ER: begin
                next_B_all_frame_state = SF_ER_BUSY;
                start_single_frame_ER = 1'b1;
                finish_all_frame_ER = 1'b0;
                reset_AF_ER_parameter = 1'b0;
            end

            SF_ER_BUSY: begin
                if (finish_B_single_frame_ER & last_frame) begin
                    next_B_all_frame_state = RESET_AF_ER;
                    start_single_frame_ER = 1'b0;
                    finish_all_frame_ER = 1'b0;
                    reset_AF_ER_parameter = 1'b0;
                end
                else if (finish_B_single_frame_ER) begin
                    next_B_all_frame_state = FINISH_SF_ER;
                    start_single_frame_ER = 1'b0;
                    finish_all_frame_ER = 1'b0;
                    reset_AF_ER_parameter = 1'b0;
                end
                else begin
                    next_B_all_frame_state = SF_ER_BUSY;
                    start_single_frame_ER = 1'b0;
                    finish_all_frame_ER = 1'b0;
                    reset_AF_ER_parameter = 1'b0;
                end
            end

            FINISH_SF_ER: begin
                next_B_all_frame_state = START_SF_ER;
                start_single_frame_ER = 1'b0;
                finish_all_frame_ER = 1'b0;
                reset_AF_ER_parameter = 1'b0;
            end

            RESET_AF_ER: begin
                next_B_all_frame_state = AF_ER_END;
                start_single_frame_ER = 1'b0;
                finish_all_frame_ER = 1'b0;
                reset_AF_ER_parameter = 1'b1;
            end


            AF_ER_END: begin
                next_B_all_frame_state = IDLE;
                start_single_frame_ER = 1'b0;
                finish_all_frame_ER = 1'b1;
                reset_AF_ER_parameter = 1'b0;
            end


            default: begin
                next_B_all_frame_state = IDLE;
                start_single_frame_ER = 1'b0;
                finish_all_frame_ER = 1'b0;
                reset_AF_ER_parameter = 1'b0;
            end
        endcase
    end


    
endmodule