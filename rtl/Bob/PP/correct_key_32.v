




`include "./error_reconcilation_parameter.v"

module correct_key_32 (
    input clk,
    input rst_n,

    input [31:0] loading_key,
    input [`CASCADE_KEY_32_DEPTH-1:0] loading_key_sel,

    input shuffle_en,
    input inv_shuffle_en,
    input [2:0] shuffle_set_sel,

    output reg [`CASCADE_KEY_LENGTH-1:0] correct_key

);


    wire [`CASCADE_KEY_LENGTH-1:0]  shuffle_key_2 , shuffle_key_3 , shuffle_key_4;
    wire [`CASCADE_KEY_LENGTH-1:0]  inv_shuffle_key_2 , inv_shuffle_key_3, inv_shuffle_key_4;

    integer i;



    always @(posedge clk ) begin
        for (i = 0; i<`CASCADE_KEY_32_DEPTH; i=i+1) begin
            if(~rst_n) begin
                correct_key[(i<<5) +: 32] <= 32'b0;
            end
            else if(loading_key_sel[i]) begin
                correct_key[(i<<5) +: 32] <= loading_key;
            end
            else if (shuffle_en&&(shuffle_set_sel==3'd2)) begin
                correct_key[(i<<5) +: 32] <= shuffle_key_2[(i<<5) +: 32];
            end
            else if (shuffle_en&&(shuffle_set_sel==3'd3)) begin
                correct_key[(i<<5) +: 32] <= shuffle_key_3[(i<<5) +: 32];
            end
            else if (shuffle_en&&(shuffle_set_sel==3'd4)) begin
                correct_key[(i<<5) +: 32] <= shuffle_key_4[(i<<5) +: 32];
            end
            else if (inv_shuffle_en&&(shuffle_set_sel==3'd2)) begin
                correct_key[(i<<5) +: 32] <= inv_shuffle_key_2[(i<<5) +: 32];
            end
            else if (inv_shuffle_en&&(shuffle_set_sel==3'd3)) begin
                correct_key[(i<<5) +: 32] <= inv_shuffle_key_3[(i<<5) +: 32];
            end
            else if (inv_shuffle_en&&(shuffle_set_sel==3'd4)) begin
                correct_key[(i<<5) +: 32] <= inv_shuffle_key_4[(i<<5) +: 32];
            end
            else begin
                correct_key[(i<<5) +: 32] <= correct_key[(i<<5) +: 32];
            end
        end
    end



    shuffle_invshuffle shuffle_and_invshuffle_32(
        .original_key(correct_key),


        .shuffle_key_2(shuffle_key_2),
        .shuffle_key_3(shuffle_key_3),
        .shuffle_key_4(shuffle_key_4),

        .inv_shuffle_key_2(inv_shuffle_key_2),
        .inv_shuffle_key_3(inv_shuffle_key_3),
        .inv_shuffle_key_4(inv_shuffle_key_4)

    );




endmodule






