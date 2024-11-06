







module top_kcu116 (


    input default_sysclk1_300_clk_n,        //SYSCLK_300_N
    input default_sysclk1_300_clk_p,        //SYSCLK_300_P
    input reset                            //system reset
);



    wire clk;
    assign clk = clk_out_125M;
    wire rst_n;
    assign rst_n = proc_rst_n;



//****************************** sifted_key_addr_index ******************************
    wire sifted_key_addr_index;
    assign sifted_key_addr_index = 1'b0;
//****************************** sifted_key_addr_index ******************************
    





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
//****************************** start switch from AXIBRAM ******************************
    reg start_switch;
    always @(posedge clk ) begin
        if (~proc_rst_n) begin
            start_switch <= 0;
        end
        else begin
            if (state==4'b1000) begin
                start_switch <= 1;
            end
            else begin
                start_switch <= 0;
            end   
        end
    end
//****************************** start switch from AXIBRAM ******************************


//****************************** read from AXIBRAM ******************************
  /* AXImanager BRAM
  // width = 64 , depth = 1024
  // addr0 for state message
  wire [31:0]AXImanager_addrb;
  wire AXImanager_clkb;
  wire [63:0]AXImanager_dinb;
  wire [63:0]AXImanager_doutb;
  wire AXImanager_enb;
  wire AXImanager_rstb;
  wire [7:0]AXImanager_web;
  */
  assign AXImanager_web = (B_finish & A_finish)? 8'b1111_1111:8'b0;
  //assign AXImanager_rstb = ~proc_rst_n;
  assign AXImanager_enb = 1'b1;
  assign AXImanager_clkb = clk;
  assign AXImanager_dinb = 64'd8888;
  assign AXImanager_addrb = 32'h00000000;

  wire [3:0] state;
  assign state = AXImanager_doutb[3:0];

//****************************** read from AXIBRAM ******************************





//****************************** ER finish ******************************

    reg A_finish, B_finish;
    always @(posedge clk ) begin
        if (~rst_n) begin
            A_finish <= 1'b0;
        end
        else if (finish_A_ER) begin
            A_finish <= 1'b1;
        end
        else begin
            A_finish <= A_finish;
        end
    end

    always @(posedge clk ) begin
        if (~rst_n) begin
            B_finish <= 1'b0;
        end
        else if (finish_B_ER) begin
            B_finish <= 1'b1;
        end
        else begin
            B_finish <= B_finish;
        end
    end
//****************************** ER finish ******************************








//****************************** AXImanager ******************************
    wire clk_out_125M;
    wire default_sysclk1_300_clk_n;
    wire default_sysclk1_300_clk_p;
    wire [0:0]proc_rst_n;
    wire reset; 

    wire [31:0]AXImanager_addrb;
    wire AXImanager_clkb;
    wire [63:0]AXImanager_dinb;
    wire [63:0]AXImanager_doutb;
    wire AXImanager_enb;
    wire AXImanager_rstb;
    wire [7:0]AXImanager_web;

    wire [31:0]Areconciledkey_addrb;
    wire Areconciledkey_clkb;
    wire [63:0]Areconciledkey_dinb;
    wire [63:0]Areconciledkey_doutb;
    wire Areconciledkey_enb;
    wire Areconciledkey_rstb;
    wire [7:0]Areconciledkey_web;

    wire [31:0]Breconciledkey_addrb;
    wire Breconciledkey_clkb;
    wire [63:0]Breconciledkey_dinb;
    wire [63:0]Breconciledkey_doutb;
    wire Breconciledkey_enb;
    wire Breconciledkey_rstb;
    wire [7:0]Breconciledkey_web;


    reg [31:0]errorcount_addrb;
    wire errorcount_clkb;
    reg [31:0]errorcount_dinb;
    wire [31:0]errorcount_doutb;
    wire errorcount_enb;
    wire errorcount_rstb;
    reg [3:0]errorcount_web;

    reg [31:0]leakedinfo_addrb;
    wire leakedinfo_clkb;
    reg [31:0]leakedinfo_dinb;
    wire [31:0]leakedinfo_doutb;
    wire leakedinfo_enb;
    wire leakedinfo_rstb;
    reg [3:0]leakedinfo_web;


    BD_ABkey_AXImanager AXImanager_ABkey
       (.AXImanager_addrb(AXImanager_addrb),
        .AXImanager_clkb(AXImanager_clkb),
        .AXImanager_dinb(AXImanager_dinb),
        .AXImanager_doutb(AXImanager_doutb),
        .AXImanager_enb(AXImanager_enb),
        .AXImanager_rstb(AXImanager_rstb),
        .AXImanager_web(AXImanager_web),

        .Areconciledkey_addrb(Areconciledkey_addrb),
        .Areconciledkey_clkb(Areconciledkey_clkb),
        .Areconciledkey_dinb(Areconciledkey_dinb),
        .Areconciledkey_doutb(Areconciledkey_doutb),
        .Areconciledkey_enb(Areconciledkey_enb),
        .Areconciledkey_rstb(Areconciledkey_rstb),
        .Areconciledkey_web(Areconciledkey_web),

        .Breconciledkey_addrb(Breconciledkey_addrb),
        .Breconciledkey_clkb(Breconciledkey_clkb),
        .Breconciledkey_dinb(Breconciledkey_dinb),
        .Breconciledkey_doutb(Breconciledkey_doutb),
        .Breconciledkey_enb(Breconciledkey_enb),
        .Breconciledkey_rstb(Breconciledkey_rstb),
        .Breconciledkey_web(Breconciledkey_web),

        .errorcount_addrb(errorcount_addrb),
        .errorcount_clkb(errorcount_clkb),
        .errorcount_dinb(errorcount_dinb),
        .errorcount_doutb(errorcount_doutb),
        .errorcount_enb(errorcount_enb),
        .errorcount_rstb(errorcount_rstb),
        .errorcount_web(errorcount_web),

        .leakedinfo_addrb(leakedinfo_addrb),
        .leakedinfo_clkb(leakedinfo_clkb),
        .leakedinfo_dinb(leakedinfo_dinb),
        .leakedinfo_doutb(leakedinfo_doutb),
        .leakedinfo_enb(leakedinfo_enb),
        .leakedinfo_rstb(leakedinfo_rstb),
        .leakedinfo_web(leakedinfo_web),

        .clk_out_125M(clk_out_125M),
        .default_sysclk1_300_clk_n(default_sysclk1_300_clk_n),
        .default_sysclk1_300_clk_p(default_sysclk1_300_clk_p),
        .proc_rst_n(proc_rst_n),
        .reset(reset));
//****************************** AXImanager ******************************












//****************************** leaked info ******************************
    assign leakedinfo_clkb = clk;
    assign leakedinfo_enb = 1'b1;

    always @(posedge clk) begin
        if (~rst_n) begin
            leakedinfo_addrb <= 32'b0;
            leakedinfo_dinb <= 32'b0;
            leakedinfo_web <= 4'b0;
        end
        else if (single_frame_parameter_valid) begin
            leakedinfo_addrb <= leakedinfo_addrb + 4'b1000;
            leakedinfo_dinb <= single_frame_leaked_info;
            leakedinfo_web <= 4'b1111;
        end
        else begin
            leakedinfo_addrb <= leakedinfo_addrb;
            leakedinfo_dinb <= 32'b0;
            leakedinfo_web <= 4'b0;
        end
    end
//****************************** leaked info ******************************
//****************************** error count ******************************
    assign errorcount_clkb = clk;
    assign errorcount_enb = 1'b1;

    always @(posedge clk) begin
        if (~rst_n) begin
            errorcount_addrb <= 32'b0;
            errorcount_dinb <= 32'b0;
            errorcount_web <= 4'b0;
        end
        else if (single_frame_parameter_valid) begin
            errorcount_addrb <= errorcount_addrb + 4'b1000;
            errorcount_dinb <= single_frame_error_count;
            errorcount_web <= 4'b1111;
        end
        else begin
            errorcount_addrb <= errorcount_addrb;
            errorcount_dinb <= 32'b0;
            errorcount_web <= 4'b0;
        end
    end
//****************************** error count ******************************









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
        .A_A2B_empty(A_A2B_empty),
        .A_A2B_wr_ack(A_A2B_wr_ack),

        // EV random bit BRAM connections
        .EVrandombit_doutb(rb_douta),
        .EVrandombit_addrb(rb_addra),
        .EVrandombit_clkb(rb_clka),
        .EVrandombit_enb(rb_ena),
        .EVrandombit_rstb(rb_rsta),
        .EVrandombit_web(rb_wea),

        // Reconciled key BRAM connections
        .reconciledkey_addra(Areconciledkey_addrb),
        .reconciledkey_clka(Areconciledkey_clkb),
        .reconciledkey_dina(Areconciledkey_dinb),
        .reconciledkey_ena(Areconciledkey_enb),
        .reconciledkey_rsta(reconciledkey_rstb),
        .reconciledkey_wea(Areconciledkey_web)
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
        .B_A2B_rd_clk(B_A2B_rd_clk),
        .B_A2B_rd_en(B_A2B_rd_en),
        .B_A2B_rd_dout(B_A2B_rd_dout),
        .B_A2B_empty(B_A2B_empty),
        .B_A2B_rd_valid(B_A2B_rd_valid),

        // EV random bit BRAM connections
        .EVrandombit_doutb(B_RX_EVrandombit_doutb),
        .EVrandombit_addrb(B_RX_EVrandombit_addrb),
        .EVrandombit_clkb(B_RX_EVrandombit_clkb),
        .EVrandombit_enb(B_RX_EVrandombit_enb),
        .EVrandombit_rstb(),
        .EVrandombit_web(B_RX_EVrandombit_web),


        // B2A ER FIFO connections
        .B_B2A_wr_clk(B_B2A_wr_clk),
        .B_B2A_wr_din(B_B2A_wr_din),
        .B_B2A_wr_en(B_B2A_wr_en),
        .B_B2A_full(B_B2A_full),
        .B_B2A_wr_ack(B_B2A_wr_ack),

        // Reconciled key BRAM connections
        .reconciledkey_addra(Breconciledkey_addrb),
        .reconciledkey_clka(Breconciledkey_clkb),
        .reconciledkey_dina(Breconciledkey_dinb),
        .reconciledkey_ena(Breconciledkey_enb),
        .reconciledkey_rsta(reconciledkey_rstb),
        .reconciledkey_wea(Breconciledkey_web)
    );

//****************************** B ER ******************************







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























//****************************** A2B test instantiation ******************************

    wire EVrandombit_full;
    wire reset_er_parameter;

    wire [3:0] A2B_state;

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
//****************************** A2B test instantiation ******************************
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


















endmodule