







module top_keylength_cal (
    input clk_125MHz,   						//clock input for fifo write

    input clk_20MHz,                    // clock input
    input rst_n, 						//rst (active low)

    input start_accumulation,
    output accumulate_busy,
    output finish_accumulation,

    // visibility parameter
    input [`FRAME_NVIS_WIDTH-1:0] nvis,                  //nvis
    input [`FRAME_A_CHECKKEY_1_WIDTH-1:0] A_checkkey_1,  //A_checkkey_1
    input [`FRAME_A_CHECKKEY_0_WIDTH-1:0] A_checkkey_0,  //A_checkkey_0
    input [`FRAME_COMPARE_1_WIDTH-1:0] A_compare_1,      //A_compare_1
    input [`FRAME_COMPARE_0_WIDTH-1:0] A_compare_0,      //A_compare_0
    input A_visibility_valid,                      //visibility parameter is valid


    // ER parameter
    input wire [`FRAME_LEAKED_INFO_WIDTH-1:0] single_frame_leaked_info,
    input wire [`FRAME_ERROR_COUNT_WIDTH-1:0] single_frame_error_count,
    input wire single_frame_parameter_valid,
    input wire single_frame_error_verification_fail,       //error verification is fail


    // visibility parameter fifo
    output visibility_rd_clk,
    output visibility_rd_en,
    input [119 : 0] visibility_rd_dout,
    input visibility_rd_empty,
    input visibility_rd_valid,

    output visibility_wr_clk,
    output [119 : 0] visibility_wr_din,
    output visibility_wr_en,
    wire visibility_wr_full,
    wire visibility_wr_ack,

    // error reconciliation parameter fifo
    output er_parm_rd_clk,
    output er_parm_rd_en,
    input [31 : 0] er_parm_rd_dout,
    input er_parm_rd_empty,
    input er_parm_rd_valid,

    output er_parm_wr_clk,
    output [31 : 0] er_parm_wr_din,
    output er_parm_wr_en,
    input er_parm_wr_full,
    input er_parm_wr_ack,




    output wire [`SECRETKEY_LENGTH_WIDTH-1:0] out_length,  //secret key length
    output wire out_valid,        //length is valid
    output wire out_length_negative, //secret key length < 0
    output wire out_length_small,    //secret key length < 10000
    output wire input_outrange,           //input parameter out of range
    output wire out_busy             //calculation is NOT DONE

);
    









//****************************** input accumulation  ******************************


    // Input wires
    // wire clk_125MHz;
    // wire clk_20MHz;
    // wire rst_n;
    // wire start_accumulation;

    // wire [`FRAME_NVIS_WIDTH-1:0] nvis;
    // wire [`FRAME_A_CHECKKEY_1_WIDTH-1:0] A_checkkey_1;
    // wire [`FRAME_A_CHECKKEY_0_WIDTH-1:0] A_checkkey_0;
    // wire [`FRAME_COMPARE_1_WIDTH-1:0] A_compare_1;
    // wire [`FRAME_COMPARE_0_WIDTH-1:0] A_compare_0;
    // wire A_visibility_valid;

    // wire [`FRAME_LEAKED_INFO_WIDTH-1:0] single_frame_leaked_info;
    // wire [`FRAME_ERROR_COUNT_WIDTH-1:0] single_frame_error_count;
    // wire single_frame_parameter_valid;
    // wire single_frame_error_verification_fail;

    // wire [119:0] visibility_rd_dout;
    // wire visibility_rd_empty;
    // wire visibility_rd_valid;
    // wire [31:0] er_parm_rd_dout;
    // wire er_parm_rd_empty;
    // wire er_parm_rd_valid;
    wire cal_busy;

    // Output wires and registers
    // wire accumulate_busy;
    wire finish_accumulation;

    // wire visibility_rd_clk;
    // wire visibility_rd_en;
    // wire visibility_wr_clk;
    // wire [119:0] visibility_wr_din;
    // wire visibility_wr_en;
    // wire visibility_wr_full;
    // wire visibility_wr_ack;
    // wire er_parm_rd_clk;
    // wire er_parm_rd_en;
    // wire er_parm_wr_clk;
    // wire [31:0] er_parm_wr_din;
    // wire er_parm_wr_en;
    // wire er_parm_wr_full;
    // wire er_parm_wr_ack;
    

    wire [`QBER_WIDTH-1:0] qber_ff;
    wire [`NCOR_WIDTH-1:0] ncor_ff;
    wire [`NVIS_WIDTH-1:0] nvis_ff;
    wire [`VOBS_WIDTH-1:0] vobs_ff;
    wire parameter_valid;



    input_accumulation u_input_accumulation (
        .clk_125MHz(clk_125MHz),                         // Clock input for fifo write
        .clk_20MHz(clk_20MHz),                           // Clock input
        .rst_n(rst_n),                                   // Reset (active low)

        .start_accumulation(start_accumulation),         // Input to start accumulation
        .accumulate_busy(accumulate_busy),               // Output indicating accumulation is busy
        .finish_accumulation(finish_accumulation),       // Output indicating accumulation finish

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
        .visibility_rd_empty(visibility_rd_empty),
        .visibility_rd_valid(visibility_rd_valid),

        .visibility_wr_clk(visibility_wr_clk),
        .visibility_wr_din(visibility_wr_din),
        .visibility_wr_en(visibility_wr_en),
        .visibility_wr_full(visibility_wr_full),
        .visibility_wr_ack(visibility_wr_ack),

        // ER parameter fifo connections
        .er_parm_rd_clk(er_parm_rd_clk),
        .er_parm_rd_en(er_parm_rd_en),
        .er_parm_rd_dout(er_parm_rd_dout),
        .er_parm_rd_empty(er_parm_rd_empty),
        .er_parm_rd_valid(er_parm_rd_valid),

        .er_parm_wr_clk(er_parm_wr_clk),
        .er_parm_wr_din(er_parm_wr_din),
        .er_parm_wr_en(er_parm_wr_en),
        .er_parm_wr_full(er_parm_wr_full),
        .er_parm_wr_ack(er_parm_wr_ack),

        // Key length calculation inputs
        .qber_ff(qber_ff),
        .ncor_ff(ncor_ff),
        .nvis_ff(nvis_ff),
        .vobs_ff(vobs_ff),
        .parameter_valid(parameter_valid),

        // Key length calculation busy signal
        .cal_busy(cal_busy)
    );

