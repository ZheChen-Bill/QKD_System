
 `include "../packet_parameter.v"
 `include "../error_reconcilation_parameter.v"



module Bob_cascade (
    input clk,                              //clk
    input rst_n,                            //reset

    //error count estimation based on previous reconciliation 
    //or default error count = 130
    input [`FRAME_ERROR_COUNT_WIDTH-1:0] est_error_count, 

    input start_cascade_error_correction,   //start to error correction
    
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
    output reg [14:0] Bsiftedkey_addrb,    //0~32767
    input wire [63:0] Bsiftedkey_doutb,
    //output wire [63:0] Bsiftedkey_dinb;   //no use

    // A2B ER FIFO (input)
    // width = 32 , depth = 2048
    output wire B_A2B_rd_clk,
    output wire B_A2B_rd_en,
    input wire [31:0] B_A2B_rd_dout,
    input wire B_A2B_empty,
    input wire B_A2B_rd_valid,
    


    // B2A ER FIFO (output)
    // width = 32 , depth = 2048
    output wire B_B2A_wr_clk,
    output reg [31:0] B_B2A_wr_din,
    output reg B_B2A_wr_en,
    input wire B_B2A_full,
    input wire B_B2A_wr_ack,




    //output reg [`FRAME_LEAKED_INFO_WIDTH-1:0] frame_leaked_info,
    //output reg [`FRAME_ERROR_COUNT_WIDTH-1:0] frame_error_count,
    //output wire frame_parameter_valid,


    output cascade_finish,
    output wire [`CASCADE_KEY_LENGTH-1:0] corrected_key
);




    integer i;
//****************************** error count ******************************
    // error count
    parameter error_count_1 = 25;     
    parameter error_count_2 = 49;
    parameter error_count_3 = 98;
    parameter error_count_4 = 204;
    parameter error_count_5 = 491;
    parameter error_count_6 = 550;
//****************************** error count ******************************
//****************************** BRAM setup ******************************
    // Bob sifted key BRAM (input)
    // width = 64 , depth = 32768
    // port B
    assign Bsiftedkey_clkb = clk;
    assign Bsiftedkey_enb = 1'b1;
    assign Bsiftedkey_web = 1'b0;
//****************************** BRAM setup ******************************
//****************************** FIFO setup ******************************
    // A2B ER FIFO (input)
    // width = 32 , depth = 2048
    //output wire A2B_rd_clk,
    assign B_A2B_rd_clk = clk;

    // B2A ER FIFO (output)
    // width = 32 , depth = 2048
    //output wire B2A_wr_clk,
    assign B_B2A_wr_clk = clk;
//****************************** FIFO setup ******************************
//****************************** DFF for bram output ******************************
    reg [`EV_W-1:0] Bsiftedkey_doutb_ff;
    always @(posedge clk ) begin
        if (~rst_n) begin
            Bsiftedkey_doutb_ff <= `EV_W'b0;
        end
        else begin
            Bsiftedkey_doutb_ff <= Bsiftedkey_doutb;
        end
    end
//****************************** DFF for bram output ******************************


//****************************** B cascade fsm ******************************
    //wire loadkey_finish;
    wire top_level_parity_correct;
    wire Bkey_correction_done;


    wire load_en;
    wire reset_parameter;
    //wire cascade_finish;
    //wire frame_parameter_valid;

    wire [2:0] cascade_level_index;
    wire top_1;
    wire top_2;
    wire top_3;
    wire top_4;
    wire first_top_parity;
    wire [4:0] cascadeB_state;

    cascadeB_fsm cascadeFSM(
        .clk(clk),
        .rst_n(rst_n),

        .start_cascade(start_cascade_error_correction),
        .loadkey_finish(loadkey_finish),
        .top_level_parity_correct(top_level_parity_correct),
        .Bkey_correction_done(Bkey_correction_done),

        
        .load_en(load_en),
        .cascade_finish(cascade_finish),
        .reset_parameter(reset_parameter),
        //.frame_parameter_valid(frame_parameter_valid),

        .cascade_level_index(cascade_level_index),   //1 2 3 4
        .top_1(top_1),
        .top_2(top_2),
        .top_3(top_3),
        .top_4(top_4),
        .first_top_parity(first_top_parity),
        .cascadeB_state(cascadeB_state)
    );
//****************************** B cascade fsm ******************************




//****************************** B read header fsm ******************************
    // fsm input
    wire [`PARITY_TYPE_WIDTH-1:0] B_A2B_parity_type;
    wire [`PARITY_TREE_ROW_INDEX_WIDTH-1:0] B_A2B_parity_tree_row;
    wire ask_parity_done;
    wire buttom_level_correction_finish;

    // fsm output
    wire read_header_en;
    //wire inv_shuffle_en;
    //wire top_level_parity_correct;
    //wire Bkey_correction_done;
    wire ask_parity_en;
    wire buttom_level_correction_en;
    wire [4:0] B_readheader_state;
    wire reset_read_cnt;
    wire write_normal_header;

    B_readheader_fsm readheader_FSM(
        .clk(clk),
        .rst_n(rst_n),

        .B_A2B_rd_valid(B_A2B_rd_valid),
        .B_A2B_parity_type(B_A2B_parity_type),
        .parity_tree_row(B_A2B_parity_tree_row),
        .buttom_level_correction_finish(buttom_level_correction_finish),
        .ask_parity_done(ask_parity_done),

        .inv_shuffle_en(inv_shuffle_en),
        .top_level_parity_correct(top_level_parity_correct),
        .Bkey_correction_done(Bkey_correction_done),
        .ask_parity_en(ask_parity_en),
        .read_header_en(read_header_en),
        .reset_read_cnt(reset_read_cnt),
        .write_normal_header(write_normal_header),
        .buttom_level_correction_en(buttom_level_correction_en),
        .B_readheader_state(B_readheader_state)
    );
//****************************** B read header fsm ******************************






//****************************** cascade parameter ******************************
    //init parity tree row index
    reg [`PARITY_TREE_ROW_INDEX_WIDTH-1:0] init_parity_tree_row_index;   //init row = 4~9

    always @(posedge clk ) begin
        if (~rst_n) begin
            init_parity_tree_row_index <= `PARITY_TREE_ROW_INDEX_WIDTH'b0;
        end
        else if (start_cascade_error_correction) begin
            if (est_error_count<=error_count_1) begin
                init_parity_tree_row_index <= `PARITY_TREE_ROW_8;
            end
            else if ((est_error_count<=error_count_2) && (est_error_count>error_count_1)) begin
                init_parity_tree_row_index <= `PARITY_TREE_ROW_8;
            end
            else if ((est_error_count<=error_count_3) && (est_error_count>error_count_2)) begin
                init_parity_tree_row_index <= `PARITY_TREE_ROW_7;
            end
            else if ((est_error_count<=error_count_4) && (est_error_count>error_count_3)) begin
                init_parity_tree_row_index <= `PARITY_TREE_ROW_6;
            end
            else if ((est_error_count<=error_count_5) && (est_error_count>error_count_4)) begin
                init_parity_tree_row_index <= `PARITY_TREE_ROW_5;
            end
            else if ((est_error_count<=error_count_6) && (est_error_count>error_count_5)) begin
                init_parity_tree_row_index <= `PARITY_TREE_ROW_4;
            end
            else begin
                init_parity_tree_row_index <= `PARITY_TREE_ROW_4;
            end

        end
        else if (reset_parameter) begin
            init_parity_tree_row_index <= `PARITY_TREE_ROW_INDEX_WIDTH'b0;
        end
        else begin
            init_parity_tree_row_index <= init_parity_tree_row_index;
        end
    end

//****************************** cascade parameter ******************************






//****************************** parity tree ******************************
    wire [`CASCADE_KEY_LENGTH-1:0] parity_tree [0:10];

    wire [(`CASCADE_KEY_LENGTH>>0)-1:0]       parity_1;       //16384
    wire [(`CASCADE_KEY_LENGTH>>1)-1:0]       parity_2;       //8192
    wire [(`CASCADE_KEY_LENGTH>>2)-1:0]       parity_4;       //4096
    wire [(`CASCADE_KEY_LENGTH>>3)-1:0]       parity_8;       //2048
    wire [(`CASCADE_KEY_LENGTH>>4)-1:0]       parity_16;      //1024
    wire [(`CASCADE_KEY_LENGTH>>5)-1:0]       parity_32;      //512
    wire [(`CASCADE_KEY_LENGTH>>6)-1:0]       parity_64;      //256
    wire [(`CASCADE_KEY_LENGTH>>7)-1:0]       parity_128;     //128
    wire [(`CASCADE_KEY_LENGTH>>8)-1:0]       parity_256;     //64
    wire [(`CASCADE_KEY_LENGTH>>9)-1:0]       parity_512;     //32
    wire [(`CASCADE_KEY_LENGTH>>10)-1:0]      parity_1024;    //16




    assign parity_tree [0][`CASCADE_KEY_LENGTH-1:0] = parity_1;
    assign parity_tree [1][`CASCADE_KEY_LENGTH-1:0] = {parity_2,{(`CASCADE_KEY_LENGTH - `PARITY_WIDTH_2){1'b0}}};
    assign parity_tree [2][`CASCADE_KEY_LENGTH-1:0] = {parity_4,{(`CASCADE_KEY_LENGTH - `PARITY_WIDTH_4){1'b0}}};
    assign parity_tree [3][`CASCADE_KEY_LENGTH-1:0] = {parity_8,{(`CASCADE_KEY_LENGTH - `PARITY_WIDTH_8){1'b0}}};
    assign parity_tree [4][`CASCADE_KEY_LENGTH-1:0] = {parity_16,{(`CASCADE_KEY_LENGTH - `PARITY_WIDTH_16){1'b0}}};
    assign parity_tree [5][`CASCADE_KEY_LENGTH-1:0] = {parity_32,{(`CASCADE_KEY_LENGTH - `PARITY_WIDTH_32){1'b0}}};
    assign parity_tree [6][`CASCADE_KEY_LENGTH-1:0] = {parity_64,{(`CASCADE_KEY_LENGTH - `PARITY_WIDTH_64){1'b0}}};
    assign parity_tree [7][`CASCADE_KEY_LENGTH-1:0] = {parity_128,{(`CASCADE_KEY_LENGTH - `PARITY_WIDTH_128){1'b0}}};
    assign parity_tree [8][`CASCADE_KEY_LENGTH-1:0] = {parity_256,{(`CASCADE_KEY_LENGTH - `PARITY_WIDTH_256){1'b0}}};
    assign parity_tree [9][`CASCADE_KEY_LENGTH-1:0] = {parity_512,{(`CASCADE_KEY_LENGTH - `PARITY_WIDTH_512){1'b0}}};
    assign parity_tree [10][`CASCADE_KEY_LENGTH-1:0] = {parity_1024,{(`CASCADE_KEY_LENGTH - `PARITY_WIDTH_1024){1'b0}}};

    

    //parity tree
    assign parity_1 = corrected_key;

    genvar gen_i;
    generate
    for(gen_i = 0;gen_i < `PARITY_WIDTH_2; gen_i = gen_i + 1) begin
        assign parity_2[gen_i] = corrected_key[gen_i<<1] ^ corrected_key[(gen_i<<1) + 1];
    end
    endgenerate

    //XOR 4
    generate
    for(gen_i = 0;gen_i < `PARITY_WIDTH_4; gen_i = gen_i + 1) begin
        assign parity_4[gen_i] = parity_2[gen_i<<1] ^ parity_2[(gen_i<<1) + 1];
    end
    endgenerate


    //XOR 8
    generate
    for(gen_i = 0;gen_i < `PARITY_WIDTH_8; gen_i = gen_i + 1) begin
        assign parity_8[gen_i] = parity_4[gen_i<<1] ^ parity_4[(gen_i<<1) + 1];
    end
    endgenerate

    //XOR 16
    generate
    for(gen_i = 0;gen_i < `PARITY_WIDTH_16; gen_i = gen_i + 1) begin
        assign parity_16[gen_i] = parity_8[gen_i<<1] ^ parity_8[(gen_i<<1) + 1];
    end
    endgenerate

    //XOR 32
    generate
    for(gen_i = 0;gen_i < `PARITY_WIDTH_32; gen_i = gen_i + 1) begin
        assign parity_32[gen_i] = parity_16[gen_i<<1] ^ parity_16[(gen_i<<1) + 1];
    end
    endgenerate

    //XOR 64
    generate
    for(gen_i = 0;gen_i < `PARITY_WIDTH_64; gen_i = gen_i + 1) begin
        assign parity_64[gen_i] = parity_32[gen_i<<1] ^ parity_32[(gen_i<<1) + 1];
    end
    endgenerate

    //XOR 128
    generate
    for(gen_i = 0;gen_i < `PARITY_WIDTH_128; gen_i = gen_i + 1) begin
        assign parity_128[gen_i] = parity_64[gen_i<<1] ^ parity_64[(gen_i<<1) + 1];
    end
    endgenerate

    //XOR 256
    generate
    for(gen_i = 0;gen_i < `PARITY_WIDTH_256; gen_i = gen_i + 1) begin
        assign parity_256[gen_i] = parity_128[gen_i<<1] ^ parity_128[(gen_i<<1) + 1];
    end
    endgenerate

    //XOR 512
    generate
    for(gen_i = 0;gen_i < `PARITY_WIDTH_512; gen_i = gen_i + 1) begin
        assign parity_512[gen_i] = parity_256[gen_i<<1] ^ parity_256[(gen_i<<1) + 1];
    end
    endgenerate

    //XOR 1024
    generate
    for(gen_i = 0;gen_i < `PARITY_WIDTH_1024; gen_i = gen_i + 1) begin
        assign parity_1024[gen_i] = parity_512[gen_i<<1] ^ parity_512[(gen_i<<1) + 1];
    end
    endgenerate

//****************************** parity tree ******************************





//****************************** corrected key ******************************

    reg [31:0] loading_key;
    reg [`CASCADE_KEY_32_DEPTH-1:0] loading_key_sel;




    wire shuffle_en;
    wire inv_shuffle_en;
    //reg [2:0] shuffle_set_sel;



    wire [63:0]corrected_key_MSB64;
    wire [63:0]corrected_key_LSB64;
    assign corrected_key_MSB64 = corrected_key[`CASCADE_KEY_LENGTH-1:`CASCADE_KEY_LENGTH-64];
    assign corrected_key_LSB64 = corrected_key[63:0];

    correct_key_32 Bcorrectkey(
        .clk(clk),
        .rst_n(rst_n),


        .loading_key(loading_key),
        .loading_key_sel(loading_key_sel),
        
        .shuffle_en(shuffle_en),
        .inv_shuffle_en(inv_shuffle_en),
        .shuffle_set_sel(shuffle_set_sel),



        .correct_key(corrected_key)
    );
//****************************** corrected key ******************************


//****************************** loading sifted key / correction key ******************************
    reg [15:0] loading_counter;
    always @(posedge clk ) begin
        if (~rst_n) begin
            loading_counter <= 16'b0;
        end
        else if (load_en) begin
            loading_counter <= loading_counter + 1;
        end
        else begin
            loading_counter <= 16'b0;
        end
    end

    wire loadkey_finish;
    assign loadkey_finish = (loading_counter[15:1]==(`SIFTED_KEY_64_DEPTH+3))? 1'b1:1'b0;
    
    


    always @(*) begin
        Bsiftedkey_addrb = {sifted_key_addr_index, frame_round, loading_counter[`SIFTED_KEY_64_WIDTH:1]};
    end


    wire sifted_key_en;
    assign sifted_key_en = ((loading_counter>1)&&(loading_counter<((`SIFTED_KEY_64_DEPTH<<1)+2)))? 1'b1:1'b0;


    reg [`CASCADE_KEY_32_DEPTH-1:0] sifted_key_loading_sel;


    always @(posedge clk) begin
        if (loading_counter==1) begin
            sifted_key_loading_sel[`CASCADE_KEY_32_DEPTH-1] <= 1'b1;
        end
        else begin
            sifted_key_loading_sel[`CASCADE_KEY_32_DEPTH-1] <= 1'b0;
        end
    end

    always @(posedge clk ) begin
        for ( i=(`CASCADE_KEY_32_DEPTH-1) ; i>=1 ; i=i-1) begin
            sifted_key_loading_sel[i-1] <= sifted_key_loading_sel[i];
        end
    end
    

    always @(*) begin
        if (sifted_key_en) begin
            loading_key_sel = sifted_key_loading_sel;
        end
        else if (correction_key_en) begin
            loading_key_sel = corrected_Bkey_loading_sel;
        end
        else begin
            loading_key_sel = 0;
        end
    end


    always @(*) begin
        if (sifted_key_en && (~loading_counter[0])) begin
            loading_key = Bsiftedkey_doutb_ff[63:32];
        end
        else if (sifted_key_en && (loading_counter[0])) begin
            loading_key = Bsiftedkey_doutb_ff[31:0];
        end
        else if (correction_key_en) begin
            loading_key = cascade_corrected_Bkey;
        end
        else begin
            loading_key = 32'b0;
        end
    end
//****************************** loading sifted key / correction key ******************************



//****************************** top level header ******************************
    // top level indicator
    wire top_level_indicator;
    assign top_level_indicator = (top_1||top_2||top_3||top_4||first_top_parity);
    assign shuffle_en = top_level_indicator;


    // top level header
    reg [31:0] B2A_top_header_ff;
    always @(posedge clk ) begin
        if (~rst_n) begin
            B2A_top_header_ff <= 32'b0;
        end
        else if (top_level_indicator) begin
            B2A_top_header_ff <= B2A_top_header;
        end
        else if (reset_parameter) begin
            B2A_top_header_ff <= 32'b0;
        end
        else begin
            B2A_top_header_ff <= B2A_top_header_ff;
        end
    end

    // B2A header
    wire [31:0] B2A_top_header;

    wire [`PACKET_TYPE_WIDTH-1:0] packet_type;
    wire [`PACKET_LENGTH_WIDTH-1:0] packet_length;
    reg [`RECONCILIATION_REAL_PACKET_DEPTH_WIDTH-1:0] top_packet_real_depth;
    reg [`PARITY_TYPE_WIDTH-1:0] top_parity_type;
    reg [`RECONCILIATION_SHUFFLE_SET_WIDTH-1:0] shuffle_set_sel;
    wire [`PARITY_TREE_ROW_INDEX_WIDTH-1:0]   current_top_row_index;      //4~9
    reg [`RECONCILIATION_SERIAL_NUMBER_WIDTH-1:0] serial_number_cnt;


    // B2A header
    assign B2A_top_header = {packet_type, packet_length, 
                             top_packet_real_depth, top_parity_type,
                             shuffle_set_sel, current_top_row_index, 
                             serial_number_cnt};


    // packet type
    assign packet_type = `B2A_ASK_PARITY;

    // packet length
    // top level ask parity packet length is always PACKET_LENGTH_257
    assign packet_length = `PACKET_LENGTH_257;

    // current top row index
    assign current_top_row_index = ((cascade_level_index>0)&&(cascade_level_index<5))? init_parity_tree_row_index + (cascade_level_index - 1):0;

    // real depth
    always @(*) begin
        if (current_top_row_index > `LESS_32_ROW_INDEX) begin
            top_packet_real_depth = 1;
        end
        else begin
            top_packet_real_depth = (`CASCADE_KEY_32_DEPTH>>(current_top_row_index-1));
        end
    end


    // parity type
    always @(*) begin
        if (first_top_parity) begin
            top_parity_type = `FIRST_TOP_PARITY_MESSAGE;
        end
        else if (top_level_indicator) begin
            top_parity_type = `TOP_PARITY_MESSAGE;
        end
        else begin
            top_parity_type = `NORMAL_PARITY;
        end
    end

    // shuffle set select
    always @(*) begin
        case (cascade_level_index)
           3'd1 : shuffle_set_sel = `RECONCILIATION_SHUFFLE_SET_1;
           3'd2 : shuffle_set_sel = `RECONCILIATION_SHUFFLE_SET_2;
           3'd3 : shuffle_set_sel = `RECONCILIATION_SHUFFLE_SET_3;
           3'd4 : shuffle_set_sel = `RECONCILIATION_SHUFFLE_SET_4;
            default: shuffle_set_sel = `RECONCILIATION_SHUFFLE_SET_1;
        endcase
    end



    // serial number counter
    always @(posedge clk ) begin
        if (~rst_n) begin
            serial_number_cnt <= `RECONCILIATION_SERIAL_NUMBER_WIDTH'b0;
        end
        else if (reset_parameter) begin
            serial_number_cnt <= `RECONCILIATION_SERIAL_NUMBER_WIDTH'b0;
        end
        else if ((top_level_indicator | write_normal_header)) begin
            serial_number_cnt <= serial_number_cnt + 1;
        end
        else begin
            serial_number_cnt <= serial_number_cnt;
        end
    end
//****************************** top level header ******************************





//****************************** write top parity ******************************

    reg [15:0] top_level_cnt;
    always @(posedge clk ) begin
        if (~rst_n) begin
            top_level_cnt <= 16'b0;
        end
        else if (reset_parameter) begin
            top_level_cnt <= 16'b0;
        end
        else if (top_level_indicator) begin
            top_level_cnt <= 16'b1;
        end
        else if (top_level_cnt == top_packet_real_depth+4) begin
            top_level_cnt <= 16'b0;
        end
        else if (top_level_cnt == 16'b0) begin
            top_level_cnt <= 16'b0;
        end
        else begin
            top_level_cnt <= top_level_cnt + 1;
        end
    end

    wire top_level_ask_en;
    assign top_level_ask_en = ((top_level_cnt>2) && (top_level_cnt < top_packet_real_depth+3))? 1'b1:1'b0;
    wire output_top_level_ask_parity_en = ((top_level_cnt>1) && (top_level_cnt < top_packet_real_depth+3))? 1'b1:1'b0;

    reg [31:0] B_top_level_parity;
    always @(*) begin
        if (top_level_cnt==2) begin
            B_top_level_parity = B2A_top_header_ff;
        end
        else if (top_level_ask_en) begin
            B_top_level_parity = parity_tree[current_top_row_index - 1][(`CASCADE_KEY_LENGTH-((top_level_cnt-2)<<5)) +:32];
        end
        else begin
            B_top_level_parity = 32'b0;
        end
    end
//****************************** write top parity ******************************



//****************************** write B2A FIFO ******************************



    always @(posedge clk ) begin
        if (~rst_n) begin
            B_B2A_wr_din <= 32'b0;
            B_B2A_wr_en <= 1'b0;
        end
        
        else if (output_top_level_ask_parity_en) begin
            B_B2A_wr_din <= B_top_level_parity;
            B_B2A_wr_en <= 1'b1;
        end

        else if (write_normal_header) begin
            B_B2A_wr_din <= normal_header;
            B_B2A_wr_en <= 1'b1;
        end

        else if (short_parity_wr_en & short_parity_en) begin
            B_B2A_wr_din <= ask_parity;
            B_B2A_wr_en <= 1'b1;
        end

        else if (ask_parity_en & (~short_parity_en)) begin
            B_B2A_wr_din <= ask_parity;
            B_B2A_wr_en <= 1'b1;
        end
        
        else begin
            B_B2A_wr_din <= 32'b0;
            B_B2A_wr_en <= 1'b0;
        end
    end
    
//****************************** write B2A FIFO ******************************






//****************************** read A2B FIFO ******************************


    assign B_A2B_rd_en = (read_header_en||(normal_ask_parity_en)||row_1_correction_en);


//****************************** read A2B FIFO ******************************





//****************************** read header ******************************
    // A2B header
    reg [31:0] B_A2B_header_ff;
    always @(posedge clk ) begin
        if (~rst_n) begin
            B_A2B_header_ff <= 32'b0;
        end
        else if (reset_parameter) begin
            B_A2B_header_ff <= 32'b0;
        end
        else if (read_header_en) begin
            B_A2B_header_ff <= B_A2B_rd_dout;
        end
        else begin
            B_A2B_header_ff <= B_A2B_header_ff;
        end
    end




    // real depth
    reg [10:0] B_A2B_realdepth;
    wire [`PACKET_LENGTH_WIDTH-1:0] B_A2B_packet_depth;
    assign B_A2B_packet_depth = B_A2B_header_ff[27:24];

    always @(*) begin
        if (B_A2B_packet_depth==`PACKET_LENGTH_257) begin
            B_A2B_realdepth = {2'b0,B_A2B_header_ff[23:15]};
        end
        else if (B_A2B_packet_depth==`PACKET_LENGTH_514) begin
            B_A2B_realdepth = 11'd512;
        end
        else if (B_A2B_packet_depth==`PACKET_LENGTH_771) begin
            B_A2B_realdepth = 11'd768;
        end
        else if (B_A2B_packet_depth==`PACKET_LENGTH_1028) begin
            B_A2B_realdepth = 11'd1024;
        end
        else begin
            B_A2B_realdepth = 11'd1024;
        end
    end





    assign B_A2B_parity_tree_row = B_A2B_header_ff[8:5];

    assign B_A2B_parity_type = B_A2B_header_ff[14:12];

    wire B_A2B_top_level_block;
    assign B_A2B_top_level_block = B_A2B_header_ff[14];



//****************************** read header ******************************



//****************************** normal ask parity ******************************
    reg [15:0] normal_ask_parity_cnt;
    always @(posedge clk ) begin
        if (~rst_n) begin
            normal_ask_parity_cnt <= 16'b0;
        end
        else if (reset_read_cnt) begin
            normal_ask_parity_cnt <= 16'b0;
        end
        else if (ask_parity_en) begin
            normal_ask_parity_cnt <= normal_ask_parity_cnt + 1;
        end
        else begin
            normal_ask_parity_cnt <= normal_ask_parity_cnt;
        end
    end



    wire short_parity_en;
    wire short_parity_wr_en;
    reg short_parity_wr_en_delay;

    always @(posedge clk ) begin
        if (~rst_n) begin
            short_parity_wr_en_delay <= 1'b0;
        end
        else begin
            short_parity_wr_en_delay <= short_parity_wr_en;
        end
    end

    assign short_parity_en = (B_A2B_parity_tree_row > `LESS_32_ROW_INDEX)? 1'b1:1'b0;
    assign short_parity_wr_en = ask_parity_en & (~short_parity_wr_en_delay);


    wire normal_ask_parity_en;
    assign normal_ask_parity_en = ask_parity_en&&(normal_ask_parity_cnt[0]);


    assign ask_parity_done = (normal_ask_parity_cnt==(B_A2B_realdepth<<1));

    wire [31:0] B_normal_parity;
    assign B_normal_parity = parity_tree[B_A2B_parity_tree_row-1][(`CASCADE_KEY_LENGTH-((normal_ask_parity_cnt[15:1]+1)<<5)) +:32];

    wire [31:0] Areply_xor_Bparity;
    assign Areply_xor_Bparity = (ask_parity_en)? (B_A2B_rd_dout ^ B_normal_parity):32'b0;

    wire [31:0] pre_ask_parity;
    assign pre_ask_parity = (B_A2B_top_level_block)? {32{1'b1}}:pre_ask_parity_fifo_dout;

    wire [31:0] Bpreask_and_Areply_xor_Bparity;
    assign Bpreask_and_Areply_xor_Bparity = pre_ask_parity & Areply_xor_Bparity;

    reg [31:0] ask_parity;
    always @(*) begin
        if ((~normal_ask_parity_cnt[0])&&ask_parity_en) begin
            ask_parity = {
                Bpreask_and_Areply_xor_Bparity[31],
                Bpreask_and_Areply_xor_Bparity[31],
                Bpreask_and_Areply_xor_Bparity[30],
                Bpreask_and_Areply_xor_Bparity[30],
                Bpreask_and_Areply_xor_Bparity[29],
                Bpreask_and_Areply_xor_Bparity[29],
                Bpreask_and_Areply_xor_Bparity[28],
                Bpreask_and_Areply_xor_Bparity[28],

                Bpreask_and_Areply_xor_Bparity[27],
                Bpreask_and_Areply_xor_Bparity[27],
                Bpreask_and_Areply_xor_Bparity[26],
                Bpreask_and_Areply_xor_Bparity[26],
                Bpreask_and_Areply_xor_Bparity[25],
                Bpreask_and_Areply_xor_Bparity[25],
                Bpreask_and_Areply_xor_Bparity[24],
                Bpreask_and_Areply_xor_Bparity[24],

                Bpreask_and_Areply_xor_Bparity[23],
                Bpreask_and_Areply_xor_Bparity[23],
                Bpreask_and_Areply_xor_Bparity[22],
                Bpreask_and_Areply_xor_Bparity[22],
                Bpreask_and_Areply_xor_Bparity[21],
                Bpreask_and_Areply_xor_Bparity[21],
                Bpreask_and_Areply_xor_Bparity[20],
                Bpreask_and_Areply_xor_Bparity[20],

                Bpreask_and_Areply_xor_Bparity[19],
                Bpreask_and_Areply_xor_Bparity[19],
                Bpreask_and_Areply_xor_Bparity[18],
                Bpreask_and_Areply_xor_Bparity[18],
                Bpreask_and_Areply_xor_Bparity[17],
                Bpreask_and_Areply_xor_Bparity[17],
                Bpreask_and_Areply_xor_Bparity[16],
                Bpreask_and_Areply_xor_Bparity[16]};
        end
        else if ((normal_ask_parity_cnt[0])&&ask_parity_en) begin
            ask_parity = {
                Bpreask_and_Areply_xor_Bparity[15],
                Bpreask_and_Areply_xor_Bparity[15],
                Bpreask_and_Areply_xor_Bparity[14],
                Bpreask_and_Areply_xor_Bparity[14],
                Bpreask_and_Areply_xor_Bparity[13],
                Bpreask_and_Areply_xor_Bparity[13],
                Bpreask_and_Areply_xor_Bparity[12],
                Bpreask_and_Areply_xor_Bparity[12],

                Bpreask_and_Areply_xor_Bparity[11],
                Bpreask_and_Areply_xor_Bparity[11],
                Bpreask_and_Areply_xor_Bparity[10],
                Bpreask_and_Areply_xor_Bparity[10],
                Bpreask_and_Areply_xor_Bparity[9],
                Bpreask_and_Areply_xor_Bparity[9],
                Bpreask_and_Areply_xor_Bparity[8],
                Bpreask_and_Areply_xor_Bparity[8],

                Bpreask_and_Areply_xor_Bparity[7],
                Bpreask_and_Areply_xor_Bparity[7],
                Bpreask_and_Areply_xor_Bparity[6],
                Bpreask_and_Areply_xor_Bparity[6],
                Bpreask_and_Areply_xor_Bparity[5],
                Bpreask_and_Areply_xor_Bparity[5],
                Bpreask_and_Areply_xor_Bparity[4],
                Bpreask_and_Areply_xor_Bparity[4],

                Bpreask_and_Areply_xor_Bparity[3],
                Bpreask_and_Areply_xor_Bparity[3],
                Bpreask_and_Areply_xor_Bparity[2],
                Bpreask_and_Areply_xor_Bparity[2],
                Bpreask_and_Areply_xor_Bparity[1],
                Bpreask_and_Areply_xor_Bparity[1],
                Bpreask_and_Areply_xor_Bparity[0],
                Bpreask_and_Areply_xor_Bparity[0]};
        end
        else begin
            ask_parity = 32'b0;
        end
    end

    // header B2A row index
    wire [`PACKET_LENGTH_WIDTH-1:0] B_B2A_row_index;
    assign B_B2A_row_index = B_A2B_parity_tree_row - 1;

    // header B2A packet length
    wire [`PACKET_LENGTH_WIDTH-1:0] B_B2A_packet_length;
    //assign B_B2A_packet_length = (B_B2A_row_index==1)? `PACKET_LENGTH_514:`PACKET_LENGTH_257;
    assign B_B2A_packet_length = `PACKET_LENGTH_257;


    //header B2A real depth
    reg [`RECONCILIATION_REAL_PACKET_DEPTH_WIDTH-1:0] B_B2A_packet_real_depth;
    always @(*) begin
        if (B_B2A_row_index > `LESS_32_ROW_INDEX) begin
            B_B2A_packet_real_depth = 1;
        end
        else begin
            B_B2A_packet_real_depth = (`CASCADE_KEY_32_DEPTH>>(B_B2A_row_index-1));
        end
    end
 
    // header B2A parity type
    wire [`PARITY_TYPE_WIDTH-1:0] normal_parity_type;
    assign normal_parity_type = `NORMAL_PARITY;

    
    // normal header
    wire [31:0] normal_header;
    assign normal_header = {packet_type, B_B2A_packet_length,
                            B_B2A_packet_real_depth, normal_parity_type,
                            shuffle_set_sel, B_B2A_row_index,
                            serial_number_cnt};




    //record ask parity
    wire [31:0] ask_parity_fifo_din;
    assign ask_parity_fifo_din = ask_parity;
    wire [31:0] pre_ask_parity_fifo_dout;
    wire pre_ask_rd_en;
    assign pre_ask_rd_en = ((~B_A2B_top_level_block)&&((normal_ask_parity_en)||pre_ask_parity_record_rd_en));

    wire ask_parity_fifo_wr_en;
    assign ask_parity_fifo_wr_en = (short_parity_en)? short_parity_wr_en:ask_parity_en;
    ask_parity_fifo askparity_fifo (
        .clk(clk),                  // input wire clk
        .srst(~rst_n),                // input wire srst
        .din(ask_parity_fifo_din),                  // input wire [31 : 0] din
        .wr_en(ask_parity_fifo_wr_en),              // input wire wr_en
        .rd_en(pre_ask_rd_en),              // input wire rd_en
        .dout(pre_ask_parity_fifo_dout),                // output wire [31 : 0] dout
        .full(),                // output wire full
        .wr_ack(),            // output wire wr_ack
        .empty(),              // output wire empty
        .valid(),              // output wire valid
        .wr_rst_busy(),  // output wire wr_rst_busy
        .rd_rst_busy()  // output wire rd_rst_busy
);

//****************************** normal ask parity ******************************






//****************************** row 1 correct Bkey ******************************
    reg [15:0] row_1_correct_cnt;
    always @(posedge clk ) begin
        if (~rst_n) begin
            row_1_correct_cnt <= 16'b0;
        end
        else if (reset_read_cnt) begin
            row_1_correct_cnt <= 16'b0;
        end
        else if (buttom_level_correction_en) begin
            row_1_correct_cnt <= row_1_correct_cnt + 1;
        end
        else begin
            row_1_correct_cnt <= row_1_correct_cnt;
        end
    end


    wire [31:0] row_1_Bkey;
    assign row_1_Bkey = (row_1_correct_cnt>0 && row_1_correct_cnt<(`CASCADE_KEY_32_DEPTH+1))? corrected_key[(`CASCADE_KEY_LENGTH-((row_1_correct_cnt)<<5)) +:32]:32'b0;
    wire pre_ask_parity_record_rd_en;
    assign pre_ask_parity_record_rd_en = (row_1_correct_cnt>0 && row_1_correct_cnt<(`CASCADE_KEY_32_DEPTH+1));
    wire row_1_correction_en;
    assign row_1_correction_en = (row_1_correct_cnt>0 && row_1_correct_cnt<(`CASCADE_KEY_32_DEPTH+1));


    assign buttom_level_correction_finish = (row_1_correct_cnt==(`CASCADE_KEY_32_DEPTH+4));



    wire correct_en;
    assign correct_en = (row_1_correct_cnt>0 && row_1_correct_cnt<(`CASCADE_KEY_32_DEPTH+1));


    wire [31:0] cascade_corrected_output;
    assign cascade_corrected_output = ((~pre_ask_parity_fifo_dout)&(row_1_Bkey))|((pre_ask_parity_fifo_dout)&(B_A2B_rd_dout));


    reg correction_key_en;
    reg [31:0] cascade_corrected_Bkey;

    always @(posedge clk ) begin
        if (~rst_n) begin
            correction_key_en <= 1'b0;
            cascade_corrected_Bkey <= 32'b0;
        end
        else begin
            correction_key_en <= correct_en;
            cascade_corrected_Bkey <= cascade_corrected_output;
        end
    end


    reg [`CASCADE_KEY_32_DEPTH-1:0] corrected_Bkey_loading_sel;

    always @(posedge clk) begin
        if (row_1_correct_cnt==1) begin
            corrected_Bkey_loading_sel[`CASCADE_KEY_32_DEPTH-1] <= 1'b1;
        end
        else begin
            corrected_Bkey_loading_sel[`CASCADE_KEY_32_DEPTH-1] <= 1'b0;
        end
    end


    always @(posedge clk ) begin
        for ( i=(`CASCADE_KEY_32_DEPTH-1) ; i>=1 ; i=i-1) begin
            corrected_Bkey_loading_sel[i-1] <= corrected_Bkey_loading_sel[i];
        end
    end



//****************************** row 1 correct Bkey ******************************










endmodule















































module B_readheader_fsm(
    input clk,
    input rst_n,

    input B_A2B_rd_valid,
    input [`PARITY_TYPE_WIDTH-1:0] B_A2B_parity_type,
    input [`PARITY_TREE_ROW_INDEX_WIDTH-1:0] parity_tree_row,
    input buttom_level_correction_finish,
    input ask_parity_done,



    output wire reset_read_cnt,
    output wire read_header_en,
    output wire write_normal_header,

    output reg inv_shuffle_en,
    output reg top_level_parity_correct,
    output reg Bkey_correction_done,
    output reg ask_parity_en,
    output reg buttom_level_correction_en,
    output reg [4:0] B_readheader_state
);



    localparam IDLE                 = 5'd0;
    localparam READ_HEADER          = 5'd1;
    localparam DETERMINE_MODE       = 5'd2;
    localparam TOPLEVEL_CORRECT     = 5'd3;
    localparam TOPCORRECT_INVSHUFFLE= 5'd4;
    localparam TOPCORRECT_OUT       = 5'd5;
    localparam ROW_1                = 5'd6;
    localparam ROW_1_CORRECTION     = 5'd7;
    localparam ROW_1_INVSHUFFLE     = 5'd8;
    localparam ROW_1_CORRECTION_OUT = 5'd9;
    localparam NORMAL_MODE          = 5'd10;
    localparam ASK_PARITY           = 5'd11;
    localparam ASK_PARITY_DONE      = 5'd12;


    reg [4:0] next_B_readheader_state;
    always @(posedge clk ) begin
        if (~rst_n) begin
            B_readheader_state <= IDLE;
        end
        else begin
            B_readheader_state <= next_B_readheader_state;
        end
    end


    assign reset_read_cnt = (B_readheader_state==ASK_PARITY_DONE)||
                            (B_readheader_state==TOPCORRECT_OUT)||
                            (B_readheader_state==ROW_1_CORRECTION_OUT);

    assign read_header_en = (READ_HEADER==B_readheader_state);
    assign write_normal_header = (NORMAL_MODE==B_readheader_state);

    always @(*) begin
        case (B_readheader_state)
            IDLE: begin
                if (B_A2B_rd_valid) begin
                    next_B_readheader_state = READ_HEADER;
                    inv_shuffle_en = 1'b0;
                    top_level_parity_correct = 1'b0;
                    Bkey_correction_done = 1'b0;
                    ask_parity_en = 1'b0;
                    buttom_level_correction_en = 1'b0;
                end
                else begin
                    next_B_readheader_state = IDLE;
                    inv_shuffle_en = 1'b0;
                    top_level_parity_correct = 1'b0;
                    Bkey_correction_done = 1'b0;
                    ask_parity_en = 1'b0;
                    buttom_level_correction_en = 1'b0;
                end
            end

            READ_HEADER: begin
                next_B_readheader_state = DETERMINE_MODE;
                inv_shuffle_en = 1'b0;
                top_level_parity_correct = 1'b0;
                Bkey_correction_done = 1'b0;
                ask_parity_en = 1'b0;
                buttom_level_correction_en = 1'b0;
            end

            DETERMINE_MODE: begin
                if (B_A2B_parity_type==`TOP_PARITY_CORRECT) begin
                    next_B_readheader_state = TOPLEVEL_CORRECT;
                    inv_shuffle_en = 1'b0;
                    top_level_parity_correct = 1'b0;
                    Bkey_correction_done = 1'b0;
                    ask_parity_en = 1'b0;
                    buttom_level_correction_en = 1'b0;
                end
                else if (parity_tree_row==`PARITY_TREE_ROW_1) begin
                    next_B_readheader_state = ROW_1;
                    inv_shuffle_en = 1'b0;
                    top_level_parity_correct = 1'b0;
                    Bkey_correction_done = 1'b0;
                    ask_parity_en = 1'b0;
                    buttom_level_correction_en = 1'b0;
                end
                else if (parity_tree_row!=`PARITY_TREE_ROW_1) begin
                    next_B_readheader_state = NORMAL_MODE;
                    inv_shuffle_en = 1'b0;
                    top_level_parity_correct = 1'b0;
                    Bkey_correction_done = 1'b0;
                    ask_parity_en = 1'b0;
                    buttom_level_correction_en = 1'b0;
                end
                else begin
                    next_B_readheader_state = DETERMINE_MODE;
                    inv_shuffle_en = 1'b0;
                    top_level_parity_correct = 1'b0;
                    Bkey_correction_done = 1'b0;
                    ask_parity_en = 1'b0;
                    buttom_level_correction_en = 1'b0;
                end
            end


            TOPLEVEL_CORRECT: begin
                next_B_readheader_state = TOPCORRECT_INVSHUFFLE;
                inv_shuffle_en = 1'b0;
                top_level_parity_correct = 1'b0;
                Bkey_correction_done = 1'b0;
                ask_parity_en = 1'b0;
                buttom_level_correction_en = 1'b0;
            end

            TOPCORRECT_INVSHUFFLE: begin
                next_B_readheader_state = TOPCORRECT_OUT;
                inv_shuffle_en = 1'b1;
                top_level_parity_correct = 1'b0;
                Bkey_correction_done = 1'b0;
                ask_parity_en = 1'b0;
                buttom_level_correction_en = 1'b0;
            end

            TOPCORRECT_OUT: begin
                next_B_readheader_state = IDLE;
                inv_shuffle_en = 1'b0;
                top_level_parity_correct = 1'b1;
                Bkey_correction_done = 1'b0;
                ask_parity_en = 1'b0;
                buttom_level_correction_en = 1'b0;
            end

            ROW_1: begin
                next_B_readheader_state = ROW_1_CORRECTION;
                inv_shuffle_en = 1'b0;
                top_level_parity_correct = 1'b0;
                Bkey_correction_done = 1'b0;
                ask_parity_en = 1'b0;
                buttom_level_correction_en = 1'b0;
            end


            ROW_1_CORRECTION: begin
                if (buttom_level_correction_finish) begin
                    next_B_readheader_state = ROW_1_INVSHUFFLE;
                    inv_shuffle_en = 1'b0;
                    top_level_parity_correct = 1'b0;
                    Bkey_correction_done = 1'b0;
                    ask_parity_en = 1'b0;
                    buttom_level_correction_en = 1'b0;
                end
                else begin
                    next_B_readheader_state = ROW_1_CORRECTION;
                    inv_shuffle_en = 1'b0;
                    top_level_parity_correct = 1'b0;
                    Bkey_correction_done = 1'b0;
                    ask_parity_en = 1'b0;
                    buttom_level_correction_en = 1'b1;
                end
            end

            ROW_1_INVSHUFFLE: begin
                next_B_readheader_state = ROW_1_CORRECTION_OUT;
                inv_shuffle_en = 1'b1;
                top_level_parity_correct = 1'b0;
                Bkey_correction_done = 1'b0;
                ask_parity_en = 1'b0;
                buttom_level_correction_en = 1'b0;
            end


            ROW_1_CORRECTION_OUT: begin
                next_B_readheader_state = IDLE;
                inv_shuffle_en = 1'b0;
                top_level_parity_correct = 1'b0;
                Bkey_correction_done = 1'b1;
                ask_parity_en = 1'b0;
                buttom_level_correction_en = 1'b0;
            end

            NORMAL_MODE: begin
                next_B_readheader_state = ASK_PARITY;
                inv_shuffle_en = 1'b0;
                top_level_parity_correct = 1'b0;
                Bkey_correction_done = 1'b0;
                ask_parity_en = 1'b0;
                buttom_level_correction_en = 1'b0;
            end

            ASK_PARITY: begin
                if (ask_parity_done) begin
                    next_B_readheader_state = ASK_PARITY_DONE;
                    inv_shuffle_en = 1'b0;
                    top_level_parity_correct = 1'b0;
                    Bkey_correction_done = 1'b0;
                    ask_parity_en = 1'b0;
                    buttom_level_correction_en = 1'b0;
                end
                else begin
                    next_B_readheader_state = ASK_PARITY;
                    inv_shuffle_en = 1'b0;
                    top_level_parity_correct = 1'b0;
                    Bkey_correction_done = 1'b0;
                    ask_parity_en = 1'b1;
                    buttom_level_correction_en = 1'b0;
                end
            end
            ASK_PARITY_DONE: begin
                next_B_readheader_state = IDLE;
                inv_shuffle_en = 1'b0;
                top_level_parity_correct = 1'b0;
                Bkey_correction_done = 1'b0;
                ask_parity_en = 1'b0;
                buttom_level_correction_en = 1'b0;
            end


            default: begin
                    next_B_readheader_state = IDLE;
                    inv_shuffle_en = 1'b0;
                    top_level_parity_correct = 1'b0;
                    Bkey_correction_done = 1'b0;
                    ask_parity_en = 1'b0;
                    buttom_level_correction_en = 1'b0;
            end
        endcase
    end





endmodule






























module cascadeB_fsm (
    input clk,
    input rst_n,

    input start_cascade,
    input loadkey_finish,
    input top_level_parity_correct,
    input Bkey_correction_done,



    

    output reg load_en,
    output reg cascade_finish,
    output reg reset_parameter,
    output reg frame_parameter_valid,

    output reg [2:0] cascade_level_index,   //1 2 3 4
    output wire top_1,
    output wire top_2,
    output wire top_3,
    output wire top_4,
    output reg first_top_parity,
    output reg [4:0] cascadeB_state
);
    

    localparam CASCADE_IDLE = 5'd31;
    localparam INIT_SETUP   = 5'd30;
    localparam LOADKEY      = 5'd29;

    localparam ITER_1       = 5'd1;

    localparam ITER_2       = 5'd2;
    localparam ITER_2_C_1   = 5'd3;
    localparam ITER_2_C_2   = 5'd4;

    localparam ITER_3       = 5'd5;
    localparam ITER_3_C_1   = 5'd6;
    localparam ITER_3_C_2   = 5'd7;
    localparam ITER_3_C_3   = 5'd8;

    localparam ITER_4       = 5'd9;
    localparam ITER_4_C_1   = 5'd10;
    localparam ITER_4_C_2   = 5'd11;
    localparam ITER_4_C_3   = 5'd12;
    localparam ITER_4_C_4   = 5'd13;

    localparam ITER_FINISH      = 5'd25;
    localparam PARAMETER_OUT    = 5'd26;
    localparam RESET_PARAMETER  = 5'd27;
    localparam CASCADE_END      = 5'd28;


    //fsm sl
    reg [4:0] next_cascadeB_state;
    always @(posedge clk ) begin
        if (~rst_n) begin
            cascadeB_state <= CASCADE_IDLE;
        end
        else begin
            cascadeB_state <= next_cascadeB_state;
        end
    end


    // cascade_level_index
    always @(*) begin
        case (cascadeB_state)
            ITER_1: cascade_level_index = 1;
            ITER_2_C_1: cascade_level_index = 1;
            ITER_3_C_1: cascade_level_index = 1;
            ITER_4_C_1: cascade_level_index = 1;

            ITER_2: cascade_level_index = 2;
            ITER_2_C_2: cascade_level_index = 2;
            ITER_3_C_2: cascade_level_index = 2;
            ITER_4_C_2: cascade_level_index = 2;

            ITER_3: cascade_level_index = 3;
            ITER_3_C_3: cascade_level_index = 3;
            ITER_4_C_3: cascade_level_index = 3;

            ITER_4: cascade_level_index = 4;
            ITER_4_C_4: cascade_level_index = 4;
            default: begin
                cascade_level_index = 0;
            end 
        endcase
    end

    // state transfer pulse
    reg state_transfer;
    always @(posedge clk ) begin
        if (~rst_n) begin
            state_transfer <= 1'b0;
        end
        else if (next_cascadeB_state!=cascadeB_state) begin
            state_transfer <= 1'b1;
        end
        else begin
            state_transfer <= 1'b0;
        end
    end

    // top1, top2, top3, top4
    assign top_1 = state_transfer&(cascade_level_index==1);
    assign top_2 = state_transfer&(cascade_level_index==2);
    assign top_3 = state_transfer&(cascade_level_index==3);
    assign top_4 = state_transfer&(cascade_level_index==4);

    // first parity
    always @(posedge clk ) begin
        if (~rst_n) begin
            first_top_parity <= 1'b0;
        end
        else if (next_cascadeB_state==ITER_1 && cascadeB_state!=ITER_1) begin
            first_top_parity <= 1'b1;
        end
        else if (next_cascadeB_state==ITER_2 && cascadeB_state!=ITER_2) begin
            first_top_parity <= 1'b1;
        end
        else if (next_cascadeB_state==ITER_3 && cascadeB_state!=ITER_3) begin
            first_top_parity <= 1'b1;
        end
        else if (next_cascadeB_state==ITER_4 && cascadeB_state!=ITER_4) begin
            first_top_parity <= 1'b1;
        end
        else if (next_cascadeB_state==ITER_4_C_4 && cascadeB_state!=ITER_4_C_4) begin
            first_top_parity <= 1'b1;
        end
        else begin
            first_top_parity <= 1'b0;
        end
    end



    //fsm cl
    always @(*) begin
        case (cascadeB_state)
            CASCADE_IDLE: begin
                if (start_cascade) begin
                    next_cascadeB_state = INIT_SETUP;
                    cascade_finish = 1'b0;
                    reset_parameter = 1'b0;
                    frame_parameter_valid = 1'b0;
                    load_en = 1'b0;
                end
                else begin
                    next_cascadeB_state = CASCADE_IDLE;
                    cascade_finish = 1'b0;
                    reset_parameter = 1'b0;
                    frame_parameter_valid = 1'b0;
                    load_en = 1'b0;
                end
            end 

            INIT_SETUP: begin
                next_cascadeB_state = LOADKEY;
                cascade_finish = 1'b0;
                reset_parameter = 1'b0;
                frame_parameter_valid = 1'b0;
                load_en = 1'b0;
            end 

            LOADKEY: begin
                if (loadkey_finish) begin
                    next_cascadeB_state = ITER_1;
                    cascade_finish = 1'b0;
                    reset_parameter = 1'b0;
                    frame_parameter_valid = 1'b0;
                    load_en = 1'b1;
                end
                else begin
                    next_cascadeB_state = LOADKEY;
                    cascade_finish = 1'b0;
                    reset_parameter = 1'b0;
                    frame_parameter_valid = 1'b0;
                    load_en = 1'b1;
                end
            end 

            ITER_1: begin
                if (top_level_parity_correct) begin
                    next_cascadeB_state = ITER_FINISH;
                    cascade_finish = 1'b0;
                    reset_parameter = 1'b0;
                    frame_parameter_valid = 1'b0;
                    load_en = 1'b0;
                end
                else if (Bkey_correction_done) begin
                    next_cascadeB_state = ITER_2;
                    cascade_finish = 1'b0;
                    reset_parameter = 1'b0;
                    frame_parameter_valid = 1'b0;
                    load_en = 1'b0;
                end
                else begin
                    next_cascadeB_state = ITER_1;
                    cascade_finish = 1'b0;
                    reset_parameter = 1'b0;
                    frame_parameter_valid = 1'b0;
                    load_en = 1'b0;
                end
            end

            ITER_2: begin
                if (top_level_parity_correct) begin
                    next_cascadeB_state = ITER_FINISH;
                    cascade_finish = 1'b0;
                    reset_parameter = 1'b0;
                    frame_parameter_valid = 1'b0;
                    load_en = 1'b0;
                end
                else if (Bkey_correction_done) begin
                    next_cascadeB_state = ITER_2_C_1;
                    cascade_finish = 1'b0;
                    reset_parameter = 1'b0;
                    frame_parameter_valid = 1'b0;
                    load_en = 1'b0;
                end
                else begin
                    next_cascadeB_state = ITER_2;
                    cascade_finish = 1'b0;
                    reset_parameter = 1'b0;
                    frame_parameter_valid = 1'b0;
                    load_en = 1'b0;
                end
            end

            ITER_2_C_1: begin
                if (top_level_parity_correct) begin
                    next_cascadeB_state = ITER_2_C_2;
                    cascade_finish = 1'b0;
                    reset_parameter = 1'b0;
                    frame_parameter_valid = 1'b0;
                    load_en = 1'b0;
                end
                else if (Bkey_correction_done) begin
                    next_cascadeB_state = ITER_2_C_2;
                    cascade_finish = 1'b0;
                    reset_parameter = 1'b0;
                    frame_parameter_valid = 1'b0;
                    load_en = 1'b0;
                end
                else begin
                    next_cascadeB_state = ITER_2_C_1;
                    cascade_finish = 1'b0;
                    reset_parameter = 1'b0;
                    frame_parameter_valid = 1'b0;
                    load_en = 1'b0;
                end
            end

            ITER_2_C_2: begin
                if (top_level_parity_correct) begin
                    next_cascadeB_state = ITER_3;
                    cascade_finish = 1'b0;
                    reset_parameter = 1'b0;
                    frame_parameter_valid = 1'b0;
                    load_en = 1'b0;
                end
                else if (Bkey_correction_done) begin
                    next_cascadeB_state = ITER_2_C_1;
                    cascade_finish = 1'b0;
                    reset_parameter = 1'b0;
                    frame_parameter_valid = 1'b0;
                    load_en = 1'b0;
                end
                else begin
                    next_cascadeB_state = ITER_2_C_2;
                    cascade_finish = 1'b0;
                    reset_parameter = 1'b0;
                    frame_parameter_valid = 1'b0;
                    load_en = 1'b0;
                end
            end

            ITER_3: begin
                if (top_level_parity_correct) begin
                    next_cascadeB_state = ITER_FINISH;
                    cascade_finish = 1'b0;
                    reset_parameter = 1'b0;
                    frame_parameter_valid = 1'b0;
                    load_en = 1'b0;
                end
                else if (Bkey_correction_done) begin
                    next_cascadeB_state = ITER_3_C_1;
                    cascade_finish = 1'b0;
                    reset_parameter = 1'b0;
                    frame_parameter_valid = 1'b0;
                    load_en = 1'b0;
                end
                else begin
                    next_cascadeB_state = ITER_3;
                    cascade_finish = 1'b0;
                    reset_parameter = 1'b0;
                    frame_parameter_valid = 1'b0;
                    load_en = 1'b0;
                end
            end

            ITER_3_C_1: begin
                if (top_level_parity_correct) begin
                    next_cascadeB_state = ITER_3_C_2;
                    cascade_finish = 1'b0;
                    reset_parameter = 1'b0;
                    frame_parameter_valid = 1'b0;
                    load_en = 1'b0;
                end
                else if (Bkey_correction_done) begin
                    next_cascadeB_state = ITER_3_C_2;
                    cascade_finish = 1'b0;
                    reset_parameter = 1'b0;
                    frame_parameter_valid = 1'b0;
                    load_en = 1'b0;
                end
                else begin
                    next_cascadeB_state = ITER_3_C_1;
                    cascade_finish = 1'b0;
                    reset_parameter = 1'b0;
                    frame_parameter_valid = 1'b0;
                    load_en = 1'b0;
                end
            end

            ITER_3_C_2: begin
                if (top_level_parity_correct) begin
                    next_cascadeB_state = ITER_3_C_3;
                    cascade_finish = 1'b0;
                    reset_parameter = 1'b0;
                    frame_parameter_valid = 1'b0;
                    load_en = 1'b0;
                end
                else if (Bkey_correction_done) begin
                    next_cascadeB_state = ITER_3_C_1;
                    cascade_finish = 1'b0;
                    reset_parameter = 1'b0;
                    frame_parameter_valid = 1'b0;
                    load_en = 1'b0;
                end
                else begin
                    next_cascadeB_state = ITER_3_C_2;
                    cascade_finish = 1'b0;
                    reset_parameter = 1'b0;
                    frame_parameter_valid = 1'b0;
                    load_en = 1'b0;
                end
            end

            ITER_3_C_3: begin
                if (top_level_parity_correct) begin
                    next_cascadeB_state = ITER_4;
                    cascade_finish = 1'b0;
                    reset_parameter = 1'b0;
                    frame_parameter_valid = 1'b0;
                    load_en = 1'b0;
                end
                else if (Bkey_correction_done) begin
                    next_cascadeB_state = ITER_3_C_1;
                    cascade_finish = 1'b0;
                    reset_parameter = 1'b0;
                    frame_parameter_valid = 1'b0;
                    load_en = 1'b0;
                end
                else begin
                    next_cascadeB_state = ITER_3_C_3;
                    cascade_finish = 1'b0;
                    reset_parameter = 1'b0;
                    frame_parameter_valid = 1'b0;
                    load_en = 1'b0;
                end
            end

            ITER_4: begin
                if (top_level_parity_correct) begin
                    next_cascadeB_state = ITER_FINISH;
                    cascade_finish = 1'b0;
                    reset_parameter = 1'b0;
                    frame_parameter_valid = 1'b0;
                    load_en = 1'b0;
                end
                else if (Bkey_correction_done) begin
                    next_cascadeB_state = ITER_4_C_1;
                    cascade_finish = 1'b0;
                    reset_parameter = 1'b0;
                    frame_parameter_valid = 1'b0;
                    load_en = 1'b0;
                end
                else begin
                    next_cascadeB_state = ITER_4;
                    cascade_finish = 1'b0;
                    reset_parameter = 1'b0;
                    frame_parameter_valid = 1'b0;
                    load_en = 1'b0;
                end
            end
            ITER_4_C_1: begin
                if (top_level_parity_correct) begin
                    next_cascadeB_state = ITER_4_C_2;
                    cascade_finish = 1'b0;
                    reset_parameter = 1'b0;
                    frame_parameter_valid = 1'b0;
                    load_en = 1'b0;
                end
                else if (Bkey_correction_done) begin
                    next_cascadeB_state = ITER_4_C_2;
                    cascade_finish = 1'b0;
                    reset_parameter = 1'b0;
                    frame_parameter_valid = 1'b0;
                    load_en = 1'b0;
                end
                else begin
                    next_cascadeB_state = ITER_4_C_1;
                    cascade_finish = 1'b0;
                    reset_parameter = 1'b0;
                    frame_parameter_valid = 1'b0;
                    load_en = 1'b0;
                end
            end
            ITER_4_C_2: begin
                if (top_level_parity_correct) begin
                    next_cascadeB_state = ITER_4_C_3;
                    cascade_finish = 1'b0;
                    reset_parameter = 1'b0;
                    frame_parameter_valid = 1'b0;
                    load_en = 1'b0;
                end
                else if (Bkey_correction_done) begin
                    next_cascadeB_state = ITER_4_C_1;
                    cascade_finish = 1'b0;
                    reset_parameter = 1'b0;
                    frame_parameter_valid = 1'b0;
                    load_en = 1'b0;
                end
                else begin
                    next_cascadeB_state = ITER_4_C_2;
                    cascade_finish = 1'b0;
                    reset_parameter = 1'b0;
                    frame_parameter_valid = 1'b0;
                    load_en = 1'b0;
                end
            end

            ITER_4_C_3: begin
                if (top_level_parity_correct) begin
                    next_cascadeB_state = ITER_4_C_4;
                    cascade_finish = 1'b0;
                    reset_parameter = 1'b0;
                    frame_parameter_valid = 1'b0;
                    load_en = 1'b0;
                end
                else if (Bkey_correction_done) begin
                    next_cascadeB_state = ITER_4_C_1;
                    cascade_finish = 1'b0;
                    reset_parameter = 1'b0;
                    frame_parameter_valid = 1'b0;
                    load_en = 1'b0;
                end
                else begin
                    next_cascadeB_state = ITER_4_C_3;
                    cascade_finish = 1'b0;
                    reset_parameter = 1'b0;
                    frame_parameter_valid = 1'b0;
                    load_en = 1'b0;
                end
            end

            ITER_4_C_4: begin
                if (top_level_parity_correct) begin
                    next_cascadeB_state = ITER_FINISH;
                    cascade_finish = 1'b0;
                    reset_parameter = 1'b0;
                    frame_parameter_valid = 1'b0;
                    load_en = 1'b0;
                end
                else if (Bkey_correction_done) begin
                    next_cascadeB_state = ITER_4_C_1;
                    cascade_finish = 1'b0;
                    reset_parameter = 1'b0;
                    frame_parameter_valid = 1'b0;
                    load_en = 1'b0;
                end
                else begin
                    next_cascadeB_state = ITER_4_C_4;
                    cascade_finish = 1'b0;
                    reset_parameter = 1'b0;
                    frame_parameter_valid = 1'b0;
                    load_en = 1'b0;
                end
            end

            ITER_FINISH: begin
                next_cascadeB_state = PARAMETER_OUT;
                cascade_finish = 1'b0;
                reset_parameter = 1'b0;
                frame_parameter_valid = 1'b0;
                load_en = 1'b0;
            end

            PARAMETER_OUT: begin
                cascade_finish = 1'b0;
                reset_parameter = 1'b0;
                frame_parameter_valid = 1'b1;
                load_en = 1'b0;
                next_cascadeB_state = RESET_PARAMETER;
            end
            RESET_PARAMETER: begin
                cascade_finish = 1'b0;
                reset_parameter = 1'b1;
                frame_parameter_valid = 1'b0;
                load_en = 1'b0;
                next_cascadeB_state = CASCADE_END;
            end
            CASCADE_END: begin
                cascade_finish = 1'b1;
                reset_parameter = 1'b0;
                frame_parameter_valid = 1'b0;
                load_en = 1'b0;
                next_cascadeB_state = CASCADE_IDLE;
            end
            default: begin
                next_cascadeB_state = CASCADE_IDLE;
                cascade_finish = 1'b0;
                reset_parameter = 1'b0;
                frame_parameter_valid = 1'b0;
                load_en = 1'b0;
            end

        endcase
    end





endmodule
