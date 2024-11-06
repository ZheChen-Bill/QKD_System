







module A_bram_controller (
    input clk,                              //clk
    input rst_n,                            //reset

    input [63:0] AXImanager_doutb,
    // input secretkey_length_request,
    input qubit_request,
    input EVrandombit_request,
    input PArandombit_request,
    input secretkey_1_request,
    input secretkey_2_request,

    input request_valid,

    output AXIbram_ready_en,
    output qubit_ready,
    output EVrandombit_ready,
    output PArandombit_ready,
    output new_round,


    output AXImanager_clkb,
    output reg [31:0] AXImanager_addrb,
    output reg [63:0] AXImanager_dinb,
    output AXImanager_enb,
    output AXImanager_rstb,
    output reg [7:0] AXImanager_web,

    output [3:0] A_bramcontroller_state
);




    assign qubit_ready = AXIbram_ready_en;
    assign EVrandombit_ready = AXIbram_ready_en;
    assign PArandombit_ready = AXIbram_ready_en;

    wire secretkey_length_request;
    assign secretkey_length_request = 1'b0;

//****************************** A bram controller fsm ******************************
    //fsm input 
    wire QKD_start;
    wire addr0_ready;
    wire addr0_idle;

    //fsm output 
    wire write_request_state_en;
    wire write_idle_state_en;
    wire QKD_idle_en;
    //wire AXIbram_ready_en;



    A_bram_controller_fsm A_bramcontroller_fsm(
        .clk(clk),
        .rst_n(rst_n),

        .QKD_start(QKD_start),
        .request_valid(request_valid),
        .addr0_ready(addr0_ready),
        .addr0_idle(addr0_idle),

        .write_request_state_en(write_request_state_en),
        .write_idle_state_en(write_idle_state_en),
        .AXIbram_ready_en(AXIbram_ready_en),     //AXI bram are ready
        .QKD_idle_en(QKD_idle_en),
        .new_round(new_round),
        .A_bramcontroller_state(A_bramcontroller_state)
    );

//****************************** A bram controller fsm ******************************


//****************************** axibram output DFF ******************************
    reg [63:0] AXImanager_doutb_DFF;
    always @(posedge clk ) begin
        if (~rst_n ) begin
            AXImanager_doutb_DFF <= 64'b0;
        end
        else begin
            AXImanager_doutb_DFF <= AXImanager_doutb;
        end
    end


    assign QKD_start = (AXImanager_doutb_DFF[31:28]==`ON_STATE);
    assign addr0_ready = (AXImanager_doutb_DFF[31:0]=={`ON_STATE , 
                                                       `READY_STATE,
                                                       `READY_STATE,
                                                       `READY_STATE,
                                                       `READY_STATE,
                                                       `READY_STATE,
                                                       `READY_STATE,
                                                       `WRITER_PC});


    assign addr0_idle   = (AXImanager_doutb_DFF[31:0]=={`ON_STATE , 
                                                       `IDLE_STATE,
                                                       `IDLE_STATE,
                                                       `IDLE_STATE,
                                                       `IDLE_STATE,
                                                       `IDLE_STATE,
                                                       `IDLE_STATE,
                                                       `WRITER_PC});

//****************************** axibram output DFF ******************************


//****************************** request DFF ******************************
    reg [5:0] request_DFF;
    always @(posedge clk ) begin
        if (~rst_n) begin
            request_DFF <= 6'b0;
        end
        else if (request_valid) begin
            request_DFF <= {secretkey_length_request,
                            qubit_request,
                            EVrandombit_request,
                            PArandombit_request,
                            secretkey_1_request,
                            secretkey_2_request};
        end
        else begin
            request_DFF <= request_DFF;
        end
    end

//****************************** request DFF ******************************


//****************************** AXI manager bram ******************************

    assign AXImanager_clkb = clk;
    assign AXImanager_enb = 1'b1;




    wire [3:0] on_off_state;
    wire [3:0] secretkey_length_state;
    wire [3:0] qubit_state;
    wire [3:0] EVrb_state;
    wire [3:0] PArb_state;
    wire [3:0] secretkey_state_1;
    wire [3:0] secretkey_state_2;
    wire [3:0] writer;

    assign secretkey_length_state = (request_DFF[5])? `REQUEST_STATE:`IDLE_STATE;
    assign qubit_state = (request_DFF[4])? `REQUEST_STATE:`IDLE_STATE;
    assign EVrb_state = (request_DFF[3])? `REQUEST_STATE:`IDLE_STATE;
    assign PArb_state = (request_DFF[2])? `REQUEST_STATE:`IDLE_STATE;
    assign secretkey_state_1 = (request_DFF[1])? `REQUEST_STATE:`IDLE_STATE;
    assign secretkey_state_2 = (request_DFF[0])? `REQUEST_STATE:`IDLE_STATE;



    always @(posedge clk) begin
        if (~rst_n) begin
            AXImanager_dinb <= 64'b0;
            AXImanager_web <= 8'b0;
            AXImanager_addrb <= `PC_STATE_ADDRESS;
        end
        else if (QKD_idle_en) begin
            AXImanager_dinb <= 64'b0;
            AXImanager_web <= 8'b0;
            AXImanager_addrb <= `PC_STATE_ADDRESS;
        end
        else if (write_request_state_en) begin
            AXImanager_dinb <= {`NO_USE_BIT_WIDTH'b0,
                                `ON_STATE,
                                secretkey_length_state,
                                qubit_state,
                                EVrb_state,
                                PArb_state,
                                secretkey_state_1,
                                secretkey_state_2,
                                `WRITER_KCU116};
            AXImanager_web <= 8'b1111_1111;
            AXImanager_addrb <= `FPGA_STATE_ADDRESS;
        end
        else if (write_idle_state_en) begin
            AXImanager_dinb <= {`NO_USE_BIT_WIDTH'b0,
                                `ON_STATE,
                                `IDLE_STATE,
                                `IDLE_STATE,
                                `IDLE_STATE,
                                `IDLE_STATE,
                                `IDLE_STATE,
                                `IDLE_STATE,
                                `WRITER_KCU116};
            AXImanager_web <= 8'b1111_1111;
            AXImanager_addrb <= `FPGA_STATE_ADDRESS;
        end
        else begin
            AXImanager_dinb <= 64'b0;
            AXImanager_web <= 8'b0;
            AXImanager_addrb <= `PC_STATE_ADDRESS;
        end
    end



//****************************** AXI manager bram ******************************
endmodule









module A_bram_controller_fsm (
    input clk,
    input rst_n,

    input QKD_start,
    input request_valid,
    input addr0_ready,
    input addr0_idle,


    output reg write_request_state_en,
    output reg write_idle_state_en,
    output reg AXIbram_ready_en,     //AXI bram are ready
    output reg QKD_idle_en,         
    output wire new_round,
    output reg [3:0] A_bramcontroller_state

);


    localparam QKD_IDLE             = 4'd0;
    localparam QKD_START            = 4'd1;
    localparam AXIBRAM_READY        = 4'd2;
    localparam AXIBRAM_REQUEST      = 4'd3;
    localparam WRITE_REQUEST        = 4'd4;
    localparam WAIT_READY           = 4'd5;
    localparam WRITE_IDLE           = 4'd6;
    localparam WAIT_IDLE            = 4'd7;
    localparam FINISH               = 4'd8;


    assign new_round = (A_bramcontroller_state==FINISH)? 1'b1:1'b0;

    reg [3:0] next_A_bramcontroller_state;
    always @(posedge clk ) begin
        if (~rst_n) begin
            A_bramcontroller_state <= QKD_IDLE;
        end
        else begin
            A_bramcontroller_state <= next_A_bramcontroller_state;
        end
    end



    always @(*) begin
        case (A_bramcontroller_state)
            QKD_IDLE: begin
                if (QKD_start) begin
                    next_A_bramcontroller_state = QKD_START;
                    write_request_state_en = 1'b0;
                    write_idle_state_en = 1'b0;
                    AXIbram_ready_en = 1'b0;
                    QKD_idle_en = 1'b1;
                end
                else begin
                    next_A_bramcontroller_state = QKD_IDLE;
                    write_request_state_en = 1'b0;
                    write_idle_state_en = 1'b0;
                    AXIbram_ready_en = 1'b0;
                    QKD_idle_en = 1'b1;
                end
            end

            QKD_START: begin
                next_A_bramcontroller_state = AXIBRAM_READY;
                write_request_state_en = 1'b0;
                write_idle_state_en = 1'b0;
                AXIbram_ready_en = 1'b0;
                QKD_idle_en = 1'b0;
            end

            AXIBRAM_READY: begin
                if (request_valid) begin
                    next_A_bramcontroller_state = AXIBRAM_REQUEST;
                    write_request_state_en = 1'b0;
                    write_idle_state_en = 1'b0;
                    AXIbram_ready_en = 1'b0;
                    QKD_idle_en = 1'b0;
                end
                else begin
                    next_A_bramcontroller_state = AXIBRAM_READY;
                    write_request_state_en = 1'b0;
                    write_idle_state_en = 1'b0;
                    AXIbram_ready_en = 1'b1;
                    QKD_idle_en = 1'b0;
                end
            end

            AXIBRAM_REQUEST: begin
                next_A_bramcontroller_state = WRITE_REQUEST;
                write_request_state_en = 1'b0;
                write_idle_state_en = 1'b0;
                AXIbram_ready_en = 1'b0;
                QKD_idle_en = 1'b0;
            end

            WRITE_REQUEST: begin
                next_A_bramcontroller_state = WAIT_READY;
                write_request_state_en = 1'b1;
                write_idle_state_en = 1'b0;
                AXIbram_ready_en = 1'b0;
                QKD_idle_en = 1'b0;
            end

            WAIT_READY: begin
                if (addr0_ready) begin
                    next_A_bramcontroller_state = WRITE_IDLE;
                    write_request_state_en = 1'b0;
                    write_idle_state_en = 1'b0;
                    AXIbram_ready_en = 1'b0;
                    QKD_idle_en = 1'b0;
                end
                else begin
                    next_A_bramcontroller_state = WAIT_READY;
                    write_request_state_en = 1'b0;
                    write_idle_state_en = 1'b0;
                    AXIbram_ready_en = 1'b0;
                    QKD_idle_en = 1'b0;
                end
            end

            WRITE_IDLE: begin
                next_A_bramcontroller_state = WAIT_IDLE;
                write_request_state_en = 1'b0;
                write_idle_state_en = 1'b1;
                AXIbram_ready_en = 1'b0;
                QKD_idle_en = 1'b0;
            end



            WAIT_IDLE: begin
                if (addr0_idle) begin
                    next_A_bramcontroller_state = FINISH;
                    write_request_state_en = 1'b0;
                    write_idle_state_en = 1'b0;
                    AXIbram_ready_en = 1'b0;
                    QKD_idle_en = 1'b0;
                end
                else begin
                    next_A_bramcontroller_state = WAIT_IDLE;
                    write_request_state_en = 1'b0;
                    write_idle_state_en = 1'b0;
                    AXIbram_ready_en = 1'b0;
                    QKD_idle_en = 1'b0;
                end
            end


            FINISH: begin
                next_A_bramcontroller_state = AXIBRAM_READY;
                write_request_state_en = 1'b0;
                write_idle_state_en = 1'b0;
                AXIbram_ready_en = 1'b0;
                QKD_idle_en = 1'b0;
            end




            default: begin
                next_A_bramcontroller_state = QKD_IDLE;
                write_request_state_en = 1'b0;
                write_idle_state_en = 1'b0;
                AXIbram_ready_en = 1'b0;
                QKD_idle_en = 1'b0;
            end
        endcase
    end


endmodule