


function secretkey_out = PA_4096_secretkey(reconciledkey , randombit)
    MAC = 1024;
    reconciledkeylength = 1048576;
    outputlength = 4096;
    operation_time = outputlength/MAC;


    reconciledkey = reconciledkey';
    % reconciled key for matrix multiplication n-m bits
    reconciledkey_matrix = reconciledkey(1:(reconciledkeylength - outputlength));
    % reconciled key for XOR m bits
    reconciledkey_xor = reconciledkey(reconciledkeylength-outputlength+1 : end);

    key_index = reconciledkeylength-outputlength;
    
    secretkey = [];

    for idx = operation_time:-1:1

        idx_1 = (idx-1)*1024+1;
        idx_2 = (idx)*1024+key_index-1;
    
        idx_3 = (operation_time-idx)*1024+1;
        idx_4 = (operation_time-idx)*1024+1024;
    
    
        partial_random_bit = randombit(1, idx_1:idx_2);
    
        partial_random_bit = [partial_random_bit(1024:end)   flip(partial_random_bit(1:1023))];
        partial_random_bit_hex = binaryVectorToHex([partial_random_bit]);
        partial_hash_product = toeplitzhash(reconciledkey_matrix',partial_random_bit);
        partial_hash_product_hex = binaryVectorToHex(partial_hash_product);
        
        reconciledkey_xor_t = reconciledkey_xor';
        partial_xor_key = reconciledkey_xor_t(1,idx_3 : idx_4);
        partial_xor_key_hex = binaryVectorToHex(partial_xor_key);

        partial_secretkey = mod((partial_hash_product+partial_xor_key),2);
        partial_secretkey_hex = binaryVectorToHex(partial_secretkey);
    

        secretkey = [secretkey partial_secretkey_hex];
    end


    secretkey_out = secretkey;

end