//****************************** input accumulation  ******************************








//****************************** key length calculation ******************************

    // Input wires
    // wire clk_20MHz;
    // wire rst_n;
    // wire [`QBER_WIDTH-1:0] qber_ff;
    // wire [`NCOR_WIDTH-1:0] ncor_ff;
    // wire [`NVIS_WIDTH-1:0] nvis_ff;
    // wire [`VOBS_WIDTH-1:0] vobs_ff;
    // wire in_valid;

    // Output wires and registers
    // reg [`SECRETKEY_LENGTH_WIDTH-1:0] out_length; // Register as it holds the calculated value across clock cycles
    // wire out_valid;
    // wire out_length_negative;
    // wire out_length_small;
    // wire input_outrange;
    // wire out_busy;

    keylength_cal u_keylength_cal (
        .clk_20MHz(clk_20MHz),                     // Clock input
        .rst_n(rst_n),                             // Reset (active low)

        .qber_ff(qber_ff),                         // Input: Quantum Bit Error Rate
        .ncor_ff(ncor_ff),                         // Input: Leaked info from cascade error correction
        .nvis_ff(nvis_ff),                         // Input: Numbers of detected photons used to determine visibility
        .vobs_ff(vobs_ff),                         // Input: Measured visibility from sifting
        .in_valid(parameter_valid),                       // Input: Validity of input data

        .out_length(out_length),                   // Output: Calculated secret key length
        .out_valid(out_valid),                     // Output: Length is valid
        .out_length_negative(out_length_negative), // Output: Secret key length < 0
        .out_length_small(out_length_small),       // Output: Secret key length < 10000
        .input_outrange(input_outrange),           // Output: Input parameter out of range
        .out_busy(cal_busy)                        // Output: Calculation is not done
    );

//****************************** key length calculation ******************************


endmodule











































































