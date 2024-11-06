


`include "./error_reconcilation_parameter.v"


module top_A_ER (
    input clk,                              //clk
    input rst_n,                            //reset

    input start_A_ER,             //start all frame error reconciliation
    input start_TX,
    
    output wait_TX,
    output finish_A_ER,             //finish all frame error reconciliation

    input sifted_key_addr_index,                            //address index
                                                            //0:addr0 ~ addr16383
                                                            //1:addr16384 ~ addr32767


    output wire [`FRAME_LEAKED_INFO_WIDTH-1:0] single_frame_leaked_info,
    output wire [`FRAME_ERROR_COUNT_WIDTH-1:0] single_frame_error_count,
    output wire single_frame_parameter_valid,
    output wire single_frame_error_verification_fail,       //error verification is fail


    // Alice sifted key BRAM (input)
    // width = 64 , depth = 32768
    // port B
    output wire Asiftedkey_clkb,            
    output wire Asiftedkey_enb,             //1'b1
    output wire Asiftedkey_web,             //write enable , 1'b0
    output wire [14:0] Asiftedkey_addrb,    //0~32767
    input wire [63:0] Asiftedkey_doutb,


    // B2A ER FIFO (input)
    // width = 32 , depth = 2048
    output wire A_B2A_rd_clk,
    input wire [31:0] A_B2A_rd_dout,
    output wire A_B2A_rd_en,
    input wire A_B2A_empty,
    input wire A_B2A_rd_valid,

    // A2B ER FIFO (output)
    // width = 32 , depth = 2048
    output wire A_A2B_wr_clk,
    output reg A_A2B_wr_en,
    output reg [31:0] A_A2B_wr_din,
    input wire A_A2B_empty,
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
    output wire [14:0] reconciledkey_addra,          //0~32767
    output wire reconciledkey_clka,      
    output wire [63:0] reconciledkey_dina,
    output wire reconciledkey_ena,                       //1'b1
    output wire reconciledkey_rsta,                      //1'b0
    output wire [3:0] reconciledkey_wea                    
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


//****************************** A er fsm ******************************
    // Input wires
    //wire clk;
    //wire rst_n;
    //wire start_A_ER;
    wire send_EVrandombit_finish;
    wire finish_all_frame_er;

    // Output registers
    wire send_EVrandombit_en;
    wire start_all_frame_er;
    wire reset_er_parameter;
    //wire finish_A_ER;
    wire ER_busy;

    // Output register for FSM state
    wire [3:0] A_er_state;



    A_er_fsm Aer_fsm (
        .clk(clk),                          // Clock signal
        .rst_n(rst_n),                      // Reset signal

        .start_A_ER(start_A_ER),            // Input signal to start A's error reconciliation
        .start_TX(start_TX),                   // control signal for both board ready
        .send_EVrandombit_finish(send_EVrandombit_finish), // Input signal indicating finish of sending EV random bits
        .finish_all_frame_er(finish_all_frame_er),         // Input signal indicating all frames error reconciliation is finished

        .wait_TX(wait_TX),                   // indicate the FSM state
        .send_EVrandombit_en(send_EVrandombit_en),     // Output signal to enable sending EV random bits
        .start_all_frame_er(start_all_frame_er),       // Output signal to start all frame error reconciliation
        .reset_er_parameter(reset_er_parameter),       // Output signal to reset error reconciliation parameters
        .finish_A_ER(finish_A_ER),                     // Output signal indicating A's error reconciliation is finished
        .ER_busy(ER_busy),
        .A_er_state(A_er_state)             // Output register for A's error reconciliation state
    );

//****************************** A er fsm ******************************





//****************************** send EV random bit ******************************
    //wire send_EVrandombit_en;
    //wire send_EVrandombit_finish;

    // Input wires
    // wire clk;
    // wire rst_n;
    // wire send_randombit_en;
    // wire A_A2B_empty; 
    wire round_count_finish;
    wire last_round;

    // Output registers
    wire round_count_en;
    wire reset_randombit_cnt;
    //wire send_EVrandombit_finish;

    // Output wires
    wire reset_round_cnt;
    wire [19:0] randombit_round_addr_offset;
    wire [7:0] randombit_round;
    wire [3:0] randombit_state;

    send_EVrandombit_fsm EVrandombit_fsm (
        .clk(clk),                                 // Clock signal
        .rst_n(rst_n),                             // Reset signal

        .send_randombit_en(send_EVrandombit_en),     // Enable signal for sending random bits
        .A_A2B_empty(A_A2B_empty),                 // Indicates if A to B FIFO is empty
        .round_count_finish(round_count_finish),   // Indicates if round count is finished
        .last_round(last_round),                   // Indicates the last round

        .round_count_en(round_count_en),           // Enable round counting
        .reset_randombit_cnt(reset_randombit_cnt), // Reset the random bit counter
        .send_randombit_finish(send_EVrandombit_finish), // Indicates the completion of sending random bits

        .reset_round_cnt(reset_round_cnt),         // Reset round counter

        .randombit_round_addr_offset(randombit_round_addr_offset), // Random bit round address offset
        .randombit_round(randombit_round),         // Current round of random bit
        .randombit_state(randombit_state)          // Current state of the FSM
    );


    // output wire [13:0]PArandombit_addrb,    //0~16383
    reg [10:0] randombit_addr_cnt;
    always @(posedge clk ) begin
        if (~rst_n) begin
            randombit_addr_cnt <= 11'b0;
        end
        else if (reset_round_cnt) begin
            randombit_addr_cnt <= 11'b0;
        end
        else if (round_count_en&&(randombit_addr_cnt<1023)) begin
            randombit_addr_cnt <= randombit_addr_cnt + 1;
        end
        else begin
            randombit_addr_cnt <= randombit_addr_cnt;
        end
    end

    wire [13:0] send_randombit_addr;    //0~16383
    assign send_randombit_addr = (randombit_addr_cnt[10:1] + randombit_round_addr_offset);

    assign round_count_finish = (randombit_addr_cnt==1023);



    reg [10:0] randombit_addr_cnt_delay_1, randombit_addr_cnt_delay_2;
    always @(posedge clk ) begin
        if (~rst_n) begin
            randombit_addr_cnt_delay_1 <= 1'b0;
            randombit_addr_cnt_delay_2 <= 1'b0;
        end
        else begin
            randombit_addr_cnt_delay_1 <= randombit_addr_cnt;
            randombit_addr_cnt_delay_2 <= randombit_addr_cnt_delay_1;
        end
    end

    reg round_count_en_delay;
    reg randombit_wr_en;
    always @(posedge clk ) begin
        if (~rst_n) begin
            round_count_en_delay <= 1'b0;
            randombit_wr_en <= 1'b0;
        end
        else begin
            round_count_en_delay <= round_count_en;
            randombit_wr_en <= round_count_en_delay;
        end
    end

    wire [31:0] randombit_wr_din;
    assign randombit_wr_din = ((~randombit_addr_cnt_delay_2[0]) && randombit_wr_en)? 
                            EVrandombit_doutb_ff[63:32]:EVrandombit_doutb_ff[31:0];

    wire [31:0] randombit_A2B_header;
    assign randombit_A2B_header = {`A2B_EV_RANDOMBIT ,
                                `PACKET_LENGTH_1028,
                                16'b0,
                                randombit_round};
    wire randombit_A2B_header_write_en;
    assign randombit_A2B_header_write_en = (randombit_addr_cnt==1)? 1'b1:1'b0;

    // last round
    assign last_round = (randombit_round==8'd31)? 1'b1:1'b0;
//****************************** send EV random bit ******************************



//****************************** write A2B FIFO ******************************

    always @(posedge clk ) begin
        if (~rst_n) begin
            A_A2B_wr_din <= 32'b0;
            A_A2B_wr_en <= 1'b0;
        end

        else if (send_EVrandombit_en && randombit_A2B_header_write_en) begin
            A_A2B_wr_din <= randombit_A2B_header;
            A_A2B_wr_en <= 1'b1;
        end
        else if (send_EVrandombit_en) begin
            A_A2B_wr_din <= randombit_wr_din;
            A_A2B_wr_en <= randombit_wr_en;
        end


        else if (ER_busy) begin
            A_A2B_wr_din <= A_ER_wr_din;
            A_A2B_wr_en <= A_ER_wr_en;
        end


        else begin
            A_A2B_wr_din <= 32'b0;
            A_A2B_wr_en <= 1'b0;
        end
    end

//****************************** write A2B FIFO ******************************










//****************************** A all frame ER ******************************



    all_frame_A_ER af_A_ER (
        .clk(clk),                                      // Connect to clock
        .rst_n(rst_n),                                  // Connect to reset

        .start_A_all_frame_ER(start_all_frame_er),    // Start signal for all frame error reconciliation

        .finish_all_frame_ER(finish_all_frame_er),        //finish all frame error reconciliation

        .sifted_key_addr_index(sifted_key_addr_index),      //address index
                                                            //0:addr0 ~ addr16383
                                                            //1:addr16384 ~ addr32767

        .single_frame_leaked_info(single_frame_leaked_info),            // Output for leaked info
        .single_frame_error_count(single_frame_error_count),            // Output for error count
        .single_frame_parameter_valid(single_frame_parameter_valid),    // Output for parameter validity
        .single_frame_error_verification_fail(single_frame_error_verification_fail), // Output for error verification status

        // Alice sifted key BRAM connections
        .Asiftedkey_clkb(Asiftedkey_clkb),            
        .Asiftedkey_enb(Asiftedkey_enb),             
        .Asiftedkey_web(Asiftedkey_web),             
        .Asiftedkey_addrb(Asiftedkey_addrb),    
        .Asiftedkey_doutb(Asiftedkey_doutb),

        // B2A ER FIFO connections
        .A_B2A_rd_clk(A_B2A_rd_clk),
        .A_B2A_rd_dout(A_B2A_rd_dout),
        .A_B2A_rd_en(A_B2A_rd_en),
        .A_B2A_empty(A_B2A_empty),
        .A_B2A_rd_valid(A_B2A_rd_valid),

        // A2B ER FIFO connections
        .A_A2B_wr_clk(A_A2B_wr_clk),
        .A_A2B_wr_en(A_ER_wr_en),
        .A_A2B_wr_din(A_ER_wr_din),
        .A_A2B_full(A_ER_full),
        .A_A2B_wr_ack(A_ER_wr_ack),

        // EV random bit BRAM connections
        .EVrandombit_doutb(rb_douta),
        .EVrandombit_addrb(rb_addra),
        .EVrandombit_clkb(EVrandombit_clkb),
        .EVrandombit_enb(EVrandombit_enb),
        .EVrandombit_rstb(EVrandombit_rstb),
        .EVrandombit_web(EVrandombit_web),

        // Reconciled key BRAM connections
        .reconciledkey_addra(reconciledkey_addra),
        .reconciledkey_clka(reconciledkey_clka),
        .reconciledkey_dina(reconciledkey_dina),
        .reconciledkey_ena(reconciledkey_ena),
        .reconciledkey_rsta(reconciledkey_rsta),
        .reconciledkey_wea(reconciledkey_wea)
    );

//****************************** A all frame ER ******************************







//****************************** A2B fifo port sel ******************************
    wire A_ER_wr_en;
    wire [31:0] A_ER_wr_din;
    wire A_ER_full;
    wire A_ER_wr_ack;

    assign A_ER_full = (ER_busy)? A_A2B_full:1'b0;
    assign A_ER_wr_ack = (ER_busy)? A_A2B_wr_ack:1'b0;


//****************************** A2B fifo port sel ******************************


//****************************** random bit bram port sel ******************************
    wire [63:0] rb_douta;
    wire [13:0] rb_addra;

    assign EVrandombit_addrb = (send_EVrandombit_en)? send_randombit_addr:rb_addra;

    assign rb_douta = (ER_busy)? EVrandombit_doutb:64'b0;


//****************************** random bit bram port sel ******************************
endmodule

















module send_EVrandombit_fsm (
    input clk,
    input rst_n,

    input send_randombit_en,
    input A_A2B_empty,
    input round_count_finish,
    input last_round,


    output reg round_count_en,
    output reg reset_randombit_cnt,
    output reg send_randombit_finish,

    output wire reset_round_cnt,

    output wire [19:0] randombit_round_addr_offset,
    output reg [7:0] randombit_round,
    output reg [3:0] randombit_state
);

    localparam RANDOMBIT_IDLE               = 4'd0;
    localparam RANDOMBIT_START              = 4'd1;
    localparam ROUND_IDLE                   = 4'd2;
    localparam ROUND_COUNT                  = 4'd3;
    localparam ROUND_COUNT_END              = 4'd4;
    localparam RESET_RANDOMBIT_CNT          = 4'd5;
    localparam RANDOMBIT_END                = 4'd6;


    assign reset_round_cnt = ((randombit_state==ROUND_IDLE)&&(next_randombit_state==ROUND_COUNT))?
                                1'b1:1'b0; 


    always @(posedge clk ) begin
        if (~rst_n) begin
            randombit_round <= 8'b0;
        end
        else if (reset_randombit_cnt) begin
            randombit_round <= 8'b0;
        end
        else if (randombit_state==ROUND_COUNT_END) begin
            randombit_round <= randombit_round + 1;
        end
        else begin
            randombit_round <= randombit_round;
        end
    end


    assign randombit_round_addr_offset = (randombit_round<<9);

    reg [3:0] next_randombit_state;
    always @(posedge clk ) begin
        if (~rst_n) begin
            randombit_state <= RANDOMBIT_IDLE;
        end
        else begin
            randombit_state <= next_randombit_state;
        end
    end


    always @(*) begin
        case (randombit_state)
            RANDOMBIT_IDLE: begin
                if (send_randombit_en) begin
                    next_randombit_state = RANDOMBIT_START;
                    round_count_en = 1'b0;
                    reset_randombit_cnt = 1'b0;
                    send_randombit_finish = 1'b0;
                end
                else begin
                    next_randombit_state = RANDOMBIT_IDLE;
                    round_count_en = 1'b0;
                    reset_randombit_cnt = 1'b0;
                    send_randombit_finish = 1'b0;
                end
            end


            RANDOMBIT_START: begin
                next_randombit_state = ROUND_IDLE;
                round_count_en = 1'b0;
                reset_randombit_cnt = 1'b0;
                send_randombit_finish = 1'b0;
            end

            ROUND_IDLE: begin
                if (A_A2B_empty) begin
                    next_randombit_state = ROUND_COUNT;
                    round_count_en = 1'b0;
                    reset_randombit_cnt = 1'b0;
                    send_randombit_finish = 1'b0;
                end
                else begin
                    next_randombit_state = ROUND_IDLE;
                    round_count_en = 1'b0;
                    reset_randombit_cnt = 1'b0;
                    send_randombit_finish = 1'b0;
                end
            end

            ROUND_COUNT: begin
                if (round_count_finish) begin
                    next_randombit_state = ROUND_COUNT_END;
                    round_count_en = 1'b1;
                    reset_randombit_cnt = 1'b0;
                    send_randombit_finish = 1'b0;
                end
                else begin
                    next_randombit_state = ROUND_COUNT;
                    round_count_en = 1'b1;
                    reset_randombit_cnt = 1'b0;
                    send_randombit_finish = 1'b0;
                end
            end


            ROUND_COUNT_END: begin
                if (last_round) begin
                    next_randombit_state = RESET_RANDOMBIT_CNT;
                    round_count_en = 1'b0;
                    reset_randombit_cnt = 1'b0;
                    send_randombit_finish = 1'b0;
                end
                else begin
                    next_randombit_state = ROUND_IDLE;
                    round_count_en = 1'b0;
                    reset_randombit_cnt = 1'b0;
                    send_randombit_finish = 1'b0;
                end
            end


            RESET_RANDOMBIT_CNT: begin
                next_randombit_state = RANDOMBIT_END;
                round_count_en = 1'b0;
                reset_randombit_cnt = 1'b1;
                send_randombit_finish = 1'b0;
            end

            RANDOMBIT_END: begin
                next_randombit_state = RANDOMBIT_IDLE;
                round_count_en = 1'b0;
                reset_randombit_cnt = 1'b0;
                send_randombit_finish = 1'b1;
            end

            default: begin
                next_randombit_state = RANDOMBIT_IDLE;
                round_count_en = 1'b0;
                reset_randombit_cnt = 1'b0;
                send_randombit_finish = 1'b0;
            end
        endcase
    end



endmodule








module A_er_fsm (
    input clk,
    input rst_n,

    input start_A_ER,
    input start_TX,
    input send_EVrandombit_finish,
    input finish_all_frame_er,

    output reg wait_TX,
    output reg send_EVrandombit_en,
    output reg start_all_frame_er,
    output reg reset_er_parameter,
    output reg finish_A_ER,
    output wire ER_busy,
    output reg [3:0] A_er_state
);

    localparam ER_IDLE                    = 4'd0;
    localparam ER_WAIT_START_TX   = 4'd1;
    localparam ER_START                 = 4'd2;
    localparam SEND_EVRANDOMBIT         = 4'd3;
    localparam EVRANDOMBIT_END          = 4'd4;
    localparam START_ALL_FRAME_ER       = 4'd5;
    localparam ALL_FRAME_ER_BUSY        = 4'd6;
    localparam ALL_FRAME_ER_END         = 4'd7;
    localparam RESET_ER_PARAMETER       = 4'd8;
    localparam ER_END                   = 4'd9;


    assign ER_busy = (A_er_state==ALL_FRAME_ER_BUSY);


    reg [3:0] next_A_er_state;
    always @(posedge clk ) begin
        if (~rst_n) begin
            A_er_state <= ER_IDLE;
        end
        else begin
            A_er_state <= next_A_er_state;
        end
    end



    always @(*) begin
        case (A_er_state)
            ER_IDLE: begin
                if (start_A_ER) begin
                    next_A_er_state = ER_WAIT_START_TX;
                    send_EVrandombit_en = 1'b0;
                    start_all_frame_er = 1'b0;
                    reset_er_parameter = 1'b0;
                    finish_A_ER = 1'b0;
                    wait_TX = 1'b0;
                end
                else begin
                    next_A_er_state = ER_IDLE;
                    send_EVrandombit_en = 1'b0;
                    start_all_frame_er = 1'b0;
                    reset_er_parameter = 1'b0;
                    finish_A_ER = 1'b0;
                    wait_TX = 1'b0;
                end
            end

            ER_WAIT_START_TX: begin
                if (start_TX) begin
                    next_A_er_state = ER_START;
                    send_EVrandombit_en = 1'b0;
                    start_all_frame_er = 1'b0;
                    reset_er_parameter = 1'b0;
                    finish_A_ER = 1'b0;
                    wait_TX = 1'b0;
                end
                else begin
                    next_A_er_state = ER_WAIT_START_TX;
                    send_EVrandombit_en = 1'b0;
                    start_all_frame_er = 1'b0;
                    reset_er_parameter = 1'b0;
                    finish_A_ER = 1'b0;
                    wait_TX = 1'b1;
                end
            end

            ER_START: begin
                next_A_er_state = SEND_EVRANDOMBIT;
                send_EVrandombit_en = 1'b0;
                start_all_frame_er = 1'b0;
                reset_er_parameter = 1'b0;
                finish_A_ER = 1'b0;
                wait_TX = 1'b0;
            end

            SEND_EVRANDOMBIT: begin
                if (send_EVrandombit_finish) begin
                    next_A_er_state = EVRANDOMBIT_END;
                    send_EVrandombit_en = 1'b1;
                    start_all_frame_er = 1'b0;
                    reset_er_parameter = 1'b0;
                    finish_A_ER = 1'b0;
                    wait_TX = 1'b0;
                end
                else begin
                    next_A_er_state = SEND_EVRANDOMBIT;
                    send_EVrandombit_en = 1'b1;
                    start_all_frame_er = 1'b0;
                    reset_er_parameter = 1'b0;
                    finish_A_ER = 1'b0;
                    wait_TX = 1'b0;
                end
            end

            EVRANDOMBIT_END: begin
                next_A_er_state = START_ALL_FRAME_ER;
                send_EVrandombit_en = 1'b0;
                start_all_frame_er = 1'b0;
                reset_er_parameter = 1'b0;
                finish_A_ER = 1'b0;
                wait_TX = 1'b0;
            end

            START_ALL_FRAME_ER: begin
                next_A_er_state = ALL_FRAME_ER_BUSY;
                send_EVrandombit_en = 1'b0;
                start_all_frame_er = 1'b1;
                reset_er_parameter = 1'b0;
                finish_A_ER = 1'b0;
                wait_TX = 1'b0;
            end

            ALL_FRAME_ER_BUSY: begin
                if (finish_all_frame_er) begin
                    next_A_er_state = ALL_FRAME_ER_END;
                    send_EVrandombit_en = 1'b0;
                    start_all_frame_er = 1'b0;
                    reset_er_parameter = 1'b0;
                    finish_A_ER = 1'b0;
                    wait_TX = 1'b0;
                end
                else begin
                    next_A_er_state = ALL_FRAME_ER_BUSY;
                    send_EVrandombit_en = 1'b0;
                    start_all_frame_er = 1'b0;
                    reset_er_parameter = 1'b0;
                    finish_A_ER = 1'b0;
                    wait_TX = 1'b0;
                end
            end

            ALL_FRAME_ER_END: begin
                next_A_er_state = RESET_ER_PARAMETER;
                send_EVrandombit_en = 1'b0;
                start_all_frame_er = 1'b0;
                reset_er_parameter = 1'b0;
                finish_A_ER = 1'b0;
                wait_TX = 1'b0;
            end

            RESET_ER_PARAMETER: begin
                next_A_er_state = ER_END;
                send_EVrandombit_en = 1'b0;
                start_all_frame_er = 1'b0;
                reset_er_parameter = 1'b1;
                finish_A_ER = 1'b0;
                wait_TX = 1'b0;
            end

            ER_END: begin
                next_A_er_state = ER_IDLE;
                send_EVrandombit_en = 1'b0;
                start_all_frame_er = 1'b0;
                reset_er_parameter = 1'b0;
                finish_A_ER = 1'b1;
                wait_TX = 1'b0;
            end

            default: begin
                next_A_er_state = ER_IDLE;
                send_EVrandombit_en = 1'b0;
                start_all_frame_er = 1'b0;
                reset_er_parameter = 1'b0;
                finish_A_ER = 1'b0;
                wait_TX = 1'b0;
            end
        endcase
    end



endmodule









