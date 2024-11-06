








//****************************** testbench ******************************

`define TEST_KEYLENGTH      32'd4096


// for fixed key length test
`define TEST_FIXED          1
`define AXISECRETKEY_DEPTH  64
`define SECRETKEY_1_REQUSET_ADDR    63
`define SECRETKEY_2_REQUSET_ADDR    127


// // for real key length test
// `define TEST_FIXED          0
// `define AXISECRETKEY_DEPTH  16384
// `define SECRETKEY_1_REQUSET_ADDR    16383
// `define SECRETKEY_2_REQUSET_ADDR    32767





`define AXIBRAM_WIDTH       64
`define AXIBRAM_DEPTH       32768
`define AXIRANDOMBIT_DEPTH  16384



//****************************** testbench ******************************






















//****************************** bram controller ******************************
// bram controller
`define NO_USE_BIT_WIDTH            32

// on/off state
`define ON_STATE                    4'b1111
`define OFF_STATE                   4'b0000

// data state
`define READY_STATE                 4'b0001
`define REQUEST_STATE               4'b0010
`define IDLE_STATE                  4'b1000

// writer
`define WRITER_PC                   4'b0001
`define WRITER_KCU116               4'b0010

// state address
`define PC_STATE_ADDRESS            32'd0
`define FPGA_STATE_ADDRESS          32'd8
//****************************** bram controller ******************************





//****************************** PP control ******************************
`define SIFTEDKEY_1_READY_ADDR      16383
`define SIFTEDKEY_2_READY_ADDR      32767

`define RECONCILEDKEY_1_READY_ADDR  16383
`define RECONCILEDKEY_2_READY_ADDR  32767

// `define SECRETKEY_1_REQUSET_ADDR    16383
// `define SECRETKEY_2_REQUSET_ADDR    32767
//****************************** PP control ******************************





//****************************** packet ******************************
//packet width
`define PACKET_WIDTH    32


//packet type = packet_message [31:28]
`define PACKET_TYPE_WIDTH       4
`define PACKET_TYPE_LOW_INDEX   28

// sifting
`define B2A_Z_BASIS_DETECTED        `PACKET_TYPE_WIDTH'd1
`define B2A_X_BASIS_DETECTED        `PACKET_TYPE_WIDTH'd2
`define A2B_Z_BASIS_DECOY           `PACKET_TYPE_WIDTH'd3
// reconciliation
`define B2A_ASK_PARITY              `PACKET_TYPE_WIDTH'd4
`define B2A_VERIFICATION_HASHTAG    `PACKET_TYPE_WIDTH'd5
`define A2B_CORRECT_PARITY          `PACKET_TYPE_WIDTH'd6
`define A2B_TARGET_HASHTAG          `PACKET_TYPE_WIDTH'd7 //hash tag & qber
// privacy amplification
`define A2B_SECRETKEY_LENGTH        `PACKET_TYPE_WIDTH'd8
// random bit
`define A2B_EV_RANDOMBIT            `PACKET_TYPE_WIDTH'd9
`define A2B_PA_RANDOMBIT            `PACKET_TYPE_WIDTH'd10


//packet length = packet_message [27:24]
`define PACKET_LENGTH_WIDTH     4
`define PACKET_LENGTH_LOW_INDEX 24

//bit_number = packet_length*32
`define PACKET_LENGTH_257   `PACKET_LENGTH_WIDTH'b0001
`define PACKET_LENGTH_514   `PACKET_LENGTH_WIDTH'b0010
`define PACKET_LENGTH_771   `PACKET_LENGTH_WIDTH'b0100
`define PACKET_LENGTH_1028  `PACKET_LENGTH_WIDTH'b1000

//packet_info = packet_message [23:0] 
`define PACKET_INFO_WIDTH       24
`define PACKET_INFO_LOW_INDEX   0
//****************************** packet ******************************








//****************************** sifting ******************************
`define PULSE_WIDTH         64
`define QUBIT_WIDTH         32

`define SIFTEDKEY_WIDTH     64

// z-basis
`define QUBIT_0             2'b10
`define QUBIT_1             2'b01
`define QUBIT_NO_DETECT     2'b00
`define QUBIT_DECOY         2'b11



// x-basis
// Alice
`define NO_PULSE            2'b00
`define PULSE_0             2'b10
`define PULSE_1             2'b01
// Bob
`define DETECT_PULSE        1'b1
`define NO_DETECT_PULSE     1'b0
// compare result
`define COMPARE_1           2'b01
`define COMPARE_0           2'b10
`define COMPARE_NO          2'b00



// visibility
`define A_CHECKKEY_1_WIDTH  22
`define A_CHECKKEY_0_WIDTH  22
`define COMPARE_1_WIDTH     22
`define COMPARE_0_WIDTH     22
`define NVIS_WIDTH          22
//****************************** sifting ******************************









//****************************** error reconciliation ******************************
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






// serial number    0~31
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
//****************************** error reconciliation ******************************












//****************************** key length ******************************
`define SQRT_WIDTH 36
`define SQRT_FBITS 32





// visibility
`define FRAME_A_CHECKKEY_1_WIDTH  22
`define FRAME_A_CHECKKEY_0_WIDTH  22
`define FRAME_COMPARE_1_WIDTH     22
`define FRAME_COMPARE_0_WIDTH     22
`define FRAME_NVIS_WIDTH          22


// // error count & leaked info
// `define FRAME_LEAKED_INFO_WIDTH     13  //0~8191
// `define FRAME_ERROR_COUNT_WIDTH     13  //0~8191





//constant
`define CONST_FBITS  32

//input bit-width
`define QBER_WIDTH  20 //word length of qber
`define QBER_FBITS  20 //fraction length of qber
`define VOBS_WIDTH  20 //word length of  vobs
`define VOBS_FBITS  20 //fraction length of vobs
`define NCOR_WIDTH  24 //word length of  ncor
`define NVIS_WIDTH  24 //word length of  nvis

//output bit-width
`define SECRETKEY_LENGTH_WIDTH  20 //word length of secretkey length



//****************************** key length ******************************











//****************************** privacy amplification ******************************
//Key length
`define PA_KEY_LENGTH       1048576



//MACs number
`define PA_K                1024
//The parameter W is chosen based on the width and throughput of the external memory interface
`define PA_W                64
//shift reg set number = (K+W)/W = 16+1 = 17
`define PA_S                17


// //word length of secretkey length
// `define SECRETKEY_LENGTH_WIDTH  20

//****************************** privacy amplification ******************************