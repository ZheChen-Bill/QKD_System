



`define POST_STNTHESIS_SIM      0

// `include "./PP_parameter.v"

`timescale 1ps/1ps


module tb_AB_PP ();
    parameter CLK_PERIOD = 3333;

    reg clk;
    reg rst_n;
    reg start_switch;

    // ===== Clk fliping ===== //
	initial begin
		clk = 1;
		forever #(CLK_PERIOD/2) clk = ~clk;
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




    top_AB_PP test_AB_PP (
        .default_sysclk1_300_clk_n(default_sysclk1_300_clk_n),
        .default_sysclk1_300_clk_p(default_sysclk1_300_clk_p),
        .reset_high(reset_high),

        // A-side AXImanager BRAM PORT-A connections
        .A_AXImanager_PORTA_addr(A_AXImanager_PORTA_addr),
        .A_AXImanager_PORTA_clk(A_AXImanager_PORTA_clk),
        .A_AXImanager_PORTA_din(A_AXImanager_PORTA_din),
        .A_AXImanager_PORTA_dout(A_AXImanager_PORTA_dout),
        .A_AXImanager_PORTA_en(A_AXImanager_PORTA_en),
        .A_AXImanager_PORTA_rst(A_AXImanager_PORTA_rst),
        .A_AXImanager_PORTA_we(A_AXImanager_PORTA_we),

        // A-side EVrandombit BRAM PORT-A connections
        .EVrandombit_PORTA_addr(EVrandombit_PORTA_addr),
        .EVrandombit_PORTA_clk(EVrandombit_PORTA_clk),
        .EVrandombit_PORTA_din(EVrandombit_PORTA_din),
        .EVrandombit_PORTA_dout(EVrandombit_PORTA_dout),
        .EVrandombit_PORTA_en(EVrandombit_PORTA_en),
        .EVrandombit_PORTA_rst(EVrandombit_PORTA_rst),
        .EVrandombit_PORTA_we(EVrandombit_PORTA_we),

        // A-side PArandombit BRAM PORT-A connections
        .PArandombit_PORTA_addr(PArandombit_PORTA_addr),
        .PArandombit_PORTA_clk(PArandombit_PORTA_clk),
        .PArandombit_PORTA_din(PArandombit_PORTA_din),
        .PArandombit_PORTA_dout(PArandombit_PORTA_dout),
        .PArandombit_PORTA_en(PArandombit_PORTA_en),
        .PArandombit_PORTA_rst(PArandombit_PORTA_rst),
        .PArandombit_PORTA_we(PArandombit_PORTA_we),

        // A-side QC BRAM PORT-A connections
        .QC_PORTA_addr(QC_PORTA_addr),
        .QC_PORTA_clk(QC_PORTA_clk),
        .QC_PORTA_din(QC_PORTA_din),
        .QC_PORTA_dout(QC_PORTA_dout),
        .QC_PORTA_en(QC_PORTA_en),
        .QC_PORTA_rst(QC_PORTA_rst),
        .QC_PORTA_we(QC_PORTA_we),

        // A-side Qubit BRAM PORT-A connections
        .Qubit_PORTA_addr(Qubit_PORTA_addr),
        .Qubit_PORTA_clk(Qubit_PORTA_clk),
        .Qubit_PORTA_din(Qubit_PORTA_din),
        .Qubit_PORTA_dout(Qubit_PORTA_dout),
        .Qubit_PORTA_en(Qubit_PORTA_en),
        .Qubit_PORTA_rst(Qubit_PORTA_rst),
        .Qubit_PORTA_we(Qubit_PORTA_we),

        // A-side Secretkey BRAM PORT-A connections
        .A_Secretkey_PORTA_addr(A_Secretkey_PORTA_addr),
        .A_Secretkey_PORTA_clk(A_Secretkey_PORTA_clk),
        .A_Secretkey_PORTA_din(A_Secretkey_PORTA_din),
        .A_Secretkey_PORTA_dout(A_Secretkey_PORTA_dout),
        .A_Secretkey_PORTA_en(A_Secretkey_PORTA_en),
        .A_Secretkey_PORTA_rst(A_Secretkey_PORTA_rst),
        .A_Secretkey_PORTA_we(A_Secretkey_PORTA_we),

        // B-side AXImanager BRAM PORT-A connections
        .B_AXImanager_PORTA_addr(B_AXImanager_PORTA_addr),
        .B_AXImanager_PORTA_clk(B_AXImanager_PORTA_clk),
        .B_AXImanager_PORTA_din(B_AXImanager_PORTA_din),
        .B_AXImanager_PORTA_dout(B_AXImanager_PORTA_dout),
        .B_AXImanager_PORTA_en(B_AXImanager_PORTA_en),
        .B_AXImanager_PORTA_rst(B_AXImanager_PORTA_rst),
        .B_AXImanager_PORTA_we(B_AXImanager_PORTA_we),

        // B-side X-basis detected pos BRAM PORT-A connections
        .Xbasis_detected_pos_PORTA_addr(Xbasis_detected_pos_PORTA_addr),
        .Xbasis_detected_pos_PORTA_clk(Xbasis_detected_pos_PORTA_clk),
        .Xbasis_detected_pos_PORTA_din(Xbasis_detected_pos_PORTA_din),
        .Xbasis_detected_pos_PORTA_dout(Xbasis_detected_pos_PORTA_dout),
        .Xbasis_detected_pos_PORTA_en(Xbasis_detected_pos_PORTA_en),
        .Xbasis_detected_pos_PORTA_rst(Xbasis_detected_pos_PORTA_rst),
        .Xbasis_detected_pos_PORTA_we(Xbasis_detected_pos_PORTA_we),

        // B-side Z-basis detected pos BRAM PORT-A connections
        .Zbasis_detected_pos_PORTA_addr(Zbasis_detected_pos_PORTA_addr),
        .Zbasis_detected_pos_PORTA_clk(Zbasis_detected_pos_PORTA_clk),
        .Zbasis_detected_pos_PORTA_din(Zbasis_detected_pos_PORTA_din),
        .Zbasis_detected_pos_PORTA_dout(Zbasis_detected_pos_PORTA_dout),
        .Zbasis_detected_pos_PORTA_en(Zbasis_detected_pos_PORTA_en),
        .Zbasis_detected_pos_PORTA_rst(Zbasis_detected_pos_PORTA_rst),
        .Zbasis_detected_pos_PORTA_we(Zbasis_detected_pos_PORTA_we),

        // B-side Secretkey BRAM PORT-A connections
        .B_Secretkey_PORTA_addr(B_Secretkey_PORTA_addr),
        .B_Secretkey_PORTA_clk(B_Secretkey_PORTA_clk),
        .B_Secretkey_PORTA_din(B_Secretkey_PORTA_din),
        .B_Secretkey_PORTA_dout(B_Secretkey_PORTA_dout),
        .B_Secretkey_PORTA_en(B_Secretkey_PORTA_en),
        .B_Secretkey_PORTA_rst(B_Secretkey_PORTA_rst),
        .B_Secretkey_PORTA_we(B_Secretkey_PORTA_we)
    );
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
