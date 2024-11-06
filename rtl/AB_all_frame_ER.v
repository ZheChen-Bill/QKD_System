











// `include "./packet_parameter.v"
// `include "./error_reconcilation_parameter.v"


module AB_all_frame_ER (

    input clk,

    input rst_n,

    input start_switch,
    
    output finish_A_all_frame_ER,
    output finish_B_all_frame_ER,

    input sifted_key_addr_index,                            //address index
                                                            //0:addr0 ~ addr16383
                                                            //1:addr16384 ~ addr32767


    output Areconciledkey_clka,
    output Areconciledkey_ena,
    output Areconciledkey_wea,
    output [14:0] Areconciledkey_addra,
    output [63:0] Areconciledkey_dina,


    output Breconciledkey_clka,
    output Breconciledkey_ena,
    output Breconciledkey_wea,
    output [14:0] Breconciledkey_addra,
    output [63:0] Breconciledkey_dina,


    output wire [`FRAME_LEAKED_INFO_WIDTH-1:0] single_frame_leaked_info,
    output wire [`FRAME_ERROR_COUNT_WIDTH-1:0] single_frame_error_count,
    output wire single_frame_parameter_valid,
    output wire A_single_frame_error_verification_fail,       //error verification is fail
    output wire B_single_frame_error_verification_fail         //B error verification is fail

);
    



