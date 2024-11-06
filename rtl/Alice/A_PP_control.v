



module A_post_processing_control (
    input clk,
    input rst_n,

    // AXI manager request & ready
    output reg request_valid,
    input wire new_round,

    input wire qubit_ready,
    output reg qubit_request,

    input wire EVrandombit_ready,
    output reg EVrandombit_request,

    input wire PArandombit_ready,
    output reg PArandombit_request,

    output reg secretkey_1_request,
    output reg secretkey_2_request,




    // sifting
    output reg start_sifting,
    input wire finish_sifting,
    // ER
    output reg start_ER,
    output reg sifted_key_addr_index,
    input wire finish_ER,
    // parameter accumulation
    output reg start_accumulation,
    input wire accumulate_busy,
    // secret key length calculation
    input wire keylength_valid,
    input wire keylength_negative,
    input wire keylength_small,
    input wire keylength_input_outrange,
    input [19:0] keylength,
    // PA
    output reg start_PA,
    output reg [31:0] secretkey_length,
    output reg reconciled_key_addr_index,
    input wire finish_PA,


    // determine sifted key ready
    input [14:0] siftedkey_addra,
    input siftedkey_wea,
    // determine reconciled key ready
    input [14:0] reconciledkey_addra,
    input reconciledkey_wea,
    // determine secret key request
    input [14:0] secretkey_addrb,
    input secretkey_web,


    output reg [4:0] post_processing_state

);






















