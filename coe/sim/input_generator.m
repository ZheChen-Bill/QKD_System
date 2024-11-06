

clc
close all
clear 


% seed
seed = 100;
rng(seed);

% parameter for test
qber  = 0;
prob_no_detected = 0.2;

%%
pulse_width = 64;
qubit_width = 32;
depth = 32768;
randombit_depth = 16384;





%% A qubit
A_qubit_decoy_pos = zeros(depth, qubit_width);
A_qubit = Alice_qubit_generator(pulse_width ,depth);
A_qubit_bin = dec2bin(A_qubit);

for depth_idx = 1:depth
    for idx = 1:qubit_width
        if ((A_qubit_bin(depth_idx,2*idx-1)=='1') && (A_qubit_bin(depth_idx,2*idx)=='1'))
            A_qubit_decoy_pos(depth_idx,idx) = 0;
        else
            A_qubit_decoy_pos(depth_idx,idx) = 1;
        end
    end
end


% A_qubit_decoy_pos_hex = binaryVectorToHex(A_qubit_decoy_pos);
% A_qubit_decoy_pos_hex(1:1025,:)
%% B z-basis detected qubit
B_Zbasis_detected_pos = zeros(depth, qubit_width);
B_Zbasis_detected_qubit_bin = Bob_qubit_detecter(A_qubit_bin , qber , prob_no_detected);



for depth_idx = 1:depth
    for idx = 1:qubit_width
        if ((B_Zbasis_detected_qubit_bin(depth_idx,2*idx-1)== 1) || (B_Zbasis_detected_qubit_bin(depth_idx,2*idx)== 1))
            B_Zbasis_detected_pos(depth_idx,idx) = 1;
        else
            B_Zbasis_detected_pos(depth_idx,idx) = 0;
        end
    end
end


%% B x-basis detected pos
B_Xbasis_detected_pos = round(rand([depth,pulse_width]));


%% PA random bit

PArandombit = typecast(randi(intmax('uint32'),randombit_depth*2,1,'uint32'),'uint64');



%% EV random bit

EVrandombit = typecast(randi(intmax('uint32'),randombit_depth*2,1,'uint32'),'uint64');




%% input test pattern



% % Alice qubit test pattern
% fileID = fopen('./input_test_pattern/input_A_Qubit.txt','w');
% 
% for string_index = 1:depth
% 
%     fprintf(fileID, '%s\n',A_qubit_bin(string_index,:));
% 
% 
% end
% fclose(fileID);
% 
% 
% % Bob Z-basis detected test pattern
% fileID = fopen('./input_test_pattern/input_B_Zbasis_detected_pos.txt','w');
% 
% B_Zbasis_detected_pos_str = mat2str(B_Zbasis_detected_qubit_bin);
% B_Zbasis_detected_pos_str = strrep(B_Zbasis_detected_pos_str,'[','');
% B_Zbasis_detected_pos_str = strrep(B_Zbasis_detected_pos_str,']','');
% B_Zbasis_detected_pos_str = strrep(B_Zbasis_detected_pos_str,' ','');
% B_Zbasis_detected_pos_str = strrep(B_Zbasis_detected_pos_str,';','');
% 
% w = 64;
% for string_index = 1:depth
% 
%     fprintf(fileID, '%s\n',B_Zbasis_detected_pos_str( 1 , (string_index-1)*w+1 :(string_index*w) ));
% 
% 
% end
% fclose(fileID);
% 
% 
% 
% % Bob X-basis detected test pattern
% fileID = fopen('./input_test_pattern/input_B_Xbasis_detected_pos.txt','w');
% 
% 
% B_Xbasis_detected_pos_str = mat2str(B_Xbasis_detected_pos);
% B_Xbasis_detected_pos_str = strrep(B_Xbasis_detected_pos_str,'[','');
% B_Xbasis_detected_pos_str = strrep(B_Xbasis_detected_pos_str,']','');
% B_Xbasis_detected_pos_str = strrep(B_Xbasis_detected_pos_str,' ','');
% B_Xbasis_detected_pos_str = strrep(B_Xbasis_detected_pos_str,';','');
% 
% 
% for string_index = 1:length(B_Xbasis_detected_pos_str)/w
%     % disp(string_index)
% 
%     fprintf(fileID, '%s\n',B_Xbasis_detected_pos_str( 1 , (string_index-1)*w+1 :(string_index*w) ));
% 
% 
% end
% fclose(fileID);
% 
% 
% 
% 
% 
% % PA random bit test pattern
% % hex value
% PArandombit_hex = dec2hex(PArandombit);
% % write hex value to file
% fileID = fopen('./input_test_pattern/PArandombit.txt','w');
% for idx = 1:randombit_depth
%     fprintf(fileID,'%s\n',PArandombit_hex(idx,:));
% end
% fclose(fileID);
% 
% 
% 
% 
% 
% 
% % EV random bit test pattern
% % hex value
% EVrandombit_hex = dec2hex(EVrandombit);
% % write hex value to file
% fileID = fopen('./input_test_pattern/EVrandombit.txt','w');
% for idx = 1:randombit_depth
%     fprintf(fileID,'%s\n',EVrandombit_hex(idx,:));
% end
% fclose(fileID);







