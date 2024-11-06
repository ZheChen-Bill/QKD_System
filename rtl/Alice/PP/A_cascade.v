
// `include "../packet_parameter.v"
// `include "../error_reconcilation_parameter.v"



module Alice_cascade (
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


    // Alice sifted key BRAM (input)
    // width = 64 , depth = 32768
    // port B
    output wire Asiftedkey_clkb,            
    output wire Asiftedkey_enb,             //1'b1
    output wire Asiftedkey_web,             //write enable , 1'b0
    output reg [14:0] Asiftedkey_addrb,    //0~32767
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
    input wire A_A2B_full,
    input wire A_A2B_wr_ack,






    output wire [`FRAME_LEAKED_INFO_WIDTH-1:0] frame_leaked_info,
    output wire [`FRAME_ERROR_COUNT_WIDTH-1:0] frame_error_count,
    output wire frame_parameter_valid,


    output cascade_finish,
    output [`CASCADE_KEY_LENGTH-1:0] corrected_key
);

    integer i;

//****************************** BRAM setup ******************************
    // Bob sifted key BRAM (input)
    // width = 64 , depth = 16384
    // port B
    assign Asiftedkey_clkb = clk;
    assign Asiftedkey_enb = 1'b1;
    assign Asiftedkey_web = 1'b0;
//****************************** BRAM setup ******************************
//****************************** FIFO setup ******************************
    // A2B ER FIFO (output)
    // width = 32 , depth = 2048
    //output wire A2B_wr_clk,
    assign A_A2B_wr_clk = clk;

    // B2A ER FIFO (input)
    // width = 32 , depth = 2048
    //output wire B2A_rd_clk,
    assign A_B2A_rd_clk = clk;
//****************************** FIFO setup ******************************

//****************************** DFF for bram output ******************************
    reg [`EV_W-1:0] Asiftedkey_doutb_ff;
    always @(posedge clk ) begin
        if (~rst_n) begin
            Asiftedkey_doutb_ff <= `EV_W'b0;
        end
        else begin
            Asiftedkey_doutb_ff <= Asiftedkey_doutb;
        end
    end
//****************************** DFF for bram output ******************************






//****************************** cascadeA fsm ******************************

    wire write_parity_done;
    assign write_parity_done = (reply_parity_cnt==(real_depth+3))? 1'b1:1'b0;
    wire loadkey_finish;
    wire first_top_level_parity_correct;
    assign first_top_level_parity_correct = ((top_level_error_count==0)&&(parity_type==`FIRST_TOP_PARITY_MESSAGE)&&(cascadeA_state>4));

    wire reset_parameter;
    wire shuffle_en;
    wire inv_shuffle_en;
    wire reply_en;
    wire read_header_en;
    wire write_header_en;
    wire load_en;

    wire [3:0] cascadeA_state;
    
    cascadeA_fsm cascadeFSM(
        .clk(clk),
        .rst_n(rst_n),

        .A_B2A_rd_valid(A_B2A_rd_valid),
        .write_parity_done(write_parity_done),
        .start_cascade_error_correction(start_cascade_error_correction),
        .loadkey_finish(loadkey_finish),
        .first_top_level_parity_correct(first_top_level_parity_correct),

        .read_header_en(read_header_en),
        .shuffle_en(shuffle_en),
        .inv_shuffle_en(inv_shuffle_en),
        .reply_en(reply_en),
        .reset_parameter(reset_parameter),
        .write_header_en(write_header_en),
        .load_en(load_en),
        .frame_parameter_valid(frame_parameter_valid),
        .cascade_finish(cascade_finish),
        .cascadeA_state(cascadeA_state)
    );

//****************************** cascadeA fsm ******************************





