



`include "./packet_parameter.v"
`include "./error_reconcilation_parameter.v"


module ER_Alice (

    input clk,
    input rst_n,
    //----------------------------new add signal------------------------------
    input clk_100M,
    //    input clk_GMII,
    input gmii_tx_clk,
    input gmii_rx_clk,


    input clk_PP,
    input link_status,

    output A2B_busy_PP2Net_TX,
    output A2B_busy_Net2PP_TX,

    output A2B_busy_PP2Net_RX,
    output A2B_busy_Net2PP_RX,


    output [7:0] gmii_txd, // Transmit data from client MAC.
    output gmii_tx_en, // Transmit control signal from client MAC.
    output gmii_tx_er, // Transmit control signal from client MAC.
    input   [7:0] gmii_rxd, // Received Data to client MAC.
    input   gmii_rx_dv, // Received control signal to client MAC.
    input   gmii_rx_er, // Received control signal to client MAC.

    output clkTX_msg,
    output clkRX_msg,
    //----------------------------new add signal------------------------------
    
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
//assign start_B_ER = (start_switch_cnt==16'b0000_0000_1111_1100)? 1'b1:1'b0;

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

//****************************** A packet  *******************************************
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
        .clk(clkTX_msg),                            // Clock signal
        .rst_n(rst_n),                     // Reset signal

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


//****************************** A2B BRAM instantiation ******************************
    
    A2B_BRAM_TX A2Bbram_TX (
        .clka(clkTX_msg), // input wire clkb
        .ena(1'b1), // input wire enb
        .wea(1'b0), // input wire [0 : 0] web
        .addra(A2B_addrTX_msg), // input wire [10 : 0] addrb
        .dina(), // input wire [31 : 0] dinb
        .douta(A2B_dataTX_msg), // output wire [31 : 0] doutb

        .clkb(A_TX_bram_clkb), // input wire clka
        .enb(A_TX_bram_enb), // input wire ena
        .web(A_TX_bram_web), // input wire [0 : 0] wea
        .addrb(A_TX_bram_addrb), // input wire [10 : 0] addra
        .dinb(A_TX_bram_dinb), // input wire [31 : 0] dina
        .doutb() // output wire [31 : 0] douta
    );

    A2B_BRAM A2Bbram_RX (
        .clka(clkRX_msg), // input wire clka
        .ena(1'b1), // input wire ena
        .wea(A2B_weRX_msg), // input wire [0 : 0] wea
        .addra(A2B_addrRX_msg), // input wire [10 : 0] addra
        .dina(A2B_dataRX_msg), // input wire [31 : 0] dina
        .douta(), // output wire [31 : 0] douta

        .clkb(A_RX_bram_clkb), // input wire clkb
        .enb(A_RX_bram_enb), // input wire enb
        .web(A_RX_bram_web), // input wire [0 : 0] web
        .addrb(A_RX_bram_addrb), // input wire [10 : 0] addrb
        .dinb(), // input wire [31 : 0] dinb
        .doutb(A_RX_bram_doutb) // output wire [31 : 0] doutb
    );
//****************************** A2B BRAM instantiation ******************************

//****************************** A unpacket  ******************************
    // Input wires
    // wire clk;
    // wire rst_n;
    wire A2B_busy_Net2PP_TX;

    // Output wires and registers
    wire A2B_busy_PP2Net_TX;
    wire A2B_msg_stored;
    wire [10:0] A2B_sizeTX_msg; // Assuming this should be a register based on your module definition
    
    // Input wires and registers
    // wire clk;
    // wire rst_n;
    wire A2B_busy_Net2PP_RX;
    wire A2B_msg_accessed;
    wire [10:0] A2B_sizeRX_msg; // Assuming it's a wire as per your definition

    // Output wires and registers
    wire A2B_busy_PP2Net_RX;
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
        .clk(clkRX_msg),                                       // Clock signal
        .rst_n(rst_n),                                   // Reset signal

        .busy_Net2PP_RX(A2B_busy_Net2PP_RX),                 // Input indicating the network to post-processing reception is busy
        .msg_accessed(A2B_msg_accessed),                     // Input indicating message access
        .sizeRX_msg(A2B_sizeRX_msg),                         // Input for size of RX message

        .busy_PP2Net_RX(A2B_busy_PP2Net_RX),                 // Output indicating post-processing to network reception is busy

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
//--------------------------------------------Network module of A--------------------------
    wire  [7:0] gmii_txd;             // Transmit data from client MAC.
    wire  gmii_tx_en;            // Transmit control signal from client MAC.
    wire  gmii_tx_er;            // Transmit control signal from client MAC.
    
    wire [7:0]     gmii_rxd;              // Received Data to client MAC.d
    wire           gmii_rx_dv;            // Received control signal to client MAC.
    wire           gmii_rx_er;
    
    wire clkTX_msg;
    wire clkRX_msg;

    wire [31:0] A2B_dataTX_msg;                // message from PP 
    wire [10:0] A2B_addrTX_msg;               // addr for BRAMMsgTX
    wire [10:0] A2B_sizeTX_msg;                // transmitting message size
        
    wire [31:0] A2B_dataRX_msg;               // message pasrsed from Ethernet frame
    wire [10:0] A2B_addrRX_msg;               // addr for BRAMMSGRX
    wire A2B_weRX_msg;                        // write enable for BRAMMsgRX
    wire [10:0] A2B_sizeRX_msg;               // receoved message size


    wire [3:0] network_fsm_TCP_A_TX;
    wire [2:0] transfer_fsm_A_TX;
    wire [2:0] network_fsm_TX_A_TX;
    wire [1:0] network_fsm_RX_A_TX;

    wire start_handle_FrameSniffer_A_TX;
    
    wire received_valid_A_TX;
    wire need_ack_A_TX;
    wire is_handshake_A_TX;
    wire transfer_en_A_TX;
    wire busy_TX2CentCtrl_A_TX;
    wire transfer_finish_A_TX;
    wire [10:0] index_frame_FrameGenerator_A_TX;
    wire [7:0] frame_data_FrameGenerator_A_TX;
    wire [15:0] total_len_TCP_FrameGenerator_A_TX;
    wire [63:0] douta_FrameGenerator_A_TX;
    wire [7:0] keep_crc32_FrameGenerator_A_TX;
    wire crc32_valid_FrameGenerator_A_TX;
    wire ack_received_A_TX;
    wire ack_received_cdc_after_FrameGenerator_A_TX;
    wire [15:0] sizeTX_msg_buf_FrameGenerator_A_TX;
    wire [15:0] base_addr_tmp_FrameGenerator_A_TX;
    wire [10:0] addr_gmii_FrameSniffer_A_TX;
    wire [15:0] tcp_segment_len_FrameSniffer_A_TX;
    wire [63:0] packet_in_crc32_FrameSniffer_A_TX;
    wire [7:0] keep_crc32_FrameSniffer_A_TX;
    wire [31:0] crc32_out_FrameSniffer_A_TX;
    wire [31:0] seq_RX_A_TX;
    wire [31:0] ack_RX_A_TX;
    wire [25:0] lost_A_TX;
    wire [19:0] tcp_chksum_FrameSniffer_A_TX;
    wire [19:0] network_chksum_FrameSniffer_A_TX;
    wire [31:0] FCS_received_FrameSniffer_A_TX;
    wire packet_valid_FrameSniffer_A_TX;
    wire msg_accessed_en_FrameSniffer_A_TX;
//    wire lost_cnt_en;
    
//---------------------------------------------TX module of A-------------------------
    networkCentCtrl #(
        .lost_cycle(26'd30),
        .phy_reset_wait(26'd20)
    ) Unetwork_A2B_TX(
        .reset(~rst_n),                 // system reset
//        .clock_100M(clk_100M),            // clock for JTAG module 
        .clk_PP(clk_PP),
        .clkTX_msg(clkTX_msg),                // clock for accessing BRAMMsgTX
        .clkRX_msg(clkRX_msg),                // clock for accessing BRAMMsgRX

        // Post Processing interface
        //------------------------------------
        .busy_PP2Net_TX(A2B_busy_PP2Net_TX),                   // BRAMMsgTX is used by PP
        .busy_Net2PP_TX(A2B_busy_Net2PP_TX),                  // BRAMMsgTX is used by NetworkCentCtrl
        .msg_stored(A2B_msg_stored),                       // msg is stored in BRAMMsgTX by PP 
        
        .busy_PP2Net_RX(A2B_busy_PP2Net_RX),                   // BRAMMsgRX is used by PP
        .busy_Net2PP_RX(A2B_busy_Net2PP_RX),                  // BRAMMsgRX is used by networkCentCtrl
        .msg_accessed(A2B_msg_accessed),                    // msg is stored in BRAMMsgTX by networkCentCtrl

        .dataTX_msg(A2B_dataTX_msg),                // message from PP 
        .addrTX_msg(A2B_addrTX_msg),               // addr for BRAMMsgTX
        .sizeTX_msg(A2B_sizeTX_msg),                // transmitting message size
        
        .dataRX_msg(A2B_dataRX_msg),               // message pasrsed from Ethernet frame
        .weRX_msg(A2B_weRX_msg),                        // write enable for BRAMMsgRX
        .addrRX_msg(A2B_addrRX_msg),               // addr for BRAMMSGRX
        .sizeRX_msg(A2B_sizeRX_msg),               // receoved message size
        
        // GMII Interface (client MAC <=> PCS)
        //------------------------------------
        .gmii_tx_clk(gmii_tx_clk),           // Transmit clock from client MAC.
        .gmii_rx_clk(gmii_rx_clk),           // Receive clock to client MAC.
        .link_status(link_status),           // Link status: use status_vector[0]
        .gmii_txd(gmii_txd),              // Transmit data from client MAC.
        .gmii_tx_en(gmii_tx_en),            // Transmit control signal from client MAC.
        .gmii_tx_er(gmii_tx_er),            // Transmit control signal from client MAC.
        .gmii_rxd(gmii_rxd),              // Received Data to client MAC.
        .gmii_rx_dv(gmii_rx_dv),            // Received control signal to client MAC.
        .gmii_rx_er(gmii_rx_er)            // Received control signal to client MAC.
        // Test signal 
        ,
        .network_fsm_TCP(network_fsm_TCP_A_TX),
        .transfer_fsm(transfer_fsm_A_TX),
        .network_fsm_TX(network_fsm_TX_A_TX),
        .network_fsm_RX(network_fsm_RX_A_TX),
        .start_handle_FrameSniffer(start_handle_FrameSniffer_A_TX),
        .received_valid(received_valid_A_TX),
        .need_ack(need_ack_A_TX),
        .is_handshake(is_handshake_A_TX),
        .transfer_finish(transfer_finish_A_TX),
        .transfer_en(transfer_en_A_TX),
        .busy_TX2CentCtrl(busy_TX2CentCtrl_A_TX),
        .index_frame_FrameGenerator(index_frame_FrameGenerator_A_TX),
        .frame_data_FrameGenerator(frame_data_FrameGenerator_A_TX),
        .total_len_TCP_FrameGenerator(total_len_TCP_FrameGenerator_A_TX),
        .douta_FrameGenerator(douta_FrameGenerator_A_TX),
        .keep_crc32_FrameGenerator(keep_crc32_FrameGenerator_A_TX),
        .crc32_valid_FrameGenerator(crc32_valid_FrameGenerator_A_TX),
        .ack_received_cdc_after_FrameGenerator(ack_received_cdc_after_FrameGenerator_A_TX),
        .ack_received(ack_received_A_TX),
        .sizeTX_msg_buf_FrameGenerator(sizeTX_msg_buf_FrameGenerator_A_TX),
        .base_addr_tmp_FrameGenerator(base_addr_tmp_FrameGenerator_A_TX),
        .addr_gmii_FrameSniffer(addr_gmii_FrameSniffer_A_TX),
        .tcp_segment_len_FrameSniffer(tcp_segment_len_FrameSniffer_A_TX),
        .packet_in_crc32_FrameSniffer(packet_in_crc32_FrameSniffer_A_TX),
        .keep_crc32_FrameSniffer(keep_crc32_FrameSniffer_A_TX),
        .crc32_out_FrameSniffer(crc32_out_FrameSniffer_A_TX),
        .seq_RX(seq_RX_A_TX),
        .ack_RX(ack_RX_A_TX),
        .lost(lost_A_TX),
        .FCS_received_FrameSniffer(FCS_received_FrameSniffer_A_TX),
        .packet_valid_FrameSniffer(packet_valid_FrameSniffer_A_TX),
        .tcp_chksum_FrameSniffer(tcp_chksum_FrameSniffer_A_TX),
        .network_chksum_FrameSniffer(network_chksum_FrameSniffer_A_TX),
        .msg_accessed_en_FrameSniffer(msg_accessed_en_FrameSniffer_A_TX)
//        .lost_cnt_en(lost_cnt_en)
);
//--------------------------------TX module of A------------------------------------


endmodule