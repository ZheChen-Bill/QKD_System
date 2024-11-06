

// `include "./error_reconcilation_parameter.v"
// `include "./packet_parameter.v"

module B2A_test (
    input clk,


    input rst_n,


    // B_B2A fifo
    output wire B_B2A_rd_clk,
    output wire B_B2A_rd_en,
    input wire [31:0] B_B2A_rd_dout,
    input wire B_B2A_empty,
    input wire B_B2A_rd_valid,

    // A_B2A fifo
    output wire A_B2A_wr_clk,
    output wire [31:0] A_B2A_wr_din,
    output wire A_B2A_wr_en,
    input wire A_B2A_full,
    input wire A_B2A_wr_ack,


    output [3:0] B2A_state


);





//****************************** FIFO setup ******************************
    assign B_B2A_rd_clk = clk;
    assign A_B2A_wr_clk = clk;

//****************************** FIFO setup ******************************







//****************************** B2A fsm ******************************

    wire read_header_en;
    wire reset_parameter;

    //wire setting_done;
    wire write_bram_done;
    assign write_bram_done = (write_bram_cnt==(real_depth+3))? 1'b1:1'b0;
    wire read_bram_done;
    assign read_bram_done = (read_bram_cnt==(real_depth+7))? 1'b1:1'b0;

    B2A_fsm B2A_FSM(
        .clk(clk),
        .rst_n(rst_n),

        .B_B2A_rd_valid(B_B2A_rd_valid),
        //.setting_done(setting_done),
        .write_bram_done(write_bram_done),
        .read_bram_done(read_bram_done),

        .reset_parameter(reset_parameter),
        .read_header_en(read_header_en),
        .B2A_state(B2A_state)
    );
//****************************** B2A fsm ******************************





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


    reg [31:0] header_ff;

    always @(posedge clk ) begin
        if (~rst_n)begin
            header_ff <= 32'b0;
        end
        else if (read_header_en) begin
            header_ff <= B_B2A_rd_dout;
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
        else if (B2A_state==4'd3) begin
            write_bram_cnt <= write_bram_cnt + 1;
        end
        else if (reset_parameter) begin
            write_bram_cnt <= 11'b0;
        end
        else begin
            write_bram_cnt <= write_bram_cnt;
        end
    end

    assign B_B2A_rd_en = ((write_bram_cnt>0)&&(write_bram_cnt<(real_depth+2)))? 1'b1:1'b0;


    reg wea;
    reg [10:0] addra;
    reg [31:0] dina;

    always @(posedge clk ) begin
        if (~rst_n) begin
            addra <= 11'b0;
            wea <= 1'b0;
            dina <= 32'b0;
        end
        else if (B_B2A_rd_en) begin
            addra <= write_bram_cnt-1;
            wea <= 1'b1;
            dina <= B_B2A_rd_dout;
        end
        else begin
            addra <= 11'b0;
            wea <= 1'b0;
            dina <= 32'b0;
        end
    end
//****************************** write to BRAM ******************************


//****************************** read from BRAM ******************************
    reg [15:0] read_bram_cnt;
    always @(posedge clk ) begin
        if (~rst_n) begin
            read_bram_cnt <= 16'b0;
        end
        else if (B2A_state==4'd5) begin
            read_bram_cnt <= read_bram_cnt + 1;
        end
        else if (reset_parameter) begin
            read_bram_cnt <= 16'b0;
        end
        else begin
            read_bram_cnt <= read_bram_cnt;
        end
    end


    

    reg [10:0] addrb;

    always @(posedge clk ) begin
        if (~rst_n) begin
            addrb <= 11'b0;
        end
        else if ((read_bram_cnt>0)&&(read_bram_cnt<(real_depth+2))) begin
            addrb <= read_bram_cnt-1;
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

    assign A_B2A_wr_en = ((read_bram_cnt>4)&&(read_bram_cnt<(real_depth+6)))? 1'b1:1'b0;
    assign A_B2A_wr_din = (A_B2A_wr_en)? doutb_ff:32'b0;
//****************************** read from BRAM ******************************




//****************************** B2A BRAM instantiation ******************************
    
    B2A_BRAM B2A_packet_bram (
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

//****************************** B2A BRAM instantiation ******************************















    
endmodule












module B2A_fsm (
    input clk,
    input rst_n,

    input B_B2A_rd_valid,
    //input setting_done,
    input write_bram_done,
    input read_bram_done,

    output reg read_header_en,
    output reg reset_parameter,
    output reg [3:0] B2A_state

);
    localparam IDLE                 = 4'd15;
    localparam READ_HEADER          = 4'd1;
    localparam SET_PARAMETER        = 4'd2;
    localparam WRITE_BRAM           = 4'd3;
    localparam PACKET_DONE          = 4'd4;
    localparam READ_BRAM            = 4'd5;
    localparam UNPACKET_DONE        = 4'd6;
    localparam B2A_FINISH           = 4'd7;





    always @(*) begin
        case (B2A_state)
            IDLE : begin
                if (B_B2A_rd_valid) begin
                    next_B2A_state = READ_HEADER;
                    read_header_en = 1'b0;
                    reset_parameter = 1'b0;
                end
                else begin
                    next_B2A_state = IDLE;
                    read_header_en = 1'b0;
                    reset_parameter = 1'b0;
                end
            end 
            READ_HEADER : begin
                next_B2A_state = SET_PARAMETER;
                read_header_en = 1'b1;
                reset_parameter = 1'b0;
            end

            SET_PARAMETER : begin
                next_B2A_state = WRITE_BRAM;
                read_header_en = 1'b0;
                reset_parameter = 1'b0;
            end

            WRITE_BRAM : begin
                if (write_bram_done) begin
                    next_B2A_state = PACKET_DONE;
                    read_header_en = 1'b0;
                    reset_parameter = 1'b0;
                end
                else begin
                    next_B2A_state = WRITE_BRAM;
                    read_header_en = 1'b0;
                    reset_parameter = 1'b0;
                end
            end

            PACKET_DONE : begin
                next_B2A_state = READ_BRAM;
                read_header_en = 1'b0;
                reset_parameter = 1'b0;
            end

            READ_BRAM : begin
                if (read_bram_done) begin
                    next_B2A_state = UNPACKET_DONE;
                    read_header_en = 1'b0;
                    reset_parameter = 1'b0;
                end
                else begin
                    next_B2A_state = READ_BRAM;
                    read_header_en = 1'b0;
                    reset_parameter = 1'b0;
                end
            end

            UNPACKET_DONE : begin
                next_B2A_state = B2A_FINISH;
                read_header_en = 1'b0;
                reset_parameter = 1'b0;
            end

            B2A_FINISH : begin
                next_B2A_state = IDLE;
                read_header_en = 1'b0;
                reset_parameter = 1'b1;
            end

            default: begin
                next_B2A_state = IDLE;
                read_header_en = 1'b0;
                reset_parameter = 1'b0;
            end
        endcase
    end






    reg [3:0] next_B2A_state;
    always @(posedge clk ) begin
        if (~rst_n) begin
            B2A_state <= IDLE;
        end
        else begin
            B2A_state <= next_B2A_state;
        end
    end


    
endmodule