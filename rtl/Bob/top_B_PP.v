//`include "D:/LAB/quantum_cryptography/QKD_post_processing/QKD_post_processing/TOP/PP_parameter.v"
`include "PP_parameter.v"


module top_B_PP (

      input clk_out_125M,
      input proc_rst_n,
      
      input clkTX_msg,
      input clkRX_msg,
      
      input start_TX,
      output wait_TX,
      
      output finish_sifting,
      output finish_ER,
      output finish_PA,
//    input default_sysclk1_300_clk_n,
//    input default_sysclk1_300_clk_p,
//    input reset_high,
    

    // TX 
    // B packet
    input busy_Net2PP_TX,
    output busy_PP2Net_TX,
    output msg_stored,
    output [10:0] sizeTX_msg,
    // TX BRAM
    output wire B_TX_bram_clkb,
    output wire B_TX_bram_enb,
    output wire B_TX_bram_web,
    output wire [10:0] B_TX_bram_addrb,
    output wire [31:0] B_TX_bram_dinb,

    // RX
    // B unpacket
    input busy_Net2PP_RX,
    input msg_accessed,
    input [10:0] sizeRX_msg,
    output busy_PP2Net_RX,
    // RX BRAM
    output B_RX_bram_clkb,
    output B_RX_bram_enb,
    output B_RX_bram_web,
    output [10:0] B_RX_bram_addrb,
    input [31:0] B_RX_bram_doutb
    ,

    // AXImanager BRAM PORT-A
    input [31:0]AXImanager_PORTA_addr,
    input AXImanager_PORTA_clk,
    input [63:0]AXImanager_PORTA_din,
    output [63:0]AXImanager_PORTA_dout,
    input AXImanager_PORTA_en,
    input AXImanager_PORTA_rst,
    input [7:0]AXImanager_PORTA_we,

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
    input [31:0]Secretkey_PORTA_addr,
    input Secretkey_PORTA_clk,
    input [63:0]Secretkey_PORTA_din,
    output [63:0]Secretkey_PORTA_dout,
    input Secretkey_PORTA_en,
    input Secretkey_PORTA_rst,
    input [7:0]Secretkey_PORTA_we

);
//****************************** wait_TX_signal ************************
    assign wait_TX = (wait_sifting_TX)||(wait_ER_TX);
//****************************** wait_TX_signal ************************
//****************************** setting ******************************
    wire clk;
    wire rst_n;
    assign clk = clk_out_125M;
    assign rst_n = proc_rst_n;
//****************************** setting ******************************





//****************************** AXI manager ******************************
    // wire [31:0]AXImanager_PORTA_addr;
    // wire AXImanager_PORTA_clk;
    // wire [63:0]AXImanager_PORTA_din;
    // wire [63:0]AXImanager_PORTA_dout;
    // wire AXImanager_PORTA_en;
    // wire AXImanager_PORTA_rst;
    // wire [7:0]AXImanager_PORTA_we;
    
    wire [31:0]AXImanager_addrb;
    wire AXImanager_clkb;
    wire [63:0]AXImanager_dinb;
    wire [63:0]AXImanager_doutb;
    wire AXImanager_enb;
    wire AXImanager_rstb;
    wire [7:0]AXImanager_web;

    // wire [31:0]Secretkey_PORTA_addr;
    // wire Secretkey_PORTA_clk;
    // wire [63:0]Secretkey_PORTA_din;
    // wire [63:0]Secretkey_PORTA_dout;
    // wire Secretkey_PORTA_en;
    // wire Secretkey_PORTA_rst;
    // wire [7:0]Secretkey_PORTA_we;

    wire [31:0]Secretkey_addrb;
    wire Secretkey_clkb;
    (* KEEP = "TRUE" *) wire [63:0]Secretkey_dinb;
    wire [63:0]Secretkey_doutb;
    wire Secretkey_enb;
    wire Secretkey_rstb;
    (* KEEP = "TRUE" *) wire [7:0]Secretkey_web;

    // wire [31:0]Xbasis_detected_pos_PORTA_addr;
    // wire Xbasis_detected_pos_PORTA_clk;
    // wire [63:0]Xbasis_detected_pos_PORTA_din;
    // wire [63:0]Xbasis_detected_pos_PORTA_dout;
    // wire Xbasis_detected_pos_PORTA_en;
    // wire Xbasis_detected_pos_PORTA_rst;
    // wire [7:0]Xbasis_detected_pos_PORTA_we;

    wire [31:0]Xbasis_detected_pos_addrb;
    wire Xbasis_detected_pos_clkb;
    wire [63:0]Xbasis_detected_pos_dinb;
    wire [63:0]Xbasis_detected_pos_doutb;
    wire Xbasis_detected_pos_enb;
    wire Xbasis_detected_pos_rstb;
    wire [7:0]Xbasis_detected_pos_web;

    // wire [31:0]Zbasis_detected_pos_PORTA_addr;
    // wire Zbasis_detected_pos_PORTA_clk;
    // wire [63:0]Zbasis_detected_pos_PORTA_din;
    // wire [63:0]Zbasis_detected_pos_PORTA_dout;
    // wire Zbasis_detected_pos_PORTA_en;
    // wire Zbasis_detected_pos_PORTA_rst;
    // wire [7:0]Zbasis_detected_pos_PORTA_we;

    wire [31:0]Zbasis_detected_pos_addrb;
    wire Zbasis_detected_pos_clkb;
    wire [63:0]Zbasis_detected_pos_dinb;
    wire [63:0]Zbasis_detected_pos_doutb;
    wire Zbasis_detected_pos_enb;
    wire Zbasis_detected_pos_rstb;
    wire [7:0]Zbasis_detected_pos_web;

      wire clk_out_125M;
      wire [0:0]proc_rst_n;
//    wire default_sysclk1_300_clk_n;
//    wire default_sysclk1_300_clk_p;
//    wire reset_high;
    
    BD_AXImanager_B_wrapper AXImanager_B
        (.AXImanager_PORTA_addr(AXImanager_PORTA_addr),
            .AXImanager_PORTA_clk(AXImanager_PORTA_clk),
            .AXImanager_PORTA_din(AXImanager_PORTA_din),
            .AXImanager_PORTA_dout(AXImanager_PORTA_dout),
            .AXImanager_PORTA_en(AXImanager_PORTA_en),
            .AXImanager_PORTA_rst(AXImanager_PORTA_rst),
            .AXImanager_PORTA_we(AXImanager_PORTA_we),
            .AXImanager_addrb(AXImanager_addrb),
            .AXImanager_clkb(AXImanager_clkb),
            .AXImanager_dinb(AXImanager_dinb),
            .AXImanager_doutb(AXImanager_doutb),
            .AXImanager_enb(AXImanager_enb),
            .AXImanager_rstb(AXImanager_rstb),
            .AXImanager_web(AXImanager_web),
            .Secretkey_PORTA_addr(Secretkey_PORTA_addr),
            .Secretkey_PORTA_clk(Secretkey_PORTA_clk),
            .Secretkey_PORTA_din(Secretkey_PORTA_din),
            .Secretkey_PORTA_dout(Secretkey_PORTA_dout),
            .Secretkey_PORTA_en(Secretkey_PORTA_en),
            .Secretkey_PORTA_rst(Secretkey_PORTA_rst),
            .Secretkey_PORTA_we(Secretkey_PORTA_we),
            .Secretkey_addrb(Secretkey_addrb),
            .Secretkey_clkb(Secretkey_clkb),
            .Secretkey_dinb(Secretkey_dinb),
            .Secretkey_doutb(Secretkey_doutb),
            .Secretkey_enb(Secretkey_enb),
            .Secretkey_rstb(Secretkey_rstb),
            .Secretkey_web(Secretkey_web),
            .Xbasis_detected_pos_PORTA_addr(Xbasis_detected_pos_PORTA_addr),
            .Xbasis_detected_pos_PORTA_clk(Xbasis_detected_pos_PORTA_clk),
            .Xbasis_detected_pos_PORTA_din(Xbasis_detected_pos_PORTA_din),
            .Xbasis_detected_pos_PORTA_dout(Xbasis_detected_pos_PORTA_dout),
            .Xbasis_detected_pos_PORTA_en(Xbasis_detected_pos_PORTA_en),
            .Xbasis_detected_pos_PORTA_rst(Xbasis_detected_pos_PORTA_rst),
            .Xbasis_detected_pos_PORTA_we(Xbasis_detected_pos_PORTA_we),
            .Xbasis_detected_pos_addrb(Xbasis_detected_pos_addrb),
            .Xbasis_detected_pos_clkb(Xbasis_detected_pos_clkb),
            .Xbasis_detected_pos_dinb(Xbasis_detected_pos_dinb),
            .Xbasis_detected_pos_doutb(Xbasis_detected_pos_doutb),
            .Xbasis_detected_pos_enb(Xbasis_detected_pos_enb),
            .Xbasis_detected_pos_rstb(Xbasis_detected_pos_rstb),
            .Xbasis_detected_pos_web(Xbasis_detected_pos_web),
            .Zbasis_detected_pos_PORTA_addr(Zbasis_detected_pos_PORTA_addr),
            .Zbasis_detected_pos_PORTA_clk(Zbasis_detected_pos_PORTA_clk),
            .Zbasis_detected_pos_PORTA_din(Zbasis_detected_pos_PORTA_din),
            .Zbasis_detected_pos_PORTA_dout(Zbasis_detected_pos_PORTA_dout),
            .Zbasis_detected_pos_PORTA_en(Zbasis_detected_pos_PORTA_en),
            .Zbasis_detected_pos_PORTA_rst(Zbasis_detected_pos_PORTA_rst),
            .Zbasis_detected_pos_PORTA_we(Zbasis_detected_pos_PORTA_we),
            .Zbasis_detected_pos_addrb(Zbasis_detected_pos_addrb),
            .Zbasis_detected_pos_clkb(Zbasis_detected_pos_clkb),
            .Zbasis_detected_pos_dinb(Zbasis_detected_pos_dinb),
            .Zbasis_detected_pos_doutb(Zbasis_detected_pos_doutb),
            .Zbasis_detected_pos_enb(Zbasis_detected_pos_enb),
            .Zbasis_detected_pos_rstb(Zbasis_detected_pos_rstb),
            .Zbasis_detected_pos_web(Zbasis_detected_pos_web)
//            .clk_out_125M(clk_out_125M),
//            .default_sysclk1_300_clk_n(default_sysclk1_300_clk_n),
//            .default_sysclk1_300_clk_p(default_sysclk1_300_clk_p),
//            .proc_rst_n(proc_rst_n),
//            .reset_high(reset_high)
            );
//****************************** AXI manager ******************************


//****************************** interface ******************************

    wire [13:0]B_RX_EVrandombit_addra;
    wire [13:0]B_RX_EVrandombit_addrb;
    wire B_RX_EVrandombit_clka;
    wire B_RX_EVrandombit_clkb;
    wire [63:0]B_RX_EVrandombit_dina;
    wire [63:0]B_RX_EVrandombit_dinb;
    wire [63:0]B_RX_EVrandombit_douta;
    wire [63:0]B_RX_EVrandombit_doutb;
    wire B_RX_EVrandombit_ena;
    wire B_RX_EVrandombit_enb;
    wire [0:0]B_RX_EVrandombit_wea;
    wire [0:0]B_RX_EVrandombit_web;

    wire [13:0]B_RX_PArandombit_addra;
    wire [13:0]B_RX_PArandombit_addrb;
    wire B_RX_PArandombit_clka;
    wire B_RX_PArandombit_clkb;
    wire [63:0]B_RX_PArandombit_dina;
    wire [63:0]B_RX_PArandombit_dinb;
    wire [63:0]B_RX_PArandombit_douta;
    wire [63:0]B_RX_PArandombit_doutb;
    wire B_RX_PArandombit_ena;
    wire B_RX_PArandombit_enb;
    wire [0:0]B_RX_PArandombit_wea;
    wire [0:0]B_RX_PArandombit_web;

    wire B_RX_Zbasis_decoy_empty;
    wire B_RX_Zbasis_decoy_full;
    wire B_RX_Zbasis_decoy_rd_clk;
    wire [31:0]B_RX_Zbasis_decoy_rd_dout;
    wire B_RX_Zbasis_decoy_rd_en;
    wire B_RX_Zbasis_decoy_rd_rst_busy;
    wire B_RX_Zbasis_decoy_rd_valid;
    wire B_RX_Zbasis_decoy_srst;
    wire B_RX_Zbasis_decoy_wr_ack;
    wire B_RX_Zbasis_decoy_wr_clk;
    wire [31:0]B_RX_Zbasis_decoy_wr_din;
    wire B_RX_Zbasis_decoy_wr_en;
    wire B_RX_Zbasis_decoy_wr_rst_busy;

    wire B_RX_er_empty;
    wire B_RX_er_full;
    wire B_RX_er_rd_clk;
    wire [31:0]B_RX_er_rd_dout;
    wire B_RX_er_rd_en;
    wire B_RX_er_rd_rst_busy;
    wire B_RX_er_rd_valid;
    wire B_RX_er_srst;
    wire B_RX_er_wr_ack;
    wire B_RX_er_wr_clk;
    wire [31:0]B_RX_er_wr_din;
    wire B_RX_er_wr_en;
    wire B_RX_er_wr_rst_busy;

    wire B_RX_secretkey_length_empty;
    wire B_RX_secretkey_length_full;
    wire B_RX_secretkey_length_rd_clk;
    wire [31:0]B_RX_secretkey_length_rd_dout;
    wire B_RX_secretkey_length_rd_en;
    wire B_RX_secretkey_length_rd_rst_busy;
    wire B_RX_secretkey_length_rd_valid;
    wire B_RX_secretkey_length_srst;
    wire B_RX_secretkey_length_wr_ack;
    wire B_RX_secretkey_length_wr_clk;
    wire [31:0]B_RX_secretkey_length_wr_din;
    wire B_RX_secretkey_length_wr_en;
    wire B_RX_secretkey_length_wr_rst_busy;

    wire B_TX_detected_empty;
    wire B_TX_detected_full;
    wire B_TX_detected_rd_clk;
    wire [31:0]B_TX_detected_rd_dout;
    wire B_TX_detected_rd_en;
    wire B_TX_detected_rd_rst_busy;
    wire B_TX_detected_rd_valid;
    wire B_TX_detected_srst;
    wire B_TX_detected_wr_ack;
    wire B_TX_detected_wr_clk;
    wire [31:0]B_TX_detected_wr_din;
    wire B_TX_detected_wr_en;
    wire B_TX_detected_wr_rst_busy;

    wire B_TX_er_empty;
    wire B_TX_er_full;
    wire B_TX_er_rd_clk;
    wire [31:0]B_TX_er_rd_dout;
    wire B_TX_er_rd_en;
    wire B_TX_er_rd_rst_busy;
    wire B_TX_er_rd_valid;
    wire B_TX_er_srst;
    wire B_TX_er_wr_ack;
    wire B_TX_er_wr_clk;
    wire [31:0]B_TX_er_wr_din;
    wire B_TX_er_wr_en;
    wire B_TX_er_wr_rst_busy;

    wire [14:0]Breconciledkey_addra;
    wire [14:0]Breconciledkey_addrb;
    wire Breconciledkey_clka;
    wire Breconciledkey_clkb;
    wire [63:0]Breconciledkey_dina;
    wire [63:0]Breconciledkey_dinb;
    wire [63:0]Breconciledkey_douta;
    wire [63:0]Breconciledkey_doutb;
    wire Breconciledkey_ena;
    wire Breconciledkey_enb;
    wire [0:0]Breconciledkey_wea;
    wire [0:0]Breconciledkey_web;

    wire [14:0]Bsiftedkey_addra;
    wire [14:0]Bsiftedkey_addrb;
    wire Bsiftedkey_clka;
    wire Bsiftedkey_clkb;
    wire [63:0]Bsiftedkey_dina;
    wire [63:0]Bsiftedkey_dinb;
    wire [63:0]Bsiftedkey_douta;
    wire [63:0]Bsiftedkey_doutb;
    wire Bsiftedkey_ena;
    wire Bsiftedkey_enb;
    wire [0:0]Bsiftedkey_wea;
    wire [0:0]Bsiftedkey_web;

    wire ask_parity_clk;
    wire ask_parity_empty;
    wire ask_parity_full;
    wire [31:0]ask_parity_rd_dout;
    wire ask_parity_rd_en;
    wire ask_parity_rd_rst_busy;
    wire ask_parity_rd_valid;
    wire ask_parity_srst;
    wire ask_parity_wr_ack;
    wire [31:0]ask_parity_wr_din;
    wire ask_parity_wr_en;
    wire ask_parity_wr_rst_busy;


    assign B_RX_Zbasis_decoy_srst = ~rst_n;
    assign B_RX_er_srst = ~rst_n;
    assign B_RX_secretkey_length_srst = ~rst_n;
    assign B_TX_detected_srst = ~rst_n;
    assign B_TX_er_srst = ~rst_n;
    assign ask_parity_srst = ~rst_n;

    BD_interface_B_wrapper interface_B
        (.B_RX_EVrandombit_addra(B_RX_EVrandombit_addra),
            .B_RX_EVrandombit_addrb(B_RX_EVrandombit_addrb),
            .B_RX_EVrandombit_clka(B_RX_EVrandombit_clka),
            .B_RX_EVrandombit_clkb(B_RX_EVrandombit_clkb),
            .B_RX_EVrandombit_dina(B_RX_EVrandombit_dina),
            .B_RX_EVrandombit_dinb(B_RX_EVrandombit_dinb),
            .B_RX_EVrandombit_douta(B_RX_EVrandombit_douta),
            .B_RX_EVrandombit_doutb(B_RX_EVrandombit_doutb),
            .B_RX_EVrandombit_ena(B_RX_EVrandombit_ena),
            .B_RX_EVrandombit_enb(B_RX_EVrandombit_enb),
            .B_RX_EVrandombit_wea(B_RX_EVrandombit_wea),
            .B_RX_EVrandombit_web(B_RX_EVrandombit_web),

            .B_RX_PArandombit_addra(B_RX_PArandombit_addra),
            .B_RX_PArandombit_addrb(B_RX_PArandombit_addrb),
            .B_RX_PArandombit_clka(B_RX_PArandombit_clka),
            .B_RX_PArandombit_clkb(B_RX_PArandombit_clkb),
            .B_RX_PArandombit_dina(B_RX_PArandombit_dina),
            .B_RX_PArandombit_dinb(B_RX_PArandombit_dinb),
            .B_RX_PArandombit_douta(B_RX_PArandombit_douta),
            .B_RX_PArandombit_doutb(B_RX_PArandombit_doutb),
            .B_RX_PArandombit_ena(B_RX_PArandombit_ena),
            .B_RX_PArandombit_enb(B_RX_PArandombit_enb),
            .B_RX_PArandombit_wea(B_RX_PArandombit_wea),
            .B_RX_PArandombit_web(B_RX_PArandombit_web),

            .B_RX_Zbasis_decoy_empty(B_RX_Zbasis_decoy_empty),
            .B_RX_Zbasis_decoy_full(B_RX_Zbasis_decoy_full),
            .B_RX_Zbasis_decoy_rd_clk(B_RX_Zbasis_decoy_rd_clk),
            .B_RX_Zbasis_decoy_rd_dout(B_RX_Zbasis_decoy_rd_dout),
            .B_RX_Zbasis_decoy_rd_en(B_RX_Zbasis_decoy_rd_en),
            .B_RX_Zbasis_decoy_rd_rst_busy(B_RX_Zbasis_decoy_rd_rst_busy),
            .B_RX_Zbasis_decoy_rd_valid(B_RX_Zbasis_decoy_rd_valid),
            .B_RX_Zbasis_decoy_srst(B_RX_Zbasis_decoy_srst),
            .B_RX_Zbasis_decoy_wr_ack(B_RX_Zbasis_decoy_wr_ack),
            .B_RX_Zbasis_decoy_wr_clk(B_RX_Zbasis_decoy_wr_clk),
            .B_RX_Zbasis_decoy_wr_din(B_RX_Zbasis_decoy_wr_din),
            .B_RX_Zbasis_decoy_wr_en(B_RX_Zbasis_decoy_wr_en),
            .B_RX_Zbasis_decoy_wr_rst_busy(B_RX_Zbasis_decoy_wr_rst_busy),

            .B_RX_er_empty(B_RX_er_empty),
            .B_RX_er_full(B_RX_er_full),
            .B_RX_er_rd_clk(B_RX_er_rd_clk),
            .B_RX_er_rd_dout(B_RX_er_rd_dout),
            .B_RX_er_rd_en(B_RX_er_rd_en),
            .B_RX_er_rd_rst_busy(B_RX_er_rd_rst_busy),
            .B_RX_er_rd_valid(B_RX_er_rd_valid),
            .B_RX_er_srst(B_RX_er_srst),
            .B_RX_er_wr_ack(B_RX_er_wr_ack),
            .B_RX_er_wr_clk(B_RX_er_wr_clk),
            .B_RX_er_wr_din(B_RX_er_wr_din),
            .B_RX_er_wr_en(B_RX_er_wr_en),
            .B_RX_er_wr_rst_busy(B_RX_er_wr_rst_busy),

            .B_RX_secretkey_length_empty(B_RX_secretkey_length_empty),
            .B_RX_secretkey_length_full(B_RX_secretkey_length_full),
            .B_RX_secretkey_length_rd_clk(B_RX_secretkey_length_rd_clk),
            .B_RX_secretkey_length_rd_dout(B_RX_secretkey_length_rd_dout),
            .B_RX_secretkey_length_rd_en(B_RX_secretkey_length_rd_en),
            .B_RX_secretkey_length_rd_rst_busy(B_RX_secretkey_length_rd_rst_busy),
            .B_RX_secretkey_length_rd_valid(B_RX_secretkey_length_rd_valid),
            .B_RX_secretkey_length_srst(B_RX_secretkey_length_srst),
            .B_RX_secretkey_length_wr_ack(B_RX_secretkey_length_wr_ack),
            .B_RX_secretkey_length_wr_clk(B_RX_secretkey_length_wr_clk),
            .B_RX_secretkey_length_wr_din(B_RX_secretkey_length_wr_din),
            .B_RX_secretkey_length_wr_en(B_RX_secretkey_length_wr_en),
            .B_RX_secretkey_length_wr_rst_busy(B_RX_secretkey_length_wr_rst_busy),

            .B_TX_detected_empty(B_TX_detected_empty),
            .B_TX_detected_full(B_TX_detected_full),
            .B_TX_detected_rd_clk(B_TX_detected_rd_clk),
            .B_TX_detected_rd_dout(B_TX_detected_rd_dout),
            .B_TX_detected_rd_en(B_TX_detected_rd_en),
            .B_TX_detected_rd_rst_busy(B_TX_detected_rd_rst_busy),
            .B_TX_detected_rd_valid(B_TX_detected_rd_valid),
            .B_TX_detected_srst(B_TX_detected_srst),
            .B_TX_detected_wr_ack(B_TX_detected_wr_ack),
            .B_TX_detected_wr_clk(B_TX_detected_wr_clk),
            .B_TX_detected_wr_din(B_TX_detected_wr_din),
            .B_TX_detected_wr_en(B_TX_detected_wr_en),
            .B_TX_detected_wr_rst_busy(B_TX_detected_wr_rst_busy),

            .B_TX_er_empty(B_TX_er_empty),
            .B_TX_er_full(B_TX_er_full),
            .B_TX_er_rd_clk(B_TX_er_rd_clk),
            .B_TX_er_rd_dout(B_TX_er_rd_dout),
            .B_TX_er_rd_en(B_TX_er_rd_en),
            .B_TX_er_rd_rst_busy(B_TX_er_rd_rst_busy),
            .B_TX_er_rd_valid(B_TX_er_rd_valid),
            .B_TX_er_srst(B_TX_er_srst),
            .B_TX_er_wr_ack(B_TX_er_wr_ack),
            .B_TX_er_wr_clk(B_TX_er_wr_clk),
            .B_TX_er_wr_din(B_TX_er_wr_din),
            .B_TX_er_wr_en(B_TX_er_wr_en),
            .B_TX_er_wr_rst_busy(B_TX_er_wr_rst_busy),

            .Breconciledkey_addra(Breconciledkey_addra),
            .Breconciledkey_addrb(Breconciledkey_addrb),
            .Breconciledkey_clka(Breconciledkey_clka),
            .Breconciledkey_clkb(Breconciledkey_clkb),
            .Breconciledkey_dina(Breconciledkey_dina),
            .Breconciledkey_dinb(Breconciledkey_dinb),
            .Breconciledkey_douta(Breconciledkey_douta),
            .Breconciledkey_doutb(Breconciledkey_doutb),
            .Breconciledkey_ena(Breconciledkey_ena),
            .Breconciledkey_enb(Breconciledkey_enb),
            .Breconciledkey_wea(Breconciledkey_wea),
            .Breconciledkey_web(Breconciledkey_web),

            .Bsiftedkey_addra(Bsiftedkey_addra),
            .Bsiftedkey_addrb(Bsiftedkey_addrb),
            .Bsiftedkey_clka(Bsiftedkey_clka),
            .Bsiftedkey_clkb(Bsiftedkey_clkb),
            .Bsiftedkey_dina(Bsiftedkey_dina),
            .Bsiftedkey_dinb(Bsiftedkey_dinb),
            .Bsiftedkey_douta(Bsiftedkey_douta),
            .Bsiftedkey_doutb(Bsiftedkey_doutb),
            .Bsiftedkey_ena(Bsiftedkey_ena),
            .Bsiftedkey_enb(Bsiftedkey_enb),
            .Bsiftedkey_wea(Bsiftedkey_wea),
            .Bsiftedkey_web(Bsiftedkey_web),

            .ask_parity_clk(ask_parity_clk),
            .ask_parity_empty(ask_parity_empty),
            .ask_parity_full(ask_parity_full),
            .ask_parity_rd_dout(ask_parity_rd_dout),
            .ask_parity_rd_en(ask_parity_rd_en),
            .ask_parity_rd_rst_busy(ask_parity_rd_rst_busy),
            .ask_parity_rd_valid(ask_parity_rd_valid),
            .ask_parity_srst(ask_parity_srst),
            .ask_parity_wr_ack(ask_parity_wr_ack),
            .ask_parity_wr_din(ask_parity_wr_din),
            .ask_parity_wr_en(ask_parity_wr_en),
            .ask_parity_wr_rst_busy(ask_parity_wr_rst_busy));

//****************************** interface ******************************













//****************************** BRAM controller ******************************
    // Input 
    // wire [63:0] AXImanager_doutb;
    wire Xbasis_detected_pos_request;
    wire Zbasis_detected_pos_request;
    wire secretkey_1_request;
    wire secretkey_2_request;
    wire request_valid;

    // Output 
    wire AXIbram_ready_en;
    wire Xbasis_detected_pos_ready;
    wire Zbasis_detected_pos_ready;
    wire new_round;

    // wire AXImanager_clkb;
    // wire [31:0] AXImanager_addrb;
    // wire [63:0] AXImanager_dinb;
    // wire AXImanager_enb;
    // wire AXImanager_rstb;
    // wire [7:0] AXImanager_web;

    wire [3:0] B_bramcontroller_state;

    B_bram_controller u_B_bram_controller (
        .clk(clk),                                     // Clock signal
        .rst_n(rst_n),                                 // Reset signal

        .AXImanager_doutb(AXImanager_doutb),           // Input data from AXImanager
        .Xbasis_detected_pos_request(Xbasis_detected_pos_request), // Input request for X-basis detected position
        .Zbasis_detected_pos_request(Zbasis_detected_pos_request), // Input request for Z-basis detected position
        .secretkey_1_request(secretkey_1_request),     // Input request for first secret key
        .secretkey_2_request(secretkey_2_request),     // Input request for second secret key
        .request_valid(request_valid),                 // Input signal indicating request validity

        .AXIbram_ready_en(AXIbram_ready_en),           // Output signal indicating AXI BRAM is ready
        .Xbasis_detected_pos_ready(Xbasis_detected_pos_ready), // Output signal indicating X-basis detected position is ready
        .Zbasis_detected_pos_ready(Zbasis_detected_pos_ready), // Output signal indicating Z-basis detected position is ready
        .new_round(new_round),                         // Output signal for new round

        .AXImanager_clkb(AXImanager_clkb),             // Output clock signal for AXImanager
        .AXImanager_addrb(AXImanager_addrb),           // Output address for AXImanager
        .AXImanager_dinb(AXImanager_dinb),             // Output data for AXImanager
        .AXImanager_enb(AXImanager_enb),               // Output enable signal for AXImanager
        .AXImanager_rstb(AXImanager_rstb),             // Output reset signal for AXImanager
        .AXImanager_web(AXImanager_web),               // Output write enable signal for AXImanager

        .B_bramcontroller_state(B_bramcontroller_state) // Output state of the BRAM controller FSM
    );

//****************************** BRAM controller ******************************





//****************************** PP control ******************************
    // Input 
    // wire new_round;
    // wire Xbasis_detected_pos_ready;
    // wire Zbasis_detected_pos_ready;
    wire finish_sifting;
    wire finish_ER;
    wire finish_PA;
    // wire [14:0] siftedkey_addra;
    // wire siftedkey_wea;
    // wire [14:0] reconciledkey_addra;
    // wire reconciledkey_wea;

    wire [14:0] secretkey_addrb;
    wire secretkey_web;
    wire [14:0] secretkey_addrb;
    wire secretkey_web;
    assign secretkey_addrb = Secretkey_addrb[17:3];
    assign secretkey_web = |Secretkey_web;

    // Output wires and registers
    // wire request_valid;
    // wire Xbasis_detected_pos_request;
    // wire Zbasis_detected_pos_request;
    // wire secretkey_1_request;
    // wire secretkey_2_request;
    wire start_sifting;
    wire start_ER;
    wire sifted_key_addr_index;
    wire start_PA;
    wire reconciled_key_addr_index;
    wire [4:0] post_processing_state;

    B_post_processing_control u_B_post_processing_control (
        .clk(clk),                                      // Clock signal
        .rst_n(rst_n),                                  // Reset signal

        // AXI manager request & ready signals
        .request_valid(request_valid),
        .new_round(new_round),

        // Xbasis and Zbasis detected position signals
        .Xbasis_detected_pos_ready(Xbasis_detected_pos_ready),
        .Xbasis_detected_pos_request(Xbasis_detected_pos_request),
        .Zbasis_detected_pos_ready(Zbasis_detected_pos_ready),
        .Zbasis_detected_pos_request(Zbasis_detected_pos_request),

        // Secret key requests
        .secretkey_1_request(secretkey_1_request),
        .secretkey_2_request(secretkey_2_request),

        // Sifting signals
        .start_sifting(start_sifting),
        .finish_sifting(finish_sifting),

        // Error Reconciliation (ER) signals
        .start_ER(start_ER),
        .sifted_key_addr_index(sifted_key_addr_index),
        .finish_ER(finish_ER),

        // Post-authentication (PA) signals
        .start_PA(start_PA),
        .reconciled_key_addr_index(reconciled_key_addr_index),
        .finish_PA(finish_PA),

        // Key readiness determination
        .siftedkey_addra(Bsiftedkey_addra),
        .siftedkey_wea(Bsiftedkey_wea),
        .reconciledkey_addra(Breconciledkey_addra),
        .reconciledkey_wea(Breconciledkey_wea),
        .secretkey_addrb(secretkey_addrb),
        .secretkey_web(secretkey_web),

        // FSM state
        .post_processing_state(post_processing_state)
    );

//****************************** PP control ******************************






//****************************** sifting ******************************
    wire wait_sifting_TX;
    top_B_sifting u_Bsifting (
        .clk(clk),
        .rst_n(rst_n),
        .start_B_sifting(start_sifting),
        
        .start_B_TX(start_TX),
        .wait_B_TX(wait_sifting_TX),
        
        .B_sifting_finish(finish_sifting),

        .Xbasis_detected_pos_doutb(Xbasis_detected_pos_doutb),
        .Xbasis_detected_pos_addrb_32(Xbasis_detected_pos_addrb),
        .Xbasis_detected_pos_clkb(Xbasis_detected_pos_clkb),
        .Xbasis_detected_pos_enb(Xbasis_detected_pos_enb),
        .Xbasis_detected_pos_rstb(Xbasis_detected_pos_rstb),
        .Xbasis_detected_pos_web(Xbasis_detected_pos_web),

        .Zbasis_detected_pos_doutb(Zbasis_detected_pos_doutb),
        .Zbasis_detected_pos_addrb_32(Zbasis_detected_pos_addrb),
        .Zbasis_detected_pos_clkb(Zbasis_detected_pos_clkb),
        .Zbasis_detected_pos_enb(Zbasis_detected_pos_enb),
        .Zbasis_detected_pos_rstb(Zbasis_detected_pos_rstb),
        .Zbasis_detected_pos_web(Zbasis_detected_pos_web),

        .B_RX_Zbasis_decoy_rd_clk(B_RX_Zbasis_decoy_rd_clk),
        .B_RX_Zbasis_decoy_rd_en(B_RX_Zbasis_decoy_rd_en),
        .B_RX_Zbasis_decoy_rd_dout(B_RX_Zbasis_decoy_rd_dout),
        .B_RX_Zbasis_decoy_empty(B_RX_Zbasis_decoy_empty),
        .B_RX_Zbasis_decoy_rd_valid(B_RX_Zbasis_decoy_rd_valid),

        .B_TX_detected_wr_clk(B_TX_detected_wr_clk),
        .B_TX_detected_wr_din(B_TX_detected_wr_din),
        .B_TX_detected_wr_en(B_TX_detected_wr_en),
        .B_TX_detected_full(B_TX_detected_full),
        .B_TX_detected_wr_ack(B_TX_detected_wr_ack),
        .B_TX_detected_empty(B_TX_detected_empty_cdc),

        .Bsiftedkey_dina(Bsiftedkey_dina),
        .Bsiftedkey_addra(Bsiftedkey_addra),
        .Bsiftedkey_clka(Bsiftedkey_clka),
        .Bsiftedkey_ena(Bsiftedkey_ena),
        .Bsiftedkey_wea(Bsiftedkey_wea)
    );

//****************************** sifting ******************************








//****************************** error reconciliation ******************************
    wire B_single_frame_error_verification_fail;
    wire wait_ER_TX;
    top_B_ER B_ER_test (
        .clk(clk),                                // Connect to clock
        .rst_n(rst_n),                            // Connect to reset

        .start_B_ER(start_ER), // Start signal for all frame error reconciliation
        
        .start_TX(start_TX),
        .wait_TX(wait_ER_TX),

        .finish_B_ER(finish_ER),        //finish all frame error reconciliation

        .EVrandombit_full(EVrandombit_full_cdc),
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
        .B_B2A_wr_ack(B_TX_er_wr_clk),

        // Reconciled key BRAM connections
        .reconciledkey_addra(Breconciledkey_addra),
        .reconciledkey_clka(Breconciledkey_clka),
        .reconciledkey_dina(Breconciledkey_dina),
        .reconciledkey_ena(Breconciledkey_ena),
        .reconciledkey_rsta(),
        .reconciledkey_wea(Breconciledkey_wea)
    );

//****************************** error reconciliation ******************************






//****************************** privacy amplification ******************************

    wire fail_PA;


    wire [14:0] Secretkey_addrb_15;
    assign Secretkey_addrb = {14'b0 , Secretkey_addrb_15 , 3'b0};



    top_B_pa u_top_B_pa (
        .clk(clk),                                     // Clock signal
        .rst_n(rst_n),                                 // Reset signal

        .start_B_pa(start_PA),                       // Input to start PA
        
        .PArandombit_full(PArandombit_full_cdc),           // Input indicating PA random bit from Alice is full
        .reset_pa_parameter(reset_pa_parameter),       // Output to reset PA parameters

        .reconciled_key_addr_index(reconciled_key_addr_index), // Input: Reconciled key address index


        .B_pa_finish(finish_PA),                     // Output indicating PA is done
        .B_pa_fail(fail_PA),                         // Output indicating PA failure due to secret key length

        // Secret key length FIFO connections
        .B_RX_secretkey_length_rd_clk(B_RX_secretkey_length_rd_clk),
        .B_RX_secretkey_length_rd_en(B_RX_secretkey_length_rd_en),
        .B_RX_secretkey_length_rd_dout(B_RX_secretkey_length_rd_dout),
        .B_RX_secretkey_length_empty(B_RX_secretkey_length_empty),
        .B_RX_secretkey_length_rd_valid(B_RX_secretkey_length_rd_valid),

        // Reconciled key BRAM connections
        .key_doutb(Breconciledkey_doutb),
        .key_clkb(Breconciledkey_clkb),
        .key_enb(Breconciledkey_enb),
        .key_web(Breconciledkey_web),
        .key_rstb(),
        .key_index_and_addrb(Breconciledkey_addrb),

        // Secret key BRAM connections
        .Secretkey_addrb(Secretkey_addrb_15),
        .Secretkey_clkb(Secretkey_clkb),
        .Secretkey_dinb(Secretkey_dinb),
        .Secretkey_enb(Secretkey_enb),
        .Secretkey_rstb(),
        .Secretkey_web(Secretkey_web),

        // Random bit BRAM connections
        .PArandombit_doutb(B_RX_PArandombit_doutb),
        .PArandombit_addrb(B_RX_PArandombit_addrb),
        .PArandombit_clkb(B_RX_PArandombit_clkb),
        .PArandombit_enb(B_RX_PArandombit_enb),
        .PArandombit_rstb(),
        .PArandombit_web(B_RX_PArandombit_web)
    );

//****************************** privacy amplification ******************************






//****************************** B packet  ******************************
    // Input 
    // wire clk;
    // wire rst_n;
    // wire busy_Net2PP_TX;

    // Output 
    // wire busy_PP2Net_TX;
    // wire msg_stored;
    // wire [10:0] sizeTX_msg; // Output register for message size

    wire [3:0] B_packet_state;

    // B_B2A detected fifo connections
    // wire B_TX_detected_rd_clk;
    // wire B_TX_detected_rd_en;
    // wire [31:0] B_TX_detected_rd_dout;
    // wire B_TX_detected_empty;
    // wire B_TX_detected_rd_valid;

    // B_B2A er fifo connections
    // wire B_TX_er_rd_clk;
    // wire B_TX_er_rd_en;
    // wire [31:0] B_TX_er_rd_dout;
    // wire B_TX_er_empty;
    // wire B_TX_er_rd_valid;

    // TX BRAM connections
    // wire B_TX_bram_clkb;
    // wire B_TX_bram_enb;
    // wire B_TX_bram_web;
    // wire [10:0] B_TX_bram_addrb;
    // wire [31:0] B_TX_bram_dinb;

    B_packet u_B_packet (
        .clk(clkTX_msg),                               // Clock signal
        .rst_n(rst_n),                           // Reset signal

        .busy_Net2PP_TX(busy_Net2PP_TX),         // Input indicating network to post-processing transmission is busy

        .busy_PP2Net_TX(busy_PP2Net_TX),         // Output indicating post-processing to network transmission is busy
        .msg_stored(msg_stored),                 // Output indicating message is stored
        .sizeTX_msg(sizeTX_msg),                 // Output register for message size

        .B_packet_state(B_packet_state),         // Output state of the B_packet FSM

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






//****************************** B unpacket  ******************************
    // Input 
    // wire clk;
    // wire rst_n;
    // wire busy_Net2PP_RX;
    // wire msg_accessed;
    // wire [10:0] sizeRX_msg;
    wire reset_er_parameter;
    wire reset_pa_parameter;

    // Output 
    // wire busy_PP2Net_RX;
    wire EVrandombit_full;
    wire PArandombit_full;
    wire [3:0] B_unpacket_state;

    // B_A2B fifo and bram connections
    // wire B_RX_Zbasis_decoy_wr_clk;
    // wire [31:0] B_RX_Zbasis_decoy_wr_din;
    // wire B_RX_Zbasis_decoy_wr_en;
    // wire B_RX_Zbasis_decoy_full;
    // wire B_RX_Zbasis_decoy_wr_ack;

    // wire B_RX_er_wr_clk;
    // wire [31:0] B_RX_er_wr_din;
    // wire B_RX_er_wr_en;
    // wire B_RX_er_full;
    // wire B_RX_er_wr_ack;

    // wire [63:0] B_RX_EVrandombit_dina;
    // wire [13:0] B_RX_EVrandombit_addra;
    // wire B_RX_EVrandombit_clka;
    // wire B_RX_EVrandombit_ena;
    // wire B_RX_EVrandombit_wea;

    // wire B_RX_secretkey_length_wr_clk;
    // wire [31:0] B_RX_secretkey_length_wr_din;
    // wire B_RX_secretkey_length_wr_en;
    // wire B_RX_secretkey_length_full;
    // wire B_RX_secretkey_length_wr_ack;

    // wire [63:0] B_RX_PArandombit_dina;
    // wire [13:0] B_RX_PArandombit_addra;
    // wire B_RX_PArandombit_clka;
    // wire B_RX_PArandombit_ena;
    // wire B_RX_PArandombit_wea;

    // wire B_RX_bram_clkb;
    // wire B_RX_bram_enb;
    // wire B_RX_bram_web;
    // wire [10:0] B_RX_bram_addrb;
    // wire [31:0] B_RX_bram_doutb;


    B_unpacket u_B_unpacket (
        .clk(clkRX_msg),                                       // Clock signal
        .rst_n(rst_n),                                   // Reset signal

        .busy_Net2PP_RX(busy_Net2PP_RX),                 // Input indicating the network to post-processing reception is busy
        .msg_accessed(msg_accessed),                     // Input indicating message access
        .sizeRX_msg(sizeRX_msg),                         // Input for size of RX message

        .busy_PP2Net_RX(busy_PP2Net_RX),                 // Output indicating post-processing to network reception is busy

        .reset_er_parameter(reset_er_parameter_cdc),         // Input to reset error reconciliation parameter
        .EVrandombit_full(EVrandombit_full),             // Output indicating EV random bit buffer is full

        .reset_pa_parameter(reset_pa_parameter_cdc),         // Input to reset post-authentication parameter
        .PArandombit_full(PArandombit_full),             // Output indicating PA random bit buffer is full

        .B_unpacket_state(B_unpacket_state),             // Output state of the B_unpacket FSM

        // B_A2B decoy fifo connections
        .B_RX_Zbasis_decoy_wr_clk(B_RX_Zbasis_decoy_wr_clk),
//        .B_RX_Zbasis_decoy_wr_din(B_RX_Zbasis_decoy_wr_din),
//        .B_RX_Zbasis_decoy_wr_en(B_RX_Zbasis_decoy_wr_en),
        .B_RX_Zbasis_decoy_wr_din_delay(B_RX_Zbasis_decoy_wr_din),
        .B_RX_Zbasis_decoy_wr_en_delay(B_RX_Zbasis_decoy_wr_en),
        .B_RX_Zbasis_decoy_full(B_RX_Zbasis_decoy_full),
        .B_RX_Zbasis_decoy_wr_ack(B_RX_Zbasis_decoy_wr_ack),

        // B_A2B ER fifo connections
        .B_RX_er_wr_clk(B_RX_er_wr_clk),
//        .B_RX_er_wr_din(B_RX_er_wr_din),
//        .B_RX_er_wr_en(B_RX_er_wr_en),
        .B_RX_er_wr_din_delay(B_RX_er_wr_din),
        .B_RX_er_wr_en_delay(B_RX_er_wr_en),
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
//        .B_RX_secretkey_length_wr_din(B_RX_secretkey_length_wr_din),
//        .B_RX_secretkey_length_wr_en(B_RX_secretkey_length_wr_en),
        .B_RX_secretkey_length_wr_din_delay(B_RX_secretkey_length_wr_din),
        .B_RX_secretkey_length_wr_en_delay(B_RX_secretkey_length_wr_en),
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
    //********************** cdc for Bob sifting signal **********************
    wire B_TX_detected_empty_cdc;
    cdc_delay1 u_B_TX_detected_empty_delay(
        .clk_src(clkTX_msg),
        .clk_des(clk),
        .reset(~rst_n),
        .pulse_src(B_TX_detected_empty),
        .pulse_des(B_TX_detected_empty_cdc)
    );
    //********************** cdc for Bob sifting signal *************************
    //********************** cdc for Bob ER signal *************************
    wire reset_er_parameter_cdc;
    cdc_delay1 u_reset_er_parameter_cdc(
        .clk_src(clk),
        .clk_des(clkRX_msg),
        .reset(~rst_n),
        .pulse_src(reset_er_parameter),
        .pulse_des(reset_er_parameter_cdc)
    );
    wire EVrandombit_full_cdc;
    cdc_delay1 u_EVrandombit_full_cdc(
        .clk_src(clkRX_msg),
        .clk_des(clk),
        .reset(~rst_n),
        .pulse_src(EVrandombit_full),
        .pulse_des(EVrandombit_full_cdc)
    );
    //********************** cdc for Bob ER signal *************************
    //********************** cdc for Bob PA signal *************************
    wire reset_pa_parameter_cdc;
    wire PArandombit_full_cdc;
    cdc_delay1 u_reset_pa_parameter_cdc(
        .clk_src(clk),
        .clk_des(clkRX_msg),
        .reset(~rst_n),
        .pulse_src(reset_pa_parameter),
        .pulse_des(reset_pa_parameter_cdc)
    );
    cdc_delay1 u_PArandombit_full_cdc(
        .clk_src(clkRX_msg),
        .clk_des(clk),
        .reset(~rst_n),
        .pulse_src(PArandombit_full),
        .pulse_des(PArandombit_full_cdc)
    );
    //********************** cdc for Bob PA signal *************************
    //********************** cdc for Bob PA signal *************************


endmodule
