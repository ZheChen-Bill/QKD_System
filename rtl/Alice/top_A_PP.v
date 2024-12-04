`include "PP_parameter.v"


module top_A_PP (

      input clk_out_125M,
      input clk_out_20M,
      input proc_rst_n,
      
      input clkTX_msg,
      input clkRX_msg,

      input start_TX,
      input start_switch,
      output wait_TX,
      
      output finish_sifting,
      output finish_ER,
      output finish_PA,
    //    input default_sysclk1_300_clk_n,
    //    input default_sysclk1_300_clk_p,
    //    input reset_high,

    //    output rst_n,
    //    output clk_out_125M,

    // TX 
    // A packet
    input busy_Net2PP_TX,
    output busy_PP2Net_TX,
    output msg_stored,
    output [10:0] sizeTX_msg,
    // TX BRAM connections
    output A_TX_bram_clkb,
    output A_TX_bram_enb,
    output A_TX_bram_web,
    output [10:0] A_TX_bram_addrb,
    output [31:0] A_TX_bram_dinb,

    // RX
    // A unpacket
    input busy_Net2PP_RX,
    input msg_accessed,
    input [10:0] sizeRX_msg,
    output busy_PP2Net_RX,
    // RX BRAM connections
    output A_RX_bram_clkb,
    output A_RX_bram_enb,
    output A_RX_bram_web,
    output [10:0] A_RX_bram_addrb,
    input [31:0] A_RX_bram_doutb,

    // AXImanager BRAM PORT-A
    input [31:0]AXImanager_PORTA_addr,
    input AXImanager_PORTA_clk,
    input [63:0]AXImanager_PORTA_din,
    output [63:0]AXImanager_PORTA_dout,
    input AXImanager_PORTA_en,
    input AXImanager_PORTA_rst,
    input [7:0]AXImanager_PORTA_we,

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
    input [31:0]Secretkey_PORTA_addr,
    input Secretkey_PORTA_clk,
    input [63:0]Secretkey_PORTA_din,
    output [63:0]Secretkey_PORTA_dout,
    input Secretkey_PORTA_en,
    input Secretkey_PORTA_rst,
    input [7:0]Secretkey_PORTA_we

);
    //****************************** wait_TX_signal ************************
    assign wait_TX = ((wait_sifting_TX)||(wait_ER_TX)||(wait_PA_TX));
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

    // wire [31:0]EVrandombit_PORTA_addr;
    // wire EVrandombit_PORTA_clk;
    // wire [63:0]EVrandombit_PORTA_din;
    // wire [63:0]EVrandombit_PORTA_dout;
    // wire EVrandombit_PORTA_en;
    // wire EVrandombit_PORTA_rst;
    // wire [7:0]EVrandombit_PORTA_we;

    wire [31:0]EVrandombit_addrb;
    wire EVrandombit_clkb;
    wire [63:0]EVrandombit_dinb;
    wire [63:0]EVrandombit_doutb;
    wire EVrandombit_enb;
    wire EVrandombit_rstb;
    wire [7:0]EVrandombit_web;

    // wire [31:0]PArandombit_PORTA_addr;
    // wire PArandombit_PORTA_clk;
    // wire [63:0]PArandombit_PORTA_din;
    // wire [63:0]PArandombit_PORTA_dout;
    // wire PArandombit_PORTA_en;
    // wire PArandombit_PORTA_rst;
    // wire [7:0]PArandombit_PORTA_we;

    wire [31:0]PArandombit_addrb;
    wire PArandombit_clkb;
    wire [63:0]PArandombit_dinb;
    wire [63:0]PArandombit_doutb;
    wire PArandombit_enb;
    wire PArandombit_rstb;
    wire [7:0]PArandombit_web;

    // wire [31:0]QC_PORTA_addr;
    // wire QC_PORTA_clk;
    // wire [63:0]QC_PORTA_din;
    // wire [63:0]QC_PORTA_dout;
    // wire QC_PORTA_en;
    // wire QC_PORTA_rst;
    // wire [7:0]QC_PORTA_we;

    wire [31:0]QC_addrb;
    wire QC_clkb;
    wire [63:0]QC_dinb;
    wire [63:0]QC_doutb;
    wire QC_enb;
    wire QC_rstb;
    wire [7:0]QC_web;

    // wire [31:0]Qubit_PORTA_addr;
    // wire Qubit_PORTA_clk;
    // wire [63:0]Qubit_PORTA_din;
    // wire [63:0]Qubit_PORTA_dout;
    // wire Qubit_PORTA_en;
    // wire Qubit_PORTA_rst;
    // wire [7:0]Qubit_PORTA_we;

    wire [31:0]Qubit_addrb;
    wire Qubit_clkb;
    wire [63:0]Qubit_dinb;
    wire [63:0]Qubit_doutb;
    wire Qubit_enb;
    wire Qubit_rstb;
    wire [7:0]Qubit_web;

    // wire [31:0]Secretkey_PORTA_addr;
    // wire Secretkey_PORTA_clk;
    // wire [63:0]Secretkey_PORTA_din;
    // wire [63:0]Secretkey_PORTA_dout;
    // wire Secretkey_PORTA_en;
    // wire Secretkey_PORTA_rst;
    // wire [7:0]Secretkey_PORTA_we;

    wire [31:0]Secretkey_addrb;
    wire Secretkey_clkb;
    wire [63:0]Secretkey_dinb;
    wire [63:0]Secretkey_doutb;
    wire Secretkey_enb;
    wire Secretkey_rstb;
    wire [7:0]Secretkey_web;


    // wire default_sysclk1_300_clk_n;
    // wire default_sysclk1_300_clk_p;
    // wire reset_high;
    wire clk_out_125M;
    wire clk_out_20M;
    wire [0:0]proc_rst_n;

    BD_AXImanager_A_wrapper AXImanager_A
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

        .EVrandombit_PORTA_addr(EVrandombit_PORTA_addr),
        .EVrandombit_PORTA_clk(EVrandombit_PORTA_clk),
        .EVrandombit_PORTA_din(EVrandombit_PORTA_din),
        .EVrandombit_PORTA_dout(EVrandombit_PORTA_dout),
        .EVrandombit_PORTA_en(EVrandombit_PORTA_en),
        .EVrandombit_PORTA_rst(EVrandombit_PORTA_rst),
        .EVrandombit_PORTA_we(EVrandombit_PORTA_we),

        .EVrandombit_addrb(EVrandombit_addrb),
        .EVrandombit_clkb(EVrandombit_clkb),
        .EVrandombit_dinb(EVrandombit_dinb),
        .EVrandombit_doutb(EVrandombit_doutb),
        .EVrandombit_enb(EVrandombit_enb),
        .EVrandombit_rstb(EVrandombit_rstb),
        .EVrandombit_web(EVrandombit_web),

        .PArandombit_PORTA_addr(PArandombit_PORTA_addr),
        .PArandombit_PORTA_clk(PArandombit_PORTA_clk),
        .PArandombit_PORTA_din(PArandombit_PORTA_din),
        .PArandombit_PORTA_dout(PArandombit_PORTA_dout),
        .PArandombit_PORTA_en(PArandombit_PORTA_en),
        .PArandombit_PORTA_rst(PArandombit_PORTA_rst),
        .PArandombit_PORTA_we(PArandombit_PORTA_we),

        .PArandombit_addrb(PArandombit_addrb),
        .PArandombit_clkb(PArandombit_clkb),
        .PArandombit_dinb(PArandombit_dinb),
        .PArandombit_doutb(PArandombit_doutb),
        .PArandombit_enb(PArandombit_enb),
        .PArandombit_rstb(PArandombit_rstb),
        .PArandombit_web(PArandombit_web),

        .QC_PORTA_addr(QC_PORTA_addr),
        .QC_PORTA_clk(QC_PORTA_clk),
        .QC_PORTA_din(QC_PORTA_din),
        .QC_PORTA_dout(QC_PORTA_dout),
        .QC_PORTA_en(QC_PORTA_en),
        .QC_PORTA_rst(QC_PORTA_rst),
        .QC_PORTA_we(QC_PORTA_we),

        .QC_addrb(QC_addrb),
        .QC_clkb(QC_clkb),
        .QC_dinb(QC_dinb),
        .QC_doutb(QC_doutb),
        .QC_enb(QC_enb),
        .QC_rstb(QC_rstb),
        .QC_web(QC_web),

        .Qubit_PORTA_addr(Qubit_PORTA_addr),
        .Qubit_PORTA_clk(Qubit_PORTA_clk),
        .Qubit_PORTA_din(Qubit_PORTA_din),
        .Qubit_PORTA_dout(Qubit_PORTA_dout),
        .Qubit_PORTA_en(Qubit_PORTA_en),
        .Qubit_PORTA_rst(Qubit_PORTA_rst),
        .Qubit_PORTA_we(Qubit_PORTA_we),

        .Qubit_addrb(Qubit_addrb),
        .Qubit_clkb(Qubit_clkb),
        .Qubit_dinb(Qubit_dinb),
        .Qubit_doutb(Qubit_doutb),
        .Qubit_enb(Qubit_enb),
        .Qubit_rstb(Qubit_rstb),
        .Qubit_web(Qubit_web),

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
        .Secretkey_web(Secretkey_web)

//        .clk_out_125M(clk_out_125M),
//        .clk_out_20M(clk_out_20M),
//        .default_sysclk1_300_clk_n(default_sysclk1_300_clk_n),
//        .default_sysclk1_300_clk_p(default_sysclk1_300_clk_p),
//        .proc_rst_n(proc_rst_n),
//        .reset_high(reset_high)
        );
    //****************************** AXI manager ******************************






    //****************************** interface ******************************

    wire A_RX_Xbasis_detected_empty;
    wire A_RX_Xbasis_detected_full;
    wire A_RX_Xbasis_detected_rd_clk;
    wire [63:0]A_RX_Xbasis_detected_rd_dout;
    wire A_RX_Xbasis_detected_rd_en;
    wire A_RX_Xbasis_detected_rd_rst_busy;
    wire A_RX_Xbasis_detected_rd_valid;
    wire A_RX_Xbasis_detected_srst;
    wire A_RX_Xbasis_detected_wr_ack;
    wire A_RX_Xbasis_detected_wr_clk;
    wire [63:0]A_RX_Xbasis_detected_wr_din;
    wire A_RX_Xbasis_detected_wr_en;
    wire A_RX_Xbasis_detected_wr_rst_busy;

    wire A_RX_Zbasis_detected_empty;
    wire A_RX_Zbasis_detected_full;
    wire A_RX_Zbasis_detected_rd_clk;
    wire [31:0]A_RX_Zbasis_detected_rd_dout;
    wire A_RX_Zbasis_detected_rd_en;
    wire A_RX_Zbasis_detected_rd_rst_busy;
    wire A_RX_Zbasis_detected_rd_valid;
    wire A_RX_Zbasis_detected_srst;
    wire A_RX_Zbasis_detected_wr_ack;
    wire A_RX_Zbasis_detected_wr_clk;
    wire [31:0]A_RX_Zbasis_detected_wr_din;
    wire A_RX_Zbasis_detected_wr_en;
    wire A_RX_Zbasis_detected_wr_rst_busy;

    wire A_RX_er_empty;
    wire A_RX_er_full;
    wire A_RX_er_rd_clk;
    wire [31:0]A_RX_er_rd_dout;
    wire A_RX_er_rd_en;
    wire A_RX_er_rd_rst_busy;
    wire A_RX_er_rd_valid;
    wire A_RX_er_srst;
    wire A_RX_er_wr_ack;
    wire A_RX_er_wr_clk;
    wire [31:0]A_RX_er_wr_din;
    wire A_RX_er_wr_en;
    wire A_RX_er_wr_rst_busy;

    wire A_TX_decoy_empty;
    wire A_TX_decoy_full;
    wire A_TX_decoy_rd_clk;
    wire [31:0]A_TX_decoy_rd_dout;
    wire A_TX_decoy_rd_en;
    wire A_TX_decoy_rd_rst_busy;
    wire A_TX_decoy_rd_valid;
    wire A_TX_decoy_srst;
    wire A_TX_decoy_wr_ack;
    wire A_TX_decoy_wr_clk;
    wire [31:0]A_TX_decoy_wr_din;
    wire A_TX_decoy_wr_en;
    wire A_TX_decoy_wr_rst_busy;

    wire A_TX_er_empty;
    wire A_TX_er_full;
    wire A_TX_er_rd_clk;
    wire [31:0]A_TX_er_rd_dout;
    wire A_TX_er_rd_en;
    wire A_TX_er_rd_rst_busy;
    wire A_TX_er_rd_valid;
    wire A_TX_er_srst;
    wire A_TX_er_wr_ack;
    wire A_TX_er_wr_clk;
    wire [31:0]A_TX_er_wr_din;
    wire A_TX_er_wr_en;
    wire A_TX_er_wr_rst_busy;

    wire A_TX_pa_empty;
    wire A_TX_pa_full;
    wire A_TX_pa_rd_clk;
    wire [31:0]A_TX_pa_rd_dout;
    wire A_TX_pa_rd_en;
    wire A_TX_pa_rd_rst_busy;
    wire A_TX_pa_rd_valid;
    wire A_TX_pa_srst;
    wire A_TX_pa_wr_ack;
    wire A_TX_pa_wr_clk;
    wire [31:0]A_TX_pa_wr_din;
    wire A_TX_pa_wr_en;
    wire A_TX_pa_wr_rst_busy;

    wire [14:0]Areconciledkey_addra;
    wire [14:0]Areconciledkey_addrb;
    wire Areconciledkey_clka;
    wire Areconciledkey_clkb;
    wire [63:0]Areconciledkey_dina;
    wire [63:0]Areconciledkey_dinb;
    wire [63:0]Areconciledkey_douta;
    wire [63:0]Areconciledkey_doutb;
    wire Areconciledkey_ena;
    wire Areconciledkey_enb;
    wire [0:0]Areconciledkey_wea;
    wire [0:0]Areconciledkey_web;

    wire [14:0]Asiftedkey_addra;
    wire [14:0]Asiftedkey_addrb;
    wire Asiftedkey_clka;
    wire Asiftedkey_clkb;
    wire [63:0]Asiftedkey_dina;
    wire [63:0]Asiftedkey_dinb;
    wire [63:0]Asiftedkey_douta;
    wire [63:0]Asiftedkey_doutb;
    wire Asiftedkey_ena;
    wire Asiftedkey_enb;
    wire [0:0]Asiftedkey_wea;
    wire [0:0]Asiftedkey_web;

    wire er_parm_empty;
    wire er_parm_full;
    wire er_parm_rd_clk;
    wire [31:0]er_parm_rd_dout;
    wire er_parm_rd_en;
    wire er_parm_rd_rst_busy;
    wire er_parm_rd_valid;
    wire er_parm_srst;
    wire er_parm_wr_ack;
    wire er_parm_wr_clk;
    wire [31:0]er_parm_wr_din;
    wire er_parm_wr_en;
    wire er_parm_wr_rst_busy;

    wire visibility_empty;
    wire visibility_full;
    wire visibility_rd_clk;
    wire [119:0]visibility_rd_dout;
    wire visibility_rd_en;
    wire visibility_rd_rst_busy;
    wire visibility_rd_valid;
    wire visibility_srst;
    wire visibility_wr_ack;
    wire visibility_wr_clk;
    wire [119:0]visibility_wr_din;
    wire visibility_wr_en;
    wire visibility_wr_rst_busy;

    assign A_RX_Xbasis_detected_srst = ~rst_n;
    assign A_RX_Zbasis_detected_srst = ~rst_n;
    assign A_RX_er_srst = ~rst_n;
    assign A_TX_decoy_srst = ~rst_n;
    assign A_TX_er_srst = ~rst_n;
    assign A_TX_pa_srst = ~rst_n;
    assign er_parm_srst = ~rst_n;
    assign visibility_srst = ~rst_n;

    BD_interface_A_wrapper interface_A
    (   .A_RX_Xbasis_detected_empty(A_RX_Xbasis_detected_empty),
        .A_RX_Xbasis_detected_full(A_RX_Xbasis_detected_full),
        .A_RX_Xbasis_detected_rd_clk(A_RX_Xbasis_detected_rd_clk),
        .A_RX_Xbasis_detected_rd_dout(A_RX_Xbasis_detected_rd_dout),
        .A_RX_Xbasis_detected_rd_en(A_RX_Xbasis_detected_rd_en),
        .A_RX_Xbasis_detected_rd_rst_busy(A_RX_Xbasis_detected_rd_rst_busy),
        .A_RX_Xbasis_detected_rd_valid(A_RX_Xbasis_detected_rd_valid),
        .A_RX_Xbasis_detected_srst(A_RX_Xbasis_detected_srst),
        .A_RX_Xbasis_detected_wr_ack(A_RX_Xbasis_detected_wr_ack),
        .A_RX_Xbasis_detected_wr_clk(A_RX_Xbasis_detected_wr_clk),
        .A_RX_Xbasis_detected_wr_din(A_RX_Xbasis_detected_wr_din),
        .A_RX_Xbasis_detected_wr_en(A_RX_Xbasis_detected_wr_en),
        .A_RX_Xbasis_detected_wr_rst_busy(A_RX_Xbasis_detected_wr_rst_busy),

        .A_RX_Zbasis_detected_empty(A_RX_Zbasis_detected_empty),
        .A_RX_Zbasis_detected_full(A_RX_Zbasis_detected_full),
        .A_RX_Zbasis_detected_rd_clk(A_RX_Zbasis_detected_rd_clk),
        .A_RX_Zbasis_detected_rd_dout(A_RX_Zbasis_detected_rd_dout),
        .A_RX_Zbasis_detected_rd_en(A_RX_Zbasis_detected_rd_en),
        .A_RX_Zbasis_detected_rd_rst_busy(A_RX_Zbasis_detected_rd_rst_busy),
        .A_RX_Zbasis_detected_rd_valid(A_RX_Zbasis_detected_rd_valid),
        .A_RX_Zbasis_detected_srst(A_RX_Zbasis_detected_srst),
        .A_RX_Zbasis_detected_wr_ack(A_RX_Zbasis_detected_wr_ack),
        .A_RX_Zbasis_detected_wr_clk(A_RX_Zbasis_detected_wr_clk),
        .A_RX_Zbasis_detected_wr_din(A_RX_Zbasis_detected_wr_din),
        .A_RX_Zbasis_detected_wr_en(A_RX_Zbasis_detected_wr_en),
        .A_RX_Zbasis_detected_wr_rst_busy(A_RX_Zbasis_detected_wr_rst_busy),

        .A_RX_er_empty(A_RX_er_empty),
        .A_RX_er_full(A_RX_er_full),
        .A_RX_er_rd_clk(A_RX_er_rd_clk),
        .A_RX_er_rd_dout(A_RX_er_rd_dout),
        .A_RX_er_rd_en(A_RX_er_rd_en),
        .A_RX_er_rd_rst_busy(A_RX_er_rd_rst_busy),
        .A_RX_er_rd_valid(A_RX_er_rd_valid),
        .A_RX_er_srst(A_RX_er_srst),
        .A_RX_er_wr_ack(A_RX_er_wr_ack),
        .A_RX_er_wr_clk(A_RX_er_wr_clk),
        .A_RX_er_wr_din(A_RX_er_wr_din),
        .A_RX_er_wr_en(A_RX_er_wr_en),
        .A_RX_er_wr_rst_busy(A_RX_er_wr_rst_busy),

        .A_TX_decoy_empty(A_TX_decoy_empty),
        .A_TX_decoy_full(A_TX_decoy_full),
        .A_TX_decoy_rd_clk(A_TX_decoy_rd_clk),
        .A_TX_decoy_rd_dout(A_TX_decoy_rd_dout),
        .A_TX_decoy_rd_en(A_TX_decoy_rd_en),
        .A_TX_decoy_rd_rst_busy(A_TX_decoy_rd_rst_busy),
        .A_TX_decoy_rd_valid(A_TX_decoy_rd_valid),
        .A_TX_decoy_srst(A_TX_decoy_srst),
        .A_TX_decoy_wr_ack(A_TX_decoy_wr_ack),
        .A_TX_decoy_wr_clk(A_TX_decoy_wr_clk),
        .A_TX_decoy_wr_din(A_TX_decoy_wr_din),
        .A_TX_decoy_wr_en(A_TX_decoy_wr_en),
        .A_TX_decoy_wr_rst_busy(A_TX_decoy_wr_rst_busy),

        .A_TX_er_empty(A_TX_er_empty),
        .A_TX_er_full(A_TX_er_full),
        .A_TX_er_rd_clk(A_TX_er_rd_clk),
        .A_TX_er_rd_dout(A_TX_er_rd_dout),
        .A_TX_er_rd_en(A_TX_er_rd_en),
        .A_TX_er_rd_rst_busy(A_TX_er_rd_rst_busy),
        .A_TX_er_rd_valid(A_TX_er_rd_valid),
        .A_TX_er_srst(A_TX_er_srst),
        .A_TX_er_wr_ack(A_TX_er_wr_ack),
        .A_TX_er_wr_clk(A_TX_er_wr_clk),
        .A_TX_er_wr_din(A_TX_er_wr_din),
        .A_TX_er_wr_en(A_TX_er_wr_en),
        .A_TX_er_wr_rst_busy(A_TX_er_wr_rst_busy),

        .A_TX_pa_empty(A_TX_pa_empty),
        .A_TX_pa_full(A_TX_pa_full),
        .A_TX_pa_rd_clk(A_TX_pa_rd_clk),
        .A_TX_pa_rd_dout(A_TX_pa_rd_dout),
        .A_TX_pa_rd_en(A_TX_pa_rd_en),
        .A_TX_pa_rd_rst_busy(A_TX_pa_rd_rst_busy),
        .A_TX_pa_rd_valid(A_TX_pa_rd_valid),
        .A_TX_pa_srst(A_TX_pa_srst),
        .A_TX_pa_wr_ack(A_TX_pa_wr_ack),
        .A_TX_pa_wr_clk(A_TX_pa_wr_clk),
        .A_TX_pa_wr_din(A_TX_pa_wr_din),
        .A_TX_pa_wr_en(A_TX_pa_wr_en),
        .A_TX_pa_wr_rst_busy(A_TX_pa_wr_rst_busy),

        .Areconciledkey_addra(Areconciledkey_addra),
        .Areconciledkey_addrb(Areconciledkey_addrb),
        .Areconciledkey_clka(Areconciledkey_clka),
        .Areconciledkey_clkb(Areconciledkey_clkb),
        .Areconciledkey_dina(Areconciledkey_dina),
        .Areconciledkey_dinb(Areconciledkey_dinb),
        .Areconciledkey_douta(Areconciledkey_douta),
        .Areconciledkey_doutb(Areconciledkey_doutb),
        .Areconciledkey_ena(Areconciledkey_ena),
        .Areconciledkey_enb(Areconciledkey_enb),
        .Areconciledkey_wea(Areconciledkey_wea),
        .Areconciledkey_web(Areconciledkey_web),

        .Asiftedkey_addra(Asiftedkey_addra),
        .Asiftedkey_addrb(Asiftedkey_addrb),
        .Asiftedkey_clka(Asiftedkey_clka),
        .Asiftedkey_clkb(Asiftedkey_clkb),
        .Asiftedkey_dina(Asiftedkey_dina),
        .Asiftedkey_dinb(Asiftedkey_dinb),
        .Asiftedkey_douta(Asiftedkey_douta),
        .Asiftedkey_doutb(Asiftedkey_doutb),
        .Asiftedkey_ena(Asiftedkey_ena),
        .Asiftedkey_enb(Asiftedkey_enb),
        .Asiftedkey_wea(Asiftedkey_wea),
        .Asiftedkey_web(Asiftedkey_web),

        .er_parm_empty(er_parm_empty),
        .er_parm_full(er_parm_full),
        .er_parm_rd_clk(er_parm_rd_clk),
        .er_parm_rd_dout(er_parm_rd_dout),
        .er_parm_rd_en(er_parm_rd_en),
        .er_parm_rd_rst_busy(er_parm_rd_rst_busy),
        .er_parm_rd_valid(er_parm_rd_valid),
        .er_parm_srst(er_parm_srst),
        .er_parm_wr_ack(er_parm_wr_ack),
        .er_parm_wr_clk(er_parm_wr_clk),
        .er_parm_wr_din(er_parm_wr_din),
        .er_parm_wr_en(er_parm_wr_en),
        .er_parm_wr_rst_busy(er_parm_wr_rst_busy),

        .visibility_empty(visibility_empty),
        .visibility_full(visibility_full),
        .visibility_rd_clk(visibility_rd_clk),
        .visibility_rd_dout(visibility_rd_dout),
        .visibility_rd_en(visibility_rd_en),
        .visibility_rd_rst_busy(visibility_rd_rst_busy),
        .visibility_rd_valid(visibility_rd_valid),
        .visibility_srst(visibility_srst),
        .visibility_wr_ack(visibility_wr_ack),
        .visibility_wr_clk(visibility_wr_clk),
        .visibility_wr_din(visibility_wr_din),
        .visibility_wr_en(visibility_wr_en),
        .visibility_wr_rst_busy(visibility_wr_rst_busy));

    //****************************** interface ******************************





    //****************************** BRAM controller ******************************
    // Input 
    // wire [63:0] AXImanager_doutb;
    // wire secretkey_length_request;
    wire qubit_request;
    wire EVrandombit_request;
    wire PArandombit_request;
    wire secretkey_1_request;
    wire secretkey_2_request;
    wire request_valid;

    // Output 
    wire AXIbram_ready_en;
    wire qubit_ready;
    wire EVrandombit_ready;
    wire PArandombit_ready;
    wire new_round;

    // wire AXImanager_clkb;
    // wire [31:0] AXImanager_addrb;
    // wire [63:0] AXImanager_dinb;
    // wire AXImanager_enb;
    // wire AXImanager_rstb;
    // wire [7:0] AXImanager_web;

    wire [3:0] A_bramcontroller_state;



    A_bram_controller u_A_bram_controller (
        .clk(clk), // Clock signal
        .rst_n(rst_n), // Reset signal

        .AXImanager_doutb(AXImanager_doutb), // Input data from AXImanager
        // .secretkey_length_request(secretkey_length_request), // Input request for secret key length
        .qubit_request(qubit_request), // Input request for qubit
        .EVrandombit_request(EVrandombit_request), // Input request for EV random bits
        .PArandombit_request(PArandombit_request), // Input request for PA random bits
        .secretkey_1_request(secretkey_1_request), // Input request for first secret key
        .secretkey_2_request(secretkey_2_request), // Input request for second secret key
        .request_valid(request_valid), // Input signal indicating AXI request is valid

        .AXIbram_ready_en(AXIbram_ready_en), // Output signal indicating AXI BRAM is ready
        .qubit_ready(qubit_ready), // Output signal indicating qubit is ready
        .EVrandombit_ready(EVrandombit_ready), // Output signal indicating EV random bits are ready
        .PArandombit_ready(PArandombit_ready), // Output signal indicating PA random bits are ready
        .new_round(new_round),

        .AXImanager_clkb(AXImanager_clkb), // Output clock signal for AXImanager
        .AXImanager_addrb(AXImanager_addrb), // Output address for AXImanager
        .AXImanager_dinb(AXImanager_dinb), // Output data for AXImanager
        .AXImanager_enb(AXImanager_enb), // Output enable signal for AXImanager
        .AXImanager_rstb(AXImanager_rstb), // Output reset signal for AXImanager
        .AXImanager_web(AXImanager_web), // Output write enable signal for AXImanager

        .A_bramcontroller_state(A_bramcontroller_state) // Output state of the BRAM controller FSM
    );

    //****************************** BRAM controller ******************************





    //****************************** PP control ******************************
    // Input 
    // wire clk;
    // wire rst_n;
    // wire new_round;
    // wire qubit_ready;
    // wire EVrandombit_ready;
    // wire PArandombit_ready;
    wire finish_sifting;
    wire finish_ER;
    wire accumulate_busy;
    wire keylength_valid;
    wire keylength_negative;
    wire keylength_small;
    wire keylength_input_outrange;
    wire [19:0] keylength;
    wire finish_PA;
    // wire [14:0] siftedkey_addra;
    // wire siftedkey_wea;
    // wire [14:0] reconciledkey_addra;
    // wire reconciledkey_wea;
    wire [14:0] secretkey_addrb;
    wire secretkey_web;
    assign secretkey_addrb = Secretkey_addrb[17:3];
    assign secretkey_web = |Secretkey_web;

    // Output 
    // wire request_valid;
    // wire qubit_request;
    // wire EVrandombit_request;
    // wire PArandombit_request;
    // wire secretkey_1_request;
    // wire secretkey_2_request;
    wire start_sifting;
    wire start_ER;
    wire sifted_key_addr_index;
    wire start_accumulation;
    wire start_PA;
    wire [31:0] secretkey_length;
    wire reconciled_key_addr_index;
     wire [4:0] post_processing_state;


    A_post_processing_control u_A_post_processing_control (
        .clk(clk), // Clock signal
        .rst_n(rst_n), // Reset signal

        // AXI manager request & ready signals
        .request_valid(request_valid),
        .new_round(new_round),

        // Qubit, EVrandombit, and PArandombit signals
        .qubit_ready(qubit_ready),
        .qubit_request(qubit_request),
        .EVrandombit_ready(EVrandombit_ready),
        .EVrandombit_request(EVrandombit_request),
        .PArandombit_ready(PArandombit_ready),
        .PArandombit_request(PArandombit_request),

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

        // Parameter accumulation signals
        .start_accumulation(start_accumulation),
        .accumulate_busy(accumulate_busy),

        // Secret key length calculation signals
        .keylength_valid(keylength_valid),
        .keylength_negative(keylength_negative),
        .keylength_small(keylength_small),
        .keylength_input_outrange(keylength_input_outrange),
        .keylength(keylength),

        // Post-authentication (PA) signals
        .start_PA(start_PA),
        .secretkey_length(secretkey_length),
        .reconciled_key_addr_index(reconciled_key_addr_index),
        .finish_PA(finish_PA),

        // Key readiness determination
        .siftedkey_addra(Asiftedkey_addra),
        .siftedkey_wea(Asiftedkey_wea),
        .reconciledkey_addra(Areconciledkey_addra),
        .reconciledkey_wea(Areconciledkey_wea),
        .secretkey_addrb(secretkey_addrb),
        .secretkey_web(secretkey_web),

        // FSM state
        .post_processing_state(post_processing_state)
    );

    //****************************** PP control ******************************






    //****************************** sifting ******************************

    wire [`FRAME_NVIS_WIDTH-1:0] nvis;
    wire [`FRAME_A_CHECKKEY_1_WIDTH-1:0] A_checkkey_1;
    wire [`FRAME_A_CHECKKEY_0_WIDTH-1:0] A_checkkey_0;
    wire [`FRAME_COMPARE_1_WIDTH-1:0] A_compare_1;
    wire [`FRAME_COMPARE_0_WIDTH-1:0] A_compare_0;
    wire A_visibility_valid;
    
    wire wait_sifting_TX;
     
    top_A_sifting u_Asifting (
        .clk(clk),
        .rst_n(rst_n),
        .start_A_sifting(start_sifting),

        .start_A_TX(start_TX),
        .wait_A_TX(wait_sifting_TX),

        .A_sifting_finish(finish_sifting),

        .reset_sift_parameter(reset_sift_parameter),

        .Zbasis_Xbasis_fifo_full(Zbasis_Xbasis_fifo_full_cdc),

        // visibility parameter
        .nvis(nvis),
        .A_checkkey_1(A_checkkey_1),
        .A_checkkey_0(A_checkkey_0),
        .A_compare_1(A_compare_1),
        .A_compare_0(A_compare_0),
        .A_visibility_valid(A_visibility_valid),


        .Qubit_doutb(Qubit_doutb),
        .Qubit_addrb_32(Qubit_addrb),
        .Qubit_clkb(Qubit_clkb),
        .Qubit_enb(Qubit_enb),
        .Qubit_rstb(Qubit_rstb),
        .Qubit_web(Qubit_web),

        .A_RX_Xbasis_detected_rd_clk(A_RX_Xbasis_detected_rd_clk),
        .A_RX_Xbasis_detected_rd_en(A_RX_Xbasis_detected_rd_en),
        .A_RX_Xbasis_detected_rd_dout(A_RX_Xbasis_detected_rd_dout),
        .A_RX_Xbasis_detected_empty(A_RX_Xbasis_detected_empty),
        .A_RX_Xbasis_detected_rd_valid(A_RX_Xbasis_detected_rd_valid),
        .A_RX_Xbasis_detected_full(A_RX_Xbasis_detected_full_cdc), // change to cdc control

        .A_RX_Zbasis_detected_rd_clk(A_RX_Zbasis_detected_rd_clk),
        .A_RX_Zbasis_detected_rd_en(A_RX_Zbasis_detected_rd_en),
        .A_RX_Zbasis_detected_rd_dout(A_RX_Zbasis_detected_rd_dout),
        .A_RX_Zbasis_detected_empty(A_RX_Zbasis_detected_empty),
        .A_RX_Zbasis_detected_rd_valid(A_RX_Zbasis_detected_rd_valid),
        .A_RX_Zbasis_detected_full(A_RX_Zbasis_detected_full_cdc),

        .A_TX_decoy_wr_clk(A_TX_decoy_wr_clk),
        .A_TX_decoy_wr_din(A_TX_decoy_wr_din),
        .A_TX_decoy_wr_en(A_TX_decoy_wr_en),
        .A_TX_decoy_full(A_TX_decoy_full),
        .A_TX_decoy_wr_ack(A_TX_decoy_wr_ack),
        .A_TX_decoy_empty(A_TX_decoy_empty_cdc),

        .Asiftedkey_dina(Asiftedkey_dina),
        .Asiftedkey_addra(Asiftedkey_addra),
        .Asiftedkey_clka(Asiftedkey_clka),
        .Asiftedkey_ena(Asiftedkey_ena),
        .Asiftedkey_wea(Asiftedkey_wea)
    );



    //****************************** sifting ******************************








    //****************************** error reconciliation ******************************

    wire [`FRAME_LEAKED_INFO_WIDTH-1:0] single_frame_leaked_info;
    wire [`FRAME_ERROR_COUNT_WIDTH-1:0] single_frame_error_count;
    wire single_frame_parameter_valid;
    wire single_frame_error_verification_fail; //error verification is fail

    wire EVrandombit_web_1;
    assign EVrandombit_web = {8{EVrandombit_web_1}};

    wire [13:0] EVrandombit_addrb_14;
    assign EVrandombit_addrb = {15'b0 , EVrandombit_addrb_14 , 3'b0};

    wire wait_ER_TX;

    top_A_ER A_ER_test (
        .clk(clk), // Connect to clock
        .rst_n(rst_n), // Connect to reset

        .start_A_ER(start_ER), // Start signal for all frame error reconciliation

        .start_TX(start_switch),
        .wait_TX(wait_ER_TX),

        .finish_A_ER(finish_ER), //finish all frame error reconciliation

        .sifted_key_addr_index(sifted_key_addr_index), //address index
        //0:addr0 ~ addr16383
        //1:addr16384 ~ addr32767

        .single_frame_leaked_info(single_frame_leaked_info), // Output for leaked info
        .single_frame_error_count(single_frame_error_count), // Output for error count
        .single_frame_parameter_valid(single_frame_parameter_valid), // Output for parameter validity
        .single_frame_error_verification_fail(single_frame_error_verification_fail), // Output for error verification status

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
        .A_A2B_empty(A_TX_er_empty_cdc),
        .A_A2B_wr_ack(A_TX_er_wr_ack),

        // EV random bit BRAM connections
        .EVrandombit_doutb(EVrandombit_doutb),
        .EVrandombit_addrb(EVrandombit_addrb_14),
        .EVrandombit_clkb(EVrandombit_clkb),
        .EVrandombit_enb(EVrandombit_enb),
        .EVrandombit_rstb(),
        .EVrandombit_web(EVrandombit_web_1),

        // Reconciled key BRAM connections
        .reconciledkey_addra(Areconciledkey_addra),
        .reconciledkey_clka(Areconciledkey_clka),
        .reconciledkey_dina(Areconciledkey_dina),
        .reconciledkey_ena(Areconciledkey_ena),
        .reconciledkey_rsta(),
        .reconciledkey_wea(Areconciledkey_wea)
    );

    //****************************** error reconciliation ******************************






    //****************************** privacy amplification ******************************
    // Input 
    // wire clk;
    // wire rst_n;
    // wire start_PA;
    wire [31:0] secretkey_length;
    // wire reconciled_key_addr_index;
    // wire [63:0] key_doutb;
    wire [63:0] PArandombit_doutb;
    wire A_TX_pa_full;
    wire A_TX_pa_wr_ack;
    wire A_TX_pa_empty;





    // Output wires and registers
    // wire A_pa_finish;
    wire fail_PA;

    // wire [13:0] PArandombit_addrb;
    // wire PArandombit_clkb;
    // wire PArandombit_enb;
    // wire PArandombit_rstb;
    // wire [7:0] PArandombit_web;


    wire [13:0] PArandombit_addrb_14;
    assign PArandombit_addrb = {15'b0 , PArandombit_addrb_14 , 3'b0};

    wire [14:0] Secretkey_addrb_15;
    assign Secretkey_addrb = {14'b0 , Secretkey_addrb_15 , 3'b0};

    // wire Secretkey_clkb;
    // wire [63:0] Secretkey_dinb;
    // wire Secretkey_enb;
    // wire Secretkey_rstb;


    wire A_TX_pa_wr_clk;
    reg [31:0] A_TX_pa_wr_din;
    reg A_TX_pa_wr_en;

    wire wait_PA_TX;

    top_A_pa u_top_A_pa (
        .clk(clk), // Clock signal
        .rst_n(rst_n), // Reset signal

        .start_A_pa(start_PA), // Input to start PA
        
        .start_TX(start_TX),
        .wait_TX(wait_PA_TX),
        
        .A_pa_finish(finish_PA), // Output indicating PA is done
        .A_pa_fail(fail_PA), // Output indicating PA failure due to secret key length

        .secretkey_length(`TEST_KEYLENGTH), // Input: Secret key length

        .reconciled_key_addr_index(reconciled_key_addr_index), // Input: Reconciled key address index

        // Reconciled key BRAM connections
        .key_doutb(Areconciledkey_doutb),
        .key_clkb(Areconciledkey_clkb),
        .key_enb(Areconciledkey_enb),
        .key_web(Areconciledkey_web),
        .key_rstb(),
        .key_index_and_addrb(Areconciledkey_addrb),

        // Random bit BRAM connections
        .PArandombit_doutb(PArandombit_doutb),
        .PArandombit_addrb(PArandombit_addrb_14),
        .PArandombit_clkb(PArandombit_clkb),
        .PArandombit_enb(PArandombit_enb),
        .PArandombit_rstb(),
        .PArandombit_web(PArandombit_web),

        // Secret key BRAM connections
        .Secretkey_addrb(Secretkey_addrb_15),
        .Secretkey_clkb(Secretkey_clkb),
        .Secretkey_dinb(Secretkey_dinb),
        .Secretkey_enb(Secretkey_enb),
        .Secretkey_rstb(),
        .Secretkey_web(Secretkey_web),

        // A_TX_pa FIFO connections
        .A_TX_pa_wr_clk(A_TX_pa_wr_clk),
        .A_TX_pa_wr_din(A_TX_pa_wr_din),
        .A_TX_pa_wr_en(A_TX_pa_wr_en),
        .A_TX_pa_full(A_TX_pa_full),
        .A_TX_pa_wr_ack(A_TX_pa_wr_ack),
        .A_TX_pa_empty(A_TX_pa_empty_cdc)
    );

    //****************************** privacy amplification ******************************







    //****************************** key length calculation ******************************

    wire finish_accumulation;


    wire keylength_busy;


    top_keylength_cal u_top_keylength_cal (
        .clk_125MHz(clk_out_125M), // Clock input for fifo write
        .clk_20MHz(clk_out_20M), // Clock input
        .rst_n(rst_n), // Reset (active low)

        .start_accumulation(start_accumulation), // Input to start accumulation
        .accumulate_busy(accumulate_busy), // Output indicating accumulation is busy
        .finish_accumulation(finish_accumulation), // Output indicating accumulation finish

        // Visibility parameter inputs
        .nvis(nvis),
        .A_checkkey_1(A_checkkey_1),
        .A_checkkey_0(A_checkkey_0),
        .A_compare_1(A_compare_1),
        .A_compare_0(A_compare_0),
        .A_visibility_valid(A_visibility_valid),

        // ER parameter inputs
        .single_frame_leaked_info(single_frame_leaked_info),
        .single_frame_error_count(single_frame_error_count),
        .single_frame_parameter_valid(single_frame_parameter_valid),
        .single_frame_error_verification_fail(single_frame_error_verification_fail),

        // Visibility parameter fifo connections
        .visibility_rd_clk(visibility_rd_clk),
        .visibility_rd_en(visibility_rd_en),
        .visibility_rd_dout(visibility_rd_dout),
        .visibility_rd_empty(visibility_empty),
        .visibility_rd_valid(visibility_rd_valid),

        .visibility_wr_clk(visibility_wr_clk),
        .visibility_wr_din(visibility_wr_din),
        .visibility_wr_en(visibility_wr_en),
        .visibility_wr_full(visibility_full),
        .visibility_wr_ack(visibility_wr_ack),

        // ER parameter fifo connections
        .er_parm_rd_clk(er_parm_rd_clk),
        .er_parm_rd_en(er_parm_rd_en),
        .er_parm_rd_dout(er_parm_rd_dout),
        .er_parm_rd_empty(er_parm_empty),
        .er_parm_rd_valid(er_parm_rd_valid),

        .er_parm_wr_clk(er_parm_wr_clk),
        .er_parm_wr_din(er_parm_wr_din),
        .er_parm_wr_en(er_parm_wr_en),
        .er_parm_wr_full(er_parm_full),
        .er_parm_wr_ack(er_parm_wr_ack),

        // Key length calculation outputs
        .out_length(keylength), // Output: Calculated secret key length
        .out_valid(keylength_valid), // Output: Length is valid
        .out_length_negative(keylength_negative), // Output: Secret key length < 0
        .out_length_small(keylength_small), // Output: Secret key length < 10000
        .input_outrange(keylength_input_outrange), // Output: Input parameter out of range
        .out_busy(keylength_busy) // Output: Calculation is not done
    );

    //****************************** key length calculation ******************************








    //****************************** A packet  ******************************

    wire [3:0] A_packet_state;


    A_packet u_A_packet (
        .clk(clkTX_msg), // Clock signal
        .rst_n(rst_n), // Reset signal

        .busy_Net2PP_TX(busy_Net2PP_TX), // Input indicating network to post-processing transmission is busy

        .busy_PP2Net_TX(busy_PP2Net_TX), // Output indicating post-processing to network transmission is busy
        .msg_stored(msg_stored), // Output indicating message is stored
        .sizeTX_msg(sizeTX_msg), // Output register for message size

        .A_packet_state(A_packet_state), // Output state of the A_packet FSM

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






    //****************************** A unpacket  ******************************

    wire reset_sift_parameter;

    (*mark_debug = "TRUE"*) wire Zbasis_Xbasis_fifo_full;
    wire [3:0] A_unpacket_state;


    A_unpacket u_A_unpacket (
        .clk(clkRX_msg), // Clock signal
        .rst_n(rst_n), // Reset signal

        .busy_Net2PP_RX(busy_Net2PP_RX), // Input indicating the network to post-processing reception is busy
        .msg_accessed(msg_accessed), // Input indicating message access
        .sizeRX_msg(sizeRX_msg), // Input for size of RX message

        .busy_PP2Net_RX(busy_PP2Net_RX), // Output indicating post-processing to network reception is busy

        .reset_sift_parameter(reset_sift_parameter_cdc), // Input to reset sift parameters
        .Zbasis_Xbasis_fifo_full(Zbasis_Xbasis_fifo_full), // Output indicating fifo full status

        .A_unpacket_state(A_unpacket_state), // Output state of the A_unpacket FSM

        // A_B2A Zbasis fifo connections
        .A_RX_Zbasis_detected_wr_clk(A_RX_Zbasis_detected_wr_clk),
//        .A_RX_Zbasis_detected_wr_din(A_RX_Zbasis_detected_wr_din),
//        .A_RX_Zbasis_detected_wr_en(A_RX_Zbasis_detected_wr_en),
        .A_RX_Zbasis_detected_wr_din_delay(A_RX_Zbasis_detected_wr_din),
        .A_RX_Zbasis_detected_wr_en_delay(A_RX_Zbasis_detected_wr_en),
        .A_RX_Zbasis_detected_full(A_RX_Zbasis_detected_full),
        .A_RX_Zbasis_detected_wr_ack(A_RX_Zbasis_detected_wr_ack),

        // A_B2A Xbasis fifo connections
        .A_RX_Xbasis_detected_wr_clk(A_RX_Xbasis_detected_wr_clk),
//        .A_RX_Xbasis_detected_wr_din(A_RX_Xbasis_detected_wr_din),
//        .A_RX_Xbasis_detected_wr_en(A_RX_Xbasis_detected_wr_en),
        .A_RX_Xbasis_detected_wr_din_delay(A_RX_Xbasis_detected_wr_din),
        .A_RX_Xbasis_detected_wr_en_delay(A_RX_Xbasis_detected_wr_en),
        .A_RX_Xbasis_detected_full(A_RX_Xbasis_detected_full),
        .A_RX_Xbasis_detected_wr_ack(A_RX_Xbasis_detected_wr_ack),

        // A_B2A er fifo connections
        .A_RX_er_wr_clk(A_RX_er_wr_clk),
//        .A_RX_er_wr_din(A_RX_er_wr_din),
//        .A_RX_er_wr_en(A_RX_er_wr_en),
        .A_RX_er_wr_din_delay(A_RX_er_wr_din),
        .A_RX_er_wr_en_delay(A_RX_er_wr_en),
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
 //*********************** cdc for Alice Sifting control signal **********************
    wire A_RX_Xbasis_detected_full_cdc;
    wire A_RX_Zbasis_detected_full_cdc;
    wire A_TX_decoy_empty_cdc;

    cdc_delay1 u_A_RX_Xbasis_detected_full_delay(
        .clk_src(clkRX_msg),
        .clk_des(clk),
        .reset(~rst_n),
        .pulse_src(A_RX_Xbasis_detected_full),
        .pulse_des(A_RX_Xbasis_detected_full_cdc)
    );

    cdc_delay1 u_A_RX_Zbasis_detected_full_delay(
        .clk_src(clkRX_msg),
        .clk_des(clk),
        .reset(~rst_n),
        .pulse_src(A_RX_Zbasis_detected_full),
        .pulse_des(A_RX_Zbasis_detected_full_cdc)
    );

    cdc_delay1 u_A_TX_decoy_empty_delay(
        .clk_src(clkTX_msg),
        .clk_des(clk),
        .reset(~rst_n),
        .pulse_src(A_TX_decoy_empty),
        .pulse_des(A_TX_decoy_empty_cdc)
    );
wire reset_sift_parameter_cdc;
(*mark_debug = "TRUE"*) wire Zbasis_Xbasis_fifo_full_cdc;
    clock_domain_crossing u_reset_sift_parameter_pulse(
        .clk_src(clk),
        .clk_des(clkRX_msg),
        .reset(~rst_n),
        .pulse_src(reset_sift_parameter),
        .pulse_des(reset_sift_parameter_cdc)
    );

    cdc_delay1 u_Zbasis_Xbasis_fifo_full_delay(
        .clk_src(clkRX_msg),
        .clk_des(clk),
        .reset(~rst_n),
        .pulse_src(Zbasis_Xbasis_fifo_full),
        .pulse_des(Zbasis_Xbasis_fifo_full_cdc)
    );

//*********************** cdc for Alice Sifting control signal **********************
//*********************** cdc for Alice ER control signal**************************
    wire A_TX_er_empty_cdc;
    cdc_delay1 u_A_TX_er_empty_cdc(
        .clk_src(clkTX_msg),
        .clk_des(clk),
        .reset(~rst_n),
        .pulse_src(A_TX_er_empty),
        .pulse_des(A_TX_er_empty_cdc)
    );
//*********************** cdc for Alice ER control signal**************************
//*********************** cdc for Alice PA control signal **************************
    wire A_TX_pa_empty_cdc;
    cdc_delay1 u_A_TX_pa_empty_cdc(
        .clk_src(clkTX_msg),
        .clk_des(clk),
        .reset(~rst_n),
        .pulse_src(A_TX_pa_empty),
        .pulse_des(A_TX_pa_empty_cdc)
    );
//*********************** cdc for Alice PA control signal **************************




















endmodule