//****************************** corrected key ******************************

    reg [31:0] loading_key;
    reg [`CASCADE_KEY_32_DEPTH-1:0] loading_key_sel;
    wire [2:0] shuffle_set_sel;

    //wire shuffle_en;
    //wire inv_shuffle_en;
    

    wire [63:0]corrected_key_MSB64;
    wire [63:0]corrected_key_LSB64;
    assign corrected_key_MSB64 = corrected_key[`CASCADE_KEY_LENGTH-1:`CASCADE_KEY_LENGTH-64];
    assign corrected_key_LSB64 = corrected_key[63:0];

    correct_key_32 Acorrectkey(
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





//****************************** loading sifted key ******************************
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
        Asiftedkey_addrb = {sifted_key_addr_index, frame_round, loading_counter[`SIFTED_KEY_64_WIDTH:1]};
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
        else begin
            loading_key_sel = 0;
        end
    end


    always @(*) begin
        if (sifted_key_en && (~loading_counter[0])) begin
            loading_key = Asiftedkey_doutb_ff[63:32];
        end
        else if (sifted_key_en && (loading_counter[0])) begin
            loading_key = Asiftedkey_doutb_ff[31:0];
        end
        else begin
            loading_key = 32'b0;
        end
    end


//****************************** loading sifted key ******************************
 



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





