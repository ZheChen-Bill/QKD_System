%% 
clc
close all
clear 
%% setup vivado path
hdlsetuptoolpath('ToolName','Xilinx Vivado','ToolPath','E:\xilinx\xilinx\Vivado\2022.1\bin\vivado.bat')
%% program FPGA
filProgramFPGA('Xilinx Vivado','Bob_top_test9.bit',1); % correct
%% set up aximanager
mem = aximanager('Xilinx');
%% write input data (Bob side)
fid = fopen('input_test_pattern\input_B_Xbasis_detected_pos.txt');
Xbasis = textscan(fid, '%s');
Xbasis = Xbasis{1};
data = uint64(zeros(1,32768));
for i = 1:length(Xbasis)
    A = Xbasis{i};
    data(i) = bin2uint64(A);
end
% write X_basis data (base address = 0x4000_0000)
writememory(mem,'40000000', data,'BurstType','Increment');
B_rd0 = readmemory(mem,'40000000', 32768,'BurstType','Increment');
for i = 1:32768
    if B_rd0(i) ~= 0
        disp("address: "+ num2str(i) + ", stored: " + dec2hex(B_rd0(i), 16));
    end
end

fid = fopen('input_test_pattern\input_B_Zbasis_detected_pos.txt');
Zbasis = textscan(fid, '%s');
Zbasis = Zbasis{1};
data = uint64(zeros(1,32768));
for i = 1:length(Zbasis)
    A = Zbasis{i};
    data(i) = bin2uint64(A);
end
% write Z_basis data (base address = 0x8000_0000)
writememory(mem,'80000000', data,'BurstType','Increment');
B_rd0 = readmemory(mem,'80000000', 32768,'BurstType','Increment');
for i = 1:32768
    if B_rd0(i) ~= 0
        disp("address: "+ num2str(i) + ", stored: " + dec2hex(B_rd0(i), 16));
    end
end
%% start the system
mem = aximanager('Xilinx');
% write to system control (base address = 0x0000_0000)
start_signal = '00000000F8888881';
data = hex2uint64(start_signal);
writememory(mem,'00000000', data,'BurstType','Increment');
B_rd0 = readmemory(mem,'00000000', 1,'BurstType','Increment');
disp("address: "+ num2str(1)+ ", stored: " + dec2hex(B_rd0, 16));

%% wait for second sifting
% read the sifting states (base address = 0x0000_0008) (equal to 0X0000_0000_F882_2882)
B_rd0 = readmemory(mem,'00000008', 1,'BurstType','Increment');
disp("address: "+ num2str(1)+ ", stored: " + dec2hex(B_rd0, 16));

% write the wait states for next sifting states (base address = 0x0000_0000)
wait_signal = '00000000F1111111';
data = hex2uint64(wait_signal);
writememory(mem,'00000000', data,'BurstType','Increment');
B_rd0 = readmemory(mem,'00000000', 1,'BurstType','Increment');
disp("address: "+ num2str(1)+ ", stored: " + dec2hex(B_rd0, 16));

% read the sifting states (base address = 0x0000_0008) (if fast enough we can see the value change from 0X0000_0000_F882_2882 to 0X0000_0000_F888_8882)
B_rd0 = readmemory(mem,'00000008', 1,'BurstType','Increment');
disp("address: "+ num2str(1)+ ", stored: " + dec2hex(B_rd0, 16));

% write to system control (base address = 0x0000_0000)
start_signal = '00000000F8888881';
data = hex2uint64(start_signal);
writememory(mem,'00000000', data,'BurstType','Increment');
B_rd0 = readmemory(mem,'00000000', 1,'BurstType','Increment');
disp("address: "+ num2str(1)+ ", stored: " + dec2hex(B_rd0, 16));
%% read out the secret key (base address = 0x1000_0000)
B_rd0 = readmemory(mem,'10000000', 32768 ,'BurstType','Increment');
for i = 1:32768
    if B_rd0(i) ~= 0
        disp("address: "+ num2str(i) + ", stored: " + dec2hex(B_rd0(i), 16));
    end
end

%% save the secret key
key = {};
for i = 1:32768
    if B_rd0(i) ~= 0
        key{i} = [dec2hex(B_rd0(i), 16)];
    end
end
fileID = fopen('Bob_top_key_HEX.txt','w+');
for i = 1:length(key)
    fprintf(fileID,'%s',key{i});
    fprintf(fileID,'\n');
end
fclose(fileID);

release(mem)
%% AXI manager write test
% mem = aximanager('Xilinx');
% data = ones(1,32768);
% writememory(mem,'10000000', data,'BurstType','Increment');
% B_rd0 = readmemory(mem,'10000000', 32768 ,'BurstType','Increment');
% for i = 1:32768
%     if B_rd0(i) ~= 0
%         disp("address: "+ num2str(i) + ", stored: " + dec2hex(B_rd0(i), 16));
%     end
% end
