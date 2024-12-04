`timescale 1ps/1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/18 16:19:54
// Design Name: 
// Module Name: top_Alice
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`include "PP_parameter.v"

module top_Alice(

    // global reset 
    input reset,

    // system clock -- 300M Hz
    input clk_300M_n,
    input clk_300M_p,

    // GT reference clock for PHY module
    input gtrefclk_p,
    input gtrefclk_n,
    // TX and RX port for connecting SFP
    output txp,
    output txn,
    input rxp,
    input rxn,
    // TX enable signal connecting to SFP module 
    output tx_disable,

    input start_switch,
    input start_TX,

    output reg output_clk,
    input independent_clk_en,
    input io_refclk_en,
    input gmii_rx_clk_en,
    output [7:0] tcp_status

    // Test signal
    //    ,
    //    output [10:0] addrRX_msg_jtag,
    //    output clkRX_msg_jtag,
    //    output [31:0] dataRX_msg_jtag,
    //    output weRX_msg_jtag,
    //    output [31:0] dataRX_msg_buf_jtag
);

    always @* begin
        output_clk = 1'b0;
        if (independent_clk_en) begin
            output_clk = independent_clk;
        end else if (io_refclk_en) begin
            output_clk = io_refclk;
        end else if (gmii_rx_clk_en) begin
            output_clk = gmii_rx_clk;
        end
    end
    wire independent_clk;
    wire io_refclk;
    wire clk_fast;

    wire txn, txp, rxn, rxp;
    wire gmii_rx_clk, gmii_tx_clk;
    wire clock_100M;
    wire clock_125M;
    wire clock_20M;
    wire clock_15M;
    wire proc_rst_n;

    wire [7:0]gmii_txd; // Transmit data from client MAC.
    wire gmii_tx_en; // Transmit control signal from client MAC.
    wire gmii_tx_er; // Transmit control signal from client MAC.
    wire [7:0]gmii_rxd; // Received Data to client MAC.
    wire gmii_rx_dv; // Received control signal to client MAC.
    wire gmii_rx_er; // Received control signal to client MAC.

    wire [15:0] status_vector;

    reg A_sifting_finish_reg;

    //    assign link_status = status_vector[0] & status_vector[1];
    assign link_status = status_vector;
    //    assign link_status = 1'b1;
    wire [3:0] network_fsm_TCP_TX;
    assign achieve = (network_fsm_TCP_TX == 4'd3)  ? 1'b1 : 1'b0; // network_fsm_TCP has reached TRANSFER_TCP state
    assign disconnect = (network_fsm_TCP_TX == 4'd0)  ? 1'b1 : 1'b0;
    assign handshake0 = (network_fsm_TCP_TX == 4'd2)  ? 1'b1 : 1'b0;
    assign handshake1 = (network_fsm_TCP_TX == 4'd4)  ? 1'b1 : 1'b0;
    assign handshake = (network_fsm_TCP_TX == 4'd1) ? 1'b1 : 1'b0;
    assign ack_t = (network_fsm_TCP_TX == 4'd6) ? 1'b1 : 1'b0;
    assign ack_r = (network_fsm_TCP_TX == 4'd5) ? 1'b1 : 1'b0;

    //                                          LED7      LED6               LED5          LED4                LED3    LED2        LED1                                 LED0
    //    assign tcp_status = {link_status, handshake0, handshake, handshake1, achieve, ack_t, A2B_busy_Net2PP_RX, A2B_busy_Net2PP_TX};

    //                                          LED7      LED6               LED5                             LED4                       LED3          LED2        LED1      LED0
    assign tcp_status = {link_status, achieve, A2B_busy_Net2PP_RX, A2B_busy_Net2PP_TX, start_switch , start_TX, wait_TX, 1'b0};



    assign tx_disable = 1'b1;

    clock_generator_wrapper Uclk_gen
    (
        .clk_in1_n(clk_300M_n), // input
        .clk_in1_p(clk_300M_p), // input
        .clk_out1_62_5M(independent_clk), // output
        .clk_out2_100M(clock_100M), // output
        .clk_out5_125M(clock_125M), // output
        
        .clk_out6_15M(clock_15M), // output
//        .clk_out6_20M(clock_20M), // output
        .clk_out3_300M(io_refclk), // output
        .clk_out4_375M(clk_fast), // output
//        .clk_out4_312_5M(clk_fast), // output

        .reset(reset), // input
        .proc_rst_n(proc_rst_n) // output
    );


    top_phy Utop_phy
    (
        .independent_clock(independent_clk),
        .io_refclk(io_refclk),

        // Tranceiver Interface
        //---------------------
        .gtrefclk_p(gtrefclk_p), // Differential +ve of reference clock for MGT: very high quality.
        .gtrefclk_n(gtrefclk_n), // Differential -ve of reference clock for MGT: very high quality.
        .txp(txp), // Differential +ve of serial transmission from PMA to PMD.
        .txn(txn), // Differential -ve of serial transmission from PMA to PMD.
        .rxp(rxp), // Differential +ve for serial reception from PMD to PMA.
        .rxn(rxn), // Differential -ve for serial reception from PMD to PMA.

        // GMII Interface (client MAC <=> PCS)
        //------------------------------------
        .gmii_tx_clk(gmii_tx_clk), // Transmit clock from client MAC.
        .gmii_rx_clk(gmii_rx_clk), // Receive clock to client MAC.
        .gmii_txd(gmii_txd), // Transmit data from client MAC.
        .gmii_tx_en(gmii_tx_en), // Transmit control signal from client MAC.
        .gmii_tx_er(gmii_tx_er), // Transmit control signal from client MAC.
        .gmii_rxd(gmii_rxd), // Received Data to client MAC.
        .gmii_rx_dv(gmii_rx_dv), // Received control signal to client MAC.
        .gmii_rx_er(gmii_rx_er), // Received control signal to client MAC.
        // Management: Alternative to MDIO Interface
        //------------------------------------------

        //    input [4:0]      configuration_vector,  // Alternative to MDIO interface.

        //    .an_interrupt(an_interrupt),          // Interrupt to processor to signal that Auto-Negotiation has completed
        //    input [15:0]     an_adv_config_vector,  // Alternate interface to program REG4 (AN ADV)
        //    input            an_restart_config,     // Alternate signal to modify AN restart bit in REG0


        // General IO's
        //-------------
        .status_vector(status_vector), // Core status.
        .reset(reset) // Asynchronous reset for entire core.
        //    input            signal_detect          // Input from PMD to indicate presence of optical input.
    );

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
        .clk_out_125M(clock_100M),
        .clk_out_20M(clock_15M),
        .proc_rst_n(~reset),
        .clkTX_msg(clkTX_msg),
        .clkRX_msg(clkRX_msg),
        
        .start_TX(start_TX),
        .start_switch(start_switch),
        .wait_TX(wait_TX),
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
        .AXImanager_PORTA_addr(AXImanager_PORTA_addr),
        .AXImanager_PORTA_clk(AXImanager_PORTA_clk),
        .AXImanager_PORTA_din(AXImanager_PORTA_din),
        .AXImanager_PORTA_dout(AXImanager_PORTA_dout),
        .AXImanager_PORTA_en(AXImanager_PORTA_en),
        .AXImanager_PORTA_rst(AXImanager_PORTA_rst),
        .AXImanager_PORTA_we(AXImanager_PORTA_we),

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
    //---------------------------------------AXI manager interface for Post processing----------------------------------------
   wire [11:0]AXImanager_PORTA_addr_12;
   wire [16:0]EVrandombit_PORTA_addr_17;
   wire [16:0]PArandombit_PORTA_addr_17;
   wire [17:0]QC_PORTA_addr_18;
   wire [17:0]Qubit_PORTA_addr_18;
   wire [17:0]Secretkey_PORTA_addr_18;
   
   assign AXImanager_PORTA_addr  = {20'b0, AXImanager_PORTA_addr_12};
   assign EVrandombit_PORTA_addr = {15'b0, EVrandombit_PORTA_addr_17};
   assign PArandombit_PORTA_addr = {15'b0, PArandombit_PORTA_addr_17};
   assign QC_PORTA_addr = {14'b0, QC_PORTA_addr_18};
   assign Qubit_PORTA_addr = {14'b0, Qubit_PORTA_addr_18};
   assign Secretkey_PORTA_addr = {14'b0, Secretkey_PORTA_addr_18};
   
    AXI_Manager_A_wrapper  u_AXI_Manager_A(
        // AXImanager BRAM PORT-A connections
        .AXImanager_PORTA_addr(AXImanager_PORTA_addr_12),
        .AXImanager_PORTA_clk(AXImanager_PORTA_clk),
        .AXImanager_PORTA_din(AXImanager_PORTA_din),
        .AXImanager_PORTA_dout(AXImanager_PORTA_dout),
        .AXImanager_PORTA_en(AXImanager_PORTA_en),
        .AXImanager_PORTA_rst(AXImanager_PORTA_rst),
        .AXImanager_PORTA_we(AXImanager_PORTA_we),

        // EVrandombit BRAM PORT-A connections
        .EVrandombit_PORTA_addr(EVrandombit_PORTA_addr_17),
        .EVrandombit_PORTA_clk(EVrandombit_PORTA_clk),
        .EVrandombit_PORTA_din(EVrandombit_PORTA_din),
        .EVrandombit_PORTA_dout(EVrandombit_PORTA_dout),
        .EVrandombit_PORTA_en(EVrandombit_PORTA_en),
        .EVrandombit_PORTA_rst(EVrandombit_PORTA_rst),
        .EVrandombit_PORTA_we(EVrandombit_PORTA_we),

            // PArandombit BRAM PORT-A connections
        .PArandombit_PORTA_addr(PArandombit_PORTA_addr_17),
        .PArandombit_PORTA_clk(PArandombit_PORTA_clk),
        .PArandombit_PORTA_din(PArandombit_PORTA_din),
        .PArandombit_PORTA_dout(PArandombit_PORTA_dout),
        .PArandombit_PORTA_en(PArandombit_PORTA_en),
        .PArandombit_PORTA_rst(PArandombit_PORTA_rst),
        .PArandombit_PORTA_we(PArandombit_PORTA_we),

        // QC BRAM PORT-A connections
        .QC_PORTA_addr(QC_PORTA_addr_18),
        .QC_PORTA_clk(QC_PORTA_clk),
        .QC_PORTA_din(QC_PORTA_din),
        .QC_PORTA_dout(QC_PORTA_dout),
        .QC_PORTA_en(QC_PORTA_en),
        .QC_PORTA_rst(QC_PORTA_rst),
        .QC_PORTA_we(QC_PORTA_we),
        
        // Qubit BRAM PORT-A connections
        .Qubit_PORTA_addr(Qubit_PORTA_addr_18),
        .Qubit_PORTA_clk(Qubit_PORTA_clk),
        .Qubit_PORTA_din(Qubit_PORTA_din),
        .Qubit_PORTA_dout(Qubit_PORTA_dout),
        .Qubit_PORTA_en(Qubit_PORTA_en),
        .Qubit_PORTA_rst(Qubit_PORTA_rst),
        .Qubit_PORTA_we(Qubit_PORTA_we),

        // Secretkey BRAM PORT-A connections
        .Secretkey_PORTA_addr(Secretkey_PORTA_addr_18),
        .Secretkey_PORTA_clk(Secretkey_PORTA_clk),
        .Secretkey_PORTA_din(Secretkey_PORTA_din),
        .Secretkey_PORTA_dout(Secretkey_PORTA_dout),
        .Secretkey_PORTA_en(Secretkey_PORTA_en),
        .Secretkey_PORTA_rst(Secretkey_PORTA_rst),
        
        .clk_100M(clock_100M),
        .rst_n(~reset)
        );
    //---------------------------------------AXI manager interface for Post processing----------------------------------------
    //---------------------------------------------------------Network of A---------------------------------------------------------
    wire clkTX_msg;
    wire clkRX_msg;

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
        .reset(reset), // system reset
//        .clock_100M(clk),            // clock for JTAG module 
//        .clk_PP(clk_PP),               // CDC interface for Network
        .clk_PP(clk_fast),          // Same clock domain 
        .clkTX_msg(clkTX_msg), // clock for accessing BRAMMsgTX
        .clkRX_msg(clkRX_msg), // clock for accessing BRAMMsgRX

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
        .gmii_rx_er(gmii_rx_er), // Received control signal to client MAC.
        // link status indicator
        .network_fsm_TCP(network_fsm_TCP_TX)
    );
    //---------------------------------------------------------Network of A---------------------------------------------------------
    //---------------------------------------------------------TX RX Bram -----------------------------------------------------------
    wire clkRX_msg;
(*mark_debug = "TRUE"*)    wire A2B_weRX_msg;
(*mark_debug = "TRUE"*)    wire [10:0] A2B_addrRX_msg;
(*mark_debug = "TRUE"*)    wire [31:0] A2B_dataRX_msg;
    
    wire A_RX_bram_clkb;
    wire A_RX_bram_enb;
    wire A_RX_bram_web;
(*mark_debug = "TRUE"*)    wire [10:0] A_RX_bram_addrb;
(*mark_debug = "TRUE"*)    wire [31:0] A_RX_bram_doutb;
    
    wire clkTX_msg;
    wire [10:0] A2B_addrTX_msg;
    wire [31:0] A2B_dataTX_msg;
    
    wire A_TX_bram_clkb;
    wire A_TX_bram_enb;
    wire A_TX_bram_web;
    wire [10:0] A_TX_bram_addrb;
    wire [31:0] A_TX_bram_dinb;

    A_TXRX_BRAM_wrapper A_TXRX_BRAM(
        .A_RX_clka(clkRX_msg),
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

        .A_TX_clka(clkTX_msg),
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
    //************************ END SIGNAL*****************************
//    always@(posedge clock_125M or posedge reset) begin
//        if(reset) begin
//            A_sifting_finish_reg <= 1'b0;
//        end else if (A_sifting_finish) begin
//            A_sifting_finish_reg <= 1'b1;
//        end else begin
//            A_sifting_finish_reg <= A_sifting_finish_reg;
//        end
//    end
    //*************************** END SIGNAL***************************
    //************************ Jtag for A siftkey bram***********************
    /*
JTAG_wrapper U_JTAG(
   .bram_addrb({15'b0, Asiftedkey_addra, 2'b00}),
   .bram_clkb(Asiftedkey_clka),
   .bram_dinb(Asiftedkey_dina[31:0]),
   .bram_enb(Asiftedkey_ena),
   .bram_rstb(reset),
   .bram_web({4{Asiftedkey_wea}}),
   
   .bram_addrb_1({15'b0, Asiftedkey_addra, 2'b00}),
   .bram_clkb_1(Asiftedkey_clka),
   .bram_dinb_1(Asiftedkey_dina[63:32]),
   .bram_enb_1(Asiftedkey_ena),
   .bram_rstb_1(reset),
   .bram_web_1({4{Asiftedkey_wea}}),
   
   .clk_in_100M(clock_100M),
   .reset(reset)
);
*/
    //************************ Jtag for A siftkey bram***********************

endmodule