//****************************** read header ******************************
    // B2A header
    reg [31:0] header_B2A_ff;

    always @(posedge clk ) begin
        if (~rst_n)begin
            header_B2A_ff <= 32'b0;
        end
        else if (read_header_en) begin
            header_B2A_ff <= A_B2A_rd_dout;
        end
        else if (reset_parameter) begin
            header_B2A_ff <= 32'b0;
        end
        else begin
            header_B2A_ff <= header_B2A_ff;
        end
    end


 
    // real depth
    reg [10:0] real_depth;
    wire [`PACKET_LENGTH_WIDTH-1:0] packet_depth;
    assign packet_depth = header_B2A_ff[27:24];

    always @(*) begin
        if (packet_depth==`PACKET_LENGTH_257) begin
            real_depth = {2'b0,header_B2A_ff[23:15]};
        end
        else if (packet_depth==`PACKET_LENGTH_514) begin
            real_depth = 11'd512;
        end
        else if (packet_depth==`PACKET_LENGTH_771) begin
            real_depth = 11'd768;
        end
        else if (packet_depth==`PACKET_LENGTH_1028) begin
            real_depth = 11'd1024;
        end
        else begin
            real_depth = 11'd1024;
        end
    end



    wire [`PARITY_TREE_ROW_INDEX_WIDTH-1:0] parity_tree_row;
    wire [`PARITY_TYPE_WIDTH-1:0] parity_type;

    // shuffle set
    assign shuffle_set_sel = header_B2A_ff[11:9];
    // parity tree row
    assign parity_tree_row = header_B2A_ff[8:5];
    // top parity type
    assign parity_type = header_B2A_ff[14:12];


//****************************** read header ******************************





//****************************** reply parity ******************************
    reg [15:0] reply_parity_cnt;
    always @(posedge clk ) begin
        if (~rst_n) begin
            reply_parity_cnt <= 16'b0;
        end
        else if (reply_en) begin
            reply_parity_cnt  <= reply_parity_cnt + 1;
        end
        else if (reset_parameter) begin
            reply_parity_cnt  <= 16'b0;
        end
        else begin
            reply_parity_cnt <= reply_parity_cnt;
        end
    end


    assign A_B2A_rd_en = ( reply_rd_en||read_header_en)? 1'b1:1'b0;
    wire reply_rd_en;
    assign reply_rd_en = (reply_parity_cnt>0)&&(reply_parity_cnt<(real_depth+1))? 1'b1:1'b0;
//****************************** reply parity ******************************





//****************************** write A2B FIFO ******************************

    always @(posedge clk ) begin
        if (~rst_n) begin
            A_A2B_wr_din <= 32'b0;
            A_A2B_wr_en <= 1'b0;
        end
        else if (write_header_en | (write_parity_done&(parity_type[2]))) begin
            A_A2B_wr_din <= header_A2B;
            A_A2B_wr_en <= 1'b1;
        end
        else if (parity_type[2] & reply_rd_en) begin
            A_A2B_wr_din <= A_correct_parity;
            A_A2B_wr_en <= 1'b1;
        end
        else if (reply_rd_en) begin
            A_A2B_wr_din <= Acorrect_and_Bask_parity;
            A_A2B_wr_en <= 1'b1;
        end
        else begin
            A_A2B_wr_din <= 32'b0;
            A_A2B_wr_en <= 1'b0;
        end
    end


    reg [31:0] header_A2B;
    always @(*) begin
        if (parity_type[2] & write_header_en) begin
            header_A2B[31:28] = `A2B_CORRECT_PARITY;
            header_A2B[27:24] = header_B2A_ff[27:24];
            header_A2B[23:15] = (header_B2A_ff[23:15]+1);
            header_A2B[14:12] = `TOP_PARITY_COMPARE;
            header_A2B[11:9]  = header_B2A_ff[11:9];
            header_A2B[8:5]   = header_B2A_ff[8:5];
            header_A2B[4:0]   = header_B2A_ff[4:0];
        end
        else if ( write_parity_done && (top_level_error_count==0)&&(parity_type[2])) begin //????
            header_A2B[31:28] = `A2B_CORRECT_PARITY;
            header_A2B[27:24] = `PACKET_LENGTH_257;
            header_A2B[23:15] = `RECONCILIATION_REAL_PACKET_DEPTH_WIDTH'b0;
            header_A2B[14:12] = `TOP_PARITY_CORRECT;
            header_A2B[11:9]  = header_B2A_ff[11:9];
            header_A2B[8:5]   = header_B2A_ff[8:5];
            header_A2B[4:0]   = header_B2A_ff[4:0];
        end
        else if ( write_parity_done && (parity_type[2])) begin
            header_A2B[31:28] = `A2B_CORRECT_PARITY;
            header_A2B[27:24] = header_B2A_ff[27:24];
            header_A2B[23:15] = header_B2A_ff[23:15];
            header_A2B[14:12] = `TOP_PARITY_MESSAGE;
            header_A2B[11:9]  = header_B2A_ff[11:9];
            header_A2B[8:5]   = header_B2A_ff[8:5];
            header_A2B[4:0]   = header_B2A_ff[4:0];
        end
        else begin
            header_A2B[31:28] = `A2B_CORRECT_PARITY;
            header_A2B[27:24] = header_B2A_ff[27:24];
            header_A2B[23:15] = header_B2A_ff[23:15];
            header_A2B[14:12] = `NORMAL_PARITY;
            header_A2B[11:9]  = header_B2A_ff[11:9];
            header_A2B[8:5]   = header_B2A_ff[8:5];
            header_A2B[4:0]   = header_B2A_ff[4:0];
        end
    end


    



    reg [31:0] A_correct_parity;
    always @(*) begin
        if (reply_rd_en) begin
            A_correct_parity = parity_tree[parity_tree_row-1][(`CASCADE_KEY_LENGTH-((reply_parity_cnt)<<5)) +:32];
        end
        else begin
            A_correct_parity = 32'b0;
        end
    end

    reg [31:0] A_correct_parity_delay;
    reg [31:0] A_B2A_rd_dout_delay;
    always @(posedge clk) begin
            A_correct_parity_delay <= A_correct_parity;
            A_B2A_rd_dout_delay <= A_B2A_rd_dout;
    end
    
    wire [31:0] Acorrect_and_Bask_parity;
    assign Acorrect_and_Bask_parity = A_correct_parity & A_B2A_rd_dout;

    wire [31:0] Acorrect_xor_Bask_parity; //delay by 1 cycle, all combination logic should delay by 1
//    assign Acorrect_xor_Bask_parity = A_correct_parity ^ A_B2A_rd_dout;
    assign Acorrect_xor_Bask_parity = A_correct_parity_delay ^ A_B2A_rd_dout_delay;

//****************************** write A2B FIFO ******************************





