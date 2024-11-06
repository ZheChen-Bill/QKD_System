



`define POST_STNTHESIS_SIM      0

`include "./PP_parameter.v"

`timescale 1ps/1ps


module tb_AB_PP_network ();
//    parameter CLK_PERIOD = 13333; // 75MHz
//    parameter CLK_PERIOD = 12500; // 80MHz
    parameter CLK_PERIOD = 10000; // 100MHz
//    parameter CLK_PERIOD = 8000; // 125MHz

    reg clk;
    reg rst_n;
    reg start_switch;
    
    reg clk_PP;
    wire wait_A_TX;
    reg start_A_TX;
    wire wait_B_TX;
    reg start_B_TX;
    
    reg clock_125M;
    
    reg clock_20M;  
    
    reg link_status;
    reg gmii_tx_clk;
    reg gmii_rx_clk;
    
    wire finish_B_sifting, finish_B_ER, finish_B_PA;
    wire finish_A_sifting, finish_A_ER, finish_A_PA;
    
    // ===== Clk fliping ===== //
	initial begin
		clk = 1;
		forever #(CLK_PERIOD/2) clk = ~clk;
	end
	
	initial begin
		clock_125M = 1;
//		forever #(8000/2) clock_125M = ~clock_125M;
		forever #(CLK_PERIOD/2) clock_125M = ~clock_125M;
	end

	initial begin
		clock_20M = 1;
		forever #(50000/2) clock_20M = ~clock_20M;	
    end
	
    initial begin
		clk_PP = 1;
//		forever #(2667/2) clk_PP = ~clk_PP;
		forever #(3200/2) clk_PP = ~clk_PP;
	end
	
	initial begin
        rst_n = 1;
        #(CLK_PERIOD*2000) rst_n = 0;
        #(CLK_PERIOD*1000) rst_n = 1;  
	end
        
    initial begin
        start_switch = 0;
		wait (rst_n == 0);
		wait (rst_n == 1);
        #(CLK_PERIOD*4000);
        @(negedge clk);
        start_switch = 1;
    end
    
    initial begin
        link_status = 1;
    end
    
	initial begin
		gmii_tx_clk = 1;
		forever #(CLK_PERIOD/2) gmii_tx_clk = ~gmii_tx_clk;
	end

	initial begin
		gmii_rx_clk = 1;
		forever #(CLK_PERIOD/2) gmii_rx_clk = ~gmii_rx_clk;
	end

    initial begin
        start_A_TX <= 0;
        
        wait (wait_A_TX == 1); //sifting 1
        #(CLK_PERIOD*10);
        start_A_TX <= 1;
        #(CLK_PERIOD*10);
        start_A_TX <= 0;
        
        wait (wait_A_TX == 1); //sifting 2
        #(CLK_PERIOD*10);
        start_A_TX <= 1;
        #(CLK_PERIOD*10);
        start_A_TX <= 0;
        
        wait ((wait_A_TX == 1) && (finish_B_sifting)); // ER 1 (need wait until Bob side count out the result)
        #(CLK_PERIOD*30);
        start_A_TX <= 1;
        #(CLK_PERIOD*10);
        start_A_TX <= 0;

        wait ((wait_A_TX == 1) && (finish_B_ER)); // PA 1 (need wait until Bob side count out the result)
        #(CLK_PERIOD*30);
        start_A_TX <= 1;
        #(CLK_PERIOD*10);
        start_A_TX <= 0;

    end

    initial begin
        start_B_TX <= 0;
        
        wait (wait_B_TX == 1); //sifting 1
        #(CLK_PERIOD*10);
        start_B_TX <= 1;
        #(CLK_PERIOD*10);
        start_B_TX <= 0;
        
        wait (wait_B_TX == 1); //sifting 2
        #(CLK_PERIOD*10);
        start_B_TX <= 1;
        #(CLK_PERIOD*10);
        start_B_TX <= 0;
        
        wait (wait_B_TX == 1); // ER 1 
        #(CLK_PERIOD*5);
        start_B_TX <= 1;
        #(CLK_PERIOD*10);
        start_B_TX <= 0;

    end
//****************************** setting ******************************
    assign default_sysclk1_300_clk_n = ~clk;
    assign default_sysclk1_300_clk_p = clk;
    assign reset_high = ~rst_n;
//****************************** setting ******************************





//****************************** A&B post-processing ******************************

    // Input wires
    wire default_sysclk1_300_clk_n;
    wire default_sysclk1_300_clk_p;
    wire reset_high;

    // A-side AXImanager BRAM PORT-A connections
    wire [31:0] A_AXImanager_PORTA_addr;
    wire A_AXImanager_PORTA_clk;
    reg [63:0] A_AXImanager_PORTA_din;
    wire [63:0] A_AXImanager_PORTA_dout;
    wire A_AXImanager_PORTA_en;
    wire A_AXImanager_PORTA_rst;
    wire [7:0] A_AXImanager_PORTA_we;

    // A-side EVrandombit BRAM PORT-A connections
    wire [31:0] EVrandombit_PORTA_addr;
    wire EVrandombit_PORTA_clk;
    wire [63:0] EVrandombit_PORTA_din;
    wire [63:0] EVrandombit_PORTA_dout;
    wire EVrandombit_PORTA_en;
    wire EVrandombit_PORTA_rst;
    wire [7:0] EVrandombit_PORTA_we;

    // A-side PArandombit BRAM PORT-A connections
    wire [31:0] PArandombit_PORTA_addr;
    wire PArandombit_PORTA_clk;
    wire [63:0] PArandombit_PORTA_din;
    wire [63:0] PArandombit_PORTA_dout;
    wire PArandombit_PORTA_en;
    wire PArandombit_PORTA_rst;
    wire [7:0] PArandombit_PORTA_we;

    // A-side QC BRAM PORT-A connections
    wire [31:0] QC_PORTA_addr;
    wire QC_PORTA_clk;
    wire [63:0] QC_PORTA_din;
    wire [63:0] QC_PORTA_dout;
    wire QC_PORTA_en;
    wire QC_PORTA_rst;
    wire [7:0] QC_PORTA_we;

    // A-side Qubit BRAM PORT-A connections
    wire [31:0] Qubit_PORTA_addr;
    wire Qubit_PORTA_clk;
    wire [63:0] Qubit_PORTA_din;
    wire [63:0] Qubit_PORTA_dout;
    wire Qubit_PORTA_en;
    wire Qubit_PORTA_rst;
    wire [7:0] Qubit_PORTA_we;

    // A-side Secretkey BRAM PORT-A connections
    reg [31:0] A_Secretkey_PORTA_addr;
    wire A_Secretkey_PORTA_clk;
    wire [63:0] A_Secretkey_PORTA_din;
    wire [63:0] A_Secretkey_PORTA_dout;
    wire A_Secretkey_PORTA_en;
    wire A_Secretkey_PORTA_rst;
    wire [7:0] A_Secretkey_PORTA_we;

    // B-side AXImanager BRAM PORT-A connections
    wire [31:0] B_AXImanager_PORTA_addr;
    wire B_AXImanager_PORTA_clk;
    reg [63:0] B_AXImanager_PORTA_din;
    wire [63:0] B_AXImanager_PORTA_dout;
    wire B_AXImanager_PORTA_en;
    wire B_AXImanager_PORTA_rst;
    wire [7:0] B_AXImanager_PORTA_we;

    // B-side X-basis detected pos BRAM PORT-A connections
    wire [31:0] Xbasis_detected_pos_PORTA_addr;
    wire Xbasis_detected_pos_PORTA_clk;
    wire [63:0] Xbasis_detected_pos_PORTA_din;
    wire [63:0] Xbasis_detected_pos_PORTA_dout;
    wire Xbasis_detected_pos_PORTA_en;
    wire Xbasis_detected_pos_PORTA_rst;
    wire [7:0] Xbasis_detected_pos_PORTA_we;

    // B-side Z-basis detected pos BRAM PORT-A connections
    wire [31:0] Zbasis_detected_pos_PORTA_addr;
    wire Zbasis_detected_pos_PORTA_clk;
    wire [63:0] Zbasis_detected_pos_PORTA_din;
    wire [63:0] Zbasis_detected_pos_PORTA_dout;
    wire Zbasis_detected_pos_PORTA_en;
    wire Zbasis_detected_pos_PORTA_rst;
    wire [7:0] Zbasis_detected_pos_PORTA_we;

    // B-side Secretkey BRAM PORT-A connections
    reg [31:0] B_Secretkey_PORTA_addr;
    wire B_Secretkey_PORTA_clk;
    wire [63:0] B_Secretkey_PORTA_din;
    wire [63:0] B_Secretkey_PORTA_dout;
    wire B_Secretkey_PORTA_en;
    wire B_Secretkey_PORTA_rst;
    wire [7:0] B_Secretkey_PORTA_we;





    //    wire [63:0] Asiftedkey_dina;      //Alice sifted key 
    //    wire [14:0] Asiftedkey_addra;    //0~32767
    //    wire Asiftedkey_clka;
    //    wire Asiftedkey_ena;                   //1'b1
    //    wire Asiftedkey_wea;                  //

    wire [10:0]A_RX_bram_addrb;
    wire A_RX_bram_clkb;
    wire [31:0]A_RX_bram_dinb;
    wire [31:0]A_RX_bram_doutb;
    wire A_RX_bram_enb;
    wire [0:0]A_RX_bram_web;

    wire [10:0]A_TX_bram_addrb;
    wire A_TX_bram_clkb;
    wire [31:0]A_TX_bram_dinb;
    wire [31:0]A_TX_bram_doutb;
    wire A_TX_bram_enb;
    wire [0:0]A_TX_bram_web;

     wire [31:0]AXImanager_PORTA_addr;
     wire AXImanager_PORTA_clk;
     wire [63:0]AXImanager_PORTA_din;
     wire [63:0]AXImanager_PORTA_dout;
     wire AXImanager_PORTA_en;
     wire AXImanager_PORTA_rst;
     wire [7:0]AXImanager_PORTA_we;

     wire [31:0]EVrandombit_PORTA_addr;
     wire EVrandombit_PORTA_clk;
     wire [63:0]EVrandombit_PORTA_din;
     wire [63:0]EVrandombit_PORTA_dout;
     wire EVrandombit_PORTA_en;
     wire EVrandombit_PORTA_rst;
     wire [7:0]EVrandombit_PORTA_we;

     wire [31:0]PArandombit_PORTA_addr;
     wire PArandombit_PORTA_clk;
     wire [63:0]PArandombit_PORTA_din;
     wire [63:0]PArandombit_PORTA_dout;
     wire PArandombit_PORTA_en;
     wire PArandombit_PORTA_rst;
     wire [7:0]PArandombit_PORTA_we;

     wire [31:0]QC_PORTA_addr;
     wire QC_PORTA_clk;
     wire [63:0]QC_PORTA_din;
     wire [63:0]QC_PORTA_dout;
     wire QC_PORTA_en;
     wire QC_PORTA_rst;
     wire [7:0]QC_PORTA_we;

     wire [31:0]Qubit_PORTA_addr;
     wire Qubit_PORTA_clk;
     wire [63:0]Qubit_PORTA_din;
     wire [63:0]Qubit_PORTA_dout;
     wire Qubit_PORTA_en;
     wire Qubit_PORTA_rst;
     wire [7:0]Qubit_PORTA_we;

     wire [31:0]Secretkey_PORTA_addr;
     wire Secretkey_PORTA_clk;
     wire [63:0]Secretkey_PORTA_din;
     wire [63:0]Secretkey_PORTA_dout;
     wire Secretkey_PORTA_en;
     wire Secretkey_PORTA_rst;
     wire [7:0]Secretkey_PORTA_we;

    top_A_PP u_Alice(
        .clk_out_125M(clock_125M),

        .clk_out_20M(clock_20M),
        .proc_rst_n(rst_n),

        .clkTX_msg(A_clkTX_msg),
        .clkRX_msg(A_clkRX_msg),
        
        .start_TX(start_A_TX),
        .wait_TX(wait_A_TX),
        
        .finish_sifting(finish_A_sifting),
        .finish_ER(finish_A_ER),
        .finish_PA(finish_A_PA),
        //        .default_sysclk1_300_clk_n(default_sysclk1_300_clk_n),
        //        .default_sysclk1_300_clk_p(default_sysclk1_300_clk_p),
        //        .reset_high(reset_high),

        //        .clk_out_125M(clk_out_125M),
        //        .rst_n(rst_n),

        // TX - A packet connections
        .busy_Net2PP_TX(A2B_busy_Net2PP_TX),
        .busy_PP2Net_TX(A2B_busy_PP2Net_TX),
        .msg_stored(A2B_msg_stored),
        .sizeTX_msg(A2B_sizeTX_msg),
        // TX BRAM connections
        .A_TX_bram_clkb(A_TX_bram_clkb),
        .A_TX_bram_enb(A_TX_bram_enb),
        .A_TX_bram_web(A_TX_bram_web),
        .A_TX_bram_addrb(A_TX_bram_addrb),
        .A_TX_bram_dinb(A_TX_bram_dinb),

        // RX - A unpacket connections
        .busy_Net2PP_RX(A2B_busy_Net2PP_RX),
        .msg_accessed(A2B_msg_accessed),
        .sizeRX_msg(A2B_sizeRX_msg),
        .busy_PP2Net_RX(A2B_busy_PP2Net_RX),
        // RX BRAM connections
        .A_RX_bram_clkb(A_RX_bram_clkb),
        .A_RX_bram_enb(A_RX_bram_enb),
        .A_RX_bram_web(A_RX_bram_web),
        .A_RX_bram_addrb(A_RX_bram_addrb),
        .A_RX_bram_doutb(A_RX_bram_doutb),
        
        // AXImanager BRAM PORT-A connections
        .AXImanager_PORTA_addr(A_AXImanager_PORTA_addr),
        .AXImanager_PORTA_clk(A_AXImanager_PORTA_clk),
        .AXImanager_PORTA_din(A_AXImanager_PORTA_din),
        .AXImanager_PORTA_dout(A_AXImanager_PORTA_dout),
        .AXImanager_PORTA_en(A_AXImanager_PORTA_en),
        .AXImanager_PORTA_rst(A_AXImanager_PORTA_rst),
        .AXImanager_PORTA_we(A_AXImanager_PORTA_we),

        // EVrandombit BRAM PORT-A connections
        .EVrandombit_PORTA_addr(EVrandombit_PORTA_addr),
        .EVrandombit_PORTA_clk(EVrandombit_PORTA_clk),
        .EVrandombit_PORTA_din(EVrandombit_PORTA_din),
        .EVrandombit_PORTA_dout(EVrandombit_PORTA_dout),
        .EVrandombit_PORTA_en(EVrandombit_PORTA_en),
        .EVrandombit_PORTA_rst(EVrandombit_PORTA_rst),
        .EVrandombit_PORTA_we(EVrandombit_PORTA_we),

        // PArandombit BRAM PORT-A connections
        .PArandombit_PORTA_addr(PArandombit_PORTA_addr),
        .PArandombit_PORTA_clk(PArandombit_PORTA_clk),
        .PArandombit_PORTA_din(PArandombit_PORTA_din),
        .PArandombit_PORTA_dout(PArandombit_PORTA_dout),
        .PArandombit_PORTA_en(PArandombit_PORTA_en),
        .PArandombit_PORTA_rst(PArandombit_PORTA_rst),
        .PArandombit_PORTA_we(PArandombit_PORTA_we),

        // QC BRAM PORT-A connections
        .QC_PORTA_addr(QC_PORTA_addr),
        .QC_PORTA_clk(QC_PORTA_clk),
        .QC_PORTA_din(QC_PORTA_din),
        .QC_PORTA_dout(QC_PORTA_dout),
        .QC_PORTA_en(QC_PORTA_en),
        .QC_PORTA_rst(QC_PORTA_rst),
        .QC_PORTA_we(QC_PORTA_we),
        
        // Qubit BRAM PORT-A connections
        .Qubit_PORTA_addr(Qubit_PORTA_addr),
        .Qubit_PORTA_clk(Qubit_PORTA_clk),
        .Qubit_PORTA_din(Qubit_PORTA_din),
        .Qubit_PORTA_dout(Qubit_PORTA_dout),
        .Qubit_PORTA_en(Qubit_PORTA_en),
        .Qubit_PORTA_rst(Qubit_PORTA_rst),
        .Qubit_PORTA_we(Qubit_PORTA_we),

        // Secretkey BRAM PORT-A connections
        .Secretkey_PORTA_addr(Secretkey_PORTA_addr),
        .Secretkey_PORTA_clk(Secretkey_PORTA_clk),
        .Secretkey_PORTA_din(Secretkey_PORTA_din),
        .Secretkey_PORTA_dout(Secretkey_PORTA_dout),
        .Secretkey_PORTA_en(Secretkey_PORTA_en),
        .Secretkey_PORTA_rst(Secretkey_PORTA_rst),
        .Secretkey_PORTA_we(Secretkey_PORTA_we)
    );
    //---------------------------------------------------------Network of A---------------------------------------------------------
    wire A_clkTX_msg;
    wire A_clkRX_msg;

    wire [31:0] A2B_dataTX_msg; // message from PP 
    wire [10:0] A2B_addrTX_msg; // addr for BRAMMsgTX
    wire [10:0] A2B_sizeTX_msg;                // transmitting message size

    wire [31:0] A2B_dataRX_msg; // message pasrsed from Ethernet frame
    wire [10:0] A2B_addrRX_msg; // addr for BRAMMSGRX
    wire A2B_weRX_msg; // write enable for BRAMMsgRX
    wire [10:0] A2B_sizeRX_msg;               // receoved message size

    wire  [7:0] gmii_txd; // Transmit data from client MAC.
    wire  gmii_tx_en; // Transmit control signal from client MAC.
    wire  gmii_tx_er; // Transmit control signal from client MAC.

    wire [7:0]   gmii_rxd; // Received Data to client MAC.d
    wire           gmii_rx_dv; // Received control signal to client MAC.
    wire           gmii_rx_er;
    //---------------------------------------------------------Network of A---------------------------------------------------------
    networkCentCtrl #(
    .lost_cycle(26'd30),
    .phy_reset_wait(26'd20)
    ) Unetwork_A2B_TX(
        .reset(~rst_n), // system reset
        .clk_PP(clk_PP),          // Same clock domain 
        .clkTX_msg(A_clkTX_msg), // clock for accessing BRAMMsgTX
        .clkRX_msg(A_clkRX_msg), // clock for accessing BRAMMsgRX

        // Post Processing interface
        //------------------------------------
        .busy_PP2Net_TX(A2B_busy_PP2Net_TX), // BRAMMsgTX is used by PP
        .busy_Net2PP_TX(A2B_busy_Net2PP_TX), // BRAMMsgTX is used by NetworkCentCtrl
        .msg_stored(A2B_msg_stored), // msg is stored in BRAMMsgTX by PP 

        .busy_PP2Net_RX(A2B_busy_PP2Net_RX), // BRAMMsgRX is used by PP
        .busy_Net2PP_RX(A2B_busy_Net2PP_RX), // BRAMMsgRX is used by networkCentCtrl
        .msg_accessed(A2B_msg_accessed), // msg is stored in BRAMMsgTX by networkCentCtrl

        .dataTX_msg(A2B_dataTX_msg), // message from PP 
        .addrTX_msg(A2B_addrTX_msg), // addr for BRAMMsgTX
        .sizeTX_msg(A2B_sizeTX_msg), // transmitting message size

        .dataRX_msg(A2B_dataRX_msg), // message pasrsed from Ethernet frame
        .weRX_msg(A2B_weRX_msg), // write enable for BRAMMsgRX
        .addrRX_msg(A2B_addrRX_msg), // addr for BRAMMSGRX
        .sizeRX_msg(A2B_sizeRX_msg), // receoved message size

        // GMII Interface (client MAC <=> PCS)
        //------------------------------------
        .gmii_tx_clk(gmii_tx_clk), // Transmit clock from client MAC.
        .gmii_rx_clk(gmii_rx_clk), // Receive clock to client MAC.
        .link_status(link_status), // Link status: use status_vector[0]
        .gmii_txd(gmii_txd), // Transmit data from client MAC.
        .gmii_tx_en(gmii_tx_en), // Transmit control signal from client MAC.
        .gmii_tx_er(gmii_tx_er), // Transmit control signal from client MAC.
        .gmii_rxd(gmii_rxd), // Received Data to client MAC.
        .gmii_rx_dv(gmii_rx_dv), // Received control signal to client MAC.
        .gmii_rx_er(gmii_rx_er) // Received control signal to client MAC.
    );
    //---------------------------------------------------------Network of A---------------------------------------------------------
    //---------------------------------------------------------TX RX Bram -----------------------------------------------------------
    wire A_clkRX_msg;
    wire A2B_weRX_msg;
    wire [10:0] A2B_addrRX_msg;
    wire [31:0] A2B_dataRX_msg;
    
    wire A_RX_bram_clkb;
    wire A_RX_bram_enb;
    wire A_RX_bram_web;
    wire [10:0] A_RX_bram_addrb;
    wire [31:0] A_RX_bram_doutb;
    
    wire A_clkTX_msg;
    wire [10:0] A2B_addrTX_msg;
    wire [31:0] A2B_dataTX_msg;
    
    wire A_TX_bram_clkb;
    wire A_TX_bram_enb;
    wire A_TX_bram_web;
    wire [10:0] A_TX_bram_addrb;
    wire [31:0] A_TX_bram_dinb;
    
    A_TXRX_BRAM_wrapper A_TXRX_BRAM(
        .A_RX_clka(A_clkRX_msg),
        .A_RX_ena(1'b1),
        .A_RX_wea(A2B_weRX_msg),
        .A_RX_addra(A2B_addrRX_msg),
        .A_RX_dina(A2B_dataRX_msg),
        .A_RX_douta(),

        .A_RX_clkb(A_RX_bram_clkb),
        .A_RX_enb(A_RX_bram_enb),
        .A_RX_web(A_RX_bram_web),
        .A_RX_addrb(A_RX_bram_addrb),
        .A_RX_dinb(),
        .A_RX_doutb(A_RX_bram_doutb),

        .A_TX_clka(A_clkTX_msg),
        .A_TX_ena(1'b1),
        .A_TX_wea(1'b0),
        .A_TX_addra(A2B_addrTX_msg),
        .A_TX_dina(),
        .A_TX_douta(A2B_dataTX_msg),

        .A_TX_clkb(A_TX_bram_clkb),
        .A_TX_enb(A_TX_bram_enb),
        .A_TX_web(A_TX_bram_web),
        .A_TX_addrb(A_TX_bram_addrb),
        .A_TX_dinb(A_TX_bram_dinb),
        .A_TX_doutb()
    );
    //---------------------------------------------------------TX RX Bram -----------------------------------------------------------

    top_B_PP u_Bob(
        .clk_out_125M(clock_125M),

        .proc_rst_n(rst_n),
        
        .clkTX_msg(B_clkTX_msg),
        .clkRX_msg(B_clkRX_msg),
        
        .start_TX(start_B_TX),
        .wait_TX(wait_B_TX),
        
        .finish_sifting(finish_B_sifting),
        .finish_ER(finish_B_ER),
        .finish_PA(finish_B_PA),
//        .default_sysclk1_300_clk_n(default_sysclk1_300_clk_n),
//        .default_sysclk1_300_clk_p(default_sysclk1_300_clk_p),
//        .reset_high(reset_high),

        // TX - B packet connections
        .busy_Net2PP_TX(B2A_busy_Net2PP_TX),
        .busy_PP2Net_TX(B2A_busy_PP2Net_TX),
        .msg_stored(B2A_msg_stored),
        .sizeTX_msg(B2A_sizeTX_msg),

        // TX BRAM
        .B_TX_bram_clkb(B_TX_bram_clkb),
        .B_TX_bram_enb(B_TX_bram_enb),
        .B_TX_bram_web(B_TX_bram_web),
        .B_TX_bram_addrb(B_TX_bram_addrb),
        .B_TX_bram_dinb(B_TX_bram_dinb),

        // RX - B unpacket connections
        .busy_Net2PP_RX(B2A_busy_Net2PP_RX),
        .msg_accessed(B2A_msg_accessed),
        .sizeRX_msg(B2A_sizeRX_msg),
        .busy_PP2Net_RX(B2A_busy_PP2Net_RX),

        // RX BRAM
        .B_RX_bram_clkb(B_RX_bram_clkb),
        .B_RX_bram_enb(B_RX_bram_enb),
        .B_RX_bram_web(B_RX_bram_web),
        .B_RX_bram_addrb(B_RX_bram_addrb),
        .B_RX_bram_doutb(B_RX_bram_doutb),

        // AXImanager BRAM PORT-A connections
        .AXImanager_PORTA_addr(B_AXImanager_PORTA_addr),
        .AXImanager_PORTA_clk(B_AXImanager_PORTA_clk),
        .AXImanager_PORTA_din(B_AXImanager_PORTA_din),
        .AXImanager_PORTA_dout(B_AXImanager_PORTA_dout),
        .AXImanager_PORTA_en(B_AXImanager_PORTA_en),
        .AXImanager_PORTA_rst(B_AXImanager_PORTA_rst),
        .AXImanager_PORTA_we(B_AXImanager_PORTA_we),

        // X-basis detected pos BRAM PORT-A connections
        .Xbasis_detected_pos_PORTA_addr(Xbasis_detected_pos_PORTA_addr),
        .Xbasis_detected_pos_PORTA_clk(Xbasis_detected_pos_PORTA_clk),
        .Xbasis_detected_pos_PORTA_din(Xbasis_detected_pos_PORTA_din),
        .Xbasis_detected_pos_PORTA_dout(Xbasis_detected_pos_PORTA_dout),
        .Xbasis_detected_pos_PORTA_en(Xbasis_detected_pos_PORTA_en),
        .Xbasis_detected_pos_PORTA_rst(Xbasis_detected_pos_PORTA_rst),
        .Xbasis_detected_pos_PORTA_we(Xbasis_detected_pos_PORTA_we),

        // Z-basis detected pos BRAM PORT-A connections
        .Zbasis_detected_pos_PORTA_addr(Zbasis_detected_pos_PORTA_addr),
        .Zbasis_detected_pos_PORTA_clk(Zbasis_detected_pos_PORTA_clk),
        .Zbasis_detected_pos_PORTA_din(Zbasis_detected_pos_PORTA_din),
        .Zbasis_detected_pos_PORTA_dout(Zbasis_detected_pos_PORTA_dout),
        .Zbasis_detected_pos_PORTA_en(Zbasis_detected_pos_PORTA_en),
        .Zbasis_detected_pos_PORTA_rst(Zbasis_detected_pos_PORTA_rst),
        .Zbasis_detected_pos_PORTA_we(Zbasis_detected_pos_PORTA_we),

        // Secretkey BRAM PORT-A connections
        .Secretkey_PORTA_addr(Secretkey_PORTA_addr),
        .Secretkey_PORTA_clk(Secretkey_PORTA_clk),
        .Secretkey_PORTA_din(Secretkey_PORTA_din),
        .Secretkey_PORTA_dout(Secretkey_PORTA_dout),
        .Secretkey_PORTA_en(Secretkey_PORTA_en),
        .Secretkey_PORTA_rst(Secretkey_PORTA_rst),
        .Secretkey_PORTA_we(Secretkey_PORTA_we)
    );
    //---------------------------------------------------------Network of B---------------------------------------------------------
    wire B_clkTX_msg;
    wire B_clkRX_msg;

    wire [31:0] B2A_dataTX_msg; // message from PP 
    wire [10:0] B2A_addrTX_msg; // addr for BRAMMsgTX
    wire [10:0] B2A_sizeTX_msg;                // transmitting message size

    wire [31:0] B2A_dataRX_msg; // message pasrsed from Ethernet frame
    wire [10:0] B2A_addrRX_msg; // addr for BRAMMSGRX
    wire B2A_weRX_msg; // write enable for BRAMMsgRX
    wire [10:0] B2A_sizeRX_msg;               // receoved message size

    wire  [7:0] gmii_txd; // Transmit data from client MAC.
    wire  gmii_tx_en; // Transmit control signal from client MAC.
    wire  gmii_tx_er; // Transmit control signal from client MAC.

    wire [7:0]     gmii_rxd; // Received Data to client MAC.d
    wire           gmii_rx_dv; // Received control signal to client MAC.
    wire           gmii_rx_er;



    //---------------------------------------------------------Network of B---------------------------------------------------------
    networkCentCtrl_B #(
    .lost_cycle(26'd30),
    .phy_reset_wait(26'd20)
    ) Unetwork_B2A_TX(
        .reset(~rst_n), // system reset
        .clk_PP(clk_PP),          // Same clock domain         
        .clkTX_msg(B_clkTX_msg), // clock for accessing BRAMMsgTX
        .clkRX_msg(B_clkRX_msg), // clock for accessing BRAMMsgRX

        // Post Processing interface
        //------------------------------------
        .busy_PP2Net_TX(B2A_busy_PP2Net_TX), // BRAMMsgTX is used by PP
        .busy_Net2PP_TX(B2A_busy_Net2PP_TX), // BRAMMsgTX is used by NetworkCentCtrl
        .msg_stored(B2A_msg_stored), // msg is stored in BRAMMsgTX by PP 

        .busy_PP2Net_RX(B2A_busy_PP2Net_RX), // BRAMMsgRX is used by PP
        .busy_Net2PP_RX(B2A_busy_Net2PP_RX), // BRAMMsgRX is used by networkCentCtrl
        .msg_accessed(B2A_msg_accessed), // msg is stored in BRAMMsgTX by networkCentCtrl

        .dataTX_msg(B2A_dataTX_msg), // message from PP 
        .addrTX_msg(B2A_addrTX_msg), // addr for BRAMMsgTX
        .sizeTX_msg(B2A_sizeTX_msg), // transmitting message size

        .dataRX_msg(B2A_dataRX_msg), // message pasrsed from Ethernet frame
        .weRX_msg(B2A_weRX_msg), // write enable for BRAMMsgRX
        .addrRX_msg(B2A_addrRX_msg), // addr for BRAMMSGRX
        .sizeRX_msg(B2A_sizeRX_msg), // receoved message size

        // GMII Interface (client MAC <=> PCS)
        //------------------------------------
        .gmii_tx_clk(gmii_tx_clk), // Transmit clock from client MAC.
        .gmii_rx_clk(gmii_rx_clk), // Receive clock to client MAC.
        .link_status(link_status), // Link status: use status_vector[0]

        .gmii_txd(gmii_rxd), // Transmit data from client MAC.
        .gmii_tx_en(gmii_rx_dv), // Transmit control signal from client MAC.
        .gmii_tx_er(gmii_rx_er), // Transmit control signal from client MAC.

        .gmii_rxd(gmii_txd), // Received Data to client MAC.
        .gmii_rx_dv(gmii_tx_en), // Received control signal to client MAC.
        .gmii_rx_er(gmii_tx_er) // Received control signal to client MAC.
    );
    //---------------------------------------------------------Network of B---------------------------------------------------------
    wire B_clkRX_msg;
    wire B2A_weRX_msg;
    wire [10:0] B2A_addrRX_msg;
    wire [31:0] B2A_dataRX_msg;
    
    wire B_RX_bram_clkb;
    wire B_RX_bram_enb;
    wire B_RX_bram_web;
    wire [10:0] B_RX_bram_addrb;
    wire [31:0] B_RX_bram_doutb;
    
    wire B_clkTX_msg;
    wire [10:0] B2A_addrTX_msg;
    wire [31:0] B2A_dataTX_msg;
    
    wire B_TX_bram_clkb;
    wire B_TX_bram_enb;
    wire B_TX_bram_web;
    wire [10:0] B_TX_bram_addrb;
    wire [31:0] B_TX_bram_dinb;
    
    //---------------------------------------------------------TX RX Bram -----------------------------------------------------------
    B_TXRX_BRAM_wrapper B_TXRX_BRAM(
    .B_RX_clka(B_clkRX_msg),
    .B_RX_ena(1'b1),
    .B_RX_wea(B2A_weRX_msg),
    .B_RX_addra(B2A_addrRX_msg),
    .B_RX_dina(B2A_dataRX_msg),
    .B_RX_douta(),

    .B_RX_clkb(B_RX_bram_clkb),
    .B_RX_enb(B_RX_bram_enb),
    .B_RX_web(B_RX_bram_web),
    .B_RX_addrb(B_RX_bram_addrb),
    .B_RX_dinb(),
    .B_RX_doutb(B_RX_bram_doutb),
    
    .B_TX_clka(B_clkTX_msg),
    .B_TX_ena(1'b1),
    .B_TX_wea(1'b0),
    .B_TX_addra(B2A_addrTX_msg),
    .B_TX_dina(),
    .B_TX_douta(B2A_dataTX_msg),

    
    .B_TX_clkb(B_TX_bram_clkb),
    .B_TX_enb(B_TX_bram_enb),
    .B_TX_web(B_TX_bram_web),
    .B_TX_addrb(B_TX_bram_addrb),
    .B_TX_dinb(B_TX_bram_dinb),
    .B_TX_doutb()
    );
    //---------------------------------------------------------TX RX Bram -----------------------------------------------------------
//****************************** A&B post-processing ******************************








//****************************** BRAM setup ******************************
    // A-side AXImanager BRAM PORT-A connections
    assign A_AXImanager_PORTA_clk = clk;
    assign A_AXImanager_PORTA_en = 1'b1;
    // A-side EVrandombit BRAM PORT-A connections
    assign EVrandombit_PORTA_clk = clk;
    assign EVrandombit_PORTA_en = 1'b1;
    // A-side PArandombit BRAM PORT-A connections
    assign PArandombit_PORTA_clk = clk;
    assign PArandombit_PORTA_en = 1'b1;
    // A-side QC BRAM PORT-A connections
    assign QC_PORTA_clk = clk;
    assign QC_PORTA_en = 1'b1;
    // A-side Qubit BRAM PORT-A connections
    assign Qubit_PORTA_clk = clk;
    assign Qubit_PORTA_en = 1'b1;
    // A-side Secretkey BRAM PORT-A connections
    assign A_Secretkey_PORTA_clk = clk;
    assign A_Secretkey_PORTA_en = 1'b1;



    // B-side AXImanager BRAM PORT-A connections
    assign B_AXImanager_PORTA_clk = clk;
    assign B_AXImanager_PORTA_en = 1'b1;
    // B-side X-basis detected pos BRAM PORT-A connections
    assign Xbasis_detected_pos_PORTA_clk = clk;
    assign Xbasis_detected_pos_PORTA_en = 1'b1;
    // B-side Z-basis detected pos BRAM PORT-A connections
    assign Zbasis_detected_pos_PORTA_clk = clk;
    assign Zbasis_detected_pos_PORTA_en = 1'b1;
    // B-side Secretkey BRAM PORT-A connections
    assign B_Secretkey_PORTA_clk = clk;
    assign B_Secretkey_PORTA_en = 1'b1;
//****************************** BRAM setup ******************************


//****************************** DFF for bram output ******************************
    reg [63:0] A_AXImanager_PORTA_dout_ff , B_AXImanager_PORTA_dout_ff;
    reg [63:0] A_Secretkey_PORTA_dout_ff , B_Secretkey_PORTA_dout_ff;

    always @(posedge clk ) begin
        if (~rst_n) begin
            A_AXImanager_PORTA_dout_ff <= 64'b0;
            B_AXImanager_PORTA_dout_ff <= 64'b0;
            A_Secretkey_PORTA_dout_ff <= 64'b0;
            B_Secretkey_PORTA_dout_ff <= 64'b0;
        end
        else begin
            A_AXImanager_PORTA_dout_ff <= A_AXImanager_PORTA_dout;
            B_AXImanager_PORTA_dout_ff <= B_AXImanager_PORTA_dout;
            A_Secretkey_PORTA_dout_ff <= A_Secretkey_PORTA_dout;
            B_Secretkey_PORTA_dout_ff <= B_Secretkey_PORTA_dout;
        end
    end
//****************************** DFF for bram output ******************************











    reg [`AXIBRAM_WIDTH-1:0] A_Qubit [0:`AXIBRAM_DEPTH-1];
    reg [`AXIBRAM_WIDTH-1:0] PArandombit [0:`AXIRANDOMBIT_DEPTH-1];
    reg [`AXIBRAM_WIDTH-1:0] EVrandombit [0:`AXIRANDOMBIT_DEPTH-1];

    reg [`AXIBRAM_WIDTH-1:0] B_Xbasis_detected_pos [0:`AXIBRAM_DEPTH-1];
    reg [`AXIBRAM_WIDTH-1:0] B_Zbasis_detected_pos [0:`AXIBRAM_DEPTH-1];



	initial begin
		

        // hex value
        $readmemh("D:/LAB/quantum_cryptography/QKD_post_processing/QKD_post_processing/TOP/sim/input_test_pattern/PArandombit.txt", PArandombit);
        $readmemh("D:/LAB/quantum_cryptography/QKD_post_processing/QKD_post_processing/TOP/sim/input_test_pattern/EVrandombit.txt", EVrandombit);

        // binary value
        $readmemb("D:/LAB/quantum_cryptography/QKD_post_processing/QKD_post_processing/TOP/sim/input_test_pattern/input_A_Qubit.txt", A_Qubit);
        $readmemb("D:/LAB/quantum_cryptography/QKD_post_processing/QKD_post_processing/TOP/sim/input_test_pattern/input_B_Xbasis_detected_pos.txt", B_Xbasis_detected_pos);
        $readmemb("D:/LAB/quantum_cryptography/QKD_post_processing/QKD_post_processing/TOP/sim/input_test_pattern/input_B_Zbasis_detected_pos.txt", B_Zbasis_detected_pos);
    end














































//****************************** A matlab fsm ******************************
    // Input 
    // wire clk;
    // wire rst_n;
    // wire start_switch;
    wire write_A_input_bram_finish;
    // wire [63:0] A_AXImanager_PORTA_dout_ff;
    wire read_A_secretkey_1_finish;
    wire read_A_secretkey_2_finish;

    // Output 
    wire write_A_input_bram_en;
    wire read_A_secretkey_1_en;
    wire read_A_secretkey_2_en;
    wire write_A_ready_state_en;
    wire write_A_idle_state_en;
    wire reset_A_cnt;

    // Output 
    wire [4:0] A_matlab_state;

    A_matlab_FSM u_A_matlab_fsm (
        .clk(clk),                                 // Clock signal
        .rst_n(rst_n),                             // Reset signal

        .start_switch(start_switch),               // Input signal to start the FSM
        .write_input_bram_finish(write_A_input_bram_finish), // Input signal indicating input BRAM write finish
        .A_AXImanager_PORTA_dout_ff(A_AXImanager_PORTA_dout_ff), // Input data from AXImanager PORTA
        .read_secretkey_1_finish(read_A_secretkey_1_finish), // Input signal indicating first secret key read finish
        .read_secretkey_2_finish(read_A_secretkey_2_finish), // Input signal indicating second secret key read finish

        .write_input_bram_en(write_A_input_bram_en), // Output signal to enable writing to input BRAM
        .read_secretkey_1_en(read_A_secretkey_1_en), // Output signal to enable reading first secret key
        .read_secretkey_2_en(read_A_secretkey_2_en), // Output signal to enable reading second secret key
        .write_ready_state_en(write_A_ready_state_en), // Output signal to enable writing ready state
        .write_idle_state_en(write_A_idle_state_en),   // Output signal to enable writing idle state
        .reset_cnt(reset_A_cnt),
        .A_matlab_state(A_matlab_state)             // Output register for A's Matlab FSM state
    );

//****************************** A matlab fsm ******************************





//****************************** write_A_input_bram ******************************
    // wire write_A_input_bram_en;
    // wire write_A_input_bram_finish;

    reg [28:0] write_A_input_bram_cnt;
    always @(posedge clk ) begin
        if (~rst_n) begin
            write_A_input_bram_cnt <= 0;
        end
        else if (reset_A_cnt) begin
            write_A_input_bram_cnt <= 0;
        end
        else if (write_A_input_bram_en) begin
            write_A_input_bram_cnt <= write_A_input_bram_cnt + 1;
        end
        else begin
            write_A_input_bram_cnt <= write_A_input_bram_cnt;
        end
    end

    assign write_A_input_bram_finish = (write_A_input_bram_cnt==(`AXIBRAM_DEPTH+10))? 1'b1:1'b0;

    // Qubit for sifting
    assign Qubit_PORTA_we = ((write_A_input_bram_cnt>=1) && (write_A_input_bram_cnt<(`AXIBRAM_DEPTH+1)))? {8{1'b1}}:8'b0;
    assign Qubit_PORTA_addr = (&Qubit_PORTA_we)? {(write_A_input_bram_cnt-1) , 3'b0} : 32'b0;
    assign Qubit_PORTA_din = (&Qubit_PORTA_we)? A_Qubit[(write_A_input_bram_cnt-1)][63:0] : 64'b0;

    // Qubit for QC
    assign QC_PORTA_we = ((write_A_input_bram_cnt>=1) && (write_A_input_bram_cnt<(`AXIBRAM_DEPTH+1)))? {8{1'b1}}:8'b0;
    assign QC_PORTA_addr = (&QC_PORTA_we)? {(write_A_input_bram_cnt-1) , 3'b0} : 32'b0;
    assign QC_PORTA_din = (&QC_PORTA_we)? A_Qubit[(write_A_input_bram_cnt-1)][63:0] : 64'b0;

    // PA random bit
    assign PArandombit_PORTA_we = ((write_A_input_bram_cnt>=1) && (write_A_input_bram_cnt<(`AXIRANDOMBIT_DEPTH+1)))? {8{1'b1}}:8'b0;
    assign PArandombit_PORTA_addr = (&PArandombit_PORTA_we)? {(write_A_input_bram_cnt-1) , 3'b0} : 32'b0;
    assign PArandombit_PORTA_din = (&PArandombit_PORTA_we)? PArandombit[(write_A_input_bram_cnt-1)][63:0] : 64'b0;

    // EV random bit
    assign EVrandombit_PORTA_we = ((write_A_input_bram_cnt>=1) && (write_A_input_bram_cnt<(`AXIRANDOMBIT_DEPTH+1)))? {8{1'b1}}:8'b0;
    assign EVrandombit_PORTA_addr = (&EVrandombit_PORTA_we)? {(write_A_input_bram_cnt-1) , 3'b0} : 32'b0;
    assign EVrandombit_PORTA_din = (&EVrandombit_PORTA_we)? EVrandombit[(write_A_input_bram_cnt-1)][63:0] : 64'b0;
//****************************** write_A_input_bram ******************************

//****************************** read_A_secretkey ******************************
    // wire read_A_secretkey_1_en;
    // wire read_A_secretkey_2_en;
    // wire read_A_secretkey_1_finish;
    // wire read_A_secretkey_2_finish;
    

    reg [28:0] read_A_secretkey_bram_cnt;
    always @(posedge clk ) begin
        if (~rst_n) begin
            read_A_secretkey_bram_cnt <= 0;
        end
        else if (reset_A_cnt) begin
            read_A_secretkey_bram_cnt <= 0;
        end
        else if (read_A_secretkey_1_en || read_A_secretkey_2_en) begin
            read_A_secretkey_bram_cnt <= read_A_secretkey_bram_cnt + 1;
        end
        else begin
            read_A_secretkey_bram_cnt <= read_A_secretkey_bram_cnt;
        end
    end

    assign read_A_secretkey_1_finish = (read_A_secretkey_bram_cnt==(`AXISECRETKEY_DEPTH+10))? 1'b1:1'b0;
    assign read_A_secretkey_2_finish = (read_A_secretkey_bram_cnt==(`AXISECRETKEY_DEPTH+10))? 1'b1:1'b0;

    // secret key read from FPGA to PC
    wire A_Secretkey_PORTA_re;
    reg A_Secretkey_PORTA_re_delay_1 , A_Secretkey_PORTA_re_delay_2;
    assign A_Secretkey_PORTA_we = 8'b0;
    assign A_Secretkey_PORTA_re = ((read_A_secretkey_bram_cnt>=1) && (read_A_secretkey_bram_cnt<(`AXISECRETKEY_DEPTH+1)))? 1'b1:1'b0;

    always @(*) begin
        if (A_Secretkey_PORTA_re & read_A_secretkey_2_en) begin
            A_Secretkey_PORTA_addr = {(read_A_secretkey_bram_cnt-1) , 3'b0} +  (`AXISECRETKEY_DEPTH<<3);
        end
        else if (A_Secretkey_PORTA_re & read_A_secretkey_1_en) begin
            A_Secretkey_PORTA_addr = {(read_A_secretkey_bram_cnt-1) , 3'b0};
        end
        else begin
            A_Secretkey_PORTA_addr = 32'b0;
        end
    end

    always @(posedge clk ) begin
        A_Secretkey_PORTA_re_delay_1 <= A_Secretkey_PORTA_re;
        A_Secretkey_PORTA_re_delay_2 <= A_Secretkey_PORTA_re_delay_1;
    end

//****************************** read_A_secretkey ******************************


//****************************** write_A_state ******************************
    // wire write_A_ready_state_en;
    // wire write_A_idle_state_en;

    assign A_AXImanager_PORTA_addr = (write_A_ready_state_en||write_A_idle_state_en)? `PC_STATE_ADDRESS:`FPGA_STATE_ADDRESS;
    assign A_AXImanager_PORTA_we = {8{write_A_ready_state_en|write_A_idle_state_en}};

    always @(*) begin
        if (write_A_idle_state_en) begin
            A_AXImanager_PORTA_din  = { `NO_USE_BIT_WIDTH'b0,
                                        `ON_STATE,
                                        `IDLE_STATE,
                                        `IDLE_STATE,
                                        `IDLE_STATE,
                                        `IDLE_STATE,
                                        `IDLE_STATE,
                                        `IDLE_STATE,
                                        `WRITER_PC};
        end
        else if (write_A_ready_state_en) begin
            A_AXImanager_PORTA_din  = { `NO_USE_BIT_WIDTH'b0,
                                        `ON_STATE,
                                        `READY_STATE,
                                        `READY_STATE,
                                        `READY_STATE,
                                        `READY_STATE,
                                        `READY_STATE,
                                        `READY_STATE,
                                        `WRITER_PC};
        end
        else begin
            A_AXImanager_PORTA_din = 64'b0;
        end
    end
//****************************** write_A_state ******************************



































//****************************** B matlab fsm ******************************
    // Input 
    // wire clk;
    // wire rst_n;
    // wire start_switch;
    wire write_B_input_bram_finish;
    // wire [63:0] B_AXImanager_PORTA_dout_ff;
    wire read_B_secretkey_1_finish;
    wire read_B_secretkey_2_finish;

    // Output 
    wire write_B_input_bram_en;
    wire read_B_secretkey_1_en;
    wire read_B_secretkey_2_en;
    wire write_B_ready_state_en;
    wire write_B_idle_state_en;
    wire reset_B_cnt;

    // Output 
    wire [4:0] B_matlab_state;

    B_matlab_FSM u_B_matlab_fsm (
        .clk(clk),                                 // Clock signal
        .rst_n(rst_n),                             // Reset signal

        .start_switch(start_switch),               // Input signal to start the FSM
        .write_input_bram_finish(write_B_input_bram_finish), // Input signal indicating input BRAM write finish
        .B_AXImanager_PORTA_dout_ff(B_AXImanager_PORTA_dout_ff), // Input data from AXImanager PORTA
        .read_secretkey_1_finish(read_B_secretkey_1_finish), // Input signal indicating first secret key read finish
        .read_secretkey_2_finish(read_B_secretkey_2_finish), // Input signal indicating second secret key read finish

        .write_input_bram_en(write_B_input_bram_en), // Output signal to enable writing to input BRAM
        .read_secretkey_1_en(read_B_secretkey_1_en), // Output signal to enable reading first secret key
        .read_secretkey_2_en(read_B_secretkey_2_en), // Output signal to enable reading second secret key
        .write_ready_state_en(write_B_ready_state_en), // Output signal to enable writing ready state
        .write_idle_state_en(write_B_idle_state_en),   // Output signal to enable writing idle state
        .reset_cnt(reset_B_cnt),
        .B_matlab_state(B_matlab_state)             // Output register for A's Matlab FSM state
    );


//****************************** B matlab fsm ******************************





//****************************** write_B_input_bram ******************************
    // wire write_B_input_bram_en;
    // wire write_B_input_bram_finish;

    reg [28:0] write_B_input_bram_cnt;
    always @(posedge clk ) begin
        if (~rst_n) begin
            write_B_input_bram_cnt <= 0;
        end
        else if (reset_B_cnt) begin
            write_B_input_bram_cnt <= 0;
        end
        else if (write_B_input_bram_en) begin
            write_B_input_bram_cnt <= write_B_input_bram_cnt + 1;
        end
        else begin
            write_B_input_bram_cnt <= write_B_input_bram_cnt;
        end
    end

    assign write_B_input_bram_finish = (write_B_input_bram_cnt==(`AXIBRAM_DEPTH+10))? 1'b1:1'b0;

    // X-basis detected pos
    assign Xbasis_detected_pos_PORTA_we = ((write_B_input_bram_cnt>=1) && (write_B_input_bram_cnt<(`AXIBRAM_DEPTH+1)))? {8{1'b1}}:8'b0;
    assign Xbasis_detected_pos_PORTA_addr = (&Xbasis_detected_pos_PORTA_we)? {(write_B_input_bram_cnt-1) , 3'b0} : 32'b0;
    assign Xbasis_detected_pos_PORTA_din = (&Xbasis_detected_pos_PORTA_we)? B_Xbasis_detected_pos[(write_B_input_bram_cnt-1)][63:0] : 64'b0;
    // Z-basis detected pos
    assign Zbasis_detected_pos_PORTA_we = ((write_B_input_bram_cnt>=1) && (write_B_input_bram_cnt<(`AXIBRAM_DEPTH+1)))? {8{1'b1}}:8'b0;
    assign Zbasis_detected_pos_PORTA_addr = (&Zbasis_detected_pos_PORTA_we)? {(write_B_input_bram_cnt-1) , 3'b0} : 32'b0;
    assign Zbasis_detected_pos_PORTA_din = (&Zbasis_detected_pos_PORTA_we)? B_Zbasis_detected_pos[(write_B_input_bram_cnt-1)][63:0] : 64'b0;

//****************************** write_B_input_bram ******************************

//****************************** read_B_secretkey ******************************
    // wire read_B_secretkey_1_en;
    // wire read_B_secretkey_2_en;
    // wire read_B_secretkey_1_finish;
    // wire read_B_secretkey_2_finish;
    

    reg [28:0] read_B_secretkey_bram_cnt;
    always @(posedge clk ) begin
        if (~rst_n) begin
            read_B_secretkey_bram_cnt <= 0;
        end
        else if (reset_B_cnt) begin
            read_B_secretkey_bram_cnt <= 0;
        end
        else if (read_B_secretkey_1_en || read_B_secretkey_2_en) begin
            read_B_secretkey_bram_cnt <= read_B_secretkey_bram_cnt + 1;
        end
        else begin
            read_B_secretkey_bram_cnt <= read_B_secretkey_bram_cnt;
        end
    end

    assign read_B_secretkey_1_finish = (read_B_secretkey_bram_cnt==(`AXISECRETKEY_DEPTH+10))? 1'b1:1'b0;
    assign read_B_secretkey_2_finish = (read_B_secretkey_bram_cnt==(`AXISECRETKEY_DEPTH+10))? 1'b1:1'b0;

    // secret key read from FPGA to PC
    wire B_Secretkey_PORTA_re;
    reg B_Secretkey_PORTA_re_delay_1 , B_Secretkey_PORTA_re_delay_2;
    assign B_Secretkey_PORTA_we = 8'b0;
    assign B_Secretkey_PORTA_re = ((read_B_secretkey_bram_cnt>=1) && (read_B_secretkey_bram_cnt<(`AXISECRETKEY_DEPTH+1)))? 1'b1:1'b0;

    always @(*) begin
        if (B_Secretkey_PORTA_re & read_B_secretkey_2_en) begin
            B_Secretkey_PORTA_addr = {(read_B_secretkey_bram_cnt-1) , 3'b0} + (`AXISECRETKEY_DEPTH<<3);
        end
        else if (B_Secretkey_PORTA_re & read_B_secretkey_1_en) begin
            B_Secretkey_PORTA_addr = {(read_B_secretkey_bram_cnt-1) , 3'b0};
        end
        else begin
            B_Secretkey_PORTA_addr = 32'b0;
        end
    end

    always @(posedge clk ) begin
        B_Secretkey_PORTA_re_delay_1 <= B_Secretkey_PORTA_re;
        B_Secretkey_PORTA_re_delay_2 <= B_Secretkey_PORTA_re_delay_1;
    end

//****************************** read_B_secretkey ******************************


//****************************** write_B_state ******************************
    // wire write_B_ready_state_en;
    // wire write_B_idle_state_en;

    assign B_AXImanager_PORTA_addr = (write_B_ready_state_en||write_B_idle_state_en)? `PC_STATE_ADDRESS:`FPGA_STATE_ADDRESS;
    assign B_AXImanager_PORTA_we = {8{write_B_ready_state_en|write_B_idle_state_en}};

    always @(*) begin
        if (write_B_idle_state_en) begin
            B_AXImanager_PORTA_din  = { `NO_USE_BIT_WIDTH'b0,
                                        `ON_STATE,
                                        `IDLE_STATE,
                                        `IDLE_STATE,
                                        `IDLE_STATE,
                                        `IDLE_STATE,
                                        `IDLE_STATE,
                                        `IDLE_STATE,
                                        `WRITER_PC};
        end
        else if (write_B_ready_state_en) begin
            B_AXImanager_PORTA_din  = { `NO_USE_BIT_WIDTH'b0,
                                        `ON_STATE,
                                        `READY_STATE,
                                        `READY_STATE,
                                        `READY_STATE,
                                        `READY_STATE,
                                        `READY_STATE,
                                        `READY_STATE,
                                        `WRITER_PC};
        end
        else begin
            B_AXImanager_PORTA_din = 64'b0;
        end
    end
//****************************** write_A_state ******************************








//****************************** write key out ******************************
    integer A_siftedkey_out;
    integer B_siftedkey_out;

    integer A_reconciledkey_out;
    integer B_reconciledkey_out;

    integer A_secretkey_out;
    integer B_secretkey_out;


    initial begin
        if (`POST_STNTHESIS_SIM) begin
            A_siftedkey_out = $fopen("D:/QKD_HW_project/QKD_post_processing/TOP/HW_sim_result/post_synthesis_sim/A_siftedkey_out.txt", "w");
            B_siftedkey_out = $fopen("D:/QKD_HW_project/QKD_post_processing/TOP/HW_sim_result/post_synthesis_sim/B_siftedkey_out.txt", "w");

            A_reconciledkey_out = $fopen("D:/QKD_HW_project/QKD_post_processing/TOP/HW_sim_result/post_synthesis_sim/A_reconciledkey_out.txt", "w");
            B_reconciledkey_out = $fopen("D:/QKD_HW_project/QKD_post_processing/TOP/HW_sim_result/post_synthesis_sim/B_reconciledkey_out.txt", "w");

            A_secretkey_out = $fopen("D:/QKD_HW_project/QKD_post_processing/TOP/HW_sim_result/post_synthesis_sim/A_secretkey_out.txt", "w");
            B_secretkey_out = $fopen("D:/QKD_HW_project/QKD_post_processing/TOP/HW_sim_result/post_synthesis_sim/B_secretkey_out.txt", "w");
        end
        else begin
            A_siftedkey_out = $fopen("../../../../HW_sim_result/A_siftedkey_out.txt", "w");
            B_siftedkey_out = $fopen("../../../../HW_sim_result/B_siftedkey_out.txt", "w");

            A_reconciledkey_out = $fopen("../../../../HW_sim_result/A_reconciledkey_out.txt", "w");
            B_reconciledkey_out = $fopen("../../../../HW_sim_result/B_reconciledkey_out.txt", "w");

            A_secretkey_out = $fopen("../../../../HW_sim_result/A_secretkey_out.txt", "w");
            B_secretkey_out = $fopen("../../../../HW_sim_result/B_secretkey_out.txt", "w");
        end
    end
//****************************** write key out ******************************


// //****************************** write sifted key out ******************************
//     always @(*) begin
//         if ((test_AB_PP.A_PP.Asiftedkey_ena) && (test_AB_PP.A_PP.Asiftedkey_wea)) begin
//             $fdisplay(A_siftedkey_out,"%h",(test_AB_PP.A_PP.Asiftedkey_dina));
//         end
//     end

//     always @(*) begin
//         if ((test_AB_PP.B_PP.Bsiftedkey_ena) && (test_AB_PP.B_PP.Bsiftedkey_wea)) begin
//             $fdisplay(B_siftedkey_out,"%h",(test_AB_PP.B_PP.Bsiftedkey_dina));
//         end
//     end
// //****************************** write sifted key out ******************************







// //****************************** write reconciled key out ******************************
//     always @(*) begin
//         if ((test_AB_PP.A_PP.Areconciledkey_ena) && (test_AB_PP.A_PP.Areconciledkey_wea)) begin
//             $fdisplay(A_reconciledkey_out,"%h",(test_AB_PP.A_PP.Areconciledkey_dina));
//         end
//     end

//     always @(*) begin
//         if ((test_AB_PP.B_PP.Breconciledkey_ena) && (test_AB_PP.B_PP.Breconciledkey_wea)) begin
//             $fdisplay(B_reconciledkey_out,"%h",(test_AB_PP.B_PP.Breconciledkey_dina));
//         end
//     end
// //****************************** write reconciled key out ******************************






//****************************** write secret key out ******************************

    always @(*) begin
        if (A_Secretkey_PORTA_re_delay_2) begin
            $fdisplay(A_secretkey_out,"%h", (A_Secretkey_PORTA_dout_ff));
        end
    end

    always @(*) begin
        if (B_Secretkey_PORTA_re_delay_2) begin
            $fdisplay(B_secretkey_out,"%h", (B_Secretkey_PORTA_dout_ff));
        end
    end
//****************************** write secret key out ******************************








    always @(*) begin
        if ((A_matlab_state==5'd31) && (B_matlab_state==5'd31)) begin
            $display("[FINISH]");
            $display("[FINISH]");
            $display("[FINISH]");
            $display("[FINISH]");
            $display("[FINISH]");
            $display("[FINISH]");
            $display("[FINISH]");
            #(CLK_PERIOD*10);
            $fclose(A_siftedkey_out);
            $fclose(B_siftedkey_out);

            $fclose(A_reconciledkey_out);
            $fclose(B_reconciledkey_out);

            $fclose(A_secretkey_out);
            $fclose(B_secretkey_out);
            $finish;
        end
    end






endmodule
