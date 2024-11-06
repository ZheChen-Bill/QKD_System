




module top_ev (
    input clk,                                      //clk
    input rst_n,                                    //reset


    
    input [`EV_KEY_LENGTH-1:0] corrected_key,       //corrected key (no shuffle)
    input start_hash,                               //start to compute hash tag

    output reg [`EV_HASHTAG_WIDTH-1:0] target_hashtag_ff,  //hash tag target
                                                    //computed from corrected key & EV random bit
    output hashtag_valid,                           //hash tag is valid


    input [`FRAME_ROUND_WIDTH-1:0] frame_round,


    //EV random bit BRAM
    // width = 64 , depth = 16384
    // port B
    input wire [63:0] EVrandombit_doutb,            //EV random bit from AXI manager
    output reg [13:0] EVrandombit_addrb,            //0~16383
    output wire EVrandombit_clkb,
    output wire EVrandombit_enb,                    //1'b1
    output wire EVrandombit_rstb,                   //1'b0
    output wire [7:0] EVrandombit_web              //8'b0


);


//****************************** BRAM setup ******************************

    /* EV random bit BRAM set up
    output wire EVrandombit_clkb,
    output wire EVrandombit_enb,            //1'b1
    output wire EVrandombit_rstb,           //~rst_n
    output wire [7:0] EVrandombit_web,      //8'b0
    */
    assign EVrandombit_clkb = clk;
    assign EVrandombit_enb = 1'b1;
    assign EVrandombit_web = 8'b0;
    assign EVrandombit_rstb = rst_n;

//****************************** BRAM setup ******************************

//****************************** DFF for bram output ******************************
    reg [`EV_W-1:0] randombit_out_ff;

    always @(posedge clk ) begin
        if (~rst_n) begin
            randombit_out_ff <= `EV_W'b0;
        end
        else begin
            randombit_out_ff <= EVrandombit_doutb;
        end
    end
//****************************** DFF for bram output ******************************


//****************************** parameter ******************************
    //start compute delay dff
    reg start_compute_delay;
    always @(posedge clk ) begin
        if (~rst_n) begin
            start_compute_delay <= 1'b0;
        end
        else begin
            start_compute_delay <= start_hash;
        end
    end


    wire hashtag_finish;
    

    //computing_busy
    reg computing_busy;
    always @(posedge clk ) begin
        if (~rst_n) begin
            computing_busy <= 1'b0;
        end
        else begin
            if (start_hash) begin
                computing_busy <= 1'b1;
            end
            else if(hashtag_finish) begin
                computing_busy <= 1'b0;
            end
            else begin
                computing_busy <= computing_busy;
            end
        end
    end
//****************************** parameter ******************************



//****************************** cycle_counter ******************************
    reg [15:0] cycle_counter;

    // count for each round
    always @(posedge clk ) begin
        if (~rst_n) begin
            cycle_counter <= 0;
        end
        else begin
            if (start_compute_delay) begin
                cycle_counter <= 0; 
            end
            else if (hashtag_finish) begin
                cycle_counter <= 0;
            end
            else if (computing_busy) begin
                cycle_counter <= cycle_counter + 1;
            end
            else begin
                cycle_counter <= cycle_counter;
            end
        end
    end


//****************************** cycle_counter ******************************





//****************************** address for key & random bit ******************************
    // corrected key 32768-bit
    //input [`EV_KEY_LENGTH-1:0] corrected_key,       corrected key (no shuffle)
    reg [`EV_W-1:0] corrected_key_ff;       //corrected key for toeplitz hash input

    wire [31:0] corrected_key_idx;
    assign corrected_key_idx = (((`RANDOM_BIT_64_DEPTH+4)-cycle_counter)<<6);

    always @(posedge clk ) begin
        if (~rst_n) begin
            corrected_key_ff <= `EV_W'b0;
        end
        else begin
            if ((cycle_counter>4) && (cycle_counter<(`RANDOM_BIT_64_DEPTH+5))) begin
                corrected_key_ff <= corrected_key[corrected_key_idx +: 64];
            end
            else begin
                corrected_key_ff <= `EV_W'b0;
            end
        end
    end



    wire [7:0] addr_255; //0~255
    assign addr_255 = (cycle_counter[7:0] - 1);


    // random bit 16384-bit
    always @(posedge clk ) begin
        if (~rst_n) begin
            EVrandombit_addrb <= 0;
        end
        else begin
            if (hashtag_finish) begin
                EVrandombit_addrb <= 0;
            end

            else if ((cycle_counter==(`RANDOM_BIT_64_DEPTH+1)))begin
                EVrandombit_addrb <= EVrandombit_addrb;
            end


            else if ((cycle_counter>0) && (cycle_counter<(`RANDOM_BIT_64_DEPTH+1)))begin
                EVrandombit_addrb <= {frame_round , addr_255};
            end

            else begin
                EVrandombit_addrb <= 0;
            end
        end
    end

//****************************** address for key & random bit ******************************


//****************************** toeplitz hashing instantiation ******************************
    //toeplitz_hashing input
    wire [`EV_W-1:0] ev_rb_in;
    wire [`EV_W-1:0] ev_key_in;
    wire ev_rb_shift_en;
    wire ev_key_en;

    assign ev_rb_shift_en = ((cycle_counter>3) && (cycle_counter<(`RANDOM_BIT_64_DEPTH+5)))? 1'b1:1'b0;
    assign ev_key_en = ((cycle_counter>5) && (cycle_counter<(`RANDOM_BIT_64_DEPTH+6)))? 1'b1:1'b0;


    assign ev_key_in = (ev_key_en)? corrected_key_ff:`EV_W'b0;
    assign ev_rb_in = (ev_rb_shift_en)? randombit_out_ff:`EV_W'b0;





    //toeplitz_hashing output
    wire [`EV_HASHTAG_WIDTH-1:0] target_hashtag;


    ev_toeplitz_hashing ev_hash(
        .clk(clk),                                          //clk
        .rst_n(rst_n),                                      //reset

        .random_bit(ev_rb_in),              //random bit(0 or 1) series for hashing 
        .key_bit(ev_key_in),                 //reconciliation key
        .shift_en(ev_rb_shift_en),                         //shift control
        .key_en(ev_key_en),                           //key control

        .hash_tag(target_hashtag)      //output hash tag for error verification

    );




    //hash tag output DFF

    always @(posedge clk ) begin
        if (~rst_n) begin
            target_hashtag_ff <= `EV_HASHTAG_WIDTH'b0;
        end
        else if (cycle_counter==(`RANDOM_BIT_64_DEPTH+6)) begin
            target_hashtag_ff <= target_hashtag;
        end
        else begin
            target_hashtag_ff <= target_hashtag_ff;
        end
    end

    //hash tag valid and finish
    assign hashtag_finish = (cycle_counter==(`RANDOM_BIT_64_DEPTH+7))? 1'b1:1'b0;
    assign hashtag_valid = hashtag_finish;

//****************************** toeplitz hashing instantiation ******************************








endmodule