%% A sifted key



A_sifted_key_1048576 = zeros(1,1048576);
siftedkey_idx = 1;

for depth_idx = 1:depth
    for idx = 1:qubit_width
        if ((A_qubit_decoy_pos(depth_idx,idx)==1) && (B_Zbasis_detected_pos(depth_idx,idx)==1))


            if ((A_qubit_bin(depth_idx,2*idx-1)=='1') && (A_qubit_bin(depth_idx,2*idx)=='0'))
                A_sifted_key_1048576(1,siftedkey_idx) = 0;
                siftedkey_idx = siftedkey_idx + 1;


            elseif ((A_qubit_bin(depth_idx,2*idx-1)=='0') && (A_qubit_bin(depth_idx,2*idx)=='1'))

                A_sifted_key_1048576(1,siftedkey_idx) = 1;
                siftedkey_idx = siftedkey_idx + 1;

            end

        end
    end
end

A_sifted_key = A_sifted_key_1048576(1 , 1:siftedkey_idx-1);

mod64 = mod(length(A_sifted_key) , 64);
if (mod64 ~= 0)
    mod64 = 64-mod64;
else
    mod64;
end
    
padding = 0 * ones(1,mod64);
A_sifted_key_64 = [A_sifted_key padding];
A_sifted_key_64 = reshape(A_sifted_key_64 , [64 , length(A_sifted_key_64)/64]);
A_sifted_key_64 = A_sifted_key_64';






% A_sifted_key_64_hex = binaryVectorToHex(A_sifted_key_64);
% A_sifted_key_64_hex(1:100)






%% B sifted key



B_sifted_key_1048576 = zeros(1,1048576);
siftedkey_idx = 1;

for depth_idx = 1:depth
    for idx = 1:qubit_width
        if ((A_qubit_decoy_pos(depth_idx,idx)==1) && (B_Zbasis_detected_pos(depth_idx,idx)==1))


            if ((B_Zbasis_detected_qubit_bin(depth_idx,2*idx-1)==1) && (B_Zbasis_detected_qubit_bin(depth_idx,2*idx)==0))


                B_sifted_key_1048576(1 , siftedkey_idx) = 0;
                siftedkey_idx = siftedkey_idx + 1;

            elseif ((B_Zbasis_detected_qubit_bin(depth_idx,2*idx-1)==0) && (B_Zbasis_detected_qubit_bin(depth_idx,2*idx)==1))
                B_sifted_key_1048576(1 , siftedkey_idx) = 1;
                siftedkey_idx = siftedkey_idx + 1;


            elseif ((B_Zbasis_detected_qubit_bin(depth_idx,2*idx-1)==1) && (B_Zbasis_detected_qubit_bin(depth_idx,2*idx)==1))

                % detect qubit==1,1
                if (mod(idx,2)==1) 
                    B_sifted_key_1048576(1 , siftedkey_idx) = 1;
                    siftedkey_idx = siftedkey_idx + 1;
                else
                    B_sifted_key_1048576(1 , siftedkey_idx) = 0;
                    siftedkey_idx = siftedkey_idx + 1;
                end
            end
        end
    end
end


B_sifted_key = B_sifted_key_1048576(1 , 1:siftedkey_idx-1);




B_sifted_key_64 = [B_sifted_key padding];
B_sifted_key_64 = reshape(B_sifted_key_64 , [64 , length(B_sifted_key_64)/64]);
B_sifted_key_64 = B_sifted_key_64';




% B_sifted_key_64_hex = binaryVectorToHex(B_sifted_key_64);
% B_sifted_key_64_hex








%% qber

errorrate=sum(abs(A_sifted_key-B_sifted_key))/length(A_sifted_key)





%% random bit


PArandombit_vector= zeros(1 , randombit_depth * pulse_width );

PArandombit_bin = dec2bin(PArandombit);
vector_idx = 1;
for depth_idx = 1:randombit_depth
    for idx = 1:pulse_width
        if (PArandombit_bin(depth_idx, idx)=='1')
            PArandombit_vector(1, vector_idx) = 1;
        else
            PArandombit_vector(1, vector_idx) = 0;
        end
        vector_idx = vector_idx + 1;
    end