module input_accumulation (
    input clk_125MHz,   						//clock input for fifo write

    input clk_20MHz,                    // clock input
    input rst_n, 						//rst (active low)

    input start_accumulation,
    output accumulate_busy,
    output finish_accumulation,

    // visibility parameter
    input [`FRAME_NVIS_WIDTH-1:0] nvis,                  //nvis
    input [`FRAME_A_CHECKKEY_1_WIDTH-1:0] A_checkkey_1,  //A_checkkey_1
    input [`FRAME_A_CHECKKEY_0_WIDTH-1:0] A_checkkey_0,  //A_checkkey_0
    input [`FRAME_COMPARE_1_WIDTH-1:0] A_compare_1,      //A_compare_1
    input [`FRAME_COMPARE_0_WIDTH-1:0] A_compare_0,      //A_compare_0
    input A_visibility_valid,                      //visibility parameter is valid


    // ER parameter
    input wire [`FRAME_LEAKED_INFO_WIDTH-1:0] single_frame_leaked_info,
    input wire [`FRAME_ERROR_COUNT_WIDTH-1:0] single_frame_error_count,
    input wire single_frame_parameter_valid,
    input wire single_frame_error_verification_fail,       //error verification is fail


    // visibility parameter fifo
    output visibility_rd_clk,
    output visibility_rd_en,
    input [119 : 0] visibility_rd_dout,
    input visibility_rd_empty,
    input visibility_rd_valid,

    output visibility_wr_clk,
    output [119 : 0] visibility_wr_din,
    output visibility_wr_en,
    wire visibility_wr_full,
    wire visibility_wr_ack,

    // error reconciliation parameter fifo
    output er_parm_rd_clk,
    output er_parm_rd_en,
    input [31 : 0] er_parm_rd_dout,
    input er_parm_rd_empty,
    input er_parm_rd_valid,

    output er_parm_wr_clk,
    output [31 : 0] er_parm_wr_din,
    output er_parm_wr_en,
    input er_parm_wr_full,
    input er_parm_wr_ack,



    // key length cal input
    output reg [`QBER_WIDTH-1:0] qber_ff,    //qber
    output reg [`NCOR_WIDTH-1:0] ncor_ff,    //leaked info from cascade error correction
    output reg [`NVIS_WIDTH-1:0] nvis_ff,    //numbers of detected photons used to determine visibility
    output reg [`VOBS_WIDTH-1:0] vobs_ff,    //measured visibility from sifting
    output wire parameter_valid,                    //input is valid
    // key length cal busy
    input wire cal_busy
);



//****************************** clock setup ******************************
    wire clk;
    assign clk = clk_20MHz;
//****************************** clock setup ******************************
//****************************** FIFO setup ******************************
    // visibility parameter fifo
    assign visibility_rd_clk = clk_125MHz;
    assign visibility_wr_clk = clk_125MHz;

    // error reconciliation parameter fifo
    assign er_parm_rd_clk = clk_125MHz;
    assign er_parm_wr_clk = clk_125MHz;
//****************************** FIFO setup ******************************






//****************************** write visibility parameter to fifo ******************************
    assign visibility_wr_din = {2'b0 , nvis,
                                2'b0 , A_checkkey_1,
                                2'b0 , A_checkkey_0,
                                2'b0 , A_compare_1,
                                2'b0 , A_compare_0};

    assign visibility_wr_en = A_visibility_valid;
//****************************** write visibility parameter to fifo ******************************



//****************************** write er parameter to fifo ******************************
    assign er_parm_wr_din[31]       = single_frame_error_verification_fail;
    assign er_parm_wr_din[30]       = single_frame_parameter_valid;
    assign er_parm_wr_din[29:15]    = (single_frame_error_verification_fail)? 15'b0:{2'b0 , single_frame_leaked_info};
    assign er_parm_wr_din[14:0]     = (single_frame_error_verification_fail)? 15'b0:{2'b0 , single_frame_error_count};

    assign er_parm_wr_en = single_frame_parameter_valid;
//****************************** write er parameter to fifo ******************************






//***************************************** FSM *****************************************
    // Input 
    // wire clk;
    // wire rst_n;
    // wire start_accumulation;
    reg frame_fail;
    wire last_round;
    // wire cal_busy;

    // Output 
    wire read_input_parm_fifo_en;
    wire accumulate_en;
    wire fraction_cal_en;
    // wire parameter_valid;
    wire reset_accumulation_parameter;
    // wire finish_accumulation;
    wire vobs_multiplication_en;
    wire [3:0] accumulation_state;

    accumulation_fsm u_accumulation_fsm (
        .clk(clk),                            // Clock signal
        .rst_n(rst_n),                        // Reset signal

        .start_accumulation(start_accumulation), // Input signal to start accumulation
        .frame_fail(frame_fail),              // Input signal indicating frame failure
        .last_round(last_round),              // Input signal indicating the last round
        .cal_busy(cal_busy),                  // Input signal indicating calculation is busy

        .accumulate_busy(accumulate_busy),
        .read_input_parm_fifo_en(read_input_parm_fifo_en), // Output to enable reading input parameter FIFO
        .accumulate_en(accumulate_en),        // Output to enable accumulation
        .fraction_cal_en(fraction_cal_en),
        .parameter_valid(parameter_valid),    // Output indicating parameter validity
        .reset_accumulation_parameter(reset_accumulation_parameter), // Output to reset accumulation parameters
        .finish_accumulation(finish_accumulation), // Output indicating accumulation finish
        .vobs_multiplication_en(vobs_multiplication_en),
        .accumulation_state(accumulation_state) // Output register for accumulation state
    );
//***************************************** FSM *****************************************



//****************************** read param fifo ******************************
    assign er_parm_rd_en = read_input_parm_fifo_en;
    assign visibility_rd_en = read_input_parm_fifo_en;

    reg [`FRAME_LEAKED_INFO_WIDTH-1:0] accu_leaked_info;
    reg [`FRAME_ERROR_COUNT_WIDTH-1:0] accu_error_count;
    reg [`FRAME_NVIS_WIDTH-1:0] accu_nvis;                  //nvis
    reg [`FRAME_A_CHECKKEY_1_WIDTH-1:0] accu_A_checkkey_1;  //A_checkkey_1
    reg [`FRAME_A_CHECKKEY_0_WIDTH-1:0] accu_A_checkkey_0;  //A_checkkey_0
    reg [`FRAME_COMPARE_1_WIDTH-1:0] accu_A_compare_1;      //A_compare_1
    reg [`FRAME_COMPARE_0_WIDTH-1:0] accu_A_compare_0;      //A_compare_0

    always @(posedge clk ) begin
        if (~rst_n) begin
            accu_nvis <= 0;
            accu_A_checkkey_1 <= 0;
            accu_A_checkkey_0 <= 0;
            accu_A_compare_1 <= 0;
            accu_A_compare_0 <= 0;
        end
        else if (reset_accumulation_parameter) begin
            accu_nvis <= 0;
            accu_A_checkkey_1 <= 0;
            accu_A_checkkey_0 <= 0;
            accu_A_compare_1 <= 0;
            accu_A_compare_0 <= 0;
        end
        else if (read_input_parm_fifo_en) begin
            accu_nvis <= visibility_rd_dout[117:96];
            accu_A_checkkey_1 <= visibility_rd_dout[93:72];
            accu_A_checkkey_0 <= visibility_rd_dout[69:48];
            accu_A_compare_1 <= visibility_rd_dout[45:24];
            accu_A_compare_0 <= visibility_rd_dout[21:0];
        end
        else begin
            accu_nvis <= accu_nvis;
            accu_A_checkkey_1 <= accu_A_checkkey_1;
            accu_A_checkkey_0 <= accu_A_checkkey_0;
            accu_A_compare_1 <= accu_A_compare_1;
            accu_A_compare_0 <= accu_A_compare_0;
        end
    end

    always @(posedge clk ) begin
        if (~rst_n) begin
            accu_leaked_info <= 0;
            accu_error_count <= 0;
            frame_fail <= 0;
        end
        else if (reset_accumulation_parameter) begin
            accu_leaked_info <= 0;
            accu_error_count <= 0;
            frame_fail <= 0;
        end
        else if (read_input_parm_fifo_en) begin
            accu_leaked_info <= er_parm_rd_dout[27:15];
            accu_error_count <= er_parm_rd_dout[12:0];
            frame_fail <= er_parm_rd_dout[31];
        end
        else begin
            accu_leaked_info <= accu_leaked_info;
            accu_error_count <= accu_error_count;
            frame_fail <= frame_fail;
        end
    end
//****************************** read param fifo ******************************




//****************************** accumulation ******************************


    reg [31:0] total_leaked_info;
    reg [31:0] total_error_count;

    reg [31:0] total_nvis;                  //nvis
    reg [31:0] total_A_checkkey_1;  //A_checkkey_1
    reg [31:0] total_A_checkkey_0;  //A_checkkey_0
    reg [31:0] total_A_compare_1;      //A_compare_1
    reg [31:0] total_A_compare_0;      //A_compare_0

    always @(posedge clk ) begin
        if (~rst_n) begin
            total_leaked_info <= 0;
            total_error_count <= 0;
            total_nvis <= 0;
            total_A_checkkey_1 <= 0;
            total_A_checkkey_0 <= 0;
            total_A_compare_1 <= 0;
            total_A_compare_0 <= 0;
        end
        else if (reset_accumulation_parameter) begin
            total_leaked_info <= 0;
            total_error_count <= 0;
            total_nvis <= 0;
            total_A_checkkey_1 <= 0;
            total_A_checkkey_0 <= 0;
            total_A_compare_1 <= 0;
            total_A_compare_0 <= 0;
        end
        else if (accumulate_en) begin
            total_leaked_info <= total_leaked_info + accu_leaked_info;
            total_error_count <= total_error_count + accu_error_count;
            total_nvis <= total_nvis + accu_nvis;
            total_A_checkkey_1 <= total_A_checkkey_1 + accu_A_checkkey_1;
            total_A_checkkey_0 <= total_A_checkkey_0 + accu_A_checkkey_0;
            total_A_compare_1 <= total_A_compare_1 + accu_A_compare_1;
            total_A_compare_0 <= total_A_compare_0 + accu_A_compare_0;
        end
        else begin
            total_leaked_info <= total_leaked_info;
            total_error_count <= total_error_count;
            total_nvis <= total_nvis;
            total_A_checkkey_1 <= total_A_checkkey_1;
            total_A_checkkey_0 <= total_A_checkkey_0;
            total_A_compare_1 <= total_A_compare_1;
            total_A_compare_0 <= total_A_compare_0;
        end
    end


    reg [31:0] accumulation_cnt;
    always @(posedge clk ) begin
        if (~rst_n) begin
            accumulation_cnt <= 0;
        end
        else if (reset_accumulation_parameter) begin
            accumulation_cnt <= 0;
        end
        else if (accumulate_en) begin
            accumulation_cnt <= accumulation_cnt + 1;
        end
        else begin
            accumulation_cnt <= accumulation_cnt;
        end
    end

    assign last_round = (accumulation_cnt==127)? 1'b1:1'b0;

//****************************** accumulation ******************************



//****************************** fraction cal ******************************
    always @(posedge clk ) begin
        if (~rst_n) begin
            qber_ff <= 0;
        end
        else if (reset_accumulation_parameter) begin
            qber_ff <= 0;
        end
        else if (fraction_cal_en) begin
            qber_ff <= total_error_count[`QBER_WIDTH-1:0];
        end
        else begin
            qber_ff <= qber_ff;
        end
    end

    always @(posedge clk ) begin
        if (~rst_n) begin
            ncor_ff <= 0;
        end
        else if (reset_accumulation_parameter) begin
            ncor_ff <= 0;
        end
        else if (fraction_cal_en ) begin
            ncor_ff <= total_leaked_info[`NCOR_WIDTH-1:0];
        end
        else begin
            ncor_ff <= ncor_ff;
        end
    end

    always @(posedge clk ) begin
        if (~rst_n) begin
            nvis_ff <= 0;
        end
        else if (reset_accumulation_parameter) begin
            nvis_ff <= 0;
        end
        else if (fraction_cal_en) begin
            nvis_ff <= total_nvis[`NVIS_WIDTH-1:0];
        end
        else begin
            nvis_ff <= nvis_ff;
        end
    end

    reg [43:0] vobs_numerator;
    reg [43:0] vobs_denominator;

    always @(posedge clk ) begin
        if (~rst_n) begin
            vobs_numerator <= 0;
            vobs_denominator <= 0;
        end
        else if (reset_accumulation_parameter) begin
            vobs_numerator <= 0;
            vobs_denominator <= 0;
        end
        else if (vobs_multiplication_en) begin
            vobs_numerator <= total_A_compare_0 * total_A_checkkey_1;
            vobs_denominator <= (total_A_compare_1 * total_A_checkkey_0)<<1;
        end
        else begin
            vobs_numerator <= vobs_numerator;
            vobs_denominator <= vobs_denominator;
        end
    end

    wire [63:0] vobs_fraction;
    assign vobs_fraction = {vobs_numerator , 20'b0} / vobs_denominator;

    always @(posedge clk ) begin
        if (~rst_n) begin
            vobs_ff <= 0;
        end
        else if (reset_accumulation_parameter) begin
            vobs_ff <= 0;
        end
        else if (fraction_cal_en) begin
            vobs_ff <= ~vobs_fraction[19:0];
        end
        else begin
            vobs_ff <= vobs_ff;
        end
    end







//****************************** fraction cal ******************************


endmodule






module accumulation_fsm (
    input clk,
    input rst_n,

    input start_accumulation,
    input frame_fail,
    input last_round,
    input cal_busy,

    output accumulate_busy,
    output reg read_input_parm_fifo_en,
    output reg accumulate_en,
    output reg fraction_cal_en,
    output reg parameter_valid,
    output reg reset_accumulation_parameter,
    output reg finish_accumulation,
    output wire vobs_multiplication_en,
    output reg [3:0] accumulation_state
);


    localparam IDLE                     = 4'd0;
    localparam ACCUMULATION_START       = 4'd1;
    localparam READ_PARM_FIFO           = 4'd2;
    localparam DETERMINE_FAIL           = 4'd3;
    localparam FRAME_ACCUMULATION       = 4'd4;
    localparam FRAME_FAIL               = 4'd5;
    localparam VOBS_MULTIPLICATION      = 4'd11;
    localparam FRACTION_CAL             = 4'd6;
    localparam ACCUMULATION_VALID       = 4'd7;
    localparam WAIT_KEYLENGTH_CAL_BUSY  = 4'd8;
    localparam RESET_ACCUMULATION       = 4'd9;
    localparam ACCUMULATION_END         = 4'd10;


    assign accumulate_busy = (accumulation_state==IDLE)? 1'b0:1'b1;
    assign vobs_multiplication_en = (accumulation_state==VOBS_MULTIPLICATION)? 1'b1:1'b0;

    reg [3:0] next_accumulation_state;
    always @(posedge clk ) begin
        if(~rst_n)
            accumulation_state <= IDLE;
        else
            accumulation_state <= next_accumulation_state;
    end

    always @(*) begin
        case (accumulation_state)
            IDLE: begin
                if (start_accumulation) begin
                    next_accumulation_state = ACCUMULATION_START;
                    read_input_parm_fifo_en = 1'b0;
                    accumulate_en = 1'b0;
                    fraction_cal_en = 1'b0;
                    parameter_valid = 1'b0;
                    reset_accumulation_parameter = 1'b0;
                    finish_accumulation = 1'b0;
                end
                else begin
                    next_accumulation_state = IDLE;
                    read_input_parm_fifo_en = 1'b0;
                    accumulate_en = 1'b0;
                    fraction_cal_en = 1'b0;
                    parameter_valid = 1'b0;
                    reset_accumulation_parameter = 1'b0;
                    finish_accumulation = 1'b0;
                end
            end

            ACCUMULATION_START: begin
                next_accumulation_state = READ_PARM_FIFO;
                read_input_parm_fifo_en = 1'b0;
                accumulate_en = 1'b0;
                fraction_cal_en = 1'b0;
                parameter_valid = 1'b0;
                reset_accumulation_parameter = 1'b0;
                finish_accumulation = 1'b0;
            end

            READ_PARM_FIFO: begin
                next_accumulation_state = DETERMINE_FAIL;
                read_input_parm_fifo_en = 1'b1;
                accumulate_en = 1'b0;
                fraction_cal_en = 1'b0;
                parameter_valid = 1'b0;
                reset_accumulation_parameter = 1'b0;
                finish_accumulation = 1'b0;
            end

            DETERMINE_FAIL: begin
                if (frame_fail) begin
                    next_accumulation_state = FRAME_FAIL;
                    read_input_parm_fifo_en = 1'b0;
                    accumulate_en = 1'b0;
                    fraction_cal_en = 1'b0;
                    parameter_valid = 1'b0;
                    reset_accumulation_parameter = 1'b0;
                    finish_accumulation = 1'b0;
                end
                else begin
                    next_accumulation_state = FRAME_ACCUMULATION;
                    read_input_parm_fifo_en = 1'b0;
                    accumulate_en = 1'b0;
                    fraction_cal_en = 1'b0;
                    parameter_valid = 1'b0;
                    reset_accumulation_parameter = 1'b0;
                    finish_accumulation = 1'b0;
                end
            end


            FRAME_FAIL: begin
                next_accumulation_state = READ_PARM_FIFO;
                read_input_parm_fifo_en = 1'b0;
                accumulate_en = 1'b0;
                fraction_cal_en = 1'b0;
                parameter_valid = 1'b0;
                reset_accumulation_parameter = 1'b0;
                finish_accumulation = 1'b0;
            end

            FRAME_ACCUMULATION: begin
                if (last_round) begin
                    next_accumulation_state = VOBS_MULTIPLICATION;
                    read_input_parm_fifo_en = 1'b0;
                    accumulate_en = 1'b1;
                    fraction_cal_en = 1'b0;
                    parameter_valid = 1'b0;
                    reset_accumulation_parameter = 1'b0;
                    finish_accumulation = 1'b0;
                end
                else begin
                    next_accumulation_state = READ_PARM_FIFO;
                    read_input_parm_fifo_en = 1'b0;
                    accumulate_en = 1'b1;
                    fraction_cal_en = 1'b0;
                    parameter_valid = 1'b0;
                    reset_accumulation_parameter = 1'b0;
                    finish_accumulation = 1'b0;
                end
            end


            VOBS_MULTIPLICATION: begin
                next_accumulation_state = FRACTION_CAL;
                read_input_parm_fifo_en = 1'b0;
                accumulate_en = 1'b0;
                fraction_cal_en = 1'b0;
                parameter_valid = 1'b0;
                reset_accumulation_parameter = 1'b0;
                finish_accumulation = 1'b0;
            end


            FRACTION_CAL: begin
                next_accumulation_state = ACCUMULATION_VALID;
                read_input_parm_fifo_en = 1'b0;
                accumulate_en = 1'b0;
                fraction_cal_en = 1'b1;
                parameter_valid = 1'b0;
                reset_accumulation_parameter = 1'b0;
                finish_accumulation = 1'b0;
            end

            ACCUMULATION_VALID: begin
                next_accumulation_state = WAIT_KEYLENGTH_CAL_BUSY;
                read_input_parm_fifo_en = 1'b0;
                accumulate_en = 1'b0;
                fraction_cal_en = 1'b0;
                parameter_valid = 1'b1;
                reset_accumulation_parameter = 1'b0;
                finish_accumulation = 1'b0;
            end

            WAIT_KEYLENGTH_CAL_BUSY: begin
                if (cal_busy) begin
                    next_accumulation_state = RESET_ACCUMULATION;
                    read_input_parm_fifo_en = 1'b0;
                    accumulate_en = 1'b0;
                    fraction_cal_en = 1'b0;
                    parameter_valid = 1'b0;
                    reset_accumulation_parameter = 1'b0;
                    finish_accumulation = 1'b0;
                end
                else begin
                    next_accumulation_state = WAIT_KEYLENGTH_CAL_BUSY;
                    read_input_parm_fifo_en = 1'b0;
                    accumulate_en = 1'b0;
                    fraction_cal_en = 1'b0;
                    parameter_valid = 1'b1;
                    reset_accumulation_parameter = 1'b0;
                    finish_accumulation = 1'b0;
                end
            end

            RESET_ACCUMULATION: begin
                next_accumulation_state = ACCUMULATION_END;
                read_input_parm_fifo_en = 1'b0;
                accumulate_en = 1'b0;
                fraction_cal_en = 1'b0;
                parameter_valid = 1'b0;
                reset_accumulation_parameter = 1'b1;
                finish_accumulation = 1'b0;
            end

            ACCUMULATION_END: begin
                next_accumulation_state = IDLE;
                read_input_parm_fifo_en = 1'b0;
                accumulate_en = 1'b0;
                fraction_cal_en = 1'b0;
                parameter_valid = 1'b0;
                reset_accumulation_parameter = 1'b0;
                finish_accumulation = 1'b1;
            end


            default: begin
                next_accumulation_state = IDLE;
                read_input_parm_fifo_en = 1'b0;
                accumulate_en = 1'b0;
                fraction_cal_en = 1'b0;
                parameter_valid = 1'b0;
                reset_accumulation_parameter = 1'b0;
                finish_accumulation = 1'b0;
            end
        endcase
    end






endmodule




















































module keylength_cal(
    input clk_20MHz,   						//clock input
    input rst_n, 						//rst (active low)
    
    input wire [`QBER_WIDTH-1:0] qber_ff,    //qber
    input wire [`NCOR_WIDTH-1:0] ncor_ff,    //leaked info from cascade error correction
    input wire [`NVIS_WIDTH-1:0] nvis_ff,    //numbers of detected photons used to determine visibility
    input wire [`VOBS_WIDTH-1:0] vobs_ff,    //measured visibility from sifting
    input wire in_valid,                    //input is valid
    
    output reg [`SECRETKEY_LENGTH_WIDTH-1:0] out_length,  //secret key length
    output wire out_valid,        //length is valid
    output reg out_length_negative, //secret key length < 0
    output wire out_length_small,    //secret key length < 10000
    output wire input_outrange,           //input parameter out of range
    output wire out_busy             //calculation is NOT DONE

);


    wire clk;
    assign clk = clk_20MHz;


