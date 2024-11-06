`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/10/17 21:28:48
// Design Name: 
// Module Name: top_Bob
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

`include "./packet_parameter.v"
`include "./error_reconcilation_parameter.v"
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

    //    input start_RX,

    output reg output_clk,
    input independent_clk_en,
    input io_refclk_en,
    input gmii_rx_clk_en,
    output [7:0] tcp_status

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

    wire txn, txp, rxn, rxp;
    wire gmii_rx_clk, gmii_tx_clk;
    wire clock_100M;
    //    wire clock_80M;
    wire clock_125M;

    (*mark_debug = "TRUE"*) wire [7:0]gmii_txd; // Transmit data from client MAC.
    (*mark_debug = "TRUE"*) wire gmii_tx_en; // Transmit control signal from client MAC.
    (*mark_debug = "TRUE"*) wire gmii_tx_er; // Transmit control signal from client MAC.
    (*mark_debug = "TRUE"*) wire [7:0]gmii_rxd; // Received Data to client MAC.
    (*mark_debug = "TRUE"*) wire gmii_rx_dv; // Received control signal to client MAC.
    (*mark_debug = "TRUE"*) wire gmii_rx_er; // Received control signal to client MAC.

//    wire [7:0]gmii_txd; // Transmit data from client MAC.
//    wire gmii_tx_en; // Transmit control signal from client MAC.
//    wire gmii_tx_er; // Transmit control signal from client MAC.
//    wire [7:0]gmii_rxd; // Received Data to client MAC.
//    wire gmii_rx_dv; // Received control signal to client MAC.
//    wire gmii_rx_er; // Received control signal to client MAC.

    wire [15:0] status_vector;
    wire A_ER_finish;
    reg A_ER_finish_reg;

    //    assign link_status = status_vector[0] & status_vector[1];
    assign link_status = status_vector[0];
    //    assign link_status = 1'b1;
    wire [3:0] network_fsm_TCP_TX;
    assign achieve = (network_fsm_TCP_TX == 4'd3)  ? 1'b1 : 1'b0; // network_fsm_TCP has reached TRANSFER_TCP state
    assign disconnect = (network_fsm_TCP_TX == 4'd0)  ? 1'b1 : 1'b0;
    assign handshake0 = (network_fsm_TCP_TX == 4'd2)  ? 1'b1 : 1'b0;
    assign handshake1 = (network_fsm_TCP_TX == 4'd4)  ? 1'b1 : 1'b0;
    assign handshake = (network_fsm_TCP_TX == 4'd1)  ? 1'b1 : 1'b0;
    assign ack_t = (network_fsm_TCP_TX == 4'd6)  ? 1'b1 : 1'b0;
    assign ack_r = (network_fsm_TCP_TX == 4'd5)  ? 1'b1 : 1'b0;

    //                                          LED7      LED6               LED5          LED4                LED3    LED2        LED1                                 LED0
    //    assign tcp_status = {link_status, handshake0, handshake, handshake1, achieve, ack_t, B2A_busy_Net2PP_RX, B2A_busy_Net2PP_TX};

    //                               LED7      LED6               LED5                             LED4               LED3             LED2        LED1              LED0
    assign tcp_status = {link_status, achieve, A2B_busy_Net2PP_RX, A2B_busy_Net2PP_TX, start_switch, start_TX ,   wait_TX ,  A_ER_finish_reg};

    //                                          LED7      LED6               LED5                             LED4                             LED3                LED2              LED1          LED0
    //    assign tcp_status = {link_status, achieve, B2A_busy_Net2PP_RX, B2A_busy_Net2PP_TX, start_switch, sift_state_4, sift_state_5, sift_state_6};

    wire [3:0] B_sift_state;
    //    assign sift_state_4 = (B_sift_state == 4'd4)  ? 1'b1 : 1'b0;
    //    assign sift_state_5 = (B_sift_state == 4'd5)  ? 1'b1 : 1'b0;
    //    assign sift_state_6 = (B_sift_state == 4'd6)  ? 1'b1 : 1'b0;

    assign tx_disable = 1'b1;

    clock_generator Uclk_gen
    (.clk_in1_n(clk_300M_n), // input
        .clk_in1_p(clk_300M_p), // input
        .clk_out1_62_5M(independent_clk), // output
        .clk_out2_100M(clock_100M), // output
        .clk_out3_300M(io_refclk), // output
        .clk_out4_375M(clk_fast), // output
        //        .clk_out5_125M(clock_125M), // output

        .reset(reset) // input
    );

    top_phy Utop_phy //for Bob is TX, for Alice is RX
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
    
    wire Areconciledkey_clka;
    wire Areconciledkey_ena; //1'b1
    (*mark_debug = "TRUE"*) wire [3:0] Areconciledkey_wea; //
    wire [14:0] Areconciledkey_addra; //0~32767
    wire [63:0] Areconciledkey_dina; //Alice sifted key 
    
    wire [`FRAME_LEAKED_INFO_WIDTH-1:0] single_frame_leaked_info;
    wire [`FRAME_ERROR_COUNT_WIDTH-1:0] single_frame_error_count;
    wire single_frame_parameter_valid;
    wire A_single_frame_error_verification_fail;       //error verification is fail
    
    ER_Alice u_Alice(
    .clk(clock_100M),
    .rst_n(~reset),
    //----------------------------new add signal------------------------------
    .gmii_tx_clk(gmii_tx_clk),
    .gmii_rx_clk(gmii_rx_clk),


    .clk_PP(clk_fast),
    .link_status(link_status),

    .A2B_busy_Net2PP_TX(A2B_busy_Net2PP_TX),
    .A2B_busy_Net2PP_RX(A2B_busy_Net2PP_RX),

    .gmii_txd(gmii_txd), // Transmit data from client MAC.
    .gmii_tx_en(gmii_tx_en), // Transmit control signal from client MAC.
    .gmii_tx_er(gmii_tx_er), // Transmit control signal from client MAC.
    .gmii_rxd(gmii_rxd), // Received Data to client MAC.
    .gmii_rx_dv(gmii_rx_dv), // Received control signal to client MAC.
    .gmii_rx_er(gmii_rx_er), // Received control signal to client MAC.


    .clkTX_msg(clkTX_msg),
    .clkRX_msg(clkRX_msg),
    .network_fsm_TCP_A_TX(network_fsm_TCP_TX),
    //----------------------------new add signal------------------------------
    
    .start_switch(start_switch),
    .start_TX(start_TX),
    .wait_TX(wait_TX),
    .finish_A_ER(A_ER_finish),

    .sifted_key_addr_index(1'b0),                //address index
                                                            //0:addr0 ~ addr16383
                                                            //1:addr16384 ~ addr32767


    .Areconciledkey_clka(Areconciledkey_clka),
    .Areconciledkey_ena(Areconciledkey_ena),
    .Areconciledkey_wea(Areconciledkey_wea),
    .Areconciledkey_addra(Areconciledkey_addra),
    .Areconciledkey_dina(Areconciledkey_dina),

    .single_frame_leaked_info(single_frame_leaked_info),
    .single_frame_error_count(single_frame_error_count),
    .single_frame_parameter_valid(single_frame_parameter_valid),
    .A_single_frame_error_verification_fail(A_single_frame_error_verification_fail)       //error verification is fail
    );

    always@(posedge clock_100M or posedge reset) begin
        if(reset) begin
            A_ER_finish_reg <= 1'b0;
        end else if (A_ER_finish) begin
            A_ER_finish_reg <= 1'b1;
        end else begin
            A_ER_finish_reg <= A_ER_finish_reg;
        end
    end
    //    //************************ Jtag for B siftkey bram***********************
JTAG_wrapper U_KEY (
    .BRAM_PORTB_0_addr({15'b0, (Areconciledkey_addra+15'b1), 2'b0}),
    .BRAM_PORTB_0_clk(Areconciledkey_clka),
    .BRAM_PORTB_0_din(Areconciledkey_dina[63:32]),
    .BRAM_PORTB_0_dout(),
    .BRAM_PORTB_0_en(Areconciledkey_ena),
    .BRAM_PORTB_0_rst(reset),
    .BRAM_PORTB_0_we(Areconciledkey_wea),
    
    .BRAM_PORTB_1_addr({15'b0, (Areconciledkey_addra+15'b1), 2'b0}),
    .BRAM_PORTB_1_clk(Areconciledkey_clka),
    .BRAM_PORTB_1_din(Areconciledkey_dina[31:0]),
    .BRAM_PORTB_1_dout(),
    .BRAM_PORTB_1_en(Areconciledkey_ena),
    .BRAM_PORTB_1_rst(reset),
    .BRAM_PORTB_1_we(Areconciledkey_wea),
    
    .clk_in_100M(clock_100M),
    .reset(reset)
);

    //    //************************ Jtag for B siftkey bram***********************
endmodule