//****************************** start compute ******************************
  wire start_A_all_frame_ER , start_B_all_frame_ER;
  reg [15:0] start_switch_cnt;
  
  always @(posedge clk ) begin
      if (~rst_n) begin
          start_switch_cnt <= 16'b0;
      end  
      else if (start_switch_cnt==16'b0000_0000_1111_1111) begin
          start_switch_cnt <= start_switch_cnt;
      end
      else if (start_switch) begin
          start_switch_cnt <= start_switch_cnt + 1'b1;
      end
      else begin
          start_switch_cnt <= start_switch_cnt;
      end
  end

assign start_A_all_frame_ER = (start_switch_cnt==16'b0000_0000_1000_0000)? 1'b1:1'b0;
assign start_B_all_frame_ER = (start_switch_cnt==16'b0000_0000_1111_1100)? 1'b1:1'b0;

//****************************** start compute ******************************








//****************************** A all frame ER ******************************

    wire [14:0] Asiftedkey_addrb;

    all_frame_A_ER af_A_ER (
        .clk(clk),                                      // Connect to clock
        .rst_n(rst_n),                                  // Connect to reset

        .start_A_all_frame_ER(start_A_all_frame_ER),    // Start signal for all frame error reconciliation

        .finish_all_frame_ER(finish_A_all_frame_ER),        //finish all frame error reconciliation

        .sifted_key_addr_index(sifted_key_addr_index),      //address index
                                                            //0:addr0 ~ addr16383
                                                            //1:addr16384 ~ addr32767

        .single_frame_leaked_info(single_frame_leaked_info),            // Output for leaked info
        .single_frame_error_count(single_frame_error_count),            // Output for error count
        .single_frame_parameter_valid(single_frame_parameter_valid),    // Output for parameter validity
        .single_frame_error_verification_fail(A_single_frame_error_verification_fail), // Output for error verification status

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
        .A_A2B_wr_en(A_A2B_wr_en),
        .A_A2B_wr_din(A_A2B_wr_din),
        .A_A2B_full(A_A2B_full),
        .A_A2B_wr_ack(A_A2B_wr_ack),

        // EV random bit BRAM connections
        .EVrandombit_doutb(rb_douta),
        .EVrandombit_addrb(rb_addra),
        .EVrandombit_clkb(rb_clka),
        .EVrandombit_enb(rb_ena),
        .EVrandombit_rstb(rb_rsta),
        .EVrandombit_web(rb_wea),

        // Reconciled key BRAM connections
        .reconciledkey_addra(Areconciledkey_addra),
        .reconciledkey_clka(Areconciledkey_clka),
        .reconciledkey_dina(Areconciledkey_dina),
        .reconciledkey_ena(Areconciledkey_ena),
        .reconciledkey_rsta(),
        .reconciledkey_wea(Areconciledkey_wea)
    );

//****************************** A all frame ER ******************************










//****************************** B all frame ER ******************************

    wire [14:0] Bsiftedkey_addrb;

    all_frame_B_ER af_B_ER (
        .clk(clk),                                // Connect to clock
        .rst_n(rst_n),                            // Connect to reset

        .start_B_all_frame_ER(start_B_all_frame_ER), // Start signal for all frame error reconciliation

        .finish_all_frame_ER(finish_B_all_frame_ER),        //finish all frame error reconciliation

        .sifted_key_addr_index(sifted_key_addr_index),      //address index
                                                            //0:addr0 ~ addr16383
                                                            //1:addr16384 ~ addr32767


        .single_frame_error_verification_fail(B_single_frame_error_verification_fail), // Output for error verification status

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
        .EVrandombit_doutb(rb_doutb),
        .EVrandombit_addrb(rb_addrb),
        .EVrandombit_clkb(rb_clkb),
        .EVrandombit_enb(rb_enb),
        .EVrandombit_rstb(rb_rstb),
        .EVrandombit_web(rb_web),

        // B2A ER FIFO connections
        .B_B2A_wr_clk(B_B2A_wr_clk),
        .B_B2A_wr_din(B_B2A_wr_din),
        .B_B2A_wr_en(B_B2A_wr_en),
        .B_B2A_full(B_B2A_full),
        .B_B2A_wr_ack(B_B2A_wr_ack),

        // Reconciled key BRAM connections
        .reconciledkey_addra(Breconciledkey_addra),
        .reconciledkey_clka(Breconciledkey_clka),
        .reconciledkey_dina(Breconciledkey_dina),
        .reconciledkey_ena(Breconciledkey_ena),
        .reconciledkey_rsta(),
        .reconciledkey_wea(Breconciledkey_wea)
    );

//****************************** B all frame ER ******************************











//****************************** B2A test instantiation ******************************
    wire [3:0] B2A_state;


    B2A_test B2Atest(
        .clk(clk),


        .rst_n(rst_n),


        // B_B2A fifo
        .B_B2A_rd_clk(B_B2A_rd_clk),
        .B_B2A_rd_en(B_B2A_rd_en),
        .B_B2A_rd_dout(B_B2A_rd_dout),
        .B_B2A_empty(B_B2A_empty),
        .B_B2A_rd_valid(B_B2A_rd_valid),

        // A_B2A fifo
        .A_B2A_wr_clk(A_B2A_wr_clk),
        .A_B2A_wr_din(A_B2A_wr_din),
        .A_B2A_wr_en(A_B2A_wr_en),
        .A_B2A_full(A_B2A_full),
        .A_B2A_wr_ack(A_B2A_wr_ack),


        .B2A_state(B2A_state)
    );
//****************************** B2A test instantiation ******************************

//****************************** A2B test instantiation ******************************
    
    wire [3:0] A2B_state;

    A2B_test A2Btest(
        .clk(clk),


        .rst_n(rst_n),

        
        // A_A2B fifo
        .A_A2B_rd_clk(A_A2B_rd_clk),
        .A_A2B_rd_en(A_A2B_rd_en),
        .A_A2B_rd_dout(A_A2B_rd_dout),
        .A_A2B_empty(A_A2B_empty),
        .A_A2B_rd_valid(A_A2B_rd_valid),

        // B_A2B fifo
        .B_A2B_ER_wr_clk(B_A2B_wr_clk),
        .B_A2B_ER_wr_din(B_A2B_wr_din),
        .B_A2B_ER_wr_en(B_A2B_wr_en),
        .B_A2B_ER_full(B_A2B_full),
        .B_A2B_ER_wr_ack(B_A2B_wr_ack),


        .A2B_state(A2B_state)

    );
//****************************** A2B test instantiation ******************************




















//****************************** init random bit BRAM instantiation ******************************
    wire rb_clka;
    wire rb_ena;
    wire [7:0] rb_wea;
    wire rb_rsta;
    wire [13 : 0] rb_addra;
    wire [63 : 0] rb_douta;


    wire rb_clkb;
    wire rb_enb;
    wire [7:0] rb_web;
    wire rb_rstb;
    wire [13 : 0] rb_addrb;
    wire [63 : 0] rb_doutb;


    init_randombit_bram init_randombit (
        .clka(rb_clka),    // input wire clka
        .ena(rb_ena),      // input wire ena
        .wea((|rb_wea)),      // input wire [0 : 0] wea
        .addra(rb_addra),  // input wire [13 : 0] addra
        .dina(64'b0),    // input wire [63 : 0] dina
        .douta(rb_douta),  // output wire [63 : 0] douta

        .clkb(rb_clkb),    // input wire clkb
        .enb(rb_enb),      // input wire enb
        .web((|rb_web)),      // input wire [0 : 0] web
        .addrb(rb_addrb),  // input wire [13 : 0] addrb
        .dinb(64'b0),    // input wire [63 : 0] dinb
        .doutb(rb_doutb)  // output wire [63 : 0] doutb
    );
//****************************** init random bit BRAM instantiation ******************************
//****************************** init A siftedkey instantiation ******************************
    wire Asiftedkey_clkb;
    wire Asiftedkey_enb;
    wire Asiftedkey_web;

    wire [63:0] Asiftedkey_dinb;
    wire [63:0] Asiftedkey_doutb;

    
    init_A_siftedkey_bram init_Asiftedkey (
        .clka(),    // input wire clka
        .ena(1'b0),      // input wire ena
        .wea(1'b0),      // input wire [0 : 0] wea
        .addra(),  // input wire [9 : 0] addra
        .dina(),    // input wire [63 : 0] dina
        .douta(),  // output wire [63 : 0] douta

        .clkb(Asiftedkey_clkb),    // input wire clkb
        .enb(Asiftedkey_enb),      // input wire enb
        .web(Asiftedkey_web),      // input wire [0 : 0] web
        .addrb(Asiftedkey_addrb),  // input wire [14 : 0] addrb
        .dinb(Asiftedkey_dinb),    // input wire [63 : 0] dinb
        .doutb(Asiftedkey_doutb)  // output wire [63 : 0] doutb
    );

//****************************** init A siftedkey instantiation ******************************
//****************************** init B siftedkey instantiation ******************************

    wire Bsiftedkey_clkb;
    wire Bsiftedkey_enb;
    wire Bsiftedkey_web;

    wire [63:0] Bsiftedkey_dinb;
    wire [63:0] Bsiftedkey_doutb;

    init_B_siftedkey_bram init_Bsiftedkey (
        .clka(),    // input wire clka
        .ena(1'b0),      // input wire ena
        .wea(1'b0),      // input wire [0 : 0] wea
        .addra(),  // input wire [14 : 0] addra
        .dina(),    // input wire [63 : 0] dina
        .douta(),  // output wire [63 : 0] douta

        .clkb(Bsiftedkey_clkb),    // input wire clkb
        .enb(Bsiftedkey_enb),      // input wire enb
        .web(Bsiftedkey_web),      // input wire [0 : 0] web
        .addrb(Bsiftedkey_addrb),  // input wire [14 : 0] addrb
        .dinb(Bsiftedkey_dinb),    // input wire [63 : 0] dinb
        .doutb(Bsiftedkey_doutb)  // output wire [63 : 0] doutb
    );
//****************************** init B siftedkey instantiation ******************************







//****************************** Bob B2A FIFO instantiation ******************************
    wire B_B2A_wr_clk;
    wire [31:0] B_B2A_wr_din;
    wire B_B2A_wr_en;
    wire B_B2A_full;
    wire B_B2A_wr_ack;

    wire B_B2A_rd_clk;
    wire B_B2A_rd_en;
    wire [31:0] B_B2A_rd_dout;
    wire B_B2A_empty;
    wire B_B2A_rd_valid;

    wire B_B2A_wr_rst_busy;
    wire B_B2A_rd_rst_busy;

    B_B2A_ER_FIFO B_B2A_FIFO (
        .srst(~rst_n),                // input wire srst, active high

        .wr_clk(B_B2A_wr_clk),             // input wire wr_clk
        .din(B_B2A_wr_din),                // input wire [31 : 0] din
        .wr_en(B_B2A_wr_en),               // input wire wr_en
        .full(B_B2A_full),                 // output wire full
        .wr_ack(B_B2A_wr_ack),             // output wire wr_ack

        .rd_clk(B_B2A_rd_clk),             // input wire rd_clk
        .rd_en(B_B2A_rd_en),               // input wire rd_en
        .dout(B_B2A_rd_dout),              // output wire [31 : 0] dout
        .empty(B_B2A_empty),               // output wire empty
        .valid(B_B2A_rd_valid),            // output wire valid

        .wr_rst_busy(B_B2A_wr_rst_busy),   // output wire wr_rst_busy
        .rd_rst_busy(B_B2A_rd_rst_busy)    // output wire rd_rst_busy
    );
//****************************** Bob B2A FIFO instantiation ******************************

//****************************** Bob A2B FIFO instantiation ******************************
    wire B_A2B_wr_clk;
    wire [31:0] B_A2B_wr_din;
    wire B_A2B_wr_en;
    wire B_A2B_full;
    wire B_A2B_wr_ack;

    wire B_A2B_rd_clk;
    wire B_A2B_rd_en;
    wire [31:0] B_A2B_rd_dout;
    wire B_A2B_empty;
    wire B_A2B_rd_valid;

    wire B_A2B_wr_rst_busy;
    wire B_A2B_rd_rst_busy;

    B_A2B_ER_FIFO B_A2B_FIFO (
        .srst(~rst_n),                // input wire srst, active high

        .wr_clk(B_A2B_wr_clk),             // input wire wr_clk
        .din(B_A2B_wr_din),                // input wire [31 : 0] din
        .wr_en(B_A2B_wr_en),               // input wire wr_en
        .full(B_A2B_full),                 // output wire full
        .wr_ack(B_A2B_wr_ack),             // output wire wr_ack

        .rd_clk(B_A2B_rd_clk),             // input wire rd_clk
        .rd_en(B_A2B_rd_en),               // input wire rd_en
        .dout(B_A2B_rd_dout),              // output wire [31 : 0] dout
        .empty(B_A2B_empty),               // output wire empty
        .valid(B_A2B_rd_valid),            // output wire valid

        .wr_rst_busy(B_A2B_wr_rst_busy),   // output wire wr_rst_busy
        .rd_rst_busy(B_A2B_rd_rst_busy)    // output wire rd_rst_busy
    );
//****************************** Bob A2B FIFO instantiation ******************************


//****************************** Alice A2B FIFO instantiation ******************************
    wire A_A2B_wr_clk;
    wire [31:0] A_A2B_wr_din;
    wire A_A2B_wr_en;
    wire A_A2B_full;
    wire A_A2B_wr_ack;

    wire A_A2B_rd_clk;
    wire A_A2B_rd_en;
    wire [31:0] A_A2B_rd_dout;
    wire A_A2B_empty;
    wire A_A2B_rd_valid;

    wire A_A2B_wr_rst_busy;
    wire A_A2B_rd_rst_busy;

    A_A2B_ER_FIFO A_A2B_FIFO (
        .srst(~rst_n),                // input wire srst, active high

        .wr_clk(A_A2B_wr_clk),             // input wire wr_clk
        .din(A_A2B_wr_din),                // input wire [31 : 0] din
        .wr_en(A_A2B_wr_en),               // input wire wr_en
        .full(A_A2B_full),                 // output wire full
        .wr_ack(A_A2B_wr_ack),             // output wire wr_ack

        .rd_clk(A_A2B_rd_clk),             // input wire rd_clk
        .rd_en(A_A2B_rd_en),               // input wire rd_en
        .dout(A_A2B_rd_dout),                // output wire [31 : 0] dout
        .empty(A_A2B_empty),               // output wire empty
        .valid(A_A2B_rd_valid),            // output wire valid

        .wr_rst_busy(A_A2B_wr_rst_busy),   // output wire wr_rst_busy
        .rd_rst_busy(A_A2B_rd_rst_busy)    // output wire rd_rst_busy
    );
//****************************** Alice A2B FIFO instantiation ******************************

//****************************** Alice B2A FIFO instantiation ******************************
    wire A_B2A_wr_clk;
    wire [31:0] A_B2A_wr_din;
    wire A_B2A_wr_en;
    wire A_B2A_full;
    wire A_B2A_wr_ack;

    wire A_B2A_rd_clk;
    wire A_B2A_rd_en;
    wire [31:0] A_B2A_rd_dout;
    wire A_B2A_empty;
    wire A_B2A_rd_valid;

    wire A_B2A_wr_rst_busy;
    wire A_B2A_rd_rst_busy;

    A_B2A_ER_FIFO A_B2A_FIFO (
        .srst(~rst_n),                // input wire srst, active high

        .wr_clk(A_B2A_wr_clk),             // input wire wr_clk
        .din(A_B2A_wr_din),                // input wire [31 : 0] din
        .wr_en(A_B2A_wr_en),               // input wire wr_en
        .full(A_B2A_full),                 // output wire full
        .wr_ack(A_B2A_wr_ack),             // output wire wr_ack

        .rd_clk(A_B2A_rd_clk),             // input wire rd_clk
        .rd_en(A_B2A_rd_en),               // input wire rd_en
        .dout(A_B2A_rd_dout),                // output wire [31 : 0] dout
        .empty(A_B2A_empty),               // output wire empty
        .valid(A_B2A_rd_valid),            // output wire valid

        .wr_rst_busy(A_B2A_wr_rst_busy),   // output wire wr_rst_busy
        .rd_rst_busy(A_B2A_rd_rst_busy)    // output wire rd_rst_busy
    );
//****************************** Alice B2A FIFO instantiation ******************************











endmodule