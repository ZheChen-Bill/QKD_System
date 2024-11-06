



`include "./packet_parameter.v"
`include "./error_reconcilation_parameter.v"


module top_AB_ER_Bram_interface (

    input clk,
    input rst_n,

    input start_switch,
    
    output finish_A_ER,
    output finish_B_ER,

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
  wire start_A_ER , start_B_ER;
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

assign start_A_ER = (start_switch_cnt==16'b0000_0000_1000_0000)? 1'b1:1'b0;
assign start_B_ER = (start_switch_cnt==16'b0000_0000_1111_1100)? 1'b1:1'b0;

//****************************** start compute ******************************











//****************************** A ER ******************************

    

    top_A_ER A_ER_test (
        .clk(clk),                                      // Connect to clock
        .rst_n(rst_n),                                  // Connect to reset

        .start_A_ER(start_A_ER),    // Start signal for all frame error reconciliation

        .finish_A_ER(finish_A_ER),        //finish all frame error reconciliation

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
        .A_B2A_rd_clk(A_RX_er_rd_clk),
        .A_B2A_rd_dout(A_RX_er_rd_dout),
        .A_B2A_rd_en(A_RX_er_rd_en),
        .A_B2A_empty(A_RX_er_empty),
        .A_B2A_rd_valid(A_RX_er_rd_valid),

        // A2B ER FIFO connections
        .A_A2B_wr_clk(A_TX_er_wr_clk),
        .A_A2B_wr_en(A_TX_er_wr_en),
        .A_A2B_wr_din(A_TX_er_wr_din),
        .A_A2B_full(A_TX_er_full),
        .A_A2B_empty(A_TX_er_empty),
        .A_A2B_wr_ack(A_TX_er_wr_ack),
        
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

//****************************** A ER ******************************





//****************************** B ER ******************************



    top_B_ER B_ER_test (
        .clk(clk),                                // Connect to clock
        .rst_n(rst_n),                            // Connect to reset

        .start_B_ER(start_B_ER), // Start signal for all frame error reconciliation

        .finish_B_ER(finish_B_ER),        //finish all frame error reconciliation

        .EVrandombit_full(EVrandombit_full),
        .reset_er_parameter(reset_er_parameter),
    

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
        .B_A2B_rd_clk(B_RX_er_rd_clk),
        .B_A2B_rd_en(B_RX_er_rd_en),
        .B_A2B_rd_dout(B_RX_er_rd_dout),
        .B_A2B_empty(B_RX_er_empty),
        .B_A2B_rd_valid(B_RX_er_rd_valid),
        
        // EV random bit BRAM connections
        .EVrandombit_doutb(B_RX_EVrandombit_doutb),
        .EVrandombit_addrb(B_RX_EVrandombit_addrb),
        .EVrandombit_clkb(B_RX_EVrandombit_clkb),
        .EVrandombit_enb(B_RX_EVrandombit_enb),
        .EVrandombit_rstb(),
        .EVrandombit_web(B_RX_EVrandombit_web),


        // B2A ER FIFO connections
        .B_B2A_wr_clk(B_TX_er_wr_clk),
        .B_B2A_wr_din(B_TX_er_wr_din),
        .B_B2A_wr_en(B_TX_er_wr_en),
        .B_B2A_full(B_TX_er_full),
        .B_B2A_wr_ack(B_TX_er_wr_ack),

        // Reconciled key BRAM connections
        .reconciledkey_addra(Breconciledkey_addra),
        .reconciledkey_clka(Breconciledkey_clka),
        .reconciledkey_dina(Breconciledkey_dina),
        .reconciledkey_ena(Breconciledkey_ena),
        .reconciledkey_rsta(),
        .reconciledkey_wea(Breconciledkey_wea)
    );

//****************************** B ER ******************************




























//****************************** B RX random bit instantiation ******************************
    // connect to B2A test
    wire [13:0] B_RX_EVrandombit_addra;
    wire B_RX_EVrandombit_clka;
    wire [63:0] B_RX_EVrandombit_dina;
    wire [63:0] B_RX_EVrandombit_douta;
    wire B_RX_EVrandombit_ena;
    wire [7:0] B_RX_EVrandombit_wea;

    // connect to top_B_ER
    wire [13:0] B_RX_EVrandombit_addrb;
    wire B_RX_EVrandombit_clkb;
    wire [63:0] B_RX_EVrandombit_dinb;
    wire [63:0] B_RX_EVrandombit_doutb;
    wire B_RX_EVrandombit_enb;
    wire [7:0] B_RX_EVrandombit_web;


    uram_randombit B_RX_EVrandombit(
        .B_RX_EVrandombit_addra(B_RX_EVrandombit_addra),
        .B_RX_EVrandombit_clka(B_RX_EVrandombit_clka),
        .B_RX_EVrandombit_dina(B_RX_EVrandombit_dina),
        .B_RX_EVrandombit_douta(B_RX_EVrandombit_douta),
        .B_RX_EVrandombit_ena(B_RX_EVrandombit_ena),
        .B_RX_EVrandombit_wea((|B_RX_EVrandombit_wea)),

        .B_RX_EVrandombit_addrb(B_RX_EVrandombit_addrb),
        .B_RX_EVrandombit_clkb(B_RX_EVrandombit_clkb),
        .B_RX_EVrandombit_dinb(B_RX_EVrandombit_dinb),
        .B_RX_EVrandombit_doutb(B_RX_EVrandombit_doutb),
        .B_RX_EVrandombit_enb(B_RX_EVrandombit_enb),
        .B_RX_EVrandombit_web((|B_RX_EVrandombit_web))
    );
//****************************** B RX random bit instantiation ******************************


//****************************** init random bit BRAM instantiation ******************************
    wire rb_clka;
    wire rb_ena;
    wire [7:0] rb_wea;
    wire rb_rsta;
    wire [13 : 0] rb_addra;
    wire [63 : 0] rb_douta;


    init_randombit_bram A_init_EVrandombit (
        .clka(rb_clka),    // input wire clka
        .ena(rb_ena),      // input wire ena
        .wea((|rb_wea)),      // input wire [0 : 0] wea
        .addra(rb_addra),  // input wire [13 : 0] addra
        .dina(64'b0),    // input wire [63 : 0] dina
        .douta(rb_douta),  // output wire [63 : 0] douta

        .clkb(),    // input wire clkb
        .enb(1'b0),      // input wire enb
        .web(1'b0),      // input wire [0 : 0] web
        .addrb(),  // input wire [13 : 0] addrb
        .dinb(),    // input wire [63 : 0] dinb
        .doutb()  // output wire [63 : 0] doutb
    );
//****************************** init random bit BRAM instantiation ******************************
//****************************** init A siftedkey instantiation ******************************
    wire Asiftedkey_clkb;
    wire Asiftedkey_enb;
    wire Asiftedkey_web;
    wire [14:0] Asiftedkey_addrb;

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
    wire [14:0] Bsiftedkey_addrb;

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
//    wire B_B2A_wr_clk;
//    wire [31:0] B_B2A_wr_din;
//    wire B_B2A_wr_en;
//    wire B_B2A_full;
//    wire B_B2A_wr_ack;

//    wire B_B2A_rd_clk;
//    wire B_B2A_rd_en;
//    wire [31:0] B_B2A_rd_dout;
//    wire B_B2A_empty;
//    wire B_B2A_rd_valid;

//    wire B_B2A_wr_rst_busy;
//    wire B_B2A_rd_rst_busy;
    wire B_TX_er_wr_clk;
    wire [31:0] B_TX_er_wr_din;
    wire B_TX_er_wr_en;
    wire B_TX_er_full;
    wire B_TX_er_wr_ack;

    wire B_TX_er_rd_clk;
    wire B_TX_er_rd_en;
    wire [31:0] B_TX_er_rd_dout;
    wire B_TX_er_empty;
    wire B_TX_er_rd_valid;

    wire B_TX_er_wr_rst_busy;
    wire B_TX_er_rd_rst_busy;
    B_B2A_ER_FIFO B_B2A_FIFO (
        .srst(~rst_n),                // input wire srst, active high

        .wr_clk(B_TX_er_wr_clk),             // input wire wr_clk
        .din(B_TX_er_wr_din),                // input wire [31 : 0] din
        .wr_en(B_TX_er_wr_en),               // input wire wr_en
        .full(B_TX_er_full),                 // output wire full
        .wr_ack(B_TX_er_wr_ack),             // output wire wr_ack

        .rd_clk(B_TX_er_rd_clk),             // input wire rd_clk
        .rd_en(B_TX_er_rd_en),               // input wire rd_en
        .dout(B_TX_er_rd_dout),              // output wire [31 : 0] dout
        .empty(B_TX_er_empty),               // output wire empty
        .valid(B_TX_er_rd_valid),            // output wire valid

        .wr_rst_busy(B_TX_er_wr_rst_busy),   // output wire wr_rst_busy
        .rd_rst_busy(B_TX_er_rd_rst_busy)    // output wire rd_rst_busy
    );
//****************************** Bob B2A FIFO instantiation ******************************

//****************************** Bob A2B FIFO instantiation ******************************
//    wire B_A2B_wr_clk;
//    wire [31:0] B_A2B_wr_din;
//    wire B_A2B_wr_en;
//    wire B_A2B_full;
//    wire B_A2B_wr_ack;

//    wire B_A2B_rd_clk;
//    wire B_A2B_rd_en;
//    wire [31:0] B_A2B_rd_dout;
//    wire B_A2B_empty;
//    wire B_A2B_rd_valid;

//    wire B_A2B_wr_rst_busy;
//    wire B_A2B_rd_rst_busy;
    wire B_RX_er_wr_clk;
    wire [31:0] B_RX_er_wr_din;
    wire B_RX_er_wr_en;
    wire B_RX_er_full;
    wire B_RX_er_wr_ack;

    wire B_RX_er_rd_clk;
    wire B_RX_er_rd_en;
    wire [31:0] B_RX_er_rd_dout;
    wire B_RX_er_empty;
    wire B_RX_er_rd_valid;

    wire B_RX_er_wr_rst_busy;
    wire B_RX_er_rd_rst_busy;
    
    B_A2B_ER_FIFO B_A2B_FIFO (
        .srst(~rst_n),                // input wire srst, active high

        .wr_clk(B_RX_er_wr_clk),             // input wire wr_clk
        .din(B_RX_er_wr_din),                // input wire [31 : 0] din
        .wr_en(B_RX_er_wr_en),               // input wire wr_en
        .full(B_RX_er_full),                 // output wire full
        .wr_ack(B_RX_er_wr_ack),             // output wire wr_ack

        .rd_clk(B_RX_er_rd_clk),             // input wire rd_clk
        .rd_en(B_RX_er_rd_en),               // input wire rd_en
        .dout(B_RX_er_rd_dout),              // output wire [31 : 0] dout
        .empty(B_RX_er_empty),               // output wire empty
        .valid(B_RX_er_rd_valid),            // output wire valid

        .wr_rst_busy(B_RX_er_wr_rst_busy),   // output wire wr_rst_busy
        .rd_rst_busy(B_RX_er_rd_rst_busy)    // output wire rd_rst_busy
    );
//****************************** Bob A2B FIFO instantiation ******************************


//****************************** Alice A2B FIFO instantiation ******************************
//    wire A_A2B_wr_clk;
//    wire [31:0] A_A2B_wr_din;
//    wire A_A2B_wr_en;
//    wire A_A2B_full;
//    wire A_A2B_wr_ack;

//    wire A_A2B_rd_clk;
//    wire A_A2B_rd_en;
//    wire [31:0] A_A2B_rd_dout;
//    wire A_A2B_empty;
//    wire A_A2B_rd_valid;

//    wire A_A2B_wr_rst_busy;
//    wire A_A2B_rd_rst_busy;
    wire A_TX_er_wr_clk;
    wire [31:0] A_TX_er_wr_din;
    wire A_TX_er_wr_en;
    wire A_TX_er_full;
    wire A_TX_er_wr_ack;

    wire A_TX_er_rd_clk;
    wire A_TX_er_rd_en;
    wire [31:0] A_TX_er_rd_dout;
    wire A_TX_er_empty;
    wire A_TX_er_rd_valid;

    wire A_TX_er_wr_rst_busy;
    wire A_TX_er_rd_rst_busy;
    
    A_A2B_ER_FIFO A_A2B_FIFO (
        .srst(~rst_n),                // input wire srst, active high

        .wr_clk(A_TX_er_wr_clk),             // input wire wr_clk
        .din(A_TX_er_wr_din),                // input wire [31 : 0] din
        .wr_en(A_TX_er_wr_en),               // input wire wr_en

        .rd_clk(A_TX_er_rd_clk),             // input wire rd_clk
        .rd_en(A_TX_er_rd_en),               // input wire rd_en
        .dout(A_TX_er_rd_dout),                // output wire [31 : 0] dout
        
        .full(A_TX_er_full),                 // output wire full
        .wr_ack(A_TX_er_wr_ack),             // output wire wr_ack
        .empty(A_TX_er_empty),               // output wire empty
        .valid(A_TX_er_rd_valid),            // output wire valid
        .wr_rst_busy(A_TX_er_wr_rst_busy),   // output wire wr_rst_busy
        .rd_rst_busy(A_TX_er_rd_rst_busy)    // output wire rd_rst_busy
    );
//****************************** Alice A2B FIFO instantiation ******************************

//****************************** Alice B2A FIFO instantiation ******************************
//    wire A_B2A_wr_clk;
//    wire [31:0] A_B2A_wr_din;
//    wire A_B2A_wr_en;
//    wire A_B2A_full;
//    wire A_B2A_wr_ack;

//    wire A_B2A_rd_clk;
//    wire A_B2A_rd_en;
//    wire [31:0] A_B2A_rd_dout;
//    wire A_B2A_empty;
//    wire A_B2A_rd_valid;

//    wire A_B2A_wr_rst_busy;
//    wire A_B2A_rd_rst_busy;
    wire A_RX_er_wr_clk;
    wire [31:0] A_RX_er_wr_din;
    wire A_RX_er_wr_en;
    wire A_RX_er_full;
    wire A_RX_er_wr_ack;

    wire A_RX_er_rd_clk;
    wire A_RX_er_rd_en;
    wire [31:0] A_RX_er_rd_dout;
    wire A_RX_er_empty;
    wire A_RX_er_rd_valid;

    wire A_RX_er_wr_rst_busy;
    wire A_RX_er_rd_rst_busy;
    
    A_B2A_ER_FIFO A_B2A_FIFO (
        .srst(~rst_n),                // input wire srst, active high

        .wr_clk(A_RX_er_wr_clk),             // input wire wr_clk
        .din(A_RX_er_wr_din),                // input wire [31 : 0] din
        .wr_en(A_RX_er_wr_en),               // input wire wr_en
        .full(A_RX_er_full),                 // output wire full
        .wr_ack(A_RX_er_wr_ack),             // output wire wr_ack
    
    
        .rd_clk(A_RX_er_rd_clk),             // input wire rd_clk
        .rd_en(A_RX_er_rd_en),               // input wire rd_en
        .dout(A_RX_er_rd_dout),                // output wire [31 : 0] dout
        .empty(A_RX_er_empty),               // output wire empty
        .valid(A_RX_er_rd_valid),            // output wire valid

        .wr_rst_busy(A_RX_er_wr_rst_busy),   // output wire wr_rst_busy
        .rd_rst_busy(A_RX_er_rd_rst_busy)    // output wire rd_rst_busy
    );
//****************************** Alice B2A FIFO instantiation ******************************


//****************************** A2B test instantiation ******************************

//    wire EVrandombit_full;
//    wire reset_er_parameter;

//   wire [3:0] A2B_state;
/*
    A2B_test A2Btest(
        .clk(clk),
        .rst_n(rst_n),


        .reset_er_parameter(reset_er_parameter),
        .EVrandombit_full(EVrandombit_full),
        
        // A_A2B fifo
        .A_A2B_rd_clk(A_A2B_rd_clk),
        .A_A2B_rd_en(A_A2B_rd_en),
        .A_A2B_rd_dout(A_A2B_rd_dout),
        .A_A2B_empty(A_A2B_empty),
        .A_A2B_rd_valid(A_A2B_rd_valid),

        // B_A2B ER fifo
        .B_A2B_ER_wr_clk(B_A2B_wr_clk),
        .B_A2B_ER_wr_din(B_A2B_wr_din),
        .B_A2B_ER_wr_en(B_A2B_wr_en),
        .B_A2B_ER_full(B_A2B_full),
        .B_A2B_ER_wr_ack(B_A2B_wr_ack),


        // B_A2B random bit bram
        .B_RX_EVrandombit_addra(B_RX_EVrandombit_addra),
        .B_RX_EVrandombit_clka(B_RX_EVrandombit_clka),
        .B_RX_EVrandombit_dina(B_RX_EVrandombit_dina),
        .B_RX_EVrandombit_ena(B_RX_EVrandombit_ena),
        .B_RX_EVrandombit_wea(B_RX_EVrandombit_wea),


        .A2B_state(A2B_state)

    );
*/
//****************************** A2B test instantiation ******************************
//****************************** A packet  ******************************
    // Input 
    // wire clk;
    // wire rst_n;
    wire A2B_busy_Net2PP_TX;

    // Output 
    wire A2B_busy_PP2Net_TX;
    wire A2B_msg_stored;
    wire [10:0] A2B_sizeTX_msg; // Assuming this should be a register based on your module definition

    wire [3:0] A_packet_state;

    // // A_A2B decoy fifo connections
    // wire A_TX_decoy_rd_clk;
    // wire A_TX_decoy_rd_en;
    // wire [31:0] A_TX_decoy_rd_dout;
    // wire A_TX_decoy_empty;
    // wire A_TX_decoy_rd_valid;

    // A_A2B er fifo connections
    wire A_TX_er_rd_clk;
    wire A_TX_er_rd_en;
    wire [31:0] A_TX_er_rd_dout;
    wire A_TX_er_empty;
    wire A_TX_er_rd_valid;

    // A_A2B pa fifo connections
    wire A_TX_pa_rd_clk;
    wire A_TX_pa_rd_en;
    wire [31:0] A_TX_pa_rd_dout;
    wire A_TX_pa_empty;
    wire A_TX_pa_rd_valid;

    // TX BRAM connections
    wire A_TX_bram_clkb;
    wire A_TX_bram_enb;
    wire A_TX_bram_web;
    wire [10:0] A_TX_bram_addrb;
    wire [31:0] A_TX_bram_dinb;

    A_packet Apacket (
        .clk(clk),                            // Clock signal
        .rst_n(rst_n),                        // Reset signal

        .busy_Net2PP_TX(A2B_busy_Net2PP_TX),      // Input indicating the network to post-processing transmission is busy

        .busy_PP2Net_TX(A2B_busy_PP2Net_TX),      // Output indicating post-processing to network transmission is busy
        .msg_stored(A2B_msg_stored),              // Output indicating message is stored
        .sizeTX_msg(A2B_sizeTX_msg),              // Output register for message size

        .A_packet_state(A_packet_state),      // Output state of the A_packet FSM

        // A_A2B decoy fifo connections
        .A_TX_decoy_rd_clk(A_TX_decoy_rd_clk),
        .A_TX_decoy_rd_en(A_TX_decoy_rd_en),
        .A_TX_decoy_rd_dout(A_TX_decoy_rd_dout),
        .A_TX_decoy_empty(A_TX_decoy_empty),
        .A_TX_decoy_rd_valid(A_TX_decoy_rd_valid),

        // A_A2B er fifo connections
        .A_TX_er_rd_clk(A_TX_er_rd_clk),
        .A_TX_er_rd_en(A_TX_er_rd_en),
        .A_TX_er_rd_dout(A_TX_er_rd_dout),
        .A_TX_er_empty(A_TX_er_empty),
        .A_TX_er_rd_valid(A_TX_er_rd_valid),

        // A_A2B pa fifo connections
        .A_TX_pa_rd_clk(A_TX_pa_rd_clk),
        .A_TX_pa_rd_en(A_TX_pa_rd_en),
        .A_TX_pa_rd_dout(A_TX_pa_rd_dout),
        .A_TX_pa_empty(A_TX_pa_empty),
        .A_TX_pa_rd_valid(A_TX_pa_rd_valid),

        // TX BRAM connections
        .A_TX_bram_clkb(A_TX_bram_clkb),
        .A_TX_bram_enb(A_TX_bram_enb),
        .A_TX_bram_web(A_TX_bram_web),
        .A_TX_bram_addrb(A_TX_bram_addrb),
        .A_TX_bram_dinb(A_TX_bram_dinb)
    );

//****************************** A packet  ******************************



//****************************** B unpacket  ******************************

    // Input
    // wire clk;
    // wire rst_n;
    wire A2B_busy_Net2PP_RX;
    wire A2B_msg_accessed;
    wire [10:0] A2B_sizeRX_msg;
    wire reset_er_parameter;
    wire reset_pa_parameter;

    // Output
    wire A2B_busy_PP2Net_RX;
    wire EVrandombit_full;
    wire PArandombit_full;
    wire [3:0] B_unpacket_state;

    // FIFO, BRAM, and other connections
    wire B_RX_Zbasis_decoy_wr_clk;
    wire [31:0] B_RX_Zbasis_decoy_wr_din;
    wire B_RX_Zbasis_decoy_wr_en;
    wire B_RX_Zbasis_decoy_full;
    assign B_RX_Zbasis_decoy_full = 1'b0;
    wire B_RX_Zbasis_decoy_wr_ack;

    wire B_RX_er_wr_clk;
    wire [31:0] B_RX_er_wr_din;
    wire B_RX_er_wr_en;
    wire B_RX_er_full;
    //assign B_RX_er_full = 1'b0;
    wire B_RX_er_wr_ack;

    wire [63:0] B_RX_EVrandombit_dina;
    wire [13:0] B_RX_EVrandombit_addra;
    wire B_RX_EVrandombit_clka;
    wire B_RX_EVrandombit_ena;
    wire B_RX_EVrandombit_wea;

    wire B_RX_secretkey_length_wr_clk;
    wire [31:0] B_RX_secretkey_length_wr_din;
    wire B_RX_secretkey_length_wr_en;
    wire B_RX_secretkey_length_full;
    wire B_RX_secretkey_length_wr_ack;

    wire [63:0] B_RX_PArandombit_dina;
    wire [13:0] B_RX_PArandombit_addra;
    wire B_RX_PArandombit_clka;
    wire B_RX_PArandombit_ena;
    wire B_RX_PArandombit_wea;

    wire B_RX_bram_clkb;
    wire B_RX_bram_enb;
    wire B_RX_bram_web;
    wire [10:0] B_RX_bram_addrb;
    wire [31:0] B_RX_bram_doutb;


    B_unpacket Bunpacket (
        .clk(clk),                                       // Clock signal
        .rst_n(rst_n),                                   // Reset signal

        .busy_Net2PP_RX(A2B_busy_Net2PP_RX),                 // Input indicating the network to post-processing reception is busy
        .msg_accessed(A2B_msg_accessed),                     // Input indicating message access
        .sizeRX_msg(A2B_sizeRX_msg),                         // Input for size of RX message

        .busy_PP2Net_RX(A2B_busy_PP2Net_RX),                 // Output indicating post-processing to network reception is busy

        .reset_er_parameter(reset_er_parameter),         // Input to reset error reconciliation parameter
        .EVrandombit_full(EVrandombit_full),             // Output indicating EV random bit buffer is full

        .reset_pa_parameter(B_reset_pa_parameter),         // Input to reset post-authentication parameter
        .PArandombit_full(PArandombit_full),             // Output indicating PA random bit buffer is full

        .B_unpacket_state(B_unpacket_state),             // Output state of the B_unpacket FSM

        // B_A2B decoy fifo connections
        .B_RX_Zbasis_decoy_wr_clk(B_RX_Zbasis_decoy_wr_clk),
        .B_RX_Zbasis_decoy_wr_din(B_RX_Zbasis_decoy_wr_din),
        .B_RX_Zbasis_decoy_wr_en(B_RX_Zbasis_decoy_wr_en),
        .B_RX_Zbasis_decoy_full(B_RX_Zbasis_decoy_full),
        .B_RX_Zbasis_decoy_wr_ack(B_RX_Zbasis_decoy_wr_ack),

        // B_A2B ER fifo connections
        .B_RX_er_wr_clk(B_RX_er_wr_clk),
        .B_RX_er_wr_din(B_RX_er_wr_din),
        .B_RX_er_wr_en(B_RX_er_wr_en),
        .B_RX_er_full(B_RX_er_full),
        .B_RX_er_wr_ack(B_RX_er_wr_ack),

        // B_A2B EV random bit bram connections
        .B_RX_EVrandombit_dina(B_RX_EVrandombit_dina),
        .B_RX_EVrandombit_addra(B_RX_EVrandombit_addra),
        .B_RX_EVrandombit_clka(B_RX_EVrandombit_clka),
        .B_RX_EVrandombit_ena(B_RX_EVrandombit_ena),
        .B_RX_EVrandombit_wea(B_RX_EVrandombit_wea),

        // B_A2B secret key length fifo connections
        .B_RX_secretkey_length_wr_clk(B_RX_secretkey_length_wr_clk),
        .B_RX_secretkey_length_wr_din(B_RX_secretkey_length_wr_din),
        .B_RX_secretkey_length_wr_en(B_RX_secretkey_length_wr_en),
        .B_RX_secretkey_length_full(B_RX_secretkey_length_full),
        .B_RX_secretkey_length_wr_ack(B_RX_secretkey_length_wr_ack),

        // B_A2B PA randombit bram connections
        .B_RX_PArandombit_dina(B_RX_PArandombit_dina),
        .B_RX_PArandombit_addra(B_RX_PArandombit_addra),
        .B_RX_PArandombit_clka(B_RX_PArandombit_clka),
        .B_RX_PArandombit_ena(B_RX_PArandombit_ena),
        .B_RX_PArandombit_wea(B_RX_PArandombit_wea),

        // RX BRAM connections
        .B_RX_bram_clkb(B_RX_bram_clkb),
        .B_RX_bram_enb(B_RX_bram_enb),
        .B_RX_bram_web(B_RX_bram_web),
        .B_RX_bram_addrb(B_RX_bram_addrb),
        .B_RX_bram_doutb(B_RX_bram_doutb)
    );

//****************************** B unpacket  ******************************



//****************************** A2B BRAM instantiation ******************************
    
    A2B_BRAM A2Bbram (
        .clka(A_TX_bram_clkb),    // input wire clka
        .ena(A_TX_bram_enb),      // input wire ena
        .wea(A_TX_bram_web),      // input wire [0 : 0] wea
        .addra(A_TX_bram_addrb),  // input wire [10 : 0] addra
        .dina(A_TX_bram_dinb),    // input wire [31 : 0] dina
        .douta(),  // output wire [31 : 0] douta


        .clkb(B_RX_bram_clkb),    // input wire clkb
        .enb(B_RX_bram_enb),      // input wire enb
        .web(B_RX_bram_web),      // input wire [0 : 0] web
        .addrb(B_RX_bram_addrb),  // input wire [10 : 0] addrb
        .dinb(),    // input wire [31 : 0] dinb
        .doutb(B_RX_bram_doutb)  // output wire [31 : 0] doutb
    );

//****************************** A2B BRAM instantiation ******************************



//****************************** A2B model  ******************************
    // Input 
    // wire clk;
    // wire rst_n;
    // wire busy_PP2Net_TX;
    // wire msg_stored;
    // wire [10:0] sizeTX_msg;
    // wire busy_PP2Net_RX;

    // // Output 
    // wire busy_Net2PP_TX;
    // wire busy_Net2PP_RX;
    // wire msg_accessed;
    // wire [10:0] sizeRX_msg; 
    wire [3:0] A2B_state;

    TXRX_model A2Bmodel (
        .clk(clk),                       // Clock signal
        .rst_n(rst_n),                   // Reset signal

        .busy_Net2PP_TX(A2B_busy_Net2PP_TX), // Output indicating the network to post-processing transmission is busy

        .busy_PP2Net_TX(A2B_busy_PP2Net_TX), // Input indicating post-processing to network transmission is busy
        .msg_stored(A2B_msg_stored),         // Input indicating message is stored
        .sizeTX_msg(A2B_sizeTX_msg),         // Input for size of TX message

        .busy_PP2Net_RX(A2B_busy_PP2Net_RX), // Input indicating post-processing to network reception is busy

        .busy_Net2PP_RX(A2B_busy_Net2PP_RX), // Output indicating the network to post-processing reception is busy
        .msg_accessed(A2B_msg_accessed),     // Output indicating message access
        .sizeRX_msg(A2B_sizeRX_msg),         // Output register for size of RX message

        .state(A2B_state)            // Output state of the A2B model FSM
    );

//****************************** A2B model  ******************************





//****************************** B2A test instantiation ******************************
//    wire [3:0] B2A_state;

/*
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
*/
//****************************** B2A test instantiation ******************************
//****************************** B packet  ******************************
    // Input wires
    // wire clk;
    // wire rst_n;
    wire B2A_busy_Net2PP_TX;

    // Output wires and registers
    wire B2A_busy_PP2Net_TX;
    wire B2A_msg_stored;
    wire [10:0] B2A_sizeTX_msg; // Assuming this should be a register based on your module definition

    wire [3:0] B_packet_state;

    // // B_B2A detected fifo connections
    // wire B_TX_detected_rd_clk;
    // wire B_TX_detected_rd_en;
    // wire [31:0] B_TX_detected_rd_dout;
    // wire B_TX_detected_empty;
    // wire B_TX_detected_rd_valid;

    // B_B2A er fifo connections
    wire B_TX_er_rd_clk;
    wire B_TX_er_rd_en;
    wire [31:0] B_TX_er_rd_dout;
    wire B_TX_er_empty;
    wire B_TX_er_rd_valid;

    // TX BRAM connections
    wire B_TX_bram_clkb;
    wire B_TX_bram_enb;
    wire B_TX_bram_web;
    wire [10:0] B_TX_bram_addrb;
    wire [31:0] B_TX_bram_dinb;

    B_packet Bpacket (
        .clk(clk),                                // Clock signal
        .rst_n(rst_n),                            // Reset signal

        .busy_Net2PP_TX(B2A_busy_Net2PP_TX),          // Input indicating the network to post-processing transmission is busy

        .busy_PP2Net_TX(B2A_busy_PP2Net_TX),          // Output indicating post-processing to network transmission is busy
        .msg_stored(B2A_msg_stored),                  // Output indicating message is stored
        .sizeTX_msg(B2A_sizeTX_msg),                  // Output register for message size

        .B_packet_state(B_packet_state),          // Output state of the B_packet FSM

        // B_B2A detected fifo connections
        .B_TX_detected_rd_clk(B_TX_detected_rd_clk),
        .B_TX_detected_rd_en(B_TX_detected_rd_en),
        .B_TX_detected_rd_dout(B_TX_detected_rd_dout),
        .B_TX_detected_empty(B_TX_detected_empty),
        .B_TX_detected_rd_valid(B_TX_detected_rd_valid),

        // B_B2A er fifo connections
        .B_TX_er_rd_clk(B_TX_er_rd_clk),
        .B_TX_er_rd_en(B_TX_er_rd_en),
        .B_TX_er_rd_dout(B_TX_er_rd_dout),
        .B_TX_er_empty(B_TX_er_empty),
        .B_TX_er_rd_valid(B_TX_er_rd_valid),

        // TX BRAM connections
        .B_TX_bram_clkb(B_TX_bram_clkb),
        .B_TX_bram_enb(B_TX_bram_enb),
        .B_TX_bram_web(B_TX_bram_web),
        .B_TX_bram_addrb(B_TX_bram_addrb),
        .B_TX_bram_dinb(B_TX_bram_dinb)
    );
//****************************** B packet  ******************************







//****************************** A unpacket  ******************************
    // Input wires and registers
    // wire clk;
    // wire rst_n;
    wire B2A_busy_Net2PP_RX;
    wire B2A_msg_accessed;
    wire [10:0] B2A_sizeRX_msg; // Assuming it's a wire as per your definition

    // Output wires and registers
    wire B2A_busy_PP2Net_RX;
    wire Zbasis_Xbasis_fifo_full;
    wire [3:0] A_unpacket_state;

    // FIFO, BRAM, and other connections
    // wire A_RX_Zbasis_detected_wr_clk;
    // wire [31:0] A_RX_Zbasis_detected_wr_din;
    // wire A_RX_Zbasis_detected_wr_en;
    // wire A_RX_Zbasis_detected_full;
    // wire A_RX_Zbasis_detected_wr_ack;

    // wire A_RX_Xbasis_detected_wr_clk;
    // wire [63:0] A_RX_Xbasis_detected_wr_din;
    // wire A_RX_Xbasis_detected_wr_en;
    // wire A_RX_Xbasis_detected_full;
    // wire A_RX_Xbasis_detected_wr_ack;

    wire A_RX_er_wr_clk;
    wire [31:0] A_RX_er_wr_din;
    wire A_RX_er_wr_en;
    wire A_RX_er_full;
    wire A_RX_er_wr_ack;

    wire A_RX_bram_clkb;
    wire A_RX_bram_enb;
    wire A_RX_bram_web;
    wire [10:0] A_RX_bram_addrb; // Declared as a register as per your module definition
    wire [31:0] A_RX_bram_doutb;

    A_unpacket Aunpacket (
        .clk(clk),                                       // Clock signal
        .rst_n(rst_n),                                   // Reset signal

        .busy_Net2PP_RX(B2A_busy_Net2PP_RX),                 // Input indicating the network to post-processing reception is busy
        .msg_accessed(B2A_msg_accessed),                     // Input indicating message access
        .sizeRX_msg(B2A_sizeRX_msg),                         // Input for size of RX message

        .busy_PP2Net_RX(B2A_busy_PP2Net_RX),                 // Output indicating post-processing to network reception is busy

        .reset_sift_parameter(reset_sift_parameter),     // Input to reset sift parameters
        .Zbasis_Xbasis_fifo_full(Zbasis_Xbasis_fifo_full), // Output indicating fifo full status

        .A_unpacket_state(A_unpacket_state),             // Output state of the A_unpacket FSM

        // A_B2A Zbasis fifo connections
        .A_RX_Zbasis_detected_wr_clk(A_RX_Zbasis_detected_wr_clk),
        .A_RX_Zbasis_detected_wr_din(A_RX_Zbasis_detected_wr_din),
        .A_RX_Zbasis_detected_wr_en(A_RX_Zbasis_detected_wr_en),
        .A_RX_Zbasis_detected_full(A_RX_Zbasis_detected_full),
        .A_RX_Zbasis_detected_wr_ack(A_RX_Zbasis_detected_wr_ack),

        // A_B2A Xbasis fifo connections
        .A_RX_Xbasis_detected_wr_clk(A_RX_Xbasis_detected_wr_clk),
        .A_RX_Xbasis_detected_wr_din(A_RX_Xbasis_detected_wr_din),
        .A_RX_Xbasis_detected_wr_en(A_RX_Xbasis_detected_wr_en),
        .A_RX_Xbasis_detected_full(A_RX_Xbasis_detected_full),
        .A_RX_Xbasis_detected_wr_ack(A_RX_Xbasis_detected_wr_ack),

        // A_B2A er fifo connections
        .A_RX_er_wr_clk(A_RX_er_wr_clk),
        .A_RX_er_wr_din(A_RX_er_wr_din),
        .A_RX_er_wr_en(A_RX_er_wr_en),
        .A_RX_er_full(A_RX_er_full),
        .A_RX_er_wr_ack(A_RX_er_wr_ack),

        // RX BRAM connections
        .A_RX_bram_clkb(A_RX_bram_clkb),
        .A_RX_bram_enb(A_RX_bram_enb),
        .A_RX_bram_web(A_RX_bram_web),
        .A_RX_bram_addrb(A_RX_bram_addrb),
        .A_RX_bram_doutb(A_RX_bram_doutb)
    );

//****************************** A unpacket  ******************************


//****************************** B2A BRAM instantiation ******************************
    
    B2A_BRAM B2Abram (
        .clka(B_TX_bram_clkb),    // input wire clka
        .ena(B_TX_bram_enb),      // input wire ena
        .wea(B_TX_bram_web),      // input wire [0 : 0] wea
        .addra(B_TX_bram_addrb),  // input wire [10 : 0] addra
        .dina(B_TX_bram_dinb),    // input wire [31 : 0] dina
        .douta(),  // output wire [31 : 0] douta


        .clkb(A_RX_bram_clkb),    // input wire clkb
        .enb(A_RX_bram_enb),      // input wire enb
        .web(A_RX_bram_web),      // input wire [0 : 0] web
        .addrb(A_RX_bram_addrb),  // input wire [10 : 0] addrb
        .dinb(),    // input wire [31 : 0] dinb
        .doutb(A_RX_bram_doutb)  // output wire [31 : 0] doutb
    );

//****************************** B2A BRAM instantiation ******************************



//****************************** B2A model  ******************************
    // Input 
    // wire clk;
    // wire rst_n;
    // wire busy_PP2Net_TX;
    // wire msg_stored;
    // wire [10:0] sizeTX_msg;
    // wire busy_PP2Net_RX;

    // // Output 
    // wire busy_Net2PP_TX;
    // wire busy_Net2PP_RX;
    // wire msg_accessed;
    // wire [10:0] sizeRX_msg; 
    wire [3:0] B2A_state;

    TXRX_model B2Amodel (
        .clk(clk),                       // Clock signal
        .rst_n(rst_n),                   // Reset signal

        .busy_Net2PP_TX(B2A_busy_Net2PP_TX), // Output indicating the network to post-processing transmission is busy

        .busy_PP2Net_TX(B2A_busy_PP2Net_TX), // Input indicating post-processing to network transmission is busy
        .msg_stored(B2A_msg_stored),         // Input indicating message is stored
        .sizeTX_msg(B2A_sizeTX_msg),         // Input for size of TX message

        .busy_PP2Net_RX(B2A_busy_PP2Net_RX), // Input indicating post-processing to network reception is busy

        .busy_Net2PP_RX(B2A_busy_Net2PP_RX), // Output indicating the network to post-processing reception is busy
        .msg_accessed(B2A_msg_accessed),     // Output indicating message access
        .sizeRX_msg(B2A_sizeRX_msg),         // Output register for size of RX message

        .state(B2A_state)            // Output state of the A2B model FSM
    );

//****************************** B2A model  ******************************


endmodule