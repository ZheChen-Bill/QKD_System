


//Key length
`define PA_KEY_LENGTH       1048576



//MACs number
`define PA_K                1024
//The parameter W is chosen based on the width and throughput of the external memory interface
`define PA_W                64
//shift reg set number = (K+W)/W = 16+1 = 17
`define PA_S                17


//word length of secretkey length
`define SECRETKEY_LENGTH_WIDTH  20


