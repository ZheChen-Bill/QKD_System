









module single_frame_A_ER (
    input clk,                              //clk
    input rst_n,                            //reset

    input start_A_single_frame_ER,       //start to error reconciliation

    input [`FRAME_ROUND_WIDTH-1:0] frame_round,

    input sifted_key_addr_index,                            //address index
                                                            //0:addr0 ~ addr16383
                                                            //1:addr16384 ~ addr32767

    // Alice sifted key BRAM (input)
    // width = 64 , depth = 32768
    // port B
    output wire Asiftedkey_clkb,            
    output wire Asiftedkey_enb,             //1'b1
    output wire Asiftedkey_web,             //write enable , 1'b0
    output wire [14:0] Asiftedkey_addrb,    //0~32767
    input wire [63:0] Asiftedkey_doutb,
    //output wire [63:0] Asiftedkey_dinb;   //no use
                    

    // B2A ER FIFO (input)
    // width = 32 , depth = 2048
    output wire A_B2A_rd_clk,
    input [31:0] A_B2A_rd_dout,
    output reg A_B2A_rd_en,
    input wire A_B2A_empty,
    input wire A_B2A_rd_valid,


    // A2B ER FIFO (output)
    // width = 32 , depth = 2048
    output wire A_A2B_wr_clk,
    output reg A_A2B_wr_en,
    output reg [31:0] A_A2B_wr_din,
    input wire A_A2B_full,
    input wire A_A2B_wr_ack,


    //EV random bit BRAM (input)
    // width = 64 , depth = 16384
    // port B
    input wire [63:0] EVrandombit_doutb,            //EV random bit from AXI manager
    output wire [13:0] EVrandombit_addrb,            //0~16383
    output wire EVrandombit_clkb,
    output wire EVrandombit_enb,                    //1'b1
    output wire EVrandombit_rstb,                   //1'b0
    output wire [7:0] EVrandombit_web,              //8 bit write enable , 8'b0


    // reconciled key BRAM (output)
    // width = 64 , depth = 32768
    // port A
    output reg [14:0] reconciledkey_addra,          //0~32767
    output wire reconciledkey_clka,      
    output reg [63:0] reconciledkey_dina,
    output wire reconciledkey_ena,                       //1'b1
    output wire reconciledkey_rsta,                      //1'b0
    output reg [3:0] reconciledkey_wea,                    
    //input [63:0] reconciledkey_dina,

    output wire [`FRAME_LEAKED_INFO_WIDTH-1:0] er_leaked_info,
    output wire [`FRAME_ERROR_COUNT_WIDTH-1:0] er_error_count,
    output wire er_parameter_valid,

    output error_verification_fail,         //error verification is fail
    output finish_error_reconciliation      //error reconsiliation is done
);





//****************************** A ER fsm ******************************

    //fsm input
    wire Acascade_finish;
    wire A_frame_parameter_valid;
    wire hashtag_valid;
    wire read_B_hashtag_end;
    wire hashtag_send_end;
    wire hashtag_compare_result;
    wire write_reconciled_key_finish;


    //fsm output
    wire start_cascade_error_correction;
    wire start_hash;
    wire read_BOB_hashtag_en;
    wire send_hashtag_en;
    wire write_reconciled_key_en;
    wire reset_ER_parameter;
    //wire error_verification_fail;
    //wire finish_error_reconciliation;
    //wire er_parameter_valid;
    wire ec_fifo_enable;
    wire er_fifo_enable;

    wire [4:0] A_ER_state;

    A_error_reconciliation_fsm A_ER_fsm(
        .clk(clk),
        .rst_n(rst_n),

        .start_A_error_reconciliation(start_A_single_frame_ER),
        .cascade_finish(Acascade_finish),
        .frame_parameter_valid(A_frame_parameter_valid),

        .hashtag_valid(hashtag_valid),

        .A_B2A_rd_valid(er_A_B2A_rd_valid),
        .read_B_hashtag_end(read_B_hashtag_end),
        .hashtag_send_end(hashtag_send_end),
        .hashtag_compare_result(hashtag_compare_result),
        .write_reconciled_key_finish(write_reconciled_key_finish),


        .start_cascade_error_correction(start_cascade_error_correction),
        .start_hash(start_hash),
        .read_BOB_hashtag_en(read_BOB_hashtag_en),
        .send_hashtag_en(send_hashtag_en),
        .write_reconciled_key_en(write_reconciled_key_en),
        .reset_ER_parameter(reset_ER_parameter),
        .error_verification_fail(error_verification_fail),
        .finish_error_reconciliation(finish_error_reconciliation),
        .er_parameter_valid(er_parameter_valid),
        .ec_fifo_enable(ec_fifo_enable),
        .er_fifo_enable(er_fifo_enable),

        .A_ER_state(A_ER_state)
    );
//****************************** A ER fsm ******************************





//****************************** fifo for EC or ER ******************************


    // B2A ER FIFO (input)
    // width = 32 , depth = 2048
    wire [31:0] ec_A_B2A_rd_dout;
    wire ec_A_B2A_rd_en;
    wire ec_A_B2A_empty;
    wire ec_A_B2A_rd_valid;


    // A2B ER FIFO (output)
    // width = 32 , depth = 2048
    wire ec_A_A2B_wr_en;
    wire [31:0] ec_A_A2B_wr_din;
    wire ec_A_A2B_full;
    wire ec_A_A2B_wr_ack;

    // B2A ER FIFO (input)
    // width = 32 , depth = 2048
    wire [31:0] er_A_B2A_rd_dout;
    wire er_A_B2A_rd_en;
    wire er_A_B2A_empty;
    wire er_A_B2A_rd_valid;


    // A2B ER FIFO (output)
    // width = 32 , depth = 2048
    wire er_A_A2B_wr_en;
    reg [31:0] er_A_A2B_wr_din;
    wire er_A_A2B_full;
    wire er_A_A2B_wr_ack;


    // output 
    always @(*) begin
        if (ec_fifo_enable) begin
            A_B2A_rd_en = ec_A_B2A_rd_en;
            A_A2B_wr_en = ec_A_A2B_wr_en;
            A_A2B_wr_din = ec_A_A2B_wr_din;
        end
        else if (er_fifo_enable) begin
            A_B2A_rd_en = er_A_B2A_rd_en;
            A_A2B_wr_en = er_A_A2B_wr_en;
            A_A2B_wr_din = er_A_A2B_wr_din;
        end
        else begin
            A_B2A_rd_en = 1'b0;
            A_A2B_wr_en = 1'b0;
            A_A2B_wr_din = 32'b0;
        end
    end

    // input
    assign ec_A_B2A_rd_dout = (ec_fifo_enable)? A_B2A_rd_dout:32'b0;
    assign ec_A_B2A_rd_valid = (ec_fifo_enable)? A_B2A_rd_valid:1'b0;
    assign ec_A_B2A_empty = (ec_fifo_enable)? A_B2A_empty:1'b0;
    assign ec_A_A2B_full = (ec_fifo_enable)? A_A2B_full:1'b0;
    assign ec_A_A2B_wr_ack = (ec_fifo_enable)? A_A2B_wr_ack:1'b0;


    assign er_A_B2A_rd_dout = (er_fifo_enable)? A_B2A_rd_dout:32'b0;
    assign er_A_B2A_rd_valid = (er_fifo_enable)? A_B2A_rd_valid:1'b0;
    assign er_A_B2A_empty = (er_fifo_enable)? A_B2A_empty:1'b0;
    assign er_A_A2B_full = (er_fifo_enable)? A_A2B_full:1'b0;
    assign er_A_A2B_wr_ack = (er_fifo_enable)? A_A2B_wr_ack:1'b0;



//****************************** fifo for EC or ER ******************************

















//****************************** Estimated error count ******************************
    reg [`FRAME_ERROR_COUNT_WIDTH-1:0] est_error_count;

    wire [`FRAME_ERROR_COUNT_WIDTH-1:0] A_frame_error_count;

    always @(posedge clk ) begin
        if (~rst_n) begin
            est_error_count <= `DEFAULT_ERROR_COUNT;
        end
        else if (A_frame_parameter_valid) begin
            est_error_count <= A_frame_error_count;
        end
        else begin
            est_error_count <= est_error_count;
        end
    end

    assign er_error_count = est_error_count;
//****************************** Estimated error count ******************************
//****************************** leaked info count ******************************
    wire [`FRAME_LEAKED_INFO_WIDTH-1:0] A_frame_leaked_info;
    reg [`FRAME_LEAKED_INFO_WIDTH-1:0] A_frame_leaked_info_ff;

    always @(posedge clk ) begin
        if (~rst_n) begin
            A_frame_leaked_info_ff <= 0;
        end
        else if (A_frame_parameter_valid) begin
            A_frame_leaked_info_ff <= A_frame_leaked_info;
        end
        else begin
            A_frame_leaked_info_ff <= A_frame_leaked_info_ff;
        end
    end

    assign er_leaked_info = A_frame_leaked_info_ff;
//****************************** leaked info count ******************************


//****************************** Alice cascade instantiation ******************************




    // cascade output
    //wire Acascade_finish;
    wire [`CASCADE_KEY_LENGTH-1:0] Acorrected_key;



    Alice_cascade Acascade(
        .clk(clk),                              // Clock input
        .rst_n(rst_n),                          // Reset input

        //error count estimation based on previous reconciliation 
        //or default error count = 250
        .est_error_count(est_error_count), 

        .start_cascade_error_correction(start_cascade_error_correction),   //start to error correction

        .frame_round(frame_round),

        .sifted_key_addr_index(sifted_key_addr_index),

        // Alice sifted key BRAM (input)
        // width = 64 , depth = 32768
        // port B
        .Asiftedkey_clkb(Asiftedkey_clkb),                     
        .Asiftedkey_enb(Asiftedkey_enb),                      // Enable signal for Asiftedkey ,1'b1
        .Asiftedkey_web(Asiftedkey_web),                      // Write enable for Asiftedkey ,1'b0
        .Asiftedkey_addrb(Asiftedkey_addrb),                    // Address for Asiftedkey ,0~16383
        .Asiftedkey_doutb(Asiftedkey_doutb),                    // Data output for Asiftedkey
        //output wire [63:0] Asiftedkey_dinb;   //no use

        // B2A ER FIFO (input)
        // width = 32 , depth = 2048
        .A_B2A_rd_clk(A_B2A_rd_clk),
        .A_B2A_rd_dout(ec_A_B2A_rd_dout),
        .A_B2A_rd_en(ec_A_B2A_rd_en),
        .A_B2A_empty(ec_A_B2A_empty),
        .A_B2A_rd_valid(ec_A_B2A_rd_valid),



        // A2B ER FIFO (output)
        // width = 32 , depth = 2048
        .A_A2B_wr_clk(A_A2B_wr_clk),
        .A_A2B_wr_en(ec_A_A2B_wr_en),
        .A_A2B_wr_din(ec_A_A2B_wr_din),
        .A_A2B_full(ec_A_A2B_full),
        .A_A2B_wr_ack(ec_A_A2B_wr_ack),



        .frame_leaked_info(A_frame_leaked_info),                   // Leaked information output
        .frame_error_count(A_frame_error_count),                   // Error count output
        .frame_parameter_valid(A_frame_parameter_valid),               // Parameter validity output


        .cascade_finish(Acascade_finish),                      // Cascade finish output
        .corrected_key(Acorrected_key)                        // Corrected key output
    );
//****************************** Alice cascade instantiation ******************************
//****************************** EV instantiation ******************************
    wire [`EV_KEY_LENGTH-1:0] A_EV_corrected_key;
    assign A_EV_corrected_key = Acorrected_key;





    wire [`EV_HASHTAG_WIDTH-1:0] target_hashtag;
    //wire hashtag_valid;




    top_ev A_ev(
        .clk(clk),                                      //clk
        .rst_n(rst_n),                                    //reset


        
        .corrected_key(A_EV_corrected_key),       //corrected key (no shuffle)
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
    reg [63:0] Alice_hashtag_ff;

    always @(posedge clk ) begin
        if (~rst_n) begin
            Alice_hashtag_ff <= `EV_HASHTAG_WIDTH'b0;
        end
        else if (reset_ER_parameter) begin
            Alice_hashtag_ff <= `EV_HASHTAG_WIDTH'b0;
        end
        else if (hashtag_valid) begin
            Alice_hashtag_ff <= target_hashtag;
        end
        else begin
            Alice_hashtag_ff <= Alice_hashtag_ff;
        end
    end
//****************************** hashtag DFF ******************************


//****************************** read Bob hashtag ******************************
    //read_BOB_hashtag_en
    //read_B_hashtag_end

    reg [3:0] read_hashtag_cnt;
    always @(posedge clk ) begin
        if (~rst_n) begin
            read_hashtag_cnt <= 4'b0;
        end
        else if (reset_ER_parameter) begin
            read_hashtag_cnt <= 4'b0;
        end
        else if (read_BOB_hashtag_en) begin
            read_hashtag_cnt <= read_hashtag_cnt + 1;
        end
        else begin
            read_hashtag_cnt <= read_hashtag_cnt;
        end
    end

    assign er_A_B2A_rd_en = (read_hashtag_cnt>0 && read_hashtag_cnt<3)? 1'b1:1'b0;
    assign read_B_hashtag_end = (read_hashtag_cnt==5);

    reg [`EV_REAL_HASHTAG_WIDTH:0] Bob_hashtag_ff;
    always @(posedge clk ) begin
        if (~rst_n) begin
            Bob_hashtag_ff <= `EV_REAL_HASHTAG_WIDTH'b0;
        end
        else if (reset_ER_parameter) begin
            Bob_hashtag_ff <= `EV_REAL_HASHTAG_WIDTH'b0;
        end
        else if (read_hashtag_cnt==2) begin
            Bob_hashtag_ff <= er_A_B2A_rd_dout;
        end
        else begin
            Bob_hashtag_ff <= Bob_hashtag_ff;
        end
    end
    
    assign hashtag_compare_result = (Alice_hashtag_ff[63:32] == Bob_hashtag_ff);
//****************************** read Bob hashtag ******************************




//****************************** send Alice hashtag ******************************
    //send_hashtag_en
    //hashtag_send_end
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

    assign er_A_A2B_wr_en = ((send_hashtag_cnt>0)&&(send_hashtag_cnt<4))? 1'b1:1'b0;


    wire [`RECONCILIATION_REAL_PACKET_DEPTH_WIDTH-1:0] hashtag_packet_real_depth;
    assign hashtag_packet_real_depth = `RECONCILIATION_REAL_PACKET_DEPTH_WIDTH'd2;


    always @(*) begin
        case (send_hashtag_cnt)
            4'b0000: er_A_A2B_wr_din = 32'b0;
            4'b0001: er_A_A2B_wr_din = {`A2B_TARGET_HASHTAG, `PACKET_LENGTH_257, hashtag_packet_real_depth, {15{1'b0}}};
            4'b0010: er_A_A2B_wr_din = Alice_hashtag_ff[63:32];
            4'b0011: er_A_A2B_wr_din = {{20{1'b0}} ,est_error_count};
            default: er_A_A2B_wr_din = 32'b0;
        endcase
    end

    assign hashtag_send_end = (send_hashtag_cnt==5);

