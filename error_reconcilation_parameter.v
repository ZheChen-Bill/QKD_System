


//cascade input key length
`define CASCADE_KEY_LENGTH      8192   

// default error count
`define DEFAULT_ERROR_COUNT     `FRAME_ERROR_COUNT_WIDTH'd80

// single frame key depth in 64-bit width sifted key BRAM
`define SIFTED_KEY_64_DEPTH     128//(`CASCADE_KEY_LENGTH<<6)
`define SIFTED_KEY_64_WIDTH     7


// single frame reconciled key depth in 64-bit width reconciled key BRAM
`define RECONCILED_KEY_64_DEPTH 128//(`CASCADE_KEY_LENGTH<<6)

// single frame key depth in 32-bit width BRAM
`define CASCADE_KEY_32_DEPTH    256//(`CASCADE_KEY_LENGTH<<5)

// single frame random bit in 64-bit width  
`define RANDOM_BIT_64_DEPTH     128//(`CASCADE_KEY_LENGTH<<6)

// log2 (key length)
`define LOG2_KEY_LENGTH         13  //  log2(8192)

// frame round
`define FRAME_ROUND_WIDTH       7   //  0~127

// max frame round for one ER operation
`define MAX_FRAME_ROUND         `FRAME_ROUND_WIDTH'd127


// real depth is less than 32 row index
`define LESS_32_ROW_INDEX       9

`define PARITY_WIDTH_1          8192    //row 1
`define PARITY_WIDTH_2          4096    //row 2
`define PARITY_WIDTH_4          2048    //row 3
`define PARITY_WIDTH_8          1024    //row 4
`define PARITY_WIDTH_16         512     //row 5
`define PARITY_WIDTH_32         256     //row 6
`define PARITY_WIDTH_64         128     //row 7
`define PARITY_WIDTH_128        64      //row 8
`define PARITY_WIDTH_256        32      //row 9
`define PARITY_WIDTH_512        16      //row 10
`define PARITY_WIDTH_1024       8       //row 11








// output for secret key length calulation
`define FRAME_LEAKED_INFO_WIDTH     13  //0~8191
`define FRAME_ERROR_COUNT_WIDTH     13  //0~8191







//packet info = packet_message [23:0] 
/*
real_packet_depth[`RECONCILIATION_REAL_PACKET_DEPTH_WIDTH-1:0] = packet_message[23:15];
parity_type[`FIRST_LAST_PARITY_MESSAGE_WIDTH-1:0] = packet_message[14:12];
reconciliation_set[`RECONCILIATION_SHUFFLE_SET_WIDTH-1:0] = packet_message[11:9];
parity_tree_row[`PARITY_TREE_ROW_INDEX_WIDTH-1:0] = packet_message[8:5];
serial_number[`RECONCILIATION_SERIAL_NUMBER_WIDTH-1:0] packet_message[4:0];
*/


// small packet depth : real_packet_depth<=257
// real_packet_depth:0~257
// real_packet_size = packet_width * packet_depth = 32 * (real_packet_depth)
// many ask_parity & correct_parity has small packet depth
// hashtag packet has small packet depth
`define RECONCILIATION_REAL_PACKET_DEPTH_WIDTH  9 //0~256





// parity type : first, top, normal 
`define PARITY_TYPE_WIDTH                   3
`define FIRST_TOP_PARITY_MESSAGE            `PARITY_TYPE_WIDTH'b101
`define TOP_PARITY_MESSAGE                  `PARITY_TYPE_WIDTH'b100
`define TOP_PARITY_COMPARE                  `PARITY_TYPE_WIDTH'b111
`define TOP_PARITY_CORRECT                  `PARITY_TYPE_WIDTH'b110
`define NORMAL_PARITY                       `PARITY_TYPE_WIDTH'b000






// shuffle set
`define RECONCILIATION_SHUFFLE_SET_WIDTH    3
`define RECONCILIATION_SHUFFLE_SET_1        `RECONCILIATION_SHUFFLE_SET_WIDTH'd1
`define RECONCILIATION_SHUFFLE_SET_2        `RECONCILIATION_SHUFFLE_SET_WIDTH'd2
`define RECONCILIATION_SHUFFLE_SET_3        `RECONCILIATION_SHUFFLE_SET_WIDTH'd3
`define RECONCILIATION_SHUFFLE_SET_4        `RECONCILIATION_SHUFFLE_SET_WIDTH'd4





// parity tree row index
`define PARITY_TREE_ROW_INDEX_WIDTH 4
`define PARITY_TREE_ROW_1           `PARITY_TREE_ROW_INDEX_WIDTH'd1
`define PARITY_TREE_ROW_2           `PARITY_TREE_ROW_INDEX_WIDTH'd2
`define PARITY_TREE_ROW_3           `PARITY_TREE_ROW_INDEX_WIDTH'd3
`define PARITY_TREE_ROW_4           `PARITY_TREE_ROW_INDEX_WIDTH'd4
`define PARITY_TREE_ROW_5           `PARITY_TREE_ROW_INDEX_WIDTH'd5
`define PARITY_TREE_ROW_6           `PARITY_TREE_ROW_INDEX_WIDTH'd6
`define PARITY_TREE_ROW_7           `PARITY_TREE_ROW_INDEX_WIDTH'd7
`define PARITY_TREE_ROW_8           `PARITY_TREE_ROW_INDEX_WIDTH'd8
`define PARITY_TREE_ROW_9           `PARITY_TREE_ROW_INDEX_WIDTH'd9
`define PARITY_TREE_ROW_10          `PARITY_TREE_ROW_INDEX_WIDTH'd10
`define PARITY_TREE_ROW_11          `PARITY_TREE_ROW_INDEX_WIDTH'd11






// serial number    0~31 流水???
`define RECONCILIATION_SERIAL_NUMBER_WIDTH  5

















// Input sifted key length
`define EV_KEY_LENGTH       `CASCADE_KEY_LENGTH



//MACs number
`define EV_K                64
//The parameter W is chosen based on the width and throughput of the external memory interface
`define EV_W                64
//shift reg set number = (K+W)/W = 1+1 = 2
`define EV_S                2

// hash tag width for EV
`define EV_HASHTAG_WIDTH    64

// real hash tag width share between A & B
`define EV_REAL_HASHTAG_WIDTH   32


