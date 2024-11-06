


//`include "error_reconcilation_parameter.v"



module single_frame_B_ER (
    input clk,                              //clk
    input rst_n,                            //reset

    input start_B_single_frame_ER,       //start to error reconciliation

    input [`FRAME_ROUND_WIDTH-1:0] frame_round,

    input sifted_key_addr_index,                            //address index
                                                            //0:addr0 ~ addr16383
                                                            //1:addr16384 ~ addr32767
                                                                



    // Bob sifted key BRAM (input)
    // width = 64 , depth = 32768
    // port B
    output wire Bsiftedkey_clkb,            
    output wire Bsiftedkey_enb,             //1'b1
    output wire Bsiftedkey_web,             //write enable , 1'b0
    output wire [14:0] Bsiftedkey_addrb,    //0~32767
    input wire [63:0] Bsiftedkey_doutb,
    //output wire [63:0] Bsiftedkey_dinb;   //no use
    


    // A2B ER FIFO (input)
    // width = 32 , depth = 2048
    output wire B_A2B_rd_clk,
    output reg B_A2B_rd_en,
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
    output reg [31:0] B_B2A_wr_din,
    output reg B_B2A_wr_en,
    input wire B_B2A_full,
    input wire B_B2A_wr_ack,


    // reconciled key BRAM (output)
    // width = 64 , depth = 32768
    // port A
    output reg [14:0] reconciledkey_addra,          //0~32767
    output wire reconciledkey_clka,      
    output reg [63:0] reconciledkey_dina,
    output wire reconciledkey_ena,                       //1'b1
    output wire reconciledkey_rsta,                      //1'b0
    output reg reconciledkey_wea,                    


    output error_verification_fail,         //error verification is fail
    output finish_error_reconciliation      //error reconsiliation is done
);






//****************************** B ER fsm ******************************
    //fsm input
    wire Bcascade_finish;
    wire hashtag_valid;
    wire hashtag_send_end;
    wire read_A_hashtag_end;
    wire hashtag_compare_result;
    wire write_reconciled_key_finish;


    //fsm output
    wire reset_ER_parameter;
    wire start_cascade_error_correction;
    wire start_hash;
    wire send_hashtag_en;
    wire read_Alice_hashtag_en;
    wire write_reconciled_key_en;
    wire ec_fifo_enable;
    wire er_fifo_enable;

    wire [4:0] B_ER_state;

    B_error_reconciliation_fsm B_ER_fsm(
        .clk(clk),
        .rst_n(rst_n),

        .start_B_error_reconciliation(start_B_single_frame_ER),
        .cascade_finish(Bcascade_finish),

        .hashtag_valid(hashtag_valid),

        .B_A2B_rd_valid(er_B_A2B_rd_valid),
        .hashtag_send_end(hashtag_send_end),
        .read_A_hashtag_end(read_A_hashtag_end),

        .hashtag_compare_result(hashtag_compare_result),
        .write_reconciled_key_finish(write_reconciled_key_finish),

        .reset_ER_parameter(reset_ER_parameter),
        .start_cascade_error_correction(start_cascade_error_correction),
        .start_hash(start_hash),
        .send_hashtag_en(send_hashtag_en),
        .read_Alice_hashtag_en(read_Alice_hashtag_en),
        .write_reconciled_key_en(write_reconciled_key_en),
        .error_verification_fail(error_verification_fail),
        .finish_error_reconciliation(finish_error_reconciliation),
        .ec_fifo_enable(ec_fifo_enable),
        .er_fifo_enable(er_fifo_enable),
        .er_parameter_valid(),

        .B_ER_state(B_ER_state)
    );
//****************************** B ER fsm ******************************


//****************************** Estimated error count ******************************

//****************************** Estimated error count ******************************




//****************************** fifo for EC or ER ******************************

    // A2B ER FIFO (input)
    // width = 32 , depth = 2048
    wire ec_B_A2B_rd_en;
    wire [31:0] ec_B_A2B_rd_dout;
    wire ec_B_A2B_empty;
    wire ec_B_A2B_rd_valid;

    // B2A ER FIFO (output)
    // width = 32 , depth = 2048
    wire [31:0] ec_B_B2A_wr_din;
    wire ec_B_B2A_wr_en;
    wire ec_B_B2A_full;
    wire ec_B_B2A_wr_ack;

    // A2B ER FIFO (input)
    // width = 32 , depth = 2048
    wire er_B_A2B_rd_en;
    wire [31:0] er_B_A2B_rd_dout;
    wire er_B_A2B_empty;
    wire er_B_A2B_rd_valid;

    // B2A ER FIFO (output)
    // width = 32 , depth = 2048
    reg [31:0] er_B_B2A_wr_din;
    wire er_B_B2A_wr_en;
    wire er_B_B2A_full;
    wire er_B_B2A_wr_ack;

    // output
    always @(*) begin
        if (ec_fifo_enable) begin
            B_A2B_rd_en = ec_B_A2B_rd_en;
            B_B2A_wr_en = ec_B_B2A_wr_en;
            B_B2A_wr_din = ec_B_B2A_wr_din;
        end
        else if (er_fifo_enable) begin
            B_A2B_rd_en = er_B_A2B_rd_en;
            B_B2A_wr_en = er_B_B2A_wr_en;
            B_B2A_wr_din = er_B_B2A_wr_din;
        end
        else begin
            B_A2B_rd_en = 1'b0;
            B_B2A_wr_en = 1'b0;
            B_B2A_wr_din = 32'b0;
        end
    end

    //input
    assign ec_B_A2B_rd_dout = (ec_fifo_enable)? B_A2B_rd_dout:32'b0;
    assign ec_B_A2B_rd_valid = (ec_fifo_enable)? B_A2B_rd_valid:1'b0;
    assign ec_B_A2B_empty = (ec_fifo_enable)? B_A2B_empty:1'b0;
    assign ec_B_B2A_full = (ec_fifo_enable)? B_B2A_full:1'b0;
    assign ec_B_B2A_wr_ack = (ec_fifo_enable)? B_B2A_wr_ack:1'b0;


    assign er_B_A2B_rd_dout = (er_fifo_enable)? B_A2B_rd_dout:32'b0;
    assign er_B_A2B_rd_valid = (er_fifo_enable)? B_A2B_rd_valid:1'b0;
    assign er_B_A2B_empty = (er_fifo_enable)? B_A2B_empty:1'b0;
    assign er_B_B2A_full = (er_fifo_enable)? B_B2A_full:1'b0;
    assign er_B_B2A_wr_ack = (er_fifo_enable)? B_B2A_wr_ack:1'b0;


//****************************** fifo for EC or ER ******************************


//****************************** Bob cascade instantiation ******************************

    wire [`CASCADE_KEY_LENGTH-1:0] Bcorrected_key;


    Bob_cascade Bcascade(
        .clk(clk),                              // Clock input
        .rst_n(rst_n),                          // Reset input

        //error count estimation based on previous reconciliation 
        //or default error count = 130
        .est_error_count(est_error_count), 

        .start_cascade_error_correction(start_cascade_error_correction),   //start to error correction
        
        .frame_round(frame_round),

        .sifted_key_addr_index(sifted_key_addr_index),

        // Bob sifted key BRAM (input)
        // width = 64 , depth = 32768
        // port B
        .Bsiftedkey_clkb(Bsiftedkey_clkb),                     // Clock output for Bsiftedkey
        .Bsiftedkey_enb(Bsiftedkey_enb),                      // Enable signal for Bsiftedkey ,1'b1
        .Bsiftedkey_web(Bsiftedkey_web),                      // Write enable for Bsiftedkey ,1'b0
        .Bsiftedkey_addrb(Bsiftedkey_addrb),                    // Address for Bsiftedkey ,0~32767
        .Bsiftedkey_doutb(Bsiftedkey_doutb),                    // Data output for Bsiftedkey


        // A2B ER FIFO (input)
        // width = 32 , depth = 2048

        .B_A2B_rd_clk(B_A2B_rd_clk),                          // Read clock for A2B ER FIFO
        .B_A2B_rd_en(ec_B_A2B_rd_en),                           // Read enable for A2B ER FIFO
        .B_A2B_rd_dout(ec_B_A2B_rd_dout),                            // Data output from A2B ER FIFO
        .B_A2B_rd_valid(ec_B_A2B_rd_valid),                           
        .B_A2B_empty(ec_B_A2B_empty),                           // Empty signal for A2B ER FIFO

        // B2A ER FIFO (output)
        // width = 32 , depth = 2048
        .B_B2A_wr_clk(B_B2A_wr_clk),                          // Write clock for B2A ER FIFO
        .B_B2A_wr_din(ec_B_B2A_wr_din),                             // Data input for B2A ER FIFO
        .B_B2A_wr_en(ec_B_B2A_wr_en),                           // Write enable for B2A ER FIFO
        .B_B2A_full(ec_B_B2A_full),                            // Full signal for B2A ER FIFO
        .B_B2A_wr_ack(ec_B_B2A_wr_ack),                           




        .cascade_finish(Bcascade_finish),                      // Cascade finish output
        .corrected_key(Bcorrected_key)                        // Corrected key output
    );
//****************************** Bob cascade instantiation ******************************
    











//****************************** EV instantiation ******************************
    wire [`EV_KEY_LENGTH-1:0] B_EV_corrected_key;
    assign B_EV_corrected_key = Bcorrected_key;


    //wire start_hash;


    wire [`EV_HASHTAG_WIDTH-1:0] target_hashtag;




    top_ev B_ev(
        .clk(clk),                                      //clk
        .rst_n(rst_n),                                    //reset


        
        .corrected_key(B_EV_corrected_key),       //corrected key (no shuffle)
        .start_hash(start_hash),                               //start to compute hash tag

        .target_hashtag_ff(target_hashtag),  //hash tag target
                                                        //computed from corrected key & EV random bit
        .hashtag_valid(hashtag_valid),                           //hash tag is valid

        .frame_round(frame_round),

        //EV random bit BRAM
        // width = 64 , depth = 16384
        // port B
        .EVrandombit_doutb(EVrandombit_doutb),            //EV random bit from AXI manager
        .EVrandombit_addrb(EVrandombit_addrb),            //0~16383
        .EVrandombit_clkb(EVrandombit_clkb),
        .EVrandombit_enb(EVrandombit_enb),                    //1'b1
        .EVrandombit_rstb(EVrandombit_rstb),                   //1'b0
        .EVrandombit_web(EVrandombit_web)              //8'b0
);



//****************************** EV instantiation ******************************





//****************************** hashtag DFF ******************************
    reg [`EV_HASHTAG_WIDTH-1:0] Bob_hashtag_ff;

    always @(posedge clk ) begin
        if (~rst_n) begin
            Bob_hashtag_ff <= `EV_HASHTAG_WIDTH'b0;
        end
        else if (reset_ER_parameter) begin
            Bob_hashtag_ff <= `EV_HASHTAG_WIDTH'b0;
        end
        else if (hashtag_valid) begin
            Bob_hashtag_ff <= target_hashtag;
        end
        else begin
            Bob_hashtag_ff <= Bob_hashtag_ff;
        end
    end

//****************************** hashtag DFF ******************************


//****************************** send hashtag ******************************

    //wire hashtag_send_end;
    //wire send_hashtag_en;

    reg [3:0] send_hashtag_cnt;
    always @(posedge clk ) begin
        if (~rst_n) begin
            send_hashtag_cnt <= 4'b0;
        end
        else if (reset_ER_parameter) begin
            send_hashtag_cnt <= 4'b0;
        end
        else if (send_hashtag_en) begin
            send_hashtag_cnt <= send_hashtag_cnt + 1;
        end
        else begin
            send_hashtag_cnt <= send_hashtag_cnt;
        end
    end

    assign er_B_B2A_wr_en = ((send_hashtag_cnt>0)&&(send_hashtag_cnt<3))? 1'b1:1'b0;

    wire [`RECONCILIATION_REAL_PACKET_DEPTH_WIDTH-1:0] hashtag_packet_real_depth;
    assign hashtag_packet_real_depth = `RECONCILIATION_REAL_PACKET_DEPTH_WIDTH'd1;


    always @(*) begin
        case (send_hashtag_cnt)
            4'b0000: er_B_B2A_wr_din = 32'b0;
            4'b0001: er_B_B2A_wr_din = {`B2A_VERIFICATION_HASHTAG, `PACKET_LENGTH_257, hashtag_packet_real_depth, {15{1'b0}}};
            4'b0010: er_B_B2A_wr_din = Bob_hashtag_ff[63:32];
            default: er_B_B2A_wr_din = 32'b0;
        endcase
    end

    assign hashtag_send_end = (send_hashtag_cnt==5);
//****************************** send hashtag ******************************



//****************************** read Alice hashtag ******************************
    //read_Alice_hashtag_en
    //read_A_hashtag_end

    reg [3:0] read_hashtag_cnt;
    always @(posedge clk ) begin
        if (~rst_n) begin
            read_hashtag_cnt <= 4'b0;
        end
        else if (reset_ER_parameter) begin
            read_hashtag_cnt <= 4'b0;
        end
        else if (read_Alice_hashtag_en) begin
            read_hashtag_cnt <= read_hashtag_cnt + 1;
        end
        else begin
            read_hashtag_cnt <= read_hashtag_cnt;
        end
    end


    assign er_B_A2B_rd_en = (read_hashtag_cnt>0 && read_hashtag_cnt<4)? 1'b1:1'b0;
    assign read_A_hashtag_end = (read_hashtag_cnt==5);

    reg [`EV_REAL_HASHTAG_WIDTH-1:0] Alice_hashtag_ff;
    always @(posedge clk ) begin
        if (~rst_n) begin
            Alice_hashtag_ff <= `EV_REAL_HASHTAG_WIDTH'b0;
        end
        else if (reset_ER_parameter) begin
            Alice_hashtag_ff <= `EV_REAL_HASHTAG_WIDTH'b0;
        end
        else if (read_hashtag_cnt==2) begin
            Alice_hashtag_ff <= er_B_A2B_rd_dout;
        end
        else begin
            Alice_hashtag_ff <= Alice_hashtag_ff;
        end
    end
    
    assign hashtag_compare_result = (Alice_hashtag_ff==Bob_hashtag_ff[63:32]);



    reg [`FRAME_ERROR_COUNT_WIDTH-1:0] est_error_count;
    always @(posedge clk ) begin
        if (~rst_n) begin
            est_error_count <= `DEFAULT_ERROR_COUNT;
        end
        else if (read_hashtag_cnt==3) begin
            est_error_count <= er_B_A2B_rd_dout[`FRAME_ERROR_COUNT_WIDTH-1:0];
        end
        else begin
            est_error_count <= est_error_count;
        end
    end


//****************************** read Alice hashtag ******************************











//****************************** write reconciliation key ******************************
    //write_reconciled_key_finish
    //write_reconciled_key_en

    reg [10:0] write_reconciled_key_cnt;
    always @(posedge clk ) begin
        if (~rst_n) begin
            write_reconciled_key_cnt <= 11'b0;
        end
        else if (reset_ER_parameter) begin
            write_reconciled_key_cnt <= 11'b0;
        end
        else if (write_reconciled_key_en) begin
            write_reconciled_key_cnt <= write_reconciled_key_cnt + 1;
        end
        else begin
            write_reconciled_key_cnt <= write_reconciled_key_cnt;
        end
    end

    assign write_reconciled_key_finish = (write_reconciled_key_cnt==(`RECONCILED_KEY_64_DEPTH+4));


    always @(posedge clk) begin
        if (~rst_n) begin
            reconciledkey_addra <= {15{1'b1}};
            reconciledkey_dina <= 64'b0;
            reconciledkey_wea <= 1'b0;
        end
        else if ((write_reconciled_key_cnt>0)&&(write_reconciled_key_cnt<(`RECONCILED_KEY_64_DEPTH+1))) begin
            reconciledkey_addra <= reconciledkey_addra + 1;
            reconciledkey_dina <= Bcorrected_key[((`RECONCILED_KEY_64_DEPTH-write_reconciled_key_cnt)<<6) +: 64];
            reconciledkey_wea <= 1'b1;
        end
        else begin
            reconciledkey_addra <= reconciledkey_addra;
            reconciledkey_dina <= 64'b0;
            reconciledkey_wea <= 1'b0;
        end
    end


    assign reconciledkey_clka = clk;
    assign reconciledkey_ena = 1'b1;
    assign reconciledkey_rsta = rst_n;



//****************************** write reconciliation key ******************************












endmodule





















module B_error_reconciliation_fsm (
    input clk,
    input rst_n,

    input start_B_error_reconciliation,
    input cascade_finish,

    input hashtag_valid,

    input B_A2B_rd_valid,
    input hashtag_send_end,
    input read_A_hashtag_end,

    input hashtag_compare_result,
    input write_reconciled_key_finish,

    output reg reset_ER_parameter,
    output reg start_cascade_error_correction,
    output reg start_hash,
    output reg send_hashtag_en,
    output reg read_Alice_hashtag_en,
    output reg write_reconciled_key_en,
    output reg error_verification_fail,
    output reg finish_error_reconciliation,
    output reg er_parameter_valid,
    output wire ec_fifo_enable,
    output wire er_fifo_enable,

    output reg [4:0] B_ER_state
);

    localparam ER_IDLE                  = 5'd0;
    localparam ER_RESET                 = 5'd1;
    localparam ER_START                 = 5'd2;

    localparam CASCADE_START            = 5'd3;
    localparam CASCADE_BUSY             = 5'd4;
    localparam CASCADE_DONE             = 5'd6;

    localparam HASHTAG_START            = 5'd7;
    localparam HASHTAG_BUSY             = 5'd8;
    localparam HASHTAG_VALID            = 5'd9;

    localparam SEND_HASHTAG_PARAMETER   = 5'd12;
    localparam WAIT_ALICE_HASHTAG       = 5'd10;
    localparam READ_ALICE_HASHTAG       = 5'd11;
    localparam COMPARE_HASHTAG          = 5'd13;

    localparam WRITE_RECONCILED_KEY     = 5'd14;
    localparam WRITE_DONE               = 5'd15;

    localparam ER_DONE                  = 5'd16;
    localparam ER_FAIL                  = 5'd17;


    assign ec_fifo_enable = ((B_ER_state==CASCADE_START)|(B_ER_state==CASCADE_BUSY)|(B_ER_state==CASCADE_DONE));
    assign er_fifo_enable = ((B_ER_state==SEND_HASHTAG_PARAMETER)|(B_ER_state==WAIT_ALICE_HASHTAG)|(B_ER_state==READ_ALICE_HASHTAG));

    reg [4:0] next_B_ER_state;


    always @(posedge clk ) begin
        if (~rst_n) begin
            B_ER_state <= ER_IDLE;
        end
        else begin
            B_ER_state <= next_B_ER_state;
        end
    end


    always @(*) begin
        case (B_ER_state)
            ER_IDLE: begin
                if (start_B_error_reconciliation) begin
                    next_B_ER_state = ER_RESET;
                    reset_ER_parameter = 1'b0;
                    start_cascade_error_correction = 1'b0;
                    start_hash = 1'b0;
                    send_hashtag_en = 1'b0;
                    read_Alice_hashtag_en = 1'b0;
                    write_reconciled_key_en = 1'b0;
                    error_verification_fail = 1'b0;
                    finish_error_reconciliation = 1'b0;
                    er_parameter_valid = 1'b0;
                end
                else begin
                    next_B_ER_state = ER_IDLE;
                    reset_ER_parameter = 1'b0;
                    start_cascade_error_correction = 1'b0;
                    start_hash = 1'b0;
                    send_hashtag_en = 1'b0;
                    read_Alice_hashtag_en = 1'b0;
                    write_reconciled_key_en = 1'b0;
                    error_verification_fail = 1'b0;
                    finish_error_reconciliation = 1'b0;
                    er_parameter_valid = 1'b0;
                end
            end 
            
            ER_RESET: begin
                next_B_ER_state = ER_START;
                reset_ER_parameter = 1'b1;
                start_cascade_error_correction = 1'b0;
                start_hash = 1'b0;
                send_hashtag_en = 1'b0;
                read_Alice_hashtag_en = 1'b0;
                write_reconciled_key_en = 1'b0;
                error_verification_fail = 1'b0;
                finish_error_reconciliation = 1'b0;
                er_parameter_valid = 1'b0;
            end 

            ER_START: begin
                next_B_ER_state = CASCADE_START;
                reset_ER_parameter = 1'b0;
                start_cascade_error_correction = 1'b0;
                start_hash = 1'b0;
                send_hashtag_en = 1'b0;
                read_Alice_hashtag_en = 1'b0;
                write_reconciled_key_en = 1'b0;
                error_verification_fail = 1'b0;
                finish_error_reconciliation = 1'b0;
                er_parameter_valid = 1'b0;
            end

            CASCADE_START: begin
                next_B_ER_state = CASCADE_BUSY;
                start_cascade_error_correction = 1'b1;
                reset_ER_parameter = 1'b0;
                start_hash = 1'b0;
                send_hashtag_en = 1'b0;
                read_Alice_hashtag_en = 1'b0;
                write_reconciled_key_en = 1'b0;
                error_verification_fail = 1'b0;
                finish_error_reconciliation = 1'b0;
                er_parameter_valid = 1'b0;
            end

            CASCADE_BUSY: begin
                if (cascade_finish) begin
                    next_B_ER_state = CASCADE_DONE;
                    reset_ER_parameter = 1'b0;
                    start_cascade_error_correction = 1'b0;
                    start_hash = 1'b0;
                    send_hashtag_en = 1'b0;
                    read_Alice_hashtag_en = 1'b0;
                    write_reconciled_key_en = 1'b0;
                    error_verification_fail = 1'b0;
                    finish_error_reconciliation = 1'b0;
                    er_parameter_valid = 1'b0;
                end
                else begin
                    next_B_ER_state = CASCADE_BUSY;
                    reset_ER_parameter = 1'b0;
                    start_cascade_error_correction = 1'b0;
                    start_hash = 1'b0;
                    send_hashtag_en = 1'b0;
                    read_Alice_hashtag_en = 1'b0;
                    write_reconciled_key_en = 1'b0;
                    error_verification_fail = 1'b0;
                    finish_error_reconciliation = 1'b0;
                    er_parameter_valid = 1'b0;
                end
            end

            CASCADE_DONE: begin
                next_B_ER_state = HASHTAG_START;
                reset_ER_parameter = 1'b0;
                start_cascade_error_correction = 1'b0;
                start_hash = 1'b0;
                send_hashtag_en = 1'b0;
                read_Alice_hashtag_en = 1'b0;
                write_reconciled_key_en = 1'b0;
                error_verification_fail = 1'b0;
                finish_error_reconciliation = 1'b0;
                er_parameter_valid = 1'b0;
            end


            HASHTAG_START: begin
                next_B_ER_state = HASHTAG_BUSY;
                start_hash = 1'b1;
                reset_ER_parameter = 1'b0;
                start_cascade_error_correction = 1'b0;
                send_hashtag_en = 1'b0;
                read_Alice_hashtag_en = 1'b0;
                write_reconciled_key_en = 1'b0;
                error_verification_fail = 1'b0;
                finish_error_reconciliation = 1'b0;
                er_parameter_valid = 1'b0;
            end


            HASHTAG_BUSY: begin
                if (hashtag_valid) begin
                    next_B_ER_state = HASHTAG_VALID;
                    reset_ER_parameter = 1'b0;
                    start_cascade_error_correction = 1'b0;
                    start_hash = 1'b0;
                    send_hashtag_en = 1'b0;
                    read_Alice_hashtag_en = 1'b0;
                    write_reconciled_key_en = 1'b0;
                    error_verification_fail = 1'b0;
                    finish_error_reconciliation = 1'b0;
                    er_parameter_valid = 1'b0;
                end
                else begin
                    next_B_ER_state = HASHTAG_BUSY;
                    reset_ER_parameter = 1'b0;
                    start_cascade_error_correction = 1'b0;
                    start_hash = 1'b0;
                    send_hashtag_en = 1'b0;
                    read_Alice_hashtag_en = 1'b0;
                    write_reconciled_key_en = 1'b0;
                    error_verification_fail = 1'b0;
                    finish_error_reconciliation = 1'b0;
                    er_parameter_valid = 1'b0;
                end
            end

            HASHTAG_VALID: begin
                next_B_ER_state = SEND_HASHTAG_PARAMETER;
                reset_ER_parameter = 1'b0;
                start_cascade_error_correction = 1'b0;
                start_hash = 1'b0;
                send_hashtag_en = 1'b0;
                read_Alice_hashtag_en = 1'b0;
                write_reconciled_key_en = 1'b0;
                error_verification_fail = 1'b0;
                finish_error_reconciliation = 1'b0;
                er_parameter_valid = 1'b0;
            end

            SEND_HASHTAG_PARAMETER: begin
                if (hashtag_send_end) begin
                    next_B_ER_state = WAIT_ALICE_HASHTAG;
                    reset_ER_parameter = 1'b0;
                    start_cascade_error_correction = 1'b0;
                    start_hash = 1'b0;
                    send_hashtag_en = 1'b1;
                    read_Alice_hashtag_en = 1'b0;
                    write_reconciled_key_en = 1'b0;
                    error_verification_fail = 1'b0;
                    finish_error_reconciliation = 1'b0;
                    er_parameter_valid = 1'b0;
                end
                else begin
                    next_B_ER_state = SEND_HASHTAG_PARAMETER;
                    reset_ER_parameter = 1'b0;
                    start_cascade_error_correction = 1'b0;
                    start_hash = 1'b0;
                    send_hashtag_en = 1'b1;
                    read_Alice_hashtag_en = 1'b0;
                    write_reconciled_key_en = 1'b0;
                    error_verification_fail = 1'b0;
                    finish_error_reconciliation = 1'b0;
                    er_parameter_valid = 1'b0;
                end
            end

            WAIT_ALICE_HASHTAG: begin
                if (B_A2B_rd_valid) begin
                    next_B_ER_state = READ_ALICE_HASHTAG;
                    reset_ER_parameter = 1'b0;
                    start_cascade_error_correction = 1'b0;
                    start_hash = 1'b0;
                    send_hashtag_en = 1'b0;
                    read_Alice_hashtag_en = 1'b0;
                    write_reconciled_key_en = 1'b0;
                    error_verification_fail = 1'b0;
                    finish_error_reconciliation = 1'b0;
                    er_parameter_valid = 1'b0;
                end
                else begin
                    next_B_ER_state = WAIT_ALICE_HASHTAG;
                    reset_ER_parameter = 1'b0;
                    start_cascade_error_correction = 1'b0;
                    start_hash = 1'b0;
                    send_hashtag_en = 1'b0;
                    read_Alice_hashtag_en = 1'b0;
                    write_reconciled_key_en = 1'b0;
                    error_verification_fail = 1'b0;
                    finish_error_reconciliation = 1'b0;
                    er_parameter_valid = 1'b0;
                end
            end

            READ_ALICE_HASHTAG: begin
                if (read_A_hashtag_end) begin
                    next_B_ER_state = COMPARE_HASHTAG;
                    reset_ER_parameter = 1'b0;
                    start_cascade_error_correction = 1'b0;
                    start_hash = 1'b0;
                    send_hashtag_en = 1'b0;
                    read_Alice_hashtag_en = 1'b1;
                    write_reconciled_key_en = 1'b0;
                    error_verification_fail = 1'b0;
                    finish_error_reconciliation = 1'b0;
                    er_parameter_valid = 1'b0;
                end
                else begin
                    next_B_ER_state = READ_ALICE_HASHTAG;
                    reset_ER_parameter = 1'b0;
                    start_cascade_error_correction = 1'b0;
                    start_hash = 1'b0;
                    send_hashtag_en = 1'b0;
                    read_Alice_hashtag_en = 1'b1;
                    write_reconciled_key_en = 1'b0;
                    error_verification_fail = 1'b0;
                    finish_error_reconciliation = 1'b0;
                    er_parameter_valid = 1'b0;
                end
            end

            COMPARE_HASHTAG: begin
                if (hashtag_compare_result) begin
                    next_B_ER_state = WRITE_RECONCILED_KEY;
                    reset_ER_parameter = 1'b0;
                    start_cascade_error_correction = 1'b0;
                    start_hash = 1'b0;
                    send_hashtag_en = 1'b0;
                    read_Alice_hashtag_en = 1'b0;
                    write_reconciled_key_en = 1'b0;
                    error_verification_fail = 1'b0;
                    finish_error_reconciliation = 1'b0;
                    er_parameter_valid = 1'b0;
                end
                else if (~hashtag_compare_result) begin
                    next_B_ER_state = ER_FAIL;
                    reset_ER_parameter = 1'b0;
                    start_cascade_error_correction = 1'b0;
                    start_hash = 1'b0;
                    send_hashtag_en = 1'b0;
                    read_Alice_hashtag_en = 1'b0;
                    write_reconciled_key_en = 1'b0;
                    error_verification_fail = 1'b0;
                    finish_error_reconciliation = 1'b0;
                    er_parameter_valid = 1'b0;
                end
                else begin
                    next_B_ER_state = COMPARE_HASHTAG;
                    reset_ER_parameter = 1'b0;
                    start_cascade_error_correction = 1'b0;
                    start_hash = 1'b0;
                    send_hashtag_en = 1'b0;
                    read_Alice_hashtag_en = 1'b0;
                    write_reconciled_key_en = 1'b0;
                    error_verification_fail = 1'b0;
                    finish_error_reconciliation = 1'b0;
                    er_parameter_valid = 1'b0;
                end
            end
            WRITE_RECONCILED_KEY: begin
                if (write_reconciled_key_finish) begin
                    next_B_ER_state = WRITE_DONE;
                    reset_ER_parameter = 1'b0;
                    start_cascade_error_correction = 1'b0;
                    start_hash = 1'b0;
                    send_hashtag_en = 1'b0;
                    read_Alice_hashtag_en = 1'b0;
                    write_reconciled_key_en = 1'b1;
                    error_verification_fail = 1'b0;
                    finish_error_reconciliation = 1'b0;
                    er_parameter_valid = 1'b0;
                end
                else begin
                    next_B_ER_state = WRITE_RECONCILED_KEY;
                    reset_ER_parameter = 1'b0;
                    start_cascade_error_correction = 1'b0;
                    start_hash = 1'b0;
                    send_hashtag_en = 1'b0;
                    read_Alice_hashtag_en = 1'b0;
                    write_reconciled_key_en = 1'b1;
                    error_verification_fail = 1'b0;
                    finish_error_reconciliation = 1'b0;
                    er_parameter_valid = 1'b0;
                end
            end

            WRITE_DONE: begin
                next_B_ER_state = ER_DONE;
                reset_ER_parameter = 1'b0;
                start_cascade_error_correction = 1'b0;
                start_hash = 1'b0;
                send_hashtag_en = 1'b0;
                read_Alice_hashtag_en = 1'b0;
                write_reconciled_key_en = 1'b0;
                error_verification_fail = 1'b0;
                finish_error_reconciliation = 1'b0;
                er_parameter_valid = 1'b0;
            end

            ER_DONE: begin
                next_B_ER_state = ER_IDLE;
                reset_ER_parameter = 1'b0;
                start_cascade_error_correction = 1'b0;
                start_hash = 1'b0;
                send_hashtag_en = 1'b0;
                read_Alice_hashtag_en = 1'b0;
                write_reconciled_key_en = 1'b0;
                error_verification_fail = 1'b0;
                finish_error_reconciliation = 1'b1;
                er_parameter_valid = 1'b1;
            end

            ER_FAIL: begin
                next_B_ER_state = ER_IDLE;
                reset_ER_parameter = 1'b0;
                start_cascade_error_correction = 1'b0;
                start_hash = 1'b0;
                send_hashtag_en = 1'b0;
                read_Alice_hashtag_en = 1'b0;
                write_reconciled_key_en = 1'b0;
                error_verification_fail = 1'b1;
                finish_error_reconciliation = 1'b1;
                er_parameter_valid = 1'b1;
            end


            default: begin
                next_B_ER_state = ER_IDLE;
                reset_ER_parameter = 1'b0;
                start_cascade_error_correction = 1'b0;
                start_hash = 1'b0;
                send_hashtag_en = 1'b0;
                read_Alice_hashtag_en = 1'b0;
                write_reconciled_key_en = 1'b0;
                error_verification_fail = 1'b0;
                finish_error_reconciliation = 1'b0;
                er_parameter_valid = 1'b0;
            end 
        endcase
    end

























endmodule