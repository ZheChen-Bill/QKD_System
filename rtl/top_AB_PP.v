`timescale 1ps/1ps




module top_AB_PP (
    input default_sysclk1_300_clk_n,
    input default_sysclk1_300_clk_p,
    input reset_high,




    // AXImanager BRAM PORT-A
    input [31:0]A_AXImanager_PORTA_addr,
    input A_AXImanager_PORTA_clk,
    input [63:0]A_AXImanager_PORTA_din,
    output [63:0]A_AXImanager_PORTA_dout,
    input A_AXImanager_PORTA_en,
    input A_AXImanager_PORTA_rst,
    input [7:0]A_AXImanager_PORTA_we,

    // EVrandombit BRAM PORT-A
    input [31:0]EVrandombit_PORTA_addr,
    input EVrandombit_PORTA_clk,
    input [63:0]EVrandombit_PORTA_din,
    output [63:0]EVrandombit_PORTA_dout,
    input EVrandombit_PORTA_en,
    input EVrandombit_PORTA_rst,
    input [7:0]EVrandombit_PORTA_we,

    // PArandombit BRAM PORT-A
    input [31:0]PArandombit_PORTA_addr,
    input PArandombit_PORTA_clk,
    input [63:0]PArandombit_PORTA_din,
    output [63:0]PArandombit_PORTA_dout,
    input PArandombit_PORTA_en,
    input PArandombit_PORTA_rst,
    input [7:0]PArandombit_PORTA_we,

    // QC BRAM PORT-A
    input [31:0]QC_PORTA_addr,
    input QC_PORTA_clk,
    input [63:0]QC_PORTA_din,
    output [63:0]QC_PORTA_dout,
    input QC_PORTA_en,
    input QC_PORTA_rst,
    input [7:0]QC_PORTA_we,

    // Qubit BRAM PORT-A
    input [31:0]Qubit_PORTA_addr,
    input Qubit_PORTA_clk,
    input [63:0]Qubit_PORTA_din,
    output [63:0]Qubit_PORTA_dout,
    input Qubit_PORTA_en,
    input Qubit_PORTA_rst,
    input [7:0]Qubit_PORTA_we,

    // Secretkey BRAM PORT-A
    input [31:0]A_Secretkey_PORTA_addr,
    input A_Secretkey_PORTA_clk,
    input [63:0]A_Secretkey_PORTA_din,
    output [63:0]A_Secretkey_PORTA_dout,
    input A_Secretkey_PORTA_en,
    input A_Secretkey_PORTA_rst,
    input [7:0]A_Secretkey_PORTA_we,












    // AXImanager BRAM PORT-A
    input [31:0]B_AXImanager_PORTA_addr,
    input B_AXImanager_PORTA_clk,
    input [63:0]B_AXImanager_PORTA_din,
    output [63:0]B_AXImanager_PORTA_dout,
    input B_AXImanager_PORTA_en,
    input B_AXImanager_PORTA_rst,
    input [7:0]B_AXImanager_PORTA_we,

    // X-basis detected pos BRAM PORT-A
    input [31:0]Xbasis_detected_pos_PORTA_addr,
    input Xbasis_detected_pos_PORTA_clk,
    input [63:0]Xbasis_detected_pos_PORTA_din,
    output [63:0]Xbasis_detected_pos_PORTA_dout,
    input Xbasis_detected_pos_PORTA_en,
    input Xbasis_detected_pos_PORTA_rst,
    input [7:0]Xbasis_detected_pos_PORTA_we,

    // Z-basis detected pos BRAM PORT-A
    input [31:0]Zbasis_detected_pos_PORTA_addr,
    input Zbasis_detected_pos_PORTA_clk,
    input [63:0]Zbasis_detected_pos_PORTA_din,
    output [63:0]Zbasis_detected_pos_PORTA_dout,
    input Zbasis_detected_pos_PORTA_en,
    input Zbasis_detected_pos_PORTA_rst,
    input [7:0]Zbasis_detected_pos_PORTA_we,

    // Secretkey BRAM PORT-A
    input [31:0]B_Secretkey_PORTA_addr,
    input B_Secretkey_PORTA_clk,
    input [63:0]B_Secretkey_PORTA_din,
    output [63:0]B_Secretkey_PORTA_dout,
    input B_Secretkey_PORTA_en,
    input B_Secretkey_PORTA_rst,
    input [7:0]B_Secretkey_PORTA_we


);
    




//****************************** Alice post-processing ******************************
    top_A_PP A_PP (
        .default_sysclk1_300_clk_n(default_sysclk1_300_clk_n),
        .default_sysclk1_300_clk_p(default_sysclk1_300_clk_p),
        .reset_high(reset_high),

        .clk_out_125M(clk_out_125M),
        .rst_n(rst_n),

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
        .busy_Net2PP_RX(B2A_busy_Net2PP_RX),
        .msg_accessed(B2A_msg_accessed),
        .sizeRX_msg(B2A_sizeRX_msg),
        .busy_PP2Net_RX(B2A_busy_PP2Net_RX),
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
        .Secretkey_PORTA_addr(A_Secretkey_PORTA_addr),
        .Secretkey_PORTA_clk(A_Secretkey_PORTA_clk),
        .Secretkey_PORTA_din(A_Secretkey_PORTA_din),
        .Secretkey_PORTA_dout(A_Secretkey_PORTA_dout),
        .Secretkey_PORTA_en(A_Secretkey_PORTA_en),
        .Secretkey_PORTA_rst(A_Secretkey_PORTA_rst),
        .Secretkey_PORTA_we(A_Secretkey_PORTA_we)
    );
//****************************** Alice post-processing ******************************




//****************************** Bob post-processing ******************************
    top_B_PP B_PP (
        .default_sysclk1_300_clk_n(default_sysclk1_300_clk_n),
        .default_sysclk1_300_clk_p(default_sysclk1_300_clk_p),
        .reset_high(reset_high),

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
        .busy_Net2PP_RX(A2B_busy_Net2PP_RX),
        .msg_accessed(A2B_msg_accessed),
        .sizeRX_msg(A2B_sizeRX_msg),
        .busy_PP2Net_RX(A2B_busy_PP2Net_RX),

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
        .Secretkey_PORTA_addr(B_Secretkey_PORTA_addr),
        .Secretkey_PORTA_clk(B_Secretkey_PORTA_clk),
        .Secretkey_PORTA_din(B_Secretkey_PORTA_din),
        .Secretkey_PORTA_dout(B_Secretkey_PORTA_dout),
        .Secretkey_PORTA_en(B_Secretkey_PORTA_en),
        .Secretkey_PORTA_rst(B_Secretkey_PORTA_rst),
        .Secretkey_PORTA_we(B_Secretkey_PORTA_we)
    );

//****************************** Bob post-processing ******************************


















//****************************** TX & RX BRAM ******************************
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

    wire [10:0]B_RX_bram_addrb;
    wire B_RX_bram_clkb;
    wire [31:0]B_RX_bram_dinb;
    wire [31:0]B_RX_bram_doutb;
    wire B_RX_bram_enb;
    wire [0:0]B_RX_bram_web;

    wire [10:0]B_TX_bram_addrb;
    wire B_TX_bram_clkb;
    wire [31:0]B_TX_bram_dinb;
    wire [31:0]B_TX_bram_doutb;
    wire B_TX_bram_enb;
    wire [0:0]B_TX_bram_web;

    TXRX_BRAM_wrapper TXRX_BRAM
        (.A_RX_bram_addrb(A_RX_bram_addrb),
            .A_RX_bram_clkb(A_RX_bram_clkb),
            .A_RX_bram_dinb(A_RX_bram_dinb),
            .A_RX_bram_doutb(A_RX_bram_doutb),
            .A_RX_bram_enb(A_RX_bram_enb),
            .A_RX_bram_web(A_RX_bram_web),

            .A_TX_bram_addrb(A_TX_bram_addrb),
            .A_TX_bram_clkb(A_TX_bram_clkb),
            .A_TX_bram_dinb(A_TX_bram_dinb),
            .A_TX_bram_doutb(A_TX_bram_doutb),
            .A_TX_bram_enb(A_TX_bram_enb),
            .A_TX_bram_web(A_TX_bram_web),

            .B_RX_bram_addrb(B_RX_bram_addrb),
            .B_RX_bram_clkb(B_RX_bram_clkb),
            .B_RX_bram_dinb(B_RX_bram_dinb),
            .B_RX_bram_doutb(B_RX_bram_doutb),
            .B_RX_bram_enb(B_RX_bram_enb),
            .B_RX_bram_web(B_RX_bram_web),

            .B_TX_bram_addrb(B_TX_bram_addrb),
            .B_TX_bram_clkb(B_TX_bram_clkb),
            .B_TX_bram_dinb(B_TX_bram_dinb),
            .B_TX_bram_doutb(B_TX_bram_doutb),
            .B_TX_bram_enb(B_TX_bram_enb),
            .B_TX_bram_web(B_TX_bram_web));
//****************************** TX & RX BRAM ******************************













//****************************** A2B model  ******************************
    // Input 
    // wire clk;
    // wire rst_n;
    wire A2B_busy_PP2Net_TX;
    wire A2B_msg_stored;
    wire [10:0] A2B_sizeTX_msg;
    wire A2B_busy_PP2Net_RX;

    // // Output 
    wire A2B_busy_Net2PP_TX;
    wire A2B_busy_Net2PP_RX;
    wire A2B_msg_accessed;
    wire [10:0] A2B_sizeRX_msg; 

    wire [3:0] A2B_state;

    TXRX_model A2Bmodel (
        .clk(clk_out_125M),                       // Clock signal
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
//****************************** B2A model  ******************************
    // Input 
    wire clk_out_125M;
    wire rst_n;
    wire B2A_busy_PP2Net_TX;
    wire B2A_msg_stored;
    wire [10:0] B2A_sizeTX_msg;
    wire B2A_busy_PP2Net_RX;

    // Output 
    wire B2A_busy_Net2PP_TX;
    wire B2A_busy_Net2PP_RX;
    wire B2A_msg_accessed;
    wire [10:0] B2A_sizeRX_msg; 
    wire [3:0] B2A_state;

    TXRX_model B2Amodel (
        .clk(clk_out_125M),                       // Clock signal
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