end








%% target sifted key
A_sifted_key = [A_sifted_key , A_sifted_key , A_sifted_key];
B_sifted_key = [B_sifted_key , B_sifted_key , B_sifted_key];

mod64 = mod(length(A_sifted_key) , 64);
A_sifted_key_64 = A_sifted_key(1:length(A_sifted_key)-mod64);



mod64 = mod(length(B_sifted_key) , 64);
B_sifted_key_64 = B_sifted_key(1:length(B_sifted_key)-mod64);



target_A_sifted_key = binaryVectorToHex(A_sifted_key_64);
target_B_sifted_key = binaryVectorToHex(B_sifted_key_64);



%% target reconciled key
A_reconciled_key = A_sifted_key(1:(qubit_width*depth*2));
B_reconciled_key = B_sifted_key(1:(qubit_width*depth*2));

target_A_reconciled_key = binaryVectorToHex(A_reconciled_key);
target_B_reconciled_key = binaryVectorToHex(B_reconciled_key);



%% target secret key
A_secret_key_1 = PA_4096_secretkey(A_reconciled_key(1:1048576) , PArandombit_vector);
A_secret_key_2 = PA_4096_secretkey(A_reconciled_key(1048576 + 1:end) , PArandombit_vector);

B_secret_key_1 = PA_4096_secretkey(B_reconciled_key(1:1048576) , PArandombit_vector);
B_secret_key_2 = PA_4096_secretkey(B_reconciled_key((1048576 + 1):end) , PArandombit_vector);

target_A_secret_key = [A_secret_key_1 , A_secret_key_2];
target_B_secret_key = [B_secret_key_1 , B_secret_key_2];


%% compare with HW result


HW_folder_name = "D:/QKD_HW_project/QKD_post_processing/TOP/HW_sim_result/";



HW_A_siftedkey_file_name = append(HW_folder_name , "A_siftedkey_out.txt");
HW_B_siftedkey_file_name = append(HW_folder_name , "B_siftedkey_out.txt");

HW_A_reconciledkey_file_name = append(HW_folder_name , "A_reconciledkey_out.txt");
HW_B_reconciledkey_file_name = append(HW_folder_name , "B_reconciledkey_out.txt");

HW_A_secretkey_file_name = append(HW_folder_name , "A_secretkey_out.txt");
HW_B_secretkey_file_name = append(HW_folder_name , "B_secretkey_out.txt");





HW_A_siftedkeyID = fopen(HW_A_siftedkey_file_name,'r');
HW_A_siftedkey = fscanf(HW_A_siftedkeyID,"%s");


HW_B_siftedkeyID = fopen(HW_B_siftedkey_file_name,'r');
HW_B_siftedkey = fscanf(HW_B_siftedkeyID,"%s");



HW_A_reconciledkeyID = fopen(HW_A_reconciledkey_file_name,'r');
HW_A_reconciledkey = fscanf(HW_A_reconciledkeyID,"%s");


HW_B_reconciledkeyID = fopen(HW_B_reconciledkey_file_name,'r');
HW_B_reconciledkey = fscanf(HW_B_reconciledkeyID,"%s");




HW_A_secretkeyID = fopen(HW_A_secretkey_file_name,'r');
HW_A_secretkey = fscanf(HW_A_secretkeyID,"%s");


HW_B_secretkeyID = fopen(HW_B_secretkey_file_name,'r');
HW_B_secretkey = fscanf(HW_B_secretkeyID,"%s");






if (isequal(HW_A_siftedkey , lower(target_A_sifted_key)))
    disp("[CORRECT] Alice sifted key")
else
    disp("[FAIL] Alice sifted key")
end


if (isequal(HW_B_siftedkey , lower(target_B_sifted_key)))
    disp("[CORRECT] Bob sifted key")
else
    disp("[FAIL] Bob sifted key")
end


if (isequal(HW_A_reconciledkey , lower(target_A_reconciled_key)))
    disp("[CORRECT] Alice reconciled key")
else
    disp("[FAIL] Alice reconciled key")
end


if (isequal(HW_B_reconciledkey , lower(target_B_reconciled_key)))
    disp("[CORRECT] Bob reconciled key")
else
    disp("[FAIL] Bob reconciled key")
end

if (isequal(HW_A_secretkey , lower(target_A_secret_key)))
    disp("[CORRECT] Alice secret key")
else
    disp("[FAIL] Alice secret key")
end


if (isequal(HW_B_secretkey , lower(target_B_secret_key)))
    disp("[CORRECT] Bob secret key")
else
    disp("[FAIL] Bob secret key")
end


