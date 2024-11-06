







function B_zbasis_qubit = Bob_qubit_detecter(A_qubit_bin , qber , prob_no_detected)

    depth = size(A_qubit_bin,1);
    qubit_width = size(A_qubit_bin,2) / 2;

    B_zbasis_qubit = (zeros(size(A_qubit_bin)));










    
    
    for depth_idx = 1:depth
        for idx = 1:qubit_width
            rand_list = rand(1,3);

            if (rand_list(1) <= prob_no_detected)
                % no detected
                B_zbasis_qubit(depth_idx,2*idx-1) = 0;
                B_zbasis_qubit(depth_idx,2*idx  ) = 0;
            elseif ((rand_list(1) > prob_no_detected) && (rand_list(2) <= qber))
                % detected & error
                if ((A_qubit_bin(depth_idx,2*idx-1)=='1') && (A_qubit_bin(depth_idx,2*idx)=='1') && (rand_list(3) <= 0.5))
                    B_zbasis_qubit(depth_idx,2*idx-1) = 0;
                    B_zbasis_qubit(depth_idx,2*idx  ) = 1;
                elseif ((A_qubit_bin(depth_idx,2*idx-1)=='1') && (A_qubit_bin(depth_idx,2*idx)=='1') && (rand_list(3) > 0.5))
                    B_zbasis_qubit(depth_idx,2*idx-1) = 1;
                    B_zbasis_qubit(depth_idx,2*idx  ) = 0;

                elseif ((A_qubit_bin(depth_idx,2*idx-1)=='0') && (A_qubit_bin(depth_idx,2*idx)=='1') && (rand_list(3) <= 0.8))
                    B_zbasis_qubit(depth_idx,2*idx-1) = 1;
                    B_zbasis_qubit(depth_idx,2*idx  ) = 0;
                elseif ((A_qubit_bin(depth_idx,2*idx-1)=='0') && (A_qubit_bin(depth_idx,2*idx)=='1') && (rand_list(3) > 0.8))
                    B_zbasis_qubit(depth_idx,2*idx-1) = 1;
                    B_zbasis_qubit(depth_idx,2*idx  ) = 1;

                elseif ((A_qubit_bin(depth_idx,2*idx-1)=='1') && (A_qubit_bin(depth_idx,2*idx)=='0') && (rand_list(3) <= 0.8))
                    B_zbasis_qubit(depth_idx,2*idx-1) = 0;
                    B_zbasis_qubit(depth_idx,2*idx  ) = 1;
                elseif ((A_qubit_bin(depth_idx,2*idx-1)=='1') && (A_qubit_bin(depth_idx,2*idx)=='0') && (rand_list(3) > 0.8))
                    B_zbasis_qubit(depth_idx,2*idx-1) = 1;
                    B_zbasis_qubit(depth_idx,2*idx  ) = 1;
                end
            elseif ((rand_list(1) > prob_no_detected) && (rand_list(2) > qber))
                % detected & correct
                B_zbasis_qubit(depth_idx,2*idx-1) = str2double(A_qubit_bin(depth_idx,2*idx-1));
                B_zbasis_qubit(depth_idx,2*idx  ) = str2double(A_qubit_bin(depth_idx,2*idx  ));
            end
        end

    end



end