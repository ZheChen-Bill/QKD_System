

% data_width = 64;
% data_length = 32768;




function qubit_output = Alice_qubit_generator(data_width ,data_length)

    prob_49 = 49/256;
    prob_14 = 14/256;
    prob_4 = 4/256;

    sample_length = data_width*data_length/4;

    qubit_tmp = randsample('5679ABDEF',sample_length,true,[prob_49 prob_49 prob_14 prob_49 prob_49 prob_14 prob_14 prob_14 prob_4]);
    qubit_output = swapbytes(typecast(uint8(sscanf(qubit_tmp, '%02x')), 'uint64'));
end