//****************************** error count ******************************

    assign frame_error_count = total_error_count;
    reg [`FRAME_ERROR_COUNT_WIDTH-1:0] total_error_count;
    reg [`FRAME_ERROR_COUNT_WIDTH-1:0] top_level_error_count;

    reg [5:0] ones;
    integer idx;
    always @(*) begin
        ones = 0;
        for(idx=0;idx<32;idx=idx+1)   //for all the bits.
            ones = ones + Acorrect_xor_Bask_parity[idx]; //Add the bit to the count.
    end


    wire count_error_en;
//    assign count_error_en = ((reply_parity_cnt>0)&&(reply_parity_cnt<(real_depth+1))&&(parity_type[2]))? 1'b1:1'b0;
    assign count_error_en = ((reply_parity_cnt>1)&&(reply_parity_cnt<(real_depth+2))&&(parity_type[2]))? 1'b1:1'b0;

    always @(posedge clk ) begin
        if (~rst_n) begin
            top_level_error_count <= `FRAME_ERROR_COUNT_WIDTH'b0;
        end
        else if (reset_parameter) begin
            top_level_error_count <= `FRAME_ERROR_COUNT_WIDTH'b0;
        end
        else if (count_error_en) begin
             top_level_error_count <= top_level_error_count + ones;
        end
        else begin
            top_level_error_count <= top_level_error_count;
        end
    end

    wire top_level_parameter_update;

//    assign top_level_parameter_update = ((parity_type[2])&&(reply_parity_cnt==(real_depth+2)))? 1'b1:1'b0;
    assign top_level_parameter_update = ((parity_type[2])&&(reply_parity_cnt==(real_depth+3)))? 1'b1:1'b0;
    always @(posedge clk ) begin
        if (~rst_n) begin
            total_error_count <= `FRAME_ERROR_COUNT_WIDTH'b0;
        end
        else if (top_level_parameter_update) begin
            total_error_count <= total_error_count + top_level_error_count;
        end
        else if (cascade_finish) begin
            total_error_count <= `FRAME_ERROR_COUNT_WIDTH'b0;
        end
        else begin
            total_error_count <= total_error_count;
        end
    end
//****************************** error count ******************************