//****************************** send Alice hashtag ******************************




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
            reconciledkey_wea <= 4'b0000;
        end
        else if ((write_reconciled_key_cnt>0)&&(write_reconciled_key_cnt<(`RECONCILED_KEY_64_DEPTH+1))) begin
            reconciledkey_addra <= reconciledkey_addra + 1;
            reconciledkey_dina <= Acorrected_key[(((`RECONCILED_KEY_64_DEPTH)-write_reconciled_key_cnt)<<6) +: 64];
            reconciledkey_wea <= 4'b1111;
        end
        else begin
            reconciledkey_addra <= reconciledkey_addra;
            reconciledkey_dina <= 64'b0;
            reconciledkey_wea <= 4'b0000;
        end
    end


    assign reconciledkey_clka = clk;
    assign reconciledkey_ena = 1'b1;
    assign reconciledkey_rsta = rst_n;



//****************************** write reconciliation key ******************************





endmodule


























module A_error_reconciliation_fsm (
    input clk,
    input rst_n,

    input start_A_error_reconciliation,
    input frame_parameter_valid,
    input cascade_finish,

    input hashtag_valid,

    input A_B2A_rd_valid,
    input read_B_hashtag_end,
    input hashtag_send_end,
    input hashtag_compare_result,
    input write_reconciled_key_finish,


    output reg start_cascade_error_correction,
    output reg start_hash,
    output reg read_BOB_hashtag_en,
    output reg send_hashtag_en,
    output reg write_reconciled_key_en,
    output reg reset_ER_parameter,
    output reg error_verification_fail,
    output reg finish_error_reconciliation,
    output reg er_parameter_valid,
    output wire ec_fifo_enable,
    output wire er_fifo_enable,

    output reg [4:0] A_ER_state
);



    localparam ER_IDLE                  = 5'd0;
    localparam ER_RESET                 = 5'd1;
    localparam ER_START                 = 5'd2;

    localparam CASCADE_START            = 5'd3;
    localparam CASCADE_BUSY             = 5'd4;
    localparam FRAME_PARAMETER_VALID    = 5'd5;
    localparam CASCADE_DONE             = 5'd6;

    localparam HASHTAG_START            = 5'd7;
    localparam HASHTAG_BUSY             = 5'd8;
    localparam HASHTAG_VALID            = 5'd9;

    localparam WAIT_BOB_HASHTAG         = 5'd10;
    localparam READ_BOB_HASHTAG         = 5'd11;
    localparam SEND_HASHTAG_PARAMETER   = 5'd12;
    localparam COMPARE_HASHTAG          = 5'd13;

    localparam WRITE_RECONCILED_KEY     = 5'd14;
    localparam WRITE_DONE               = 5'd15;

    localparam ER_DONE                  = 5'd16;
    localparam ER_FAIL                  = 5'd17;



    assign ec_fifo_enable = ((A_ER_state==CASCADE_START)|(A_ER_state==CASCADE_BUSY)|(A_ER_state==FRAME_PARAMETER_VALID)|(A_ER_state==CASCADE_DONE));
    assign er_fifo_enable = ((A_ER_state==WAIT_BOB_HASHTAG)|(A_ER_state==READ_BOB_HASHTAG)|(A_ER_state==SEND_HASHTAG_PARAMETER));
    


    reg [4:0] next_A_ER_state;

    always @(posedge clk ) begin
        if (~rst_n) begin
            A_ER_state <= ER_IDLE;
        end
        else begin
            A_ER_state <= next_A_ER_state;
        end
    end


    always @(*) begin
        case (A_ER_state)
            ER_IDLE: begin
                if (start_A_error_reconciliation) begin
                    next_A_ER_state = ER_RESET;
                    reset_ER_parameter = 1'b0;
                    start_cascade_error_correction = 1'b0;
                    start_hash = 1'b0;
                    read_BOB_hashtag_en = 1'b0;
                    send_hashtag_en = 1'b0;
                    finish_error_reconciliation = 1'b0;
                    write_reconciled_key_en = 1'b0;
                    error_verification_fail = 1'b0;
                    er_parameter_valid = 1'b0;
                end
                else begin
                    next_A_ER_state = ER_IDLE;
                    reset_ER_parameter = 1'b0;
                    start_cascade_error_correction = 1'b0;
                    start_hash = 1'b0;
                    read_BOB_hashtag_en = 1'b0;
                    send_hashtag_en = 1'b0;
                    finish_error_reconciliation = 1'b0;
                    write_reconciled_key_en = 1'b0;
                    error_verification_fail = 1'b0;
                    er_parameter_valid = 1'b0;
                end
            end

            ER_RESET: begin
                next_A_ER_state = ER_START;
                reset_ER_parameter = 1'b1;
                start_cascade_error_correction = 1'b0;
                start_hash = 1'b0;
                read_BOB_hashtag_en = 1'b0;
                send_hashtag_en = 1'b0;
                finish_error_reconciliation = 1'b0;
                write_reconciled_key_en = 1'b0;
                error_verification_fail = 1'b0;
                er_parameter_valid = 1'b0;
            end

            ER_START: begin
                next_A_ER_state = CASCADE_START;
                reset_ER_parameter = 1'b0;
                start_cascade_error_correction = 1'b0;
                start_hash = 1'b0;
                read_BOB_hashtag_en = 1'b0;
                send_hashtag_en = 1'b0;
                finish_error_reconciliation = 1'b0;
                write_reconciled_key_en = 1'b0;
                error_verification_fail = 1'b0;
                er_parameter_valid = 1'b0;
            end


            CASCADE_START: begin
                next_A_ER_state = CASCADE_BUSY;
                start_cascade_error_correction = 1'b1;
                reset_ER_parameter = 1'b0;
                start_hash = 1'b0;
                read_BOB_hashtag_en = 1'b0;
                send_hashtag_en = 1'b0;
                finish_error_reconciliation = 1'b0;
                write_reconciled_key_en = 1'b0;
                error_verification_fail = 1'b0;
                er_parameter_valid = 1'b0;
            end

            CASCADE_BUSY: begin
                if (frame_parameter_valid) begin
                    next_A_ER_state = FRAME_PARAMETER_VALID;
                    reset_ER_parameter = 1'b0;
                    start_cascade_error_correction = 1'b0;
                    start_hash = 1'b0;
                    read_BOB_hashtag_en = 1'b0;
                    send_hashtag_en = 1'b0;
                    finish_error_reconciliation = 1'b0;
                    write_reconciled_key_en = 1'b0;
                    error_verification_fail = 1'b0;
                    er_parameter_valid = 1'b0;
                end
                else begin
                    next_A_ER_state = CASCADE_BUSY;
                    reset_ER_parameter = 1'b0;
                    start_cascade_error_correction = 1'b0;
                    start_hash = 1'b0;
                    read_BOB_hashtag_en = 1'b0;
                    send_hashtag_en = 1'b0;
                    finish_error_reconciliation = 1'b0;
                    write_reconciled_key_en = 1'b0;
                    error_verification_fail = 1'b0;
                    er_parameter_valid = 1'b0;
                end
            end

            FRAME_PARAMETER_VALID: begin
                if (cascade_finish) begin
                    next_A_ER_state = CASCADE_DONE;
                    reset_ER_parameter = 1'b0;
                    start_cascade_error_correction = 1'b0;
                    start_hash = 1'b0;
                    read_BOB_hashtag_en = 1'b0;
                    send_hashtag_en = 1'b0;
                    finish_error_reconciliation = 1'b0;
                    write_reconciled_key_en = 1'b0;
                    error_verification_fail = 1'b0;
                    er_parameter_valid = 1'b0;
                end
                else begin
                    next_A_ER_state = FRAME_PARAMETER_VALID;
                    reset_ER_parameter = 1'b0;
                    start_cascade_error_correction = 1'b0;
                    start_hash = 1'b0;
                    read_BOB_hashtag_en = 1'b0;
                    send_hashtag_en = 1'b0;
                    finish_error_reconciliation = 1'b0;
                    write_reconciled_key_en = 1'b0;
                    error_verification_fail = 1'b0;
                    er_parameter_valid = 1'b0;
                end
            end

            CASCADE_DONE: begin
                next_A_ER_state = HASHTAG_START;
                reset_ER_parameter = 1'b0;
                start_cascade_error_correction = 1'b0;
                start_hash = 1'b0;
                read_BOB_hashtag_en = 1'b0;
                send_hashtag_en = 1'b0;
                finish_error_reconciliation = 1'b0;
                write_reconciled_key_en = 1'b0;
                error_verification_fail = 1'b0;
                er_parameter_valid = 1'b0;
            end

            HASHTAG_START: begin
                next_A_ER_state = HASHTAG_BUSY;
                start_hash = 1'b1;
                reset_ER_parameter = 1'b0;
                start_cascade_error_correction = 1'b0;
                read_BOB_hashtag_en = 1'b0;
                send_hashtag_en = 1'b0;
                finish_error_reconciliation = 1'b0;
                write_reconciled_key_en = 1'b0;
                error_verification_fail = 1'b0;
                er_parameter_valid = 1'b0;
            end


            HASHTAG_BUSY: begin
                if (hashtag_valid) begin
                    next_A_ER_state = HASHTAG_VALID;
                    reset_ER_parameter = 1'b0;
                    start_cascade_error_correction = 1'b0;
                    start_hash = 1'b0;
                    read_BOB_hashtag_en = 1'b0;
                    send_hashtag_en = 1'b0;
                    finish_error_reconciliation = 1'b0;
                    write_reconciled_key_en = 1'b0;
                    error_verification_fail = 1'b0;
                    er_parameter_valid = 1'b0;
                end
                else begin
                    next_A_ER_state = HASHTAG_BUSY;
                    reset_ER_parameter = 1'b0;
                    start_cascade_error_correction = 1'b0;
                    start_hash = 1'b0;
                    read_BOB_hashtag_en = 1'b0;
                    send_hashtag_en = 1'b0;
                    finish_error_reconciliation = 1'b0;
                    write_reconciled_key_en = 1'b0;
                    error_verification_fail = 1'b0;
                    er_parameter_valid = 1'b0;
                end
            end

            HASHTAG_VALID: begin
                next_A_ER_state = WAIT_BOB_HASHTAG;
                reset_ER_parameter = 1'b0;
                start_cascade_error_correction = 1'b0;
                start_hash = 1'b0;
                read_BOB_hashtag_en = 1'b0;
                send_hashtag_en = 1'b0;
                finish_error_reconciliation = 1'b0;
                write_reconciled_key_en = 1'b0;
                error_verification_fail = 1'b0;
                er_parameter_valid = 1'b0;
            end

            WAIT_BOB_HASHTAG: begin
                if (A_B2A_rd_valid) begin
                    next_A_ER_state = READ_BOB_HASHTAG;
                    reset_ER_parameter = 1'b0;
                    start_cascade_error_correction = 1'b0;
                    start_hash = 1'b0;
                    read_BOB_hashtag_en = 1'b0;
                    send_hashtag_en = 1'b0;
                    finish_error_reconciliation = 1'b0;
                    write_reconciled_key_en = 1'b0;
                    error_verification_fail = 1'b0;
                    er_parameter_valid = 1'b0;
                end
                else begin
                    next_A_ER_state = WAIT_BOB_HASHTAG;
                    reset_ER_parameter = 1'b0;
                    start_cascade_error_correction = 1'b0;
                    start_hash = 1'b0;
                    read_BOB_hashtag_en = 1'b0;
                    send_hashtag_en = 1'b0;
                    finish_error_reconciliation = 1'b0;
                    write_reconciled_key_en = 1'b0;
                    error_verification_fail = 1'b0;
                    er_parameter_valid = 1'b0;
                end
            end

            READ_BOB_HASHTAG: begin
                if (read_B_hashtag_end) begin
                    next_A_ER_state = SEND_HASHTAG_PARAMETER;
                    reset_ER_parameter = 1'b0;
                    start_cascade_error_correction = 1'b0;
                    start_hash = 1'b0;
                    send_hashtag_en = 1'b0;
                    finish_error_reconciliation = 1'b0;
                    write_reconciled_key_en = 1'b0;
                    error_verification_fail = 1'b0;
                    read_BOB_hashtag_en = 1'b1;
                    er_parameter_valid = 1'b0;
                end
                else begin
                    next_A_ER_state = READ_BOB_HASHTAG;
                    read_BOB_hashtag_en = 1'b1;
                    reset_ER_parameter = 1'b0;
                    start_cascade_error_correction = 1'b0;
                    start_hash = 1'b0;
                    send_hashtag_en = 1'b0;
                    finish_error_reconciliation = 1'b0;
                    write_reconciled_key_en = 1'b0;
                    error_verification_fail = 1'b0;
                    er_parameter_valid = 1'b0;
                end
            end

            SEND_HASHTAG_PARAMETER: begin
                if (hashtag_send_end) begin
                    next_A_ER_state = COMPARE_HASHTAG;
                    reset_ER_parameter = 1'b0;
                    start_cascade_error_correction = 1'b0;
                    start_hash = 1'b0;
                    read_BOB_hashtag_en = 1'b0;
                    send_hashtag_en = 1'b1;
                    finish_error_reconciliation = 1'b0;
                    write_reconciled_key_en = 1'b0;
                    error_verification_fail = 1'b0;
                    er_parameter_valid = 1'b0;
                end
                else begin
                    next_A_ER_state = SEND_HASHTAG_PARAMETER;
                    send_hashtag_en = 1'b1;
                    reset_ER_parameter = 1'b0;
                    start_cascade_error_correction = 1'b0;
                    start_hash = 1'b0;
                    read_BOB_hashtag_en = 1'b0;
                    finish_error_reconciliation = 1'b0;
                    write_reconciled_key_en = 1'b0;
                    error_verification_fail = 1'b0;
                    er_parameter_valid = 1'b0;
                end
            end

            COMPARE_HASHTAG: begin
                if (hashtag_compare_result) begin
                    next_A_ER_state = WRITE_RECONCILED_KEY;
                    reset_ER_parameter = 1'b0;
                    start_cascade_error_correction = 1'b0;
                    start_hash = 1'b0;
                    read_BOB_hashtag_en = 1'b0;
                    send_hashtag_en = 1'b0;
                    finish_error_reconciliation = 1'b0;
                    write_reconciled_key_en = 1'b0;
                    error_verification_fail = 1'b0;
                    er_parameter_valid = 1'b0;
                end
                else if (~hashtag_compare_result) begin
                    next_A_ER_state = ER_FAIL;
                    reset_ER_parameter = 1'b0;
                    start_cascade_error_correction = 1'b0;
                    start_hash = 1'b0;
                    read_BOB_hashtag_en = 1'b0;
                    send_hashtag_en = 1'b0;
                    finish_error_reconciliation = 1'b0;
                    write_reconciled_key_en = 1'b0;
                    error_verification_fail = 1'b0;
                    er_parameter_valid = 1'b0;
                end
                else begin
                    next_A_ER_state = COMPARE_HASHTAG;
                    reset_ER_parameter = 1'b0;
                    start_cascade_error_correction = 1'b0;
                    start_hash = 1'b0;
                    read_BOB_hashtag_en = 1'b0;
                    send_hashtag_en = 1'b0;
                    finish_error_reconciliation = 1'b0;
                    write_reconciled_key_en = 1'b0;
                    error_verification_fail = 1'b0;
                    er_parameter_valid = 1'b0;
                end
            end

            WRITE_RECONCILED_KEY: begin
                if (write_reconciled_key_finish) begin
                    next_A_ER_state = WRITE_DONE;
                    reset_ER_parameter = 1'b0;
                    start_cascade_error_correction = 1'b0;
                    start_hash = 1'b0;
                    read_BOB_hashtag_en = 1'b0;
                    send_hashtag_en = 1'b0;
                    finish_error_reconciliation = 1'b0;
                    write_reconciled_key_en = 1'b1;
                    error_verification_fail = 1'b0;
                    er_parameter_valid = 1'b0;
                end
                else begin
                    next_A_ER_state = WRITE_RECONCILED_KEY;
                    write_reconciled_key_en = 1'b1;
                    reset_ER_parameter = 1'b0;
                    start_cascade_error_correction = 1'b0;
                    start_hash = 1'b0;
                    read_BOB_hashtag_en = 1'b0;
                    send_hashtag_en = 1'b0;
                    finish_error_reconciliation = 1'b0;
                    error_verification_fail = 1'b0;
                    er_parameter_valid = 1'b0;
                end
            end

            WRITE_DONE: begin
                next_A_ER_state = ER_DONE;
                reset_ER_parameter = 1'b0;
                start_cascade_error_correction = 1'b0;
                start_hash = 1'b0;
                read_BOB_hashtag_en = 1'b0;
                send_hashtag_en = 1'b0;
                finish_error_reconciliation = 1'b0;
                write_reconciled_key_en = 1'b0;
                error_verification_fail = 1'b0;
                er_parameter_valid = 1'b0;
            end


            ER_DONE: begin
                next_A_ER_state = ER_IDLE;
                finish_error_reconciliation = 1'b1;
                er_parameter_valid = 1'b1;
                error_verification_fail = 1'b0;
                reset_ER_parameter = 1'b0;
                start_cascade_error_correction = 1'b0;
                start_hash = 1'b0;
                read_BOB_hashtag_en = 1'b0;
                send_hashtag_en = 1'b0;
                write_reconciled_key_en = 1'b0;
            end

            ER_FAIL: begin
                next_A_ER_state = ER_IDLE;
                finish_error_reconciliation = 1'b1;
                error_verification_fail = 1'b1;
                er_parameter_valid = 1'b1;
                reset_ER_parameter = 1'b0;
                start_cascade_error_correction = 1'b0;
                start_hash = 1'b0;
                read_BOB_hashtag_en = 1'b0;
                send_hashtag_en = 1'b0;
                write_reconciled_key_en = 1'b0;
            end

            default: begin
                next_A_ER_state = ER_IDLE;
                reset_ER_parameter = 1'b0;
                start_cascade_error_correction = 1'b0;
                start_hash = 1'b0;
                read_BOB_hashtag_en = 1'b0;
                send_hashtag_en = 1'b0;
                finish_error_reconciliation = 1'b0;
                write_reconciled_key_en = 1'b0;
                error_verification_fail = 1'b0;
                er_parameter_valid = 1'b0;
            end
        endcase
    end






















endmodule
