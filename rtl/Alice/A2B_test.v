


// `include "./error_reconcilation_parameter.v"
// `include "./packet_parameter.v"


module A2B_test (
    input clk,


    input rst_n,



    input reset_er_parameter,
    output EVrandombit_full,

    
    // A_A2B fifo
    output wire A_A2B_rd_clk,
    output wire A_A2B_rd_en,
    input wire [31:0] A_A2B_rd_dout,
    input wire A_A2B_empty,
    input wire A_A2B_rd_valid,

    // B_A2B fifo
    output wire B_A2B_ER_wr_clk,
    output wire [31:0] B_A2B_ER_wr_din,
    output wire B_A2B_ER_wr_en,
    input wire B_A2B_ER_full,
    input wire B_A2B_ER_wr_ack,



    // B_A2B random bit bram
    output reg [13:0] B_RX_EVrandombit_addra,
    output wire B_RX_EVrandombit_clka,
    output wire [63:0] B_RX_EVrandombit_dina,
    output wire B_RX_EVrandombit_ena,
    output wire [7:0] B_RX_EVrandombit_wea,



    output [3:0] A2B_state

);




    reg [31:0] randombit_bram_cnt;
    always @(posedge clk ) begin
        if (~rst_n) begin
            randombit_bram_cnt <= 32'b0;
        end
        else if (reset_er_parameter) begin
            randombit_bram_cnt <= 32'b0;
        end
        else if (reset_parameter && (bram_packet_type==`A2B_EV_RANDOMBIT)) begin
            randombit_bram_cnt <= randombit_bram_cnt + 1;
        end
        else begin
            randombit_bram_cnt <= randombit_bram_cnt;
        end
    end
    assign EVrandombit_full = (randombit_bram_cnt==32);





//****************************** FIFO setup ******************************

    // B_A2B fifo
    wire [31:0] B_A2B_wr_din;
    wire B_A2B_wr_en;
    //wire B_A2B_full;
    //wire B_A2B_wr_ack;

    assign B_A2B_ER_wr_clk = clk;
    assign A_A2B_rd_clk = clk;

//****************************** FIFO setup ******************************
//****************************** BRAM setup ******************************
    assign B_RX_EVrandombit_clka = clk;
    assign B_RX_EVrandombit_ena = 1'b1;
//****************************** BRAM setup ******************************



//****************************** A2B fsm ******************************

    wire read_header_en;
    wire reset_parameter;
    wire write_bram_en;
    wire read_bram_en;
    wire read_bram_header;

    //wire setting_done;
    wire write_bram_done;
    
    wire read_bram_done;
    

    A2B_fsm A2B_FSM(
        .clk(clk),
        .rst_n(rst_n),

        .A_A2B_rd_valid(A_A2B_rd_valid),
        //.setting_done(setting_done),
        .write_bram_done(write_bram_done),
        .read_bram_done(read_bram_done),

        .reset_parameter(reset_parameter),
        .read_header_en(read_header_en),
        .write_bram_en(write_bram_en),
        .read_bram_en(read_bram_en),
        .read_bram_header(read_bram_header),
        .A2B_state(A2B_state)
    );
//****************************** A2B fsm ******************************





//****************************** parameter ******************************
 

    reg [10:0] real_depth;
    wire [`PACKET_LENGTH_WIDTH-1:0] packet_depth;
    assign packet_depth = header_ff[27:24];

    always @(*) begin
        if (packet_depth==`PACKET_LENGTH_257) begin
            real_depth = header_ff[23:15];
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


    wire [`PARITY_TYPE_WIDTH-1:0] parity_type;
    assign parity_type = header_ff[14:12];
    wire top_level_indicator;
    assign top_level_indicator = parity_type[2];

    reg [31:0] header_ff;

    always @(posedge clk ) begin
        if (~rst_n)begin
            header_ff <= 32'b0;
        end
        else if (read_header_en) begin
            header_ff <= A_A2B_rd_dout;
        end
        else if (reset_parameter) begin
            header_ff <= 32'b0;
        end
        else begin
            header_ff <= header_ff;
        end
    end

//****************************** parameter ******************************





//****************************** write to BRAM ******************************
    reg [10:0] write_bram_cnt;
    always @(posedge clk ) begin
        if (~rst_n) begin
            write_bram_cnt <= 11'b0;
        end
        else if (write_bram_en) begin
            write_bram_cnt <= write_bram_cnt + 1;
        end
        else if (reset_parameter) begin
            write_bram_cnt <= 11'b0;
        end
        else begin
            write_bram_cnt <= write_bram_cnt;
        end
    end

    assign write_bram_done = (write_bram_cnt==(real_depth+5))? 1'b1:1'b0;

    assign A_A2B_rd_en = ((write_bram_cnt>0)&&(write_bram_cnt<(real_depth+2)))? 1'b1:1'b0;


    reg wea;
    reg [10:0] addra;
    reg [31:0] dina;

    always @(posedge clk ) begin
        if (~rst_n) begin
            addra <= 11'b0;
            wea <= 1'b0;
            dina <= 32'b0;
        end
        else if (A_A2B_rd_en&&top_level_indicator&&(write_bram_cnt==(real_depth+1))) begin
            addra <= 0;
            wea <= 1'b1;
            dina <= A_A2B_rd_dout;
        end
        else if (A_A2B_rd_en) begin
            addra <= write_bram_cnt-1;
            wea <= 1'b1;
            dina <= A_A2B_rd_dout;
        end
        else begin
            addra <= 11'b0;
            wea <= 1'b0;
            dina <= 32'b0;
        end
    end
//****************************** write to BRAM ******************************






//****************************** read from BRAM ******************************

    reg [10:0] read_bram_cnt;
    always @(posedge clk ) begin
        if (~rst_n) begin
            read_bram_cnt <= 11'b0;
        end
        else if (reset_parameter) begin
            read_bram_cnt <= 11'b0;
        end
        else if (read_bram_en) begin
            read_bram_cnt <= read_bram_cnt + 1;
        end
        else begin
            read_bram_cnt <= read_bram_cnt;
        end
    end















    assign read_bram_done = (read_bram_cnt==(bram_real_depth+9))? 1'b1:1'b0;

    reg [31:0] bram_header_ff;
    
    always @(posedge clk ) begin
        if (~rst_n)begin
            bram_header_ff <= 32'b0;
        end
        else if (read_bram_cnt==1) begin
            bram_header_ff <= doutb_ff;
        end
        else if (reset_parameter) begin
            bram_header_ff <= 32'b0;
        end
        else begin
            bram_header_ff <= bram_header_ff;
        end
    end

    reg [10:0] bram_real_depth;

    wire [`PACKET_LENGTH_WIDTH-1:0] bram_packet_depth;
    assign bram_packet_depth = bram_header_ff[27:24];

    wire [`PACKET_TYPE_WIDTH-1:0] bram_packet_type;
    assign bram_packet_type = bram_header_ff[31:28];

    always @(*) begin
        if (bram_packet_depth==`PACKET_LENGTH_257) begin
            bram_real_depth = bram_header_ff[23:15];
        end
        else if (bram_packet_depth==`PACKET_LENGTH_514) begin
            bram_real_depth = 11'd512;
        end
        else if (bram_packet_depth==`PACKET_LENGTH_771) begin
            bram_real_depth = 11'd768;
        end
        else if (bram_packet_depth==`PACKET_LENGTH_1028) begin
            bram_real_depth = 11'd1024;
        end
        else begin
            bram_real_depth = 11'd1024;
        end
    end
 


    reg [10:0] addrb;
    always @(posedge clk) begin
        if (~rst_n) begin
            addrb <= 11'b0;
        end
        else if ((read_bram_cnt>2)&&(read_bram_cnt<(bram_real_depth+4))) begin
            addrb <= read_bram_cnt - 3;
        end
        else begin
            addrb <= 11'b0;
        end
    end


    wire [31:0] doutb;
    reg [31:0] doutb_ff;
    always @(posedge clk ) begin
        if (~rst_n) begin
            doutb_ff <= 32'b0;
        end
        else begin
            doutb_ff <= doutb;
        end
    end

    wire no_write_header;
    assign no_write_header = ((bram_packet_type==`A2B_EV_RANDOMBIT))? 1'b1:1'b0;

    assign B_A2B_wr_en = ((read_bram_cnt>(6 + no_write_header))&&(read_bram_cnt<(bram_real_depth+8)))? 1'b1:1'b0;
    assign B_A2B_wr_din = (B_A2B_wr_en)? doutb_ff:32'b0;




    //RX sel
    assign B_A2B_ER_wr_en = ((bram_packet_type==`A2B_CORRECT_PARITY) || (bram_packet_type==`A2B_TARGET_HASHTAG))? 
                                B_A2B_wr_en:1'b0;
    assign B_A2B_ER_wr_din = ((bram_packet_type==`A2B_CORRECT_PARITY) || (bram_packet_type==`A2B_TARGET_HASHTAG))? 
                                B_A2B_wr_din:32'b0;

    assign B_RX_EVrandombit_wea = ((bram_packet_type==`A2B_EV_RANDOMBIT)&&B_A2B_wr_en)? 
                                        {8{(B_RX_EVrandombit_we_sel)}}:8'b0;
    assign B_RX_EVrandombit_dina = ((bram_packet_type==`A2B_EV_RANDOMBIT)&&B_RX_EVrandombit_we_sel)?
                                        ({B_A2B_wr_din_delay, B_A2B_wr_din}):64'b0;


    always @(posedge clk ) begin
        if (~rst_n) begin
            B_RX_EVrandombit_addra <= 14'b0;
        end
        else if (reset_er_parameter) begin
            B_RX_EVrandombit_addra <= 14'b0;
        end
        else if (|B_RX_EVrandombit_wea) begin
            B_RX_EVrandombit_addra <= B_RX_EVrandombit_addra + 1;
        end
        else begin
            B_RX_EVrandombit_addra <= B_RX_EVrandombit_addra;
        end
    end



    // RX bram 32 bit -> randombit bram 64 bit
    reg [31:0] B_A2B_wr_din_delay;
    always @(posedge clk ) begin
        if (~rst_n) begin
            B_A2B_wr_din_delay <= 32'b0;
        end
        else begin
            B_A2B_wr_din_delay <= B_A2B_wr_din;
        end
    end

    reg B_RX_EVrandombit_we_sel;
    always @(posedge clk ) begin
        if (~rst_n) begin
            B_RX_EVrandombit_we_sel <= 1'b0;
        end
        else if (reset_parameter) begin
            B_RX_EVrandombit_we_sel <= 1'b0;
        end
        else if (B_A2B_wr_en) begin
            B_RX_EVrandombit_we_sel <= ~B_RX_EVrandombit_we_sel;
        end
        else begin
            B_RX_EVrandombit_we_sel <= B_RX_EVrandombit_we_sel;
        end
    end
    












//****************************** read from BRAM ******************************










//****************************** A2B BRAM instantiation ******************************
    
    A2B_BRAM A2B_packet_bram (
        .clka(clk),    // input wire clka
        .ena(1'b1),      // input wire ena
        .wea(wea),      // input wire [0 : 0] wea
        .addra(addra),  // input wire [10 : 0] addra
        .dina(dina),    // input wire [31 : 0] dina
        .douta(),  // output wire [31 : 0] douta


        .clkb(clk),    // input wire clkb
        .enb(1'b1),      // input wire enb
        .web(1'b0),      // input wire [0 : 0] web
        .addrb(addrb),  // input wire [10 : 0] addrb
        .dinb(),    // input wire [31 : 0] dinb
        .doutb(doutb)  // output wire [31 : 0] doutb
    );

//****************************** A2B BRAM instantiation ******************************


endmodule


































module A2B_fsm (
    input clk,
    input rst_n,

    input A_A2B_rd_valid,
    //input setting_done,
    input write_bram_done,
    input read_bram_done,

    output reg read_header_en,
    output wire write_bram_en,
    output wire read_bram_en,
    output wire read_bram_header,
    output reg reset_parameter,
    output reg [3:0] A2B_state

);
    localparam IDLE                 = 4'd15;
    localparam READ_HEADER          = 4'd1;
    localparam SET_PARAMETER        = 4'd2;
    localparam WRITE_BRAM           = 4'd3;
    localparam PACKET_DONE          = 4'd4;
    localparam READ_BRAM            = 4'd5;
    localparam UNPACKET_DONE        = 4'd6;
    localparam A2B_FINISH           = 4'd7;

    reg [3:0] next_A2B_state;
    always @(posedge clk ) begin
        if (~rst_n) begin
            A2B_state <= IDLE;
        end
        else begin
            A2B_state <= next_A2B_state;
        end
    end

    assign write_bram_en = (A2B_state==WRITE_BRAM)? 1'b1:1'b0;
    assign read_bram_en = (A2B_state==READ_BRAM)? 1'b1:1'b0;
    assign read_bram_header = (A2B_state==PACKET_DONE)? 1'b1:1'b0;


    always @(*) begin
        case (A2B_state)
            IDLE : begin
                if (A_A2B_rd_valid) begin
                    next_A2B_state = READ_HEADER;
                    read_header_en = 1'b0;
                    reset_parameter = 1'b0;
                end
                else begin
                    next_A2B_state = IDLE;
                    read_header_en = 1'b0;
                    reset_parameter = 1'b0;
                end
            end 
            READ_HEADER : begin
                next_A2B_state = SET_PARAMETER;
                read_header_en = 1'b1;
                reset_parameter = 1'b0;
            end

            SET_PARAMETER : begin
                next_A2B_state = WRITE_BRAM;
                read_header_en = 1'b0;
                reset_parameter = 1'b0;
            end

            WRITE_BRAM : begin
                if (write_bram_done) begin
                    next_A2B_state = PACKET_DONE;
                    read_header_en = 1'b0;
                    reset_parameter = 1'b0;
                end
                else begin
                    next_A2B_state = WRITE_BRAM;
                    read_header_en = 1'b0;
                    reset_parameter = 1'b0;
                end
            end

            PACKET_DONE : begin
                next_A2B_state = READ_BRAM;
                read_header_en = 1'b0;
                reset_parameter = 1'b0;
            end

            READ_BRAM : begin
                if (read_bram_done) begin
                    next_A2B_state = UNPACKET_DONE;
                    read_header_en = 1'b0;
                    reset_parameter = 1'b0;
                end
                else begin
                    next_A2B_state = READ_BRAM;
                    read_header_en = 1'b0;
                    reset_parameter = 1'b0;
                end
            end

            UNPACKET_DONE : begin
                next_A2B_state = A2B_FINISH;
                read_header_en = 1'b0;
                reset_parameter = 1'b0;
            end

            A2B_FINISH : begin
                next_A2B_state = IDLE;
                read_header_en = 1'b0;
                reset_parameter = 1'b1;
            end

            default: begin
                next_A2B_state = IDLE;
                read_header_en = 1'b0;
                reset_parameter = 1'b0;
            end
        endcase
    end









    
endmodule