//***************************************** constant *****************************************
    wire [`CONST_FBITS-1:0] const_1, const_2;
    //constant 1
    assign const_1 = 32'he7a36ccf;
    //constant 2
    assign const_2 = 32'h2e67a94f;

    wire [`CONST_FBITS+8-1:0] const_3;
    //constant 3
    assign const_3 = 40'h19bee6ea75;

    wire [`CONST_FBITS+16-1:0] const_4;
    //constant 4
    assign const_4 = 48'h9919875470fc;

    wire [20:0] ncpp;
    assign ncpp = 21'd1048576;

    wire [6:0] nver;
    assign nver = 7'd48;

    wire [31:0] scaling_factor; //scaling factor = 0.9945
    assign scaling_factor = 32'hfeb851ec;
//***************************************** constant *****************************************




//***************************************** input DFF *****************************************
    reg [`QBER_WIDTH-1:0] qber;
    reg [`NCOR_WIDTH-1:0] ncor;
    reg [`NVIS_WIDTH-1:0] nvis;
    reg [`VOBS_WIDTH-1:0] vobs;






    always @(posedge clk ) begin
        if (~rst_n) begin
            qber 	<= 0;
        end
        else if (in_valid) begin
            qber 	<= qber_ff;
        end
        else begin
            qber 	<= qber;
        end
    end

    always @(posedge clk ) begin
        if (~rst_n) begin
            ncor 	<= 0;
        end
        else if (in_valid) begin
            ncor 	<= ncor_ff;
        end
        else begin
            ncor 	<= ncor;
        end
    end

    always @(posedge clk ) begin
        if (~rst_n) begin
            nvis 	<= 0;
        end
        else if (in_valid && (nvis_ff>1048576)) begin
            nvis 	<= 1048576;
        end
        else if (in_valid) begin
            nvis 	<= nvis_ff;
        end
        else begin
            nvis 	<= nvis;
        end
    end

    always @(posedge clk ) begin
        if (~rst_n) begin
            vobs 	<= 0;
        end
        else if (in_valid && (vobs_ff>20'hfd70a)) begin
            vobs 	<= 20'hfd70a;
        end
        else if (in_valid) begin
            vobs 	<= vobs_ff;
        end
        else begin
            vobs 	<= vobs;
        end
    end


//***************************************** input DFF *****************************************



// //***************************************** compute start *****************************************
//     reg compute_start;
//     always @(posedge clk ) begin
//         if(~rst_n) begin
//             compute_start <= 0;
//         end
//         else begin
//             compute_start <= in_valid;
//         end
//     end
// //***************************************** compute start *****************************************



//***************************************** input outrange *****************************************
    wire input_outrange;
    assign input_outrange = ((qber>20'h10a3d) || (vobs<20'he147b) || (vobs>20'hfd70a) || (nvis>1048576) || (nvis<10485) || (ncor>1048576))? 1:0;
//***************************************** input outrange *****************************************





//***************************************** FSM *****************************************
    fsm keylength_fsm(
        .clk(clk),
        .rst_n(rst_n),

        .compute_start(in_valid),
        .input_outrange(input_outrange),
        .valid_s1(valid_s1),
        .valid_s2(valid_s2),
        .s1(s1),
        .s2(s2),

        .start_s1(start_s1),
        .start_s2(start_s2),

        .rad_s1(rad_s1),
        .rad_s2(rad_s2),

        .out_busy(out_busy),
        .out_valid(out_valid)
    );

//***************************************** FSM *****************************************




    //***************************************** log table *****************************************
    //p index
    wire [31:0] p_index;
    assign p_index = (p[31:0] - 32'h999a0000)>>20;
    //log2(1-p) table
    wire [11-1:0] index_log2_1_p;
    wire [36-1:0] table_out_log2_1_p;
    assign index_log2_1_p = p_index[10:0];
    log2_1_p_table t_log2_1_p(
        .index(index_log2_1_p), //0~1228
        .table_out(table_out_log2_1_p) //36 word length, 32 fraction length
    );
    //log(p) table
    wire [11-1:0] index_log2_p;
    wire [36-1:0] table_out_log2_p;
    assign index_log2_p = p_index[10:0];
    log2_p_table t_log2_p(
        .index(index_log2_p), //0~1228
        .table_out(table_out_log2_p) //36 word length, 32 fraction length
    );


    //nvis index
    wire [19:0] nvis_index;
    assign nvis_index = (nvis - 20'd10485)>>10;
    //ln(nvis) table
    wire [10-1:0] index_ln_nvis;
    wire [36-1:0] table_out_ln_nvis;
    assign index_ln_nvis = nvis_index[9:0];
    ln_nvis_table t_ln_nvis(
        .index(index_ln_nvis), //0~1014
        .table_out(table_out_ln_nvis) //36 word length, 32 fraction length
    );
    //ln(nvis+ncpp) table
    wire [10-1:0] index_ln_ncpp_nvis;
    wire [36-1:0] table_out_ln_ncpp_nvis;
    assign index_ln_ncpp_nvis = nvis_index[9:0];
    ln_ncpp_nvis_table t_ln_ncpp_nvis(
        .index(index_ln_ncpp_nvis), //0~1014
        .table_out(table_out_ln_ncpp_nvis) //36 word length, 32 fraction length
    );

    //vobs index
    wire [19:0] vobs_index;
    assign vobs_index = (vobs - 20'he147b)>>9;
    //ln(lam*(1-lam)) table
    wire [8-1:0] index_ln_lam_1_lam;
    wire [36-1:0] table_out_ln_lam_1_lam;
    assign index_ln_lam_1_lam = vobs_index[7:0];
    ln_lam_1_lam_table t_ln_lam_1_lam(
        .index(index_ln_lam_1_lam), //0~255
        .table_out(table_out_ln_lam_1_lam) //36 word length, 32 fraction length
    );
    //***************************************** log table *****************************************

    //***************************************** sqrt *****************************************
    //sqrt 1
    wire start_s1; 
    wire busy_s1, valid_s1;
    wire [`SQRT_WIDTH-1:0] rad_s1;
    wire [`SQRT_WIDTH-1:0] root_s1, rem_s1;


    sqrt #(
      .WIDTH(`SQRT_WIDTH),
      .FBITS(`SQRT_FBITS)
    ) sqrt_inst_1(
        .clk(clk),
        .start(start_s1),             // start signal
        .busy(busy_s1),              // calculation in progress
        .valid(valid_s1),             // root and rem are valid

        .rad(rad_s1),   // radicand
        .root(root_s1),  // root
        .rem(rem_s1)    // remainder
    );

    //sqrt 2
    wire start_s2;
    wire busy_s2, valid_s2;
    wire [`SQRT_WIDTH-1:0] rad_s2;
    wire [`SQRT_WIDTH-1:0] root_s2, rem_s2;
    sqrt #(
      .WIDTH(`SQRT_WIDTH),
      .FBITS(`SQRT_FBITS)
    ) sqrt_inst_2(
        .clk(clk),
        .start(start_s2),             // start signal
        .busy(busy_s2),              // calculation in progress
        .valid(valid_s2),             // root and rem are valid

        .rad(rad_s2),   // radicand
        .root(root_s2),  // root
        .rem(rem_s2)    // remainder
    );
    //***************************************** sqrt *****************************************



    //***************************************** calculation *****************************************
    wire [39:0] x;
    wire [59:0] xa;
    assign xa = ((ncpp<<32)/nvis); //xa = (ncpp*2^16/nvis)
    assign x = xa[39:0];


    wire [19:0] lam, lam_1;
    wire [31:0] lam_1_lam;
    wire [39:0] lam_prod;
    assign lam = {1'b1,19'b0} - ({1'b0,vobs[19:1]}); //lam = 0.5 - vobs/2
    assign lam_1 = ~lam; //1-lam
    assign lam_prod = lam * lam_1;
    assign lam_1_lam = lam_prod[39:8];

    //log1 = table_out_ln_ncpp_nvis;
    wire [35:0] log_1;
    assign log_1 = table_out_ln_ncpp_nvis;
    //log2
    wire [35:0] log_2;
    assign log_2 = table_out_ln_nvis + table_out_ln_lam_1_lam;

    //CAL s1
    wire [71:0] s1_1a; 
    wire [39:0] x1,s1_1;
    assign x1 = x + {1'b1,32'b0};
    assign s1_1a = x1 * lam_1_lam; //(1 + x)*lam*(1-lam)
    assign s1_1 = s1_1a[71:32];
    wire [39:0] s1_2; //log_TY_1 - log_TY_2 - constant_3_fi
    assign s1_2 = table_out_ln_ncpp_nvis + const_3 - log_2;
    wire [79:0] s1_3a;
    assign s1_3a = s1_1*s1_2;

    //sqrt 1
    wire [35:0] s1;
    assign s1 = {16'b0,s1_3a[71:52]};

    //CAL s2
    wire [31:0] v,v_1; //vobs - 2*root_s1
    wire [31:0] root_s1_2;
    assign root_s1_2 = (root_s1[31:0])<<1;
    assign v = {vobs,12'b0} - root_s1_2;
    assign v_1 = ~v;
    wire [63:0] s2_1p;
    wire [31:0] s2_1; //v*(1-v)
    assign s2_1p = v*v_1;
    assign s2_1 = s2_1p[63:32];
    wire [63:0] s2p = s2_1*const_2;

    //sqrt 2
    wire [35:0] s2;
    assign s2 = {4'b0,s2p[63:32]};

    //CAL A
    wire [35:0] b; //((2*v-1)*constant_1_fi - 2*sqrt_2)
    wire [32:0] v2,v2_1;
    assign v2 = v<<1;
    assign v2_1 = v2-{1'b1,32'b0};
    wire [64:0] b_p;
    assign b_p = (v2_1)*const_1;
    wire [35:0] root_s2_2;
    assign root_s2_2 = root_s2<<1;
    assign b = {3'b0,b_p[64:32]} - root_s2_2;

    wire [35:0] p; //(1 + b)/2
    wire [35:0] b_2;
    assign b_2 = b>>1;
    assign p = {5'b1,31'b0} + b_2;

    wire [71:0] a1p; //-p*log2_p
    wire [35:0] log2_p,a1;
    assign log2_p = ~table_out_log2_p;
    assign a1p = p*log2_p;
    assign a1 = a1p[71:32];

    wire [35:0] a2,log2_1_p,p_1; //-(1-p)*log2_1_p
    wire [71:0] a2p;
    assign log2_1_p = ~table_out_log2_1_p;
    assign p_1 = {4'b1,32'b0} - p;
    assign a2p = p_1 * log2_1_p;
    assign a2 = a2p[71:32];

    wire [35:0] a; //a1+a2
    assign a = a1 + a2;


    //CAL length
    //ncpp*(1 - QBER)*(1-a)
    wire [51:0] nqa;
    wire [19:0] q_1;
    wire [31:0] a_1;
    assign q_1 = ~qber;
    assign a_1 = ~a[31:0];
    assign nqa = q_1 * a_1;


    wire [51:0] outr; //nqa - constant_4 - ncor - nver
    wire [52:0] removed_bit;
    assign removed_bit = (const_4) + ({ncor,32'b0}) + {13'b0,nver,32'b0};

    always @(*) begin
        if (input_outrange) begin
            out_length_negative = 1'b0;
        end
        else if ((~input_outrange) && (removed_bit > {0,nqa})) begin
            out_length_negative = 1'b1;
        end
        else begin
            out_length_negative = 1'b0;
        end
    end


    assign outr = (out_length_negative)? 53'b0:({0,nqa} - removed_bit);


    wire [83:0] out_length_p; //secret key length output
    assign out_length_p = outr* scaling_factor;





    always @(*) begin
        if (out_valid && input_outrange) begin
            out_length = 20'b0;
        end 
        else if (out_valid && out_length_negative) begin
            out_length = 20'b0;
        end
        else if (out_valid)begin
            out_length = out_length_p[83:64];
        end
        else begin
            out_length = 20'b0;
        end
    end

    assign out_length_small = (out_length[19:0] < 20'd10000)? 1:0;
    //***************************************** calculation *****************************************

endmodule

























































module fsm (
    input clk,
    input rst_n,

    input compute_start,
    // input in_valid,
    input input_outrange,
    input valid_s1,
    input valid_s2,
    input wire [35:0] s1,
    input wire [35:0] s2,


    output reg start_s1,
    output reg start_s2,

    output reg [`SQRT_WIDTH-1:0] rad_s1,
    output reg [`SQRT_WIDTH-1:0] rad_s2,

    output reg out_busy,
    output reg out_valid
);



    reg [3:0] state, next_state;
    localparam IDLE             = 4'd0;
    localparam COMPUTE_START    = 4'd15;
    localparam INPUT_INRANGE    = 4'd14;
    localparam INPUT_OUTRANGE   = 4'd1;
    localparam CAL_S1		    = 4'd2;
    localparam SQRT_1           = 4'd3;
    localparam CAL_S2           = 4'd4;
    localparam SQRT_2           = 4'd5;
    localparam CAL_A            = 4'd6;
    localparam CAL_LENGTH       = 4'd7;
    localparam OUTPUT_LENGTH    = 4'd8;


    always @(posedge clk ) begin
        if(~rst_n)
            state <= IDLE;
        else
            state <= next_state;
    end




    always @(*) begin
        case(state)
            IDLE : begin
                if (compute_start) begin
                    next_state = COMPUTE_START;
                    start_s1 = 0;
                    start_s2 = 0;
                    rad_s1 = 0;
                    rad_s2 = 0;
                    out_valid = 0;
                    out_busy = 0;
                end
                else begin
                    next_state = IDLE;
                    start_s1 = 0;
                    start_s2 = 0;
                    rad_s1 = 0;
                    rad_s2 = 0;
                    out_valid = 0;
                    out_busy = 0;
                end
            end

            COMPUTE_START : begin
                if (input_outrange) begin
                    next_state = INPUT_OUTRANGE;
                    start_s1 = 0;
                    start_s2 = 0;
                    rad_s1 = 0;
                    rad_s2 = 0;
                    out_valid = 0;
                    out_busy = 1;
                end
                else begin
                    next_state = INPUT_INRANGE;
                    start_s1 = 0;
                    start_s2 = 0;
                    rad_s1 = 0;
                    rad_s2 = 0;
                    out_valid = 0;
                    out_busy = 1;
                end
            end


            INPUT_OUTRANGE : begin
                next_state = IDLE;
                start_s1 = 0;
                start_s2 = 0;
                rad_s1 = 0;
                rad_s2 = 0;
                out_valid = 1;
                out_busy = 0;
            end


            INPUT_INRANGE : begin
                next_state = CAL_S1;
                start_s1 = 0;
                start_s2 = 0;
                rad_s1 = 0;
                rad_s2 = 0;
                out_valid = 0;
                out_busy = 1;
            end


            CAL_S1 : begin
                if (cnt==3'd2) begin
                    next_state = SQRT_1;
                    start_s1 = 1;
                    start_s2 = 0;
                    rad_s1 = s1;
                    rad_s2 = 0;
                    out_valid = 0;
                    out_busy = 1;
                end
                else begin
                    next_state = CAL_S1;
                    start_s1 = 0;
                    start_s2 = 0;
                    rad_s1 = 0;
                    rad_s2 = 0;
                    out_valid = 0;
                    out_busy = 1;
                end
            end

            SQRT_1 : begin
                if (valid_s1) begin
                    next_state = CAL_S2;
                    start_s1 = 0;
                    start_s2 = 0;
                    rad_s1 = 0;
                    rad_s2 = 0;
                    out_valid = 0;
                    out_busy = 1;
                end
                else begin
                    next_state = SQRT_1;
                    start_s1 = 0;
                    start_s2 = 0;
                    rad_s1 = s1;
                    rad_s2 = 0;
                    out_valid = 0;
                    out_busy = 1;
                end
            end

            CAL_S2 : begin
                if (cnt==3'd2) begin
                    next_state = SQRT_2;
                    start_s1 = 0;
                    start_s2 = 1;
                    rad_s1 = 0;
                    rad_s2 = s2;
                    out_valid = 0;
                    out_busy = 1;
                end
                else begin
                    next_state = CAL_S2;
                    start_s1 = 0;
                    start_s2 = 0;
                    rad_s1 = 0;
                    rad_s2 = 0;
                    out_valid = 0;
                    out_busy = 1;
                end
            end


            SQRT_2 : begin
                if (valid_s2) begin
                    next_state = CAL_A;
                    start_s1 = 0;
                    start_s2 = 0;
                    rad_s1 = 0;
                    rad_s2 = 0;
                    out_valid = 0;
                    out_busy = 1;
                end
                else begin
                    next_state = SQRT_2;
                    start_s1 = 0;
                    start_s2 = 0;
                    rad_s1 = 0;
                    rad_s2 = s2;
                    out_valid = 0;
                    out_busy = 1;
                end
            end

            CAL_A : begin
                next_state = CAL_LENGTH;
                start_s1 = 0;
                start_s2 = 0;
                rad_s1 = 0;
                rad_s2 = 0;
                out_valid = 0;
                out_busy = 1;
            end

            CAL_LENGTH : begin
                next_state = OUTPUT_LENGTH;
                start_s1 = 0;
                start_s2 = 0;
                rad_s1 = 0;
                rad_s2 = 0;
                out_valid = 0;
                out_busy = 1;
            end



            OUTPUT_LENGTH : begin
                next_state = IDLE;
                start_s1 = 0;
                start_s2 = 0;
                rad_s1 = 0;
                rad_s2 = 0;
                out_valid = 1;
                out_busy = 0;
            end


            default : begin
                next_state = IDLE;
                start_s1 = 0;
                start_s2 = 0;
                rad_s1 = 0;
                rad_s2 = 0;
                out_valid = 0;
                out_busy = 0;
            end 
        endcase
    end


    reg [2:0] cnt;
    always @(posedge clk) begin
        if(~rst_n)
            cnt <= 3'b0;
        else if (((state==CAL_S1) || (state==CAL_S2)) &&(cnt!=3'd2))
            cnt <= cnt + 1'b1;
        else 
            cnt <= 3'b0;
    end

endmodule