`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/05/26 03:18:19
// Design Name: 
// Module Name: B_matlab_FSM
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


module B_matlab_FSM (
    input clk,
    input rst_n,

    input start_switch,
    input write_input_bram_finish,
    input [63:0] B_AXImanager_PORTA_dout_ff,
    input read_secretkey_1_finish,
    input read_secretkey_2_finish,

    output reg write_input_bram_en,
    output reg read_secretkey_1_en,
    output reg read_secretkey_2_en,
    output reg write_ready_state_en,
    output reg write_idle_state_en,

    output wire reset_cnt,
    output reg [4:0] B_matlab_state
);

    localparam QKD_IDLE                 = 5'd0;
    localparam QKD_START                = 5'd1;
    localparam WRITE_INPUT_BRAM         = 5'd2;
    localparam WRITE_INPUT_BRAM_END     = 5'd3;
    localparam WRITE_INIT_IDLE          = 5'd16;

    localparam AXIMANAGER_IDLE          = 5'd4;
    localparam SECRETKEY_1_READ         = 5'd13;
    localparam SECRETKEY_2_READ         = 5'd14;
    localparam SECRETKEY_READ_END       = 5'd15;
    localparam PREPARE_INPUT            = 5'd6;
    localparam FAKE_WRITE               = 5'd7;
    localparam FAKE_WRITE_END           = 5'd8;

    localparam WRITE_READY_STATE        = 5'd9;
    localparam WAIT_IDLE_STATE          = 5'd10;
    localparam WRITE_IDLE_STATE         = 5'd11;
    localparam FINISH                   = 5'd12;

    localparam TEST_END                 = 5'd31;

    assign reset_cnt = (B_matlab_state==FINISH)? 1'b01:1'b0;

    reg test_end;

    always @(posedge clk ) begin
        if (~rst_n) begin
            test_end <= 0;
        end
        else if ((B_matlab_state==SECRETKEY_2_READ) && read_secretkey_2_finish) begin
            test_end <= 1;
        end
        else begin
            test_end <= test_end;
        end
    end


    reg [4:0] next_B_matlab_state;
    always @(posedge clk ) begin
        if (~rst_n) begin
            B_matlab_state <= QKD_IDLE;
        end
        else begin
            B_matlab_state <= next_B_matlab_state;
        end
    end

    always @(*) begin
        case (B_matlab_state)
            QKD_IDLE: begin
                if (start_switch) begin
                    next_B_matlab_state = QKD_START;
                    write_input_bram_en = 1'b0;
                    write_ready_state_en = 1'b0;
                    write_idle_state_en = 1'b0;
                    read_secretkey_1_en = 1'b0;
                    read_secretkey_2_en = 1'b0;
                end
                else begin
                    next_B_matlab_state = QKD_IDLE;
                    write_input_bram_en = 1'b0;
                    write_ready_state_en = 1'b0;
                    write_idle_state_en = 1'b0;
                    read_secretkey_1_en = 1'b0;
                    read_secretkey_2_en = 1'b0;
                end
            end

            QKD_START: begin
                next_B_matlab_state = WRITE_INPUT_BRAM;
                write_input_bram_en = 1'b0;
                write_ready_state_en = 1'b0;
                write_idle_state_en = 1'b0;
                read_secretkey_1_en = 1'b0;
                read_secretkey_2_en = 1'b0;
            end

            WRITE_INPUT_BRAM: begin
                if (write_input_bram_finish) begin
                    next_B_matlab_state = WRITE_INPUT_BRAM_END;
                    write_input_bram_en = 1'b1;
                    write_ready_state_en = 1'b0;
                    write_idle_state_en = 1'b0;
                    read_secretkey_1_en = 1'b0;
                    read_secretkey_2_en = 1'b0;
                end
                else begin
                    next_B_matlab_state = WRITE_INPUT_BRAM;
                    write_input_bram_en = 1'b1;
                    write_ready_state_en = 1'b0;
                    write_idle_state_en = 1'b0;
                    read_secretkey_1_en = 1'b0;
                    read_secretkey_2_en = 1'b0;
                end
            end

            WRITE_INPUT_BRAM_END: begin
                next_B_matlab_state = WRITE_INIT_IDLE;
                write_input_bram_en = 1'b0;
                write_ready_state_en = 1'b0;
                write_idle_state_en = 1'b0;
                read_secretkey_1_en = 1'b0;
                read_secretkey_2_en = 1'b0;
            end

            WRITE_INIT_IDLE: begin
                next_B_matlab_state = AXIMANAGER_IDLE;
                write_input_bram_en = 1'b0;
                write_ready_state_en = 1'b0;
                write_idle_state_en = 1'b1;
                read_secretkey_1_en = 1'b0;
                read_secretkey_2_en = 1'b0;
            end


            AXIMANAGER_IDLE: begin
                if (B_AXImanager_PORTA_dout_ff[11:8]==`REQUEST_STATE) begin
                    next_B_matlab_state = SECRETKEY_1_READ;
                    write_input_bram_en = 1'b0;
                    write_ready_state_en = 1'b0;
                    write_idle_state_en = 1'b0;
                    read_secretkey_1_en = 1'b0;
                    read_secretkey_2_en = 1'b0;
                end
                else if (B_AXImanager_PORTA_dout_ff[7:4]==`REQUEST_STATE) begin
                    next_B_matlab_state = SECRETKEY_2_READ;
                    write_input_bram_en = 1'b0;
                    write_ready_state_en = 1'b0;
                    write_idle_state_en = 1'b0;
                    read_secretkey_1_en = 1'b0;
                    read_secretkey_2_en = 1'b0;
                end

                else if ((B_AXImanager_PORTA_dout_ff[15:12]==`REQUEST_STATE) ||
                         (B_AXImanager_PORTA_dout_ff[19:16]==`REQUEST_STATE)) begin
                    next_B_matlab_state = PREPARE_INPUT;
                    write_input_bram_en = 1'b0;
                    write_ready_state_en = 1'b0;
                    write_idle_state_en = 1'b0;
                    read_secretkey_1_en = 1'b0;
                    read_secretkey_2_en = 1'b0;
                end

                else begin
                    next_B_matlab_state = AXIMANAGER_IDLE;
                    write_input_bram_en = 1'b0;
                    write_ready_state_en = 1'b0;
                    write_idle_state_en = 1'b0;
                    read_secretkey_1_en = 1'b0;
                    read_secretkey_2_en = 1'b0;
                end
            end


            SECRETKEY_1_READ: begin
                if (read_secretkey_1_finish) begin
                    next_B_matlab_state = SECRETKEY_READ_END;
                    write_input_bram_en = 1'b0;
                    write_ready_state_en = 1'b0;
                    write_idle_state_en = 1'b0;
                    read_secretkey_1_en = 1'b1;
                    read_secretkey_2_en = 1'b0;
                end
                else begin
                    next_B_matlab_state = SECRETKEY_1_READ;
                    write_input_bram_en = 1'b0;
                    write_ready_state_en = 1'b0;
                    write_idle_state_en = 1'b0;
                    read_secretkey_1_en = 1'b1;
                    read_secretkey_2_en = 1'b0;
                end
            end

            SECRETKEY_2_READ: begin
                if (read_secretkey_2_finish) begin
                    next_B_matlab_state = SECRETKEY_READ_END;
                    write_input_bram_en = 1'b0;
                    write_ready_state_en = 1'b0;
                    write_idle_state_en = 1'b0;
                    read_secretkey_1_en = 1'b0;
                    read_secretkey_2_en = 1'b1;
                end
                else begin
                    next_B_matlab_state = SECRETKEY_2_READ;
                    write_input_bram_en = 1'b0;
                    write_ready_state_en = 1'b0;
                    write_idle_state_en = 1'b0;
                    read_secretkey_1_en = 1'b0;
                    read_secretkey_2_en = 1'b1;
                end
            end

            
            SECRETKEY_READ_END: begin
                if (test_end) begin
                    next_B_matlab_state = TEST_END;
                    write_input_bram_en = 1'b0;
                    write_ready_state_en = 1'b0;
                    write_idle_state_en = 1'b0;
                    read_secretkey_1_en = 1'b0;
                    read_secretkey_2_en = 1'b0;
                end

                else if ((B_AXImanager_PORTA_dout_ff[15:12]==`REQUEST_STATE) ||
                    (B_AXImanager_PORTA_dout_ff[19:16]==`REQUEST_STATE)) begin
                    next_B_matlab_state = PREPARE_INPUT;
                    write_input_bram_en = 1'b0;
                    write_ready_state_en = 1'b0;
                    write_idle_state_en = 1'b0;
                    read_secretkey_1_en = 1'b0;
                    read_secretkey_2_en = 1'b0;
                end

                else begin
                    next_B_matlab_state = FAKE_WRITE_END;
                    write_input_bram_en = 1'b0;
                    write_ready_state_en = 1'b0;
                    write_idle_state_en = 1'b0;
                    read_secretkey_1_en = 1'b0;
                    read_secretkey_2_en = 1'b0;
                end
            end


            PREPARE_INPUT: begin
                next_B_matlab_state = FAKE_WRITE;
                write_input_bram_en = 1'b0;
                write_ready_state_en = 1'b0;
                write_idle_state_en = 1'b0;
                read_secretkey_1_en = 1'b0;
                read_secretkey_2_en = 1'b0;
            end

            FAKE_WRITE: begin
                next_B_matlab_state = FAKE_WRITE_END;
                write_input_bram_en = 1'b0;
                write_ready_state_en = 1'b0;
                write_idle_state_en = 1'b0;
                read_secretkey_1_en = 1'b0;
                read_secretkey_2_en = 1'b0;
            end

            FAKE_WRITE_END: begin
                next_B_matlab_state = WRITE_READY_STATE;
                write_input_bram_en = 1'b0;
                write_ready_state_en = 1'b0;
                write_idle_state_en = 1'b0;
                read_secretkey_1_en = 1'b0;
                read_secretkey_2_en = 1'b0;
            end

            WRITE_READY_STATE: begin
                next_B_matlab_state = WAIT_IDLE_STATE;
                write_input_bram_en = 1'b0;
                write_ready_state_en = 1'b1;
                write_idle_state_en = 1'b0;
                read_secretkey_1_en = 1'b0;
                read_secretkey_2_en = 1'b0;
            end

            WAIT_IDLE_STATE: begin
                if ((B_AXImanager_PORTA_dout_ff[3:0]==`WRITER_KCU116) &&
                    (B_AXImanager_PORTA_dout_ff[7:4]==`IDLE_STATE) &&
                    (B_AXImanager_PORTA_dout_ff[11:8]==`IDLE_STATE) &&
                    (B_AXImanager_PORTA_dout_ff[15:12]==`IDLE_STATE) &&
                    (B_AXImanager_PORTA_dout_ff[19:16]==`IDLE_STATE)) begin

                    next_B_matlab_state = WRITE_IDLE_STATE;
                    write_input_bram_en = 1'b0;
                    write_ready_state_en = 1'b0;
                    write_idle_state_en = 1'b0;
                    read_secretkey_1_en = 1'b0;
                    read_secretkey_2_en = 1'b0;
                end
                else begin
                    next_B_matlab_state = WAIT_IDLE_STATE;
                    write_input_bram_en = 1'b0;
                    write_ready_state_en = 1'b0;
                    write_idle_state_en = 1'b0;
                    read_secretkey_1_en = 1'b0;
                    read_secretkey_2_en = 1'b0;
                end
            end   

            WRITE_IDLE_STATE: begin
                next_B_matlab_state = FINISH;
                write_input_bram_en = 1'b0;
                write_ready_state_en = 1'b0;
                write_idle_state_en = 1'b1;
                read_secretkey_1_en = 1'b0;
                read_secretkey_2_en = 1'b0;
            end

            FINISH: begin
                next_B_matlab_state = QKD_IDLE;
                write_input_bram_en = 1'b0;
                write_ready_state_en = 1'b0;
                write_idle_state_en = 1'b0;
                read_secretkey_1_en = 1'b0;
                read_secretkey_2_en = 1'b0;
            end


            TEST_END: begin
                next_B_matlab_state = TEST_END;
                write_input_bram_en = 1'b0;
                write_ready_state_en = 1'b0;
                write_idle_state_en = 1'b0;
                read_secretkey_1_en = 1'b0;
                read_secretkey_2_en = 1'b0;
            end



            default: begin
                next_B_matlab_state = QKD_IDLE;
                write_input_bram_en = 1'b0;
                write_ready_state_en = 1'b0;
                write_idle_state_en = 1'b0;
                read_secretkey_1_en = 1'b0;
                read_secretkey_2_en = 1'b0;
            end
        endcase
    end


    
endmodule
