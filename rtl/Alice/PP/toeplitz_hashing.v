

/*
`include "./packet_parameter.v"
`include "./error_reconcilation_parameter.v"
*/







module ev_toeplitz_hashing(
    input clk,                              //clk
    input rst_n,                            //reset

    input [`EV_W-1:0] random_bit,              //random bit(0 or 1) series for hashing 
    input [`EV_W-1:0] key_bit,                 //reconciliation key
    input shift_en,                         //shift control
    input key_en,                           //key control

    output [`EV_HASHTAG_WIDTH-1:0] hash_tag      //output hash tag for error verification

);









//****************************** shift random bits ******************************
    //64 random_bit * 2
    // (K + W) bit shift reg = 64+64 = 128
    wire [(`EV_K+`EV_W-1):0] shift_random_bit;


//****************************** shift random bits ******************************





//****************************** MAC input ******************************
    //64 random_bit * 64
    wire [`EV_W-1:0]   mac_input   [0:`EV_K-1];


/*
    assign mac_input[`EV_K-64][`EV_W-1:0] = shift_random_bit[64:1];
    assign mac_input[`EV_K-63][`EV_W-1:0] = shift_random_bit[65:2];
    assign mac_input[`EV_K-62][`EV_W-1:0] = shift_random_bit[66:3];
    assign mac_input[`EV_K-61][`EV_W-1:0] = shift_random_bit[67:4];
    .
    .
    .
    assign mac_input[`EV_K-1][`EV_W-1:0] = shift_random_bit[127:64];
*/

    genvar i;
    generate
        for (i=0 ; i<`EV_K ; i=i+1) begin
            assign mac_input[i][`EV_W-1:0] = {shift_random_bit[(i+1) +: `EV_W]};
        end
    endgenerate




//****************************** MAC input ******************************





//****************************** MAC instantiation ******************************
    genvar mac_idx;
    generate
        for (mac_idx=0 ; mac_idx<`EV_K ; mac_idx=mac_idx+1) begin
            mac mac_i(
                .clk(clk),      //clk
                .rst_n(rst_n),    //reset

                .random_bit(mac_input[mac_idx][`EV_W-1:0]),
                .key_bit(key_bit),
                .key_en(key_en),

                .sum_bit(hash_tag[`EV_K-(mac_idx+1)])
            );


        end
    endgenerate

//****************************** MAC instantiation ******************************







//****************************** shift register instantiation ******************************
    shift_register B_s_reg_0(
        .clk(clk),      //clk
        .rst_n(rst_n),    //reset

        .input_random_bit(random_bit),
        .shift_en(shift_en),
        
        .output_random_bit(shift_random_bit[`EV_W-1:0])
    );
        
    shift_register B_s_reg_1(
        .clk(clk),      //clk
        .rst_n(rst_n),    //reset

        .input_random_bit(shift_random_bit[`EV_W-1:0]),
        .shift_en(shift_en),
        
        .output_random_bit(shift_random_bit[(`EV_K+`EV_W-1):`EV_W])
    );
//****************************** shift register instantiation ******************************




        



endmodule







//****************************** shift reg ******************************
module shift_register(
    input clk,      //clk
    input rst_n,    //reset

    input [`EV_W-1:0] input_random_bit,
    input shift_en,
    
    output reg [`EV_W-1:0] output_random_bit
);




    //DFF
    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            output_random_bit <= `EV_W'b0;
        end
        else if (shift_en)begin
            output_random_bit <= input_random_bit;
        end
        else begin
            output_random_bit <= output_random_bit;
        end
    end

endmodule
//****************************** shift reg ******************************













//****************************** MAC ******************************
module mac (
    input clk,      //clk
    input rst_n,    //reset

    input [`EV_W-1:0] random_bit,
    input [`EV_W-1:0] key_bit,
    input key_en,

    output reg sum_bit
);
    //next sum bit
    wire next_sum_bit;
    assign next_sum_bit = (key_en)? ((^and_result)^(sum_bit)):0;

    // AND gate
    wire [`EV_W-1:0] and_result;
    assign and_result = random_bit & key_bit;



    //sum bit DFF
    always @(posedge clk ) begin
        if (~rst_n) begin
            sum_bit <= 0;
        end
        else begin
            sum_bit <= next_sum_bit;
        end
    end

endmodule
//****************************** MAC ******************************