//****************************** leaked info ******************************
    reg [`FRAME_LEAKED_INFO_WIDTH-1:0] total_leaked_info;
    assign frame_leaked_info = total_leaked_info;
    //reg [14:0] top_level_leaked_info;


    always @(posedge clk ) begin
        if (~rst_n) begin
            total_leaked_info <= `FRAME_LEAKED_INFO_WIDTH'b0;
        end
        else if (top_level_parameter_update && (top_level_error_count==0)&&(parity_type==`FIRST_TOP_PARITY_MESSAGE)) begin
                case (shuffle_set_sel)
                    `RECONCILIATION_SHUFFLE_SET_1 : begin
                        total_leaked_info <= total_leaked_info + (`CASCADE_KEY_LENGTH>>(parity_tree_row-1));
                    end
                    `RECONCILIATION_SHUFFLE_SET_2 : begin
                        total_leaked_info <= total_leaked_info 
                                            + (`CASCADE_KEY_LENGTH>>(parity_tree_row-1))
                                            + (`CASCADE_KEY_LENGTH>>(parity_tree_row-2));
                    end
                    `RECONCILIATION_SHUFFLE_SET_3 : begin
                        total_leaked_info <= total_leaked_info 
                                            + (`CASCADE_KEY_LENGTH>>(parity_tree_row-1))
                                            + (`CASCADE_KEY_LENGTH>>(parity_tree_row-2))
                                            + (`CASCADE_KEY_LENGTH>>(parity_tree_row-3));
                    end
                    `RECONCILIATION_SHUFFLE_SET_4 : begin
                        total_leaked_info <= total_leaked_info 
                                            + (`CASCADE_KEY_LENGTH>>(parity_tree_row-1))
                                            + (`CASCADE_KEY_LENGTH>>(parity_tree_row-2))
                                            + (`CASCADE_KEY_LENGTH>>(parity_tree_row-3))
                                            + (`CASCADE_KEY_LENGTH>>(parity_tree_row-4));
                    end
                    default: total_leaked_info <= total_leaked_info;
                endcase
        end
        else if (top_level_parameter_update) begin
            total_leaked_info <= total_leaked_info + top_level_error_count*(parity_tree_row-1);
        end
        else if (cascade_finish) begin
            total_leaked_info <= `FRAME_LEAKED_INFO_WIDTH'b0;
        end
        else begin
            total_leaked_info <= total_leaked_info;
        end
    end






//****************************** leaked info ******************************





endmodule



















module cascadeA_fsm (
    input clk,
    input rst_n,

    
    input start_cascade_error_correction,
    input loadkey_finish,
    input A_B2A_rd_valid,
    input write_parity_done,
    input first_top_level_parity_correct,

    
    output wire load_en,
    output reg write_header_en,

    output reg shuffle_en,
    output reg inv_shuffle_en,
    output reg reply_en,
    output reg reset_parameter,
    output reg read_header_en,
    output reg cascade_finish,
    output reg frame_parameter_valid,
    output reg [3:0] cascadeA_state

);

    localparam CASCADE_IDLE         = 4'd13;
    localparam LOADKEY              = 4'd14;
    localparam IDLE                 = 4'd15;
    localparam READ_HEADER          = 4'd1;
    localparam SET_PARAMETER        = 4'd2;
    localparam SHUFFLE              = 4'd3;
    localparam REPLY_PARITY         = 4'd4;
    localparam WRITE_DONE           = 4'd5;
    localparam INV_SHUFFLE          = 4'd6;
    localparam DELAY = 4'd10; // add new FSM for the timing slack of XOR
    localparam FINISH               = 4'd7;
    localparam PARAMETER_OUT        = 4'd8;
    localparam CASCADE_END          = 4'd9;


    reg [3:0] next_cascadeA_state;
    always @(posedge clk ) begin
        if (~rst_n) begin
            cascadeA_state <= CASCADE_IDLE;
        end
        else begin
            cascadeA_state <= next_cascadeA_state;
        end
    end

    reg frame_parameter_valid_next;
    always @(posedge clk ) begin
        if (~rst_n) begin
            frame_parameter_valid <= 1'b0;
        end
        else begin
            frame_parameter_valid <= frame_parameter_valid_next;
        end
    end

    always @(*) begin
        case (cascadeA_state)
            CASCADE_IDLE: begin
                if (start_cascade_error_correction) begin
                    frame_parameter_valid_next = 1'b0;
                end
                else begin
                    frame_parameter_valid_next = 1'b0;
                end
            end
            LOADKEY: begin
                if (loadkey_finish) begin
                    frame_parameter_valid_next = 1'b0;
                end
                else begin
                    frame_parameter_valid_next = 1'b0;
                end
            end


            IDLE: begin
                if (A_B2A_rd_valid) begin
                    frame_parameter_valid_next = 1'b0;
                end
                else begin
                    frame_parameter_valid_next = 1'b0;
                end
            end
            READ_HEADER: begin
                frame_parameter_valid_next = 1'b0;
            end

            SET_PARAMETER: begin
                frame_parameter_valid_next = 1'b0;
            end

            SHUFFLE: begin
                frame_parameter_valid_next = 1'b0;
            end

            REPLY_PARITY: begin
                if (write_parity_done) begin
                    frame_parameter_valid_next = 1'b0;
                end
                else begin
                    frame_parameter_valid_next = 1'b0;
                end
            end

            WRITE_DONE: begin
                frame_parameter_valid_next = 1'b0;
            end


            INV_SHUFFLE: begin
                frame_parameter_valid_next = 1'b0;
            end
            
            DELAY: begin
                frame_parameter_valid_next = 1'b0;
            end
            
            FINISH: begin
                if (first_top_level_parity_correct) begin
                    frame_parameter_valid_next = 1'b1;
                end
                else begin
                    frame_parameter_valid_next = 1'b0;
                end
            end

            PARAMETER_OUT: begin
                frame_parameter_valid_next = 1'b0;
            end

            CASCADE_END: begin
                frame_parameter_valid_next = 1'b0;
            end

            default: begin
                frame_parameter_valid_next = 1'b0;
            end
        endcase
    end

    always @(posedge clk ) begin
        if (~rst_n) begin
            write_header_en <= 1'b0;
        end
        else if ((next_cascadeA_state==REPLY_PARITY)&&(cascadeA_state==SHUFFLE)) begin
            write_header_en <= 1'b1;
        end
        else begin
            write_header_en <= 1'b0;
        end
    end

    assign load_en = (cascadeA_state==LOADKEY);
    

    always @(*) begin
        case (cascadeA_state)
            CASCADE_IDLE: begin
                if (start_cascade_error_correction) begin
                    next_cascadeA_state = LOADKEY;
                    read_header_en = 1'b0;
                    shuffle_en = 1'b0;
                    inv_shuffle_en = 1'b0;
                    reply_en = 1'b0;
                    reset_parameter = 1'b0;
                    cascade_finish = 1'b0;
//                    frame_parameter_valid = 1'b0;
                end
                else begin
                    next_cascadeA_state = CASCADE_IDLE;
                    read_header_en = 1'b0;
                    shuffle_en = 1'b0;
                    inv_shuffle_en = 1'b0;
                    reply_en = 1'b0;
                    reset_parameter = 1'b0;
                    cascade_finish = 1'b0;
//                    frame_parameter_valid = 1'b0;
                end
            end
            LOADKEY: begin
                if (loadkey_finish) begin
                    next_cascadeA_state = IDLE;
                    read_header_en = 1'b0;
                    shuffle_en = 1'b0;
                    inv_shuffle_en = 1'b0;
                    reply_en = 1'b0;
                    reset_parameter = 1'b0;
                    cascade_finish = 1'b0;
//                    frame_parameter_valid = 1'b0;
                end
                else begin
                    next_cascadeA_state = LOADKEY;
                    read_header_en = 1'b0;
                    shuffle_en = 1'b0;
                    inv_shuffle_en = 1'b0;
                    reply_en = 1'b0;
                    reset_parameter = 1'b0;
                    cascade_finish = 1'b0;
//                    frame_parameter_valid = 1'b0;
                end
            end


            IDLE: begin
                if (A_B2A_rd_valid) begin
                    next_cascadeA_state = READ_HEADER;
                    read_header_en = 1'b0;
                    shuffle_en = 1'b0;
                    inv_shuffle_en = 1'b0;
                    reply_en = 1'b0;
                    reset_parameter = 1'b0;
                    cascade_finish = 1'b0;
//                    frame_parameter_valid = 1'b0;
                end
                else begin
                    next_cascadeA_state = IDLE;
                    read_header_en = 1'b0;
                    shuffle_en = 1'b0;
                    inv_shuffle_en = 1'b0;
                    reply_en = 1'b0;
                    reset_parameter = 1'b0;
                    cascade_finish = 1'b0;
//                    frame_parameter_valid = 1'b0;
                end
            end
            READ_HEADER: begin
                next_cascadeA_state = SET_PARAMETER;
                read_header_en = 1'b1;
                shuffle_en = 1'b0;
                inv_shuffle_en = 1'b0;
                reply_en = 1'b0;
                reset_parameter = 1'b0;
                cascade_finish = 1'b0;
//                frame_parameter_valid = 1'b0;
            end

            SET_PARAMETER: begin
                next_cascadeA_state = SHUFFLE;
                read_header_en = 1'b0;
                shuffle_en = 1'b0;
                inv_shuffle_en = 1'b0;
                reply_en = 1'b0;
                reset_parameter = 1'b0;
                cascade_finish = 1'b0;
//                frame_parameter_valid = 1'b0;
            end

            SHUFFLE: begin
                next_cascadeA_state = REPLY_PARITY;
                read_header_en = 1'b0;
                shuffle_en = 1'b1;
                inv_shuffle_en = 1'b0;
                reply_en = 1'b0;
                reset_parameter = 1'b0;
                cascade_finish = 1'b0;
//                frame_parameter_valid = 1'b0;
            end

            REPLY_PARITY: begin
                if (write_parity_done) begin
                    next_cascadeA_state = WRITE_DONE;
                    read_header_en = 1'b0;
                    shuffle_en = 1'b0;
                    inv_shuffle_en = 1'b0;
                    reply_en = 1'b1;
                    reset_parameter = 1'b0;
                    cascade_finish = 1'b0;
//                    frame_parameter_valid = 1'b0;
                end
                else begin
                    next_cascadeA_state = REPLY_PARITY;
                    read_header_en = 1'b0;
                    shuffle_en = 1'b0;
                    inv_shuffle_en = 1'b0;
                    reply_en = 1'b1;
                    reset_parameter = 1'b0;
                    cascade_finish = 1'b0;
//                    frame_parameter_valid = 1'b0;
                end
            end

            WRITE_DONE: begin
                next_cascadeA_state = INV_SHUFFLE;
                read_header_en = 1'b0;
                shuffle_en = 1'b0;
                inv_shuffle_en = 1'b0;
                reply_en = 1'b0;
                reset_parameter = 1'b0;
                cascade_finish = 1'b0;
//                frame_parameter_valid = 1'b0;
            end


            INV_SHUFFLE: begin
                next_cascadeA_state = DELAY;
                read_header_en = 1'b0;
                shuffle_en = 1'b0;
                inv_shuffle_en = 1'b1;
                reply_en = 1'b0;
                reset_parameter = 1'b0;
                cascade_finish = 1'b0;
//                frame_parameter_valid = 1'b0;
            end

            DELAY: begin
                next_cascadeA_state = FINISH;
                read_header_en = 1'b0;
                shuffle_en = 1'b0;
                inv_shuffle_en = 1'b0;
                reply_en = 1'b0;
                reset_parameter = 1'b0;
                cascade_finish = 1'b0;
//                frame_parameter_valid = 1'b0;
            end

            FINISH: begin
                if (first_top_level_parity_correct) begin
                    next_cascadeA_state = PARAMETER_OUT;
                    read_header_en = 1'b0;
                    shuffle_en = 1'b0;
                    inv_shuffle_en = 1'b0;
                    reply_en = 1'b0;
                    reset_parameter = 1'b1;
                    cascade_finish = 1'b0;
//                    frame_parameter_valid = 1'b0;
                end
                else begin
                    next_cascadeA_state = IDLE;
                    read_header_en = 1'b0;
                    shuffle_en = 1'b0;
                    inv_shuffle_en = 1'b0;
                    reply_en = 1'b0;
                    reset_parameter = 1'b1;
                    cascade_finish = 1'b0;
//                    frame_parameter_valid = 1'b0;
                end
            end


            PARAMETER_OUT: begin
                next_cascadeA_state = CASCADE_END;
                read_header_en = 1'b0;
                shuffle_en = 1'b0;
                inv_shuffle_en = 1'b0;
                reply_en = 1'b0;
                reset_parameter = 1'b0;
                cascade_finish = 1'b0;
//                frame_parameter_valid = 1'b1;
            end

            CASCADE_END: begin
                next_cascadeA_state = CASCADE_IDLE;
                read_header_en = 1'b0;
                shuffle_en = 1'b0;
                inv_shuffle_en = 1'b0;
                reply_en = 1'b0;
                reset_parameter = 1'b0;
                cascade_finish = 1'b1;
//                frame_parameter_valid = 1'b0;
            end


            default: begin
                next_cascadeA_state = CASCADE_IDLE;
                read_header_en = 1'b0;
                shuffle_en = 1'b0;
                inv_shuffle_en = 1'b0;
                reply_en = 1'b0;
                reset_parameter = 1'b0;
                cascade_finish = 1'b0;
//                frame_parameter_valid = 1'b0;
            end
        endcase
    end



endmodule





