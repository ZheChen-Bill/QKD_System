



module B_post_processing_control (
    input clk,
    input rst_n,

    // AXI manager request & ready
    output reg request_valid,
    input wire new_round,

    input wire Xbasis_detected_pos_ready,
    output reg Xbasis_detected_pos_request,

    input wire Zbasis_detected_pos_ready,
    output reg Zbasis_detected_pos_request,

    output reg secretkey_1_request,
    output reg secretkey_2_request,




    // sifting
    output reg start_sifting,
    input wire finish_sifting,
    // ER
    output reg start_ER,
    output reg sifted_key_addr_index,
    input wire finish_ER,
    // PA
    output reg start_PA,
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
    reg Xbasis_detected_pos_used;
    reg Zbasis_detected_pos_used;

    always @(posedge clk ) begin
        if (~rst_n) begin
            Xbasis_detected_pos_request <= 0;
        end
        else if (reset_control_parameter) begin
            Xbasis_detected_pos_request <= 0;
        end
        else if (Xbasis_detected_pos_used) begin
            Xbasis_detected_pos_request <= 1;
        end
        else begin
            Xbasis_detected_pos_request <= Xbasis_detected_pos_request;
        end
    end

    always @(posedge clk ) begin
        if (~rst_n) begin
            Zbasis_detected_pos_request <= 0;
        end
        else if (reset_control_parameter) begin
            Zbasis_detected_pos_request <= 0;
        end
        else if (Zbasis_detected_pos_used) begin
            Zbasis_detected_pos_request <= 1;
        end
        else begin
            Zbasis_detected_pos_request <= Zbasis_detected_pos_request;
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
                if (Xbasis_detected_pos_ready & Zbasis_detected_pos_ready) begin
                    next_post_processing_state = PP_START;
                    Xbasis_detected_pos_used = 1'b0;
                    Zbasis_detected_pos_used = 1'b0;
                    start_sifting = 1'b0;
                    start_ER = 1'b0;
                    start_PA = 1'b0;
                    request_valid = 1'b0;
                    reset_control_parameter = 1'b0;
                end
                else begin
                    next_post_processing_state = PP_IDLE;
                    Xbasis_detected_pos_used = 1'b0;
                    Zbasis_detected_pos_used = 1'b0;
                    start_sifting = 1'b0;
                    start_ER = 1'b0;
                    start_PA = 1'b0;
                    request_valid = 1'b0;
                    reset_control_parameter = 1'b0;
                end
            end

            PP_START: begin
                next_post_processing_state = SIFTING_START;
                Xbasis_detected_pos_used = 1'b0;
                Zbasis_detected_pos_used = 1'b0;
                start_sifting = 1'b0;
                start_ER = 1'b0;
                start_PA = 1'b0;
                request_valid = 1'b0;
                reset_control_parameter = 1'b0;
            end

            SIFTING_START: begin
                next_post_processing_state = SIFTING_BUSY;
                Xbasis_detected_pos_used = 1'b1;
                Zbasis_detected_pos_used = 1'b1;
                start_sifting = 1'b1;
                start_ER = 1'b0;
                start_PA = 1'b0;
                request_valid = 1'b0;
                reset_control_parameter = 1'b0;
            end

            SIFTING_BUSY: begin
                if (finish_sifting) begin
                    next_post_processing_state = SIFTING_END;
                    Xbasis_detected_pos_used = 1'b0;
                    Zbasis_detected_pos_used = 1'b0;
                    start_sifting = 1'b0;
                    start_ER = 1'b0;
                    start_PA = 1'b0;
                    request_valid = 1'b0;
                    reset_control_parameter = 1'b0;
                end
                else begin
                    next_post_processing_state = SIFTING_BUSY;
                    Xbasis_detected_pos_used = 1'b0;
                    Zbasis_detected_pos_used = 1'b0;
                    start_sifting = 1'b0;
                    start_ER = 1'b0;
                    start_PA = 1'b0;
                    request_valid = 1'b0;
                    reset_control_parameter = 1'b0;
                end
            end

            SIFTING_END: begin
                next_post_processing_state = DETERMINE_ER;
                Xbasis_detected_pos_used = 1'b0;
                Zbasis_detected_pos_used = 1'b0;
                start_sifting = 1'b0;
                start_ER = 1'b0;
                start_PA = 1'b0;
                request_valid = 1'b0;
                reset_control_parameter = 1'b0;
            end


            DETERMINE_ER: begin
                if (siftedkey_ready) begin
                    next_post_processing_state = ER_START;
                    Xbasis_detected_pos_used = 1'b0;
                    Zbasis_detected_pos_used = 1'b0;
                    start_sifting = 1'b0;
                    start_ER = 1'b0;
                    start_PA = 1'b0;
                    request_valid = 1'b0;
                    reset_control_parameter = 1'b0;
                end
                else if (~siftedkey_ready) begin
                    next_post_processing_state = ER_IDLE;
                    Xbasis_detected_pos_used = 1'b0;
                    Zbasis_detected_pos_used = 1'b0;
                    start_sifting = 1'b0;
                    start_ER = 1'b0;
                    start_PA = 1'b0;
                    request_valid = 1'b0;
                    reset_control_parameter = 1'b0;
                end
                else begin
                    next_post_processing_state = DETERMINE_ER;
                    Xbasis_detected_pos_used = 1'b0;
                    Zbasis_detected_pos_used = 1'b0;
                    start_sifting = 1'b0;
                    start_ER = 1'b0;
                    start_PA = 1'b0;
                    request_valid = 1'b0;
                    reset_control_parameter = 1'b0;
                end
            end


            ER_IDLE: begin
                next_post_processing_state = REQUEST_VALID;
                Xbasis_detected_pos_used = 1'b0;
                Zbasis_detected_pos_used = 1'b0;
                start_sifting = 1'b0;
                start_ER = 1'b0;
                start_PA = 1'b0;
                request_valid = 1'b0;
                reset_control_parameter = 1'b0;
            end

            ER_START: begin
                next_post_processing_state = ER_BUSY;
                Xbasis_detected_pos_used = 1'b0;
                Zbasis_detected_pos_used = 1'b0;
                start_sifting = 1'b0;
                start_ER = 1'b1;
                start_PA = 1'b0;
                request_valid = 1'b0;
                reset_control_parameter = 1'b0;
            end

            ER_BUSY: begin
                if (finish_ER) begin
                    next_post_processing_state = ER_END;
                    Xbasis_detected_pos_used = 1'b0;
                    Zbasis_detected_pos_used = 1'b0;
                    start_sifting = 1'b0;
                    start_ER = 1'b0;
                    start_PA = 1'b0;
                    request_valid = 1'b0;
                    reset_control_parameter = 1'b0;
                end
                else begin
                    next_post_processing_state = ER_BUSY;
                    Xbasis_detected_pos_used = 1'b0;
                    Zbasis_detected_pos_used = 1'b0;
                    start_sifting = 1'b0;
                    start_ER = 1'b0;
                    start_PA = 1'b0;
                    request_valid = 1'b0;
                    reset_control_parameter = 1'b0;
                end
            end

            ER_END: begin
                next_post_processing_state = DETERMINE_PA;
                Xbasis_detected_pos_used = 1'b0;
                Zbasis_detected_pos_used = 1'b0;
                start_sifting = 1'b0;
                start_ER = 1'b0;
                start_PA = 1'b0;
                request_valid = 1'b0;
                reset_control_parameter = 1'b0;
            end

            DETERMINE_PA: begin
                if (reconciledkey_ready) begin
                    next_post_processing_state = PA_START;
                    Xbasis_detected_pos_used = 1'b0;
                    Zbasis_detected_pos_used = 1'b0;
                    start_sifting = 1'b0;
                    start_ER = 1'b0;
                    start_PA = 1'b0;
                    request_valid = 1'b0;
                    reset_control_parameter = 1'b0;
                end
                else if (~reconciledkey_ready) begin
                    next_post_processing_state = PA_IDLE;
                    Xbasis_detected_pos_used = 1'b0;
                    Zbasis_detected_pos_used = 1'b0;
                    start_sifting = 1'b0;
                    start_ER = 1'b0;
                    start_PA = 1'b0;
                    request_valid = 1'b0;
                    reset_control_parameter = 1'b0;
                end
                else begin
                    next_post_processing_state = DETERMINE_PA;
                    Xbasis_detected_pos_used = 1'b0;
                    Zbasis_detected_pos_used = 1'b0;
                    start_sifting = 1'b0;
                    start_ER = 1'b0;
                    start_PA = 1'b0;
                    request_valid = 1'b0;
                    reset_control_parameter = 1'b0;
                end
            end


            PA_IDLE: begin
                next_post_processing_state = REQUEST_VALID;
                Xbasis_detected_pos_used = 1'b0;
                Zbasis_detected_pos_used = 1'b0;
                start_sifting = 1'b0;
                start_ER = 1'b0;
                start_PA = 1'b0;
                request_valid = 1'b0;
                reset_control_parameter = 1'b0;
            end



            PA_START: begin
                next_post_processing_state = PA_BUSY;
                Xbasis_detected_pos_used = 1'b0;
                Zbasis_detected_pos_used = 1'b0;
                start_sifting = 1'b0;
                start_ER = 1'b0;
                start_PA = 1'b1;
                request_valid = 1'b0;
                reset_control_parameter = 1'b0;
            end

            PA_BUSY: begin
                if (finish_PA) begin
                    next_post_processing_state = PA_END;
                    Xbasis_detected_pos_used = 1'b0;
                    Zbasis_detected_pos_used = 1'b0;
                    start_sifting = 1'b0;
                    start_ER = 1'b0;
                    start_PA = 1'b0;
                    request_valid = 1'b0;
                    reset_control_parameter = 1'b0;
                end
                else begin
                    next_post_processing_state = PA_BUSY;
                    Xbasis_detected_pos_used = 1'b0;
                    Zbasis_detected_pos_used = 1'b0;
                    start_sifting = 1'b0;
                    start_ER = 1'b0;
                    start_PA = 1'b0;
                    request_valid = 1'b0;
                    reset_control_parameter = 1'b0;
                end
            end


            PA_END: begin
                next_post_processing_state = REQUEST_VALID;
                Xbasis_detected_pos_used = 1'b0;
                Zbasis_detected_pos_used = 1'b0;
                start_sifting = 1'b0;
                start_ER = 1'b0;
                start_PA = 1'b0;
                request_valid = 1'b0;
                reset_control_parameter = 1'b0;
            end

            REQUEST_VALID: begin
                next_post_processing_state = WAIT_NEW_ROUND;
                Xbasis_detected_pos_used = 1'b0;
                Zbasis_detected_pos_used = 1'b0;
                start_sifting = 1'b0;
                start_ER = 1'b0;
                start_PA = 1'b0;
                request_valid = 1'b1;
                reset_control_parameter = 1'b0;
            end

            WAIT_NEW_ROUND: begin
                if (new_round) begin
                    next_post_processing_state = NEW_ROUND;
                    Xbasis_detected_pos_used = 1'b0;
                    Zbasis_detected_pos_used = 1'b0;
                    start_sifting = 1'b0;
                    start_ER = 1'b0;
                    start_PA = 1'b0;
                    request_valid = 1'b0;
                    reset_control_parameter = 1'b0;
                end
                else begin
                    next_post_processing_state = WAIT_NEW_ROUND;
                    Xbasis_detected_pos_used = 1'b0;
                    Zbasis_detected_pos_used = 1'b0;
                    start_sifting = 1'b0;
                    start_ER = 1'b0;
                    start_PA = 1'b0;
                    request_valid = 1'b0;
                    reset_control_parameter = 1'b0;
                end
            end


            NEW_ROUND: begin
                next_post_processing_state = RESET_CONTROL_PARAMETER;
                Xbasis_detected_pos_used = 1'b0;
                Zbasis_detected_pos_used = 1'b0;
                start_sifting = 1'b0;
                start_ER = 1'b0;
                start_PA = 1'b0;
                request_valid = 1'b0;
                reset_control_parameter = 1'b0;
            end

            RESET_CONTROL_PARAMETER: begin
                next_post_processing_state = PP_IDLE;
                Xbasis_detected_pos_used = 1'b0;
                Zbasis_detected_pos_used = 1'b0;
                start_sifting = 1'b0;
                start_ER = 1'b0;
                start_PA = 1'b0;
                request_valid = 1'b0;
                reset_control_parameter = 1'b1;
            end




            default: begin
                next_post_processing_state = PP_IDLE;
                Xbasis_detected_pos_used = 1'b0;
                Zbasis_detected_pos_used = 1'b0;
                start_sifting = 1'b0;
                start_ER = 1'b0;
                start_PA = 1'b0;
                request_valid = 1'b0;
                reset_control_parameter = 1'b0;
            end
        endcase
    end
    
//****************************** fsm ******************************



















endmodule