//****************************** key length ******************************
    wire keylength_load_valid;
    always @(posedge clk ) begin
        if (~rst_n) begin
            secretkey_length <= 0;
        end
        else if (reset_control_parameter) begin
            secretkey_length <= 0;
        end

        else if (keylength_valid && (keylength_input_outrange||keylength_negative||keylength_small)) begin
            secretkey_length <= {4'b1111 , 28'b0};
        end

        else if (keylength_valid) begin
            secretkey_length <= {12'b0 , keylength};
        end

        else begin
            secretkey_length <= secretkey_length;
        end
    end
//****************************** key length ******************************






//****************************** sifted key ready ******************************
    reg siftedkey_ready;
    always @(posedge clk ) begin
        if (~rst_n) begin
            siftedkey_ready <= 0;
            sifted_key_addr_index <= 0;
        end 
        else if (reset_control_parameter) begin
            siftedkey_ready <= 0;
            sifted_key_addr_index <= 0;
        end
        else if ((siftedkey_addra==`SIFTEDKEY_1_READY_ADDR) && (siftedkey_wea)) begin
            siftedkey_ready <= 1;
            sifted_key_addr_index <= 0;
        end
        else if ((siftedkey_addra==`SIFTEDKEY_2_READY_ADDR) && (siftedkey_wea)) begin
            siftedkey_ready <= 1;
            sifted_key_addr_index <= 1;
        end
        else begin
            siftedkey_ready <= siftedkey_ready;
            sifted_key_addr_index <= sifted_key_addr_index;
        end       
    end

//****************************** sifted key ready ******************************




//****************************** reconciled key ready ******************************
    reg reconciledkey_ready;
    always @(posedge clk ) begin
        if (~rst_n) begin
            reconciledkey_ready <= 0;
            reconciled_key_addr_index <= 0;
        end 
        else if (reset_control_parameter) begin
            reconciledkey_ready <= 0;
            reconciled_key_addr_index <= 0;
        end
        else if ((reconciledkey_addra==`RECONCILEDKEY_1_READY_ADDR) && (reconciledkey_wea)) begin
            reconciledkey_ready <= 1;
            reconciled_key_addr_index <= 0;
        end
        else if ((reconciledkey_addra==`RECONCILEDKEY_2_READY_ADDR) && (reconciledkey_wea)) begin
            reconciledkey_ready <= 1;
            reconciled_key_addr_index <= 1;
        end
        else begin
            reconciledkey_ready <= reconciledkey_ready;
            reconciled_key_addr_index <= reconciled_key_addr_index;
        end       
    end
//****************************** reconciled key ready ******************************






//****************************** bram used ******************************
    // output reg qubit_request,
    // output reg EVrandombit_request,
    // output reg PArandombit_request,

    reg Qubit_used;
    reg EVrandombit_used;
    reg PArandombit_used;

    always @(posedge clk ) begin
        if (~rst_n) begin
            qubit_request <= 0;
        end
        else if (reset_control_parameter) begin
            qubit_request <= 0;
        end
        else if (Qubit_used) begin
            qubit_request <= 1;
        end
        else begin
            qubit_request <= qubit_request;
        end
    end

    always @(posedge clk ) begin
        if (~rst_n) begin
            EVrandombit_request <= 0;
        end
        else if (reset_control_parameter) begin
            EVrandombit_request <= 0;
        end
        else if (EVrandombit_used) begin
            EVrandombit_request <= 1;
        end
        else begin
            EVrandombit_request <= EVrandombit_request;
        end
    end

    always @(posedge clk ) begin
        if (~rst_n) begin
            PArandombit_request <= 0;
        end
        else if (reset_control_parameter) begin
            PArandombit_request <= 0;
        end
        else if (PArandombit_used) begin
            PArandombit_request <= 1;
        end
        else begin
            PArandombit_request <= PArandombit_request;
        end
    end
    
//****************************** bram used ******************************


//****************************** secret key request ******************************
    always @(posedge clk ) begin
        if (~rst_n) begin
            secretkey_1_request <= 0;
        end 
        else if (reset_control_parameter) begin
            secretkey_1_request <= 0;
        end
        else if ((secretkey_addrb==`SECRETKEY_1_REQUSET_ADDR) && (secretkey_web)) begin
            secretkey_1_request <= 1;
        end
        else begin
            secretkey_1_request <= secretkey_1_request;
        end       
    end

    always @(posedge clk ) begin
        if (~rst_n) begin
            secretkey_2_request <= 0;
        end 
        else if (reset_control_parameter) begin
            secretkey_2_request <= 0;
        end
        else if ((secretkey_addrb==`SECRETKEY_2_REQUSET_ADDR) && (secretkey_web)) begin
            secretkey_2_request <= 1;
        end
        else begin
            secretkey_2_request <= secretkey_2_request;
        end       
    end
//****************************** secret key request ******************************










































//****************************** fsm ******************************
    localparam PP_IDLE                  = 5'd0;
    localparam PP_START                 = 5'd1;
    localparam SIFTING_START            = 5'd2;
    localparam SIFTING_BUSY             = 5'd3;
    localparam SIFTING_END              = 5'd4;

    localparam DETERMINE_ER             = 5'd5;
    localparam ER_IDLE                  = 5'd6;
    localparam ER_START                 = 5'd7;
    localparam ER_BUSY                  = 5'd8;
    localparam ER_END                   = 5'd9;
    
    localparam DETERMINE_PA             = 5'd10;
    localparam PA_IDLE                  = 5'd11;
    localparam ACCUMULATION_START       = 5'd12;
    localparam WAIT_ACCUMULATE_BUSY     = 5'd13;
    localparam KEYLENGTH_CAL_BUSY       = 5'd14;
    localparam KEYLENGTH_VALID          = 5'd15;
    localparam PA_START                 = 5'd16;
    localparam PA_BUSY                  = 5'd17;
    localparam PA_END                   = 5'd18;
    
    localparam REQUEST_VALID            = 5'd19;
    localparam WAIT_NEW_ROUND           = 5'd20;
    localparam NEW_ROUND                = 5'd21;
    localparam RESET_CONTROL_PARAMETER  = 5'd22;


    reg [4:0] next_post_processing_state;
    always @(posedge clk ) begin
        if (~rst_n) begin
            post_processing_state <= PP_IDLE;
        end
        else begin
            post_processing_state <= next_post_processing_state;
        end
    end

    reg reset_control_parameter;

    always @(*) begin
        case (post_processing_state)
            PP_IDLE: begin
                if (qubit_ready & EVrandombit_ready & PArandombit_ready) begin
                    next_post_processing_state = PP_START;
                    Qubit_used = 1'b0;
                    EVrandombit_used = 1'b0;
                    PArandombit_used = 1'b0;
                    start_sifting = 1'b0;
                    start_ER = 1'b0;
                    start_accumulation = 1'b0;
                    start_PA = 1'b0;
                    request_valid = 1'b0;
                    reset_control_parameter = 1'b0;
                end
                else begin
                    next_post_processing_state = PP_IDLE;
                    Qubit_used = 1'b0;
                    EVrandombit_used = 1'b0;
                    PArandombit_used = 1'b0;
                    start_sifting = 1'b0;
                    start_ER = 1'b0;
                    start_accumulation = 1'b0;
                    start_PA = 1'b0;
                    request_valid = 1'b0;
                    reset_control_parameter = 1'b0;
                end
            end

            PP_START: begin
                next_post_processing_state = SIFTING_START;
                Qubit_used = 1'b0;
                EVrandombit_used = 1'b0;
                PArandombit_used = 1'b0;
                start_sifting = 1'b0;
                start_ER = 1'b0;
                start_accumulation = 1'b0;
                start_PA = 1'b0;
                request_valid = 1'b0;
                reset_control_parameter = 1'b0;
            end

            SIFTING_START: begin
                next_post_processing_state = SIFTING_BUSY;
                Qubit_used = 1'b1;
                EVrandombit_used = 1'b0;
                PArandombit_used = 1'b0;
                start_sifting = 1'b1;
                start_ER = 1'b0;
                start_accumulation = 1'b0;
                start_PA = 1'b0;
                request_valid = 1'b0;
                reset_control_parameter = 1'b0;
            end

            SIFTING_BUSY: begin
                if (finish_sifting) begin
                    next_post_processing_state = SIFTING_END;
                    Qubit_used = 1'b0;
                    EVrandombit_used = 1'b0;
                    PArandombit_used = 1'b0;
                    start_sifting = 1'b0;
                    start_ER = 1'b0;
                    start_accumulation = 1'b0;
                    start_PA = 1'b0;
                    request_valid = 1'b0;
                    reset_control_parameter = 1'b0;
                end
                else begin
                    next_post_processing_state = SIFTING_BUSY;
                    Qubit_used = 1'b0;
                    EVrandombit_used = 1'b0;
                    PArandombit_used = 1'b0;
                    start_sifting = 1'b0;
                    start_ER = 1'b0;
                    start_accumulation = 1'b0;
                    start_PA = 1'b0;
                    request_valid = 1'b0;
                    reset_control_parameter = 1'b0;
                end
            end

            SIFTING_END: begin
                next_post_processing_state = DETERMINE_ER;
                Qubit_used = 1'b0;
                EVrandombit_used = 1'b0;
                PArandombit_used = 1'b0;
                start_sifting = 1'b0;
                start_ER = 1'b0;
                start_accumulation = 1'b0;
                start_PA = 1'b0;
                request_valid = 1'b0;
                reset_control_parameter = 1'b0;
            end


            DETERMINE_ER: begin
                if (siftedkey_ready) begin
                    next_post_processing_state = ER_START;
                    Qubit_used = 1'b0;
                    EVrandombit_used = 1'b0;
                    PArandombit_used = 1'b0;
                    start_sifting = 1'b0;
                    start_ER = 1'b0;
                    start_accumulation = 1'b0;
                    start_PA = 1'b0;
                    request_valid = 1'b0;
                    reset_control_parameter = 1'b0;
                end
                else if (~siftedkey_ready) begin
                    next_post_processing_state = ER_IDLE;
                    Qubit_used = 1'b0;
                    EVrandombit_used = 1'b0;
                    PArandombit_used = 1'b0;
                    start_sifting = 1'b0;
                    start_ER = 1'b0;
                    start_accumulation = 1'b0;
                    start_PA = 1'b0;
                    request_valid = 1'b0;
                    reset_control_parameter = 1'b0;
                end
                else begin
                    next_post_processing_state = DETERMINE_ER;
                    Qubit_used = 1'b0;
                    EVrandombit_used = 1'b0;
                    PArandombit_used = 1'b0;
                    start_sifting = 1'b0;
                    start_ER = 1'b0;
                    start_accumulation = 1'b0;
                    start_PA = 1'b0;
                    request_valid = 1'b0;
                    reset_control_parameter = 1'b0;
                end
            end

            ER_IDLE: begin
                next_post_processing_state = REQUEST_VALID;
                Qubit_used = 1'b0;
                EVrandombit_used = 1'b0;
                PArandombit_used = 1'b0;
                start_sifting = 1'b0;
                start_ER = 1'b0;
                start_accumulation = 1'b0;
                start_PA = 1'b0;
                request_valid = 1'b0;
                reset_control_parameter = 1'b0;
            end

            ER_START: begin
                next_post_processing_state = ER_BUSY;
                Qubit_used = 1'b0;
                EVrandombit_used = 1'b1;
                PArandombit_used = 1'b0;
                start_sifting = 1'b0;
                start_ER = 1'b1;
                start_accumulation = 1'b0;
                start_PA = 1'b0;
                request_valid = 1'b0;
                reset_control_parameter = 1'b0;
            end

            ER_BUSY: begin
                if (finish_ER) begin
                    next_post_processing_state = ER_END;
                    Qubit_used = 1'b0;
                    EVrandombit_used = 1'b0;
                    PArandombit_used = 1'b0;
                    start_sifting = 1'b0;
                    start_ER = 1'b0;
                    start_accumulation = 1'b0;
                    start_PA = 1'b0;
                    request_valid = 1'b0;
                    reset_control_parameter = 1'b0;
                end
                else begin
                    next_post_processing_state = ER_BUSY;
                    Qubit_used = 1'b0;
                    EVrandombit_used = 1'b0;
                    PArandombit_used = 1'b0;
                    start_sifting = 1'b0;
                    start_ER = 1'b0;
                    start_accumulation = 1'b0;
                    start_PA = 1'b0;
                    request_valid = 1'b0;
                    reset_control_parameter = 1'b0;
                end
            end

            ER_END: begin
                next_post_processing_state = DETERMINE_PA;
                Qubit_used = 1'b0;
                EVrandombit_used = 1'b0;
                PArandombit_used = 1'b0;
                start_sifting = 1'b0;
                start_ER = 1'b0;
                start_accumulation = 1'b0;
                start_PA = 1'b0;
                request_valid = 1'b0;
                reset_control_parameter = 1'b0;
            end

            DETERMINE_PA: begin
                if (reconciledkey_ready) begin
                    next_post_processing_state = ACCUMULATION_START;
                    Qubit_used = 1'b0;
                    EVrandombit_used = 1'b0;
                    PArandombit_used = 1'b0;
                    start_sifting = 1'b0;
                    start_ER = 1'b0;
                    start_accumulation = 1'b0;
                    start_PA = 1'b0;
                    request_valid = 1'b0;
                    reset_control_parameter = 1'b0;
                end
                else if (~reconciledkey_ready) begin
                    next_post_processing_state = PA_IDLE;
                    Qubit_used = 1'b0;
                    EVrandombit_used = 1'b0;
                    PArandombit_used = 1'b0;
                    start_sifting = 1'b0;
                    start_ER = 1'b0;
                    start_accumulation = 1'b0;
                    start_PA = 1'b0;
                    request_valid = 1'b0;
                    reset_control_parameter = 1'b0;
                end
                else begin
                    next_post_processing_state = DETERMINE_PA;
                    Qubit_used = 1'b0;
                    EVrandombit_used = 1'b0;
                    PArandombit_used = 1'b0;
                    start_sifting = 1'b0;
                    start_ER = 1'b0;
                    start_accumulation = 1'b0;
                    start_PA = 1'b0;
                    request_valid = 1'b0;
                    reset_control_parameter = 1'b0;
                end
            end


            PA_IDLE: begin
                next_post_processing_state = REQUEST_VALID;
                Qubit_used = 1'b0;
                EVrandombit_used = 1'b0;
                PArandombit_used = 1'b0;
                start_sifting = 1'b0;
                start_ER = 1'b0;
                start_accumulation = 1'b0;
                start_PA = 1'b0;
                request_valid = 1'b0;
                reset_control_parameter = 1'b0;
            end


            ACCUMULATION_START: begin
                next_post_processing_state = WAIT_ACCUMULATE_BUSY;
                Qubit_used = 1'b0;
                EVrandombit_used = 1'b0;
                PArandombit_used = 1'b0;
                start_sifting = 1'b0;
                start_ER = 1'b0;
                start_accumulation = 1'b1;
                start_PA = 1'b0;
                request_valid = 1'b0;
                reset_control_parameter = 1'b0;
            end

            WAIT_ACCUMULATE_BUSY: begin
                if (accumulate_busy) begin
                    next_post_processing_state = KEYLENGTH_CAL_BUSY;
                    Qubit_used = 1'b0;
                    EVrandombit_used = 1'b0;
                    PArandombit_used = 1'b0;
                    start_sifting = 1'b0;
                    start_ER = 1'b0;
                    start_accumulation = 1'b1;
                    start_PA = 1'b0;
                    request_valid = 1'b0;
                    reset_control_parameter = 1'b0;
                end
                else begin
                    next_post_processing_state = WAIT_ACCUMULATE_BUSY;
                    Qubit_used = 1'b0;
                    EVrandombit_used = 1'b0;
                    PArandombit_used = 1'b0;
                    start_sifting = 1'b0;
                    start_ER = 1'b0;
                    start_accumulation = 1'b1;
                    start_PA = 1'b0;
                    request_valid = 1'b0;
                    reset_control_parameter = 1'b0;
                end
            end



            KEYLENGTH_CAL_BUSY: begin
                if (keylength_valid) begin
                    next_post_processing_state = KEYLENGTH_VALID;
                    Qubit_used = 1'b0;
                    EVrandombit_used = 1'b0;
                    PArandombit_used = 1'b0;
                    start_sifting = 1'b0;
                    start_ER = 1'b0;
                    start_accumulation = 1'b0;
                    start_PA = 1'b0;
                    request_valid = 1'b0;
                    reset_control_parameter = 1'b0;
                end
                else begin
                    next_post_processing_state = KEYLENGTH_CAL_BUSY;
                    Qubit_used = 1'b0;
                    EVrandombit_used = 1'b0;
                    PArandombit_used = 1'b0;
                    start_sifting = 1'b0;
                    start_ER = 1'b0;
                    start_accumulation = 1'b0;
                    start_PA = 1'b0;
                    request_valid = 1'b0;
                    reset_control_parameter = 1'b0;
                end
            end

            KEYLENGTH_VALID: begin
                next_post_processing_state = PA_START;
                Qubit_used = 1'b0;
                EVrandombit_used = 1'b0;
                PArandombit_used = 1'b0;
                start_sifting = 1'b0;
                start_ER = 1'b0;
                start_accumulation = 1'b0;
                start_PA = 1'b0;
                request_valid = 1'b0;
                reset_control_parameter = 1'b0;
            end

            PA_START: begin
                next_post_processing_state = PA_BUSY;
                Qubit_used = 1'b0;
                EVrandombit_used = 1'b0;
                PArandombit_used = 1'b1;
                start_sifting = 1'b0;
                start_ER = 1'b0;
                start_accumulation = 1'b0;
                start_PA = 1'b1;
                request_valid = 1'b0;
                reset_control_parameter = 1'b0;
            end

            PA_BUSY: begin
                if (finish_PA) begin
                    next_post_processing_state = PA_END;
                    Qubit_used = 1'b0;
                    EVrandombit_used = 1'b0;
                    PArandombit_used = 1'b0;
                    start_sifting = 1'b0;
                    start_ER = 1'b0;
                    start_accumulation = 1'b0;
                    start_PA = 1'b0;
                    request_valid = 1'b0;
                    reset_control_parameter = 1'b0;
                end
                else begin
                    next_post_processing_state = PA_BUSY;
                    Qubit_used = 1'b0;
                    EVrandombit_used = 1'b0;
                    PArandombit_used = 1'b0;
                    start_sifting = 1'b0;
                    start_ER = 1'b0;
                    start_accumulation = 1'b0;
                    start_PA = 1'b0;
                    request_valid = 1'b0;
                    reset_control_parameter = 1'b0;
                end
            end


            PA_END: begin
                next_post_processing_state = REQUEST_VALID;
                Qubit_used = 1'b0;
                EVrandombit_used = 1'b0;
                PArandombit_used = 1'b0;
                start_sifting = 1'b0;
                start_ER = 1'b0;
                start_accumulation = 1'b0;
                start_PA = 1'b0;
                request_valid = 1'b0;
                reset_control_parameter = 1'b0;
            end

            REQUEST_VALID: begin
                next_post_processing_state = WAIT_NEW_ROUND;
                Qubit_used = 1'b0;
                EVrandombit_used = 1'b0;
                PArandombit_used = 1'b0;
                start_sifting = 1'b0;
                start_ER = 1'b0;
                start_accumulation = 1'b0;
                start_PA = 1'b0;
                request_valid = 1'b1;
                reset_control_parameter = 1'b0;
            end

            WAIT_NEW_ROUND: begin
                if (new_round) begin
                    next_post_processing_state = NEW_ROUND;
                    Qubit_used = 1'b0;
                    EVrandombit_used = 1'b0;
                    PArandombit_used = 1'b0;
                    start_sifting = 1'b0;
                    start_ER = 1'b0;
                    start_accumulation = 1'b0;
                    start_PA = 1'b0;
                    request_valid = 1'b0;
                    reset_control_parameter = 1'b0;
                end
                else begin
                    next_post_processing_state = WAIT_NEW_ROUND;
                    Qubit_used = 1'b0;
                    EVrandombit_used = 1'b0;
                    PArandombit_used = 1'b0;
                    start_sifting = 1'b0;
                    start_ER = 1'b0;
                    start_accumulation = 1'b0;
                    start_PA = 1'b0;
                    request_valid = 1'b0;
                    reset_control_parameter = 1'b0;
                end
            end


            NEW_ROUND: begin
                next_post_processing_state = RESET_CONTROL_PARAMETER;
                Qubit_used = 1'b0;
                EVrandombit_used = 1'b0;
                PArandombit_used = 1'b0;
                start_sifting = 1'b0;
                start_ER = 1'b0;
                start_accumulation = 1'b0;
                start_PA = 1'b0;
                request_valid = 1'b0;
                reset_control_parameter = 1'b0;
            end

            RESET_CONTROL_PARAMETER: begin
                next_post_processing_state = PP_IDLE;
                Qubit_used = 1'b0;
                EVrandombit_used = 1'b0;
                PArandombit_used = 1'b0;
                start_sifting = 1'b0;
                start_ER = 1'b0;
                start_accumulation = 1'b0;
                start_PA = 1'b0;
                request_valid = 1'b0;
                reset_control_parameter = 1'b1;
            end




            default: begin
                next_post_processing_state = PP_IDLE;
                Qubit_used = 1'b0;
                EVrandombit_used = 1'b0;
                PArandombit_used = 1'b0;
                start_sifting = 1'b0;
                start_ER = 1'b0;
                start_accumulation = 1'b0;
                start_PA = 1'b0;
                request_valid = 1'b0;
                reset_control_parameter = 1'b0;
            end
        endcase
    end
    
//****************************** fsm ******************************



















endmodule