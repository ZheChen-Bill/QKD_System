%% 
clc
close all
clear 
%% setup vivado path
hdlsetuptoolpath('ToolName','Xilinx Vivado','ToolPath','D:\xilinx\Vivado\2022.1\bin\vivado.bat')
%% program FPGA
% filProgramFPGA('Xilinx Vivado','Alice_top_test17.bit',1); % base address = 0x4000_0000 and can't W/R output secret key
% filProgramFPGA('Xilinx Vivado','Alice_top_test20.bit',1); % base address = 0x5000_0000 and can't read generate secret key
filProgramFPGA('Xilinx Vivado','Alice_top_test25.bit',1); % base address = 0x5000_0000 (Correct)
%% set up aximanager
mem = aximanager('Xilinx');
%% write input data
fid = fopen('C:\Users\Bill\Downloads\input_test_pattern\EVrandombit.txt');
EVrandombit = textscan(fid, '%s');
EVrandombit = EVrandombit{1};
data = uint64(zeros(1,16384));
for i = 1:length(EVrandombit)
    A = EVrandombit{i};
    data(i) = hex2uint64(A);
end

% write EVrandombit data (base address = 0x1000_0000
writememory(mem,'10000000', data,'BurstType','Increment');
B_rd0 = readmemory(mem,'10000000', 16384,'BurstType','Increment');
for i = 1:16384
    if B_rd0(i) ~= 0
        disp("address: "+ num2str(i) + ", stored: " + dec2hex(B_rd0(i), 16));
    end
end

fid = fopen('C:\Users\Bill\Downloads\input_test_pattern\PArandombit.txt');
PArandombit = textscan(fid, '%s');
PArandombit = PArandombit{1};
data = uint64(zeros(1,16384));
for i = 1:length(PArandombit)
    A = PArandombit{i};
    data(i) = hex2uint64(A);
end
% write EVrandombit data (base address = 0x2000_0000)
writememory(mem,'20000000', data,'BurstType','Increment');
B_rd0 = readmemory(mem,'20000000', 16384,'BurstType','Increment');
for i = 1:16384
    if B_rd0(i) ~= 0
        disp("address: "+ num2str(i) + ", stored: " + dec2hex(B_rd0(i), 16));
    end
end

fid = fopen('C:\Users\Bill\Downloads\input_test_pattern\input_A_Qubit.txt');
Qubit = textscan(fid, '%s');
Qubit = Qubit{1};
data = uint64(zeros(1,32768));
for i = 1:length(Qubit)
    A = Qubit{i};
    data(i) = bin2uint64(A);
end
% write Qubit data(Qubit_BRAM) (base address = 0x0000_0000)
writememory(mem,'00000000', data,'BurstType','Increment');
B_rd0 = readmemory(mem,'00000000', 32768,'BurstType','Increment');
for i = 1:32768
    if B_rd0(i) ~= 0
        disp("address: "+ num2str(i) + ", stored: " + dec2hex(B_rd0(i), 16));
    end
end
% write Qubit data(QC_BRAM) (base address = 0x3000_0000)
writememory(mem,'30000000', data,'BurstType','Increment');
B_rd0 = readmemory(mem,'30000000', 32768,'BurstType','Increment');
for i = 1:32768
    if B_rd0(i) ~= 0
        disp("address: "+ num2str(i) + ", stored: " + dec2hex(B_rd0(i), 16));
    end
end
%% start the system
mem = aximanager('Xilinx');
% write to system control (base address = 0x8000_0000)
start_signal = '00000000F8888881';
data = hex2uint64(start_signal);
writememory(mem,'80000000', data,'BurstType','Increment');
B_rd0 = readmemory(mem,'80000000', 1,'BurstType','Increment');
disp("address: "+ num2str(1)+ ", stored: " + dec2hex(B_rd0, 16));

%%  wait for second sifting
% read the sifting states (base address = 0x8000_0008) (equal to 0X0000_0000_F828_8882)
B_rd0 = readmemory(mem,'80000008', 1,'BurstType','Increment');
disp("address: "+ num2str(1)+ ", stored: " + dec2hex(B_rd0, 16));

% write the wait states for next sifting states (base address = 0x8000_0000)
wait_signal = '00000000F1111111';
data = hex2uint64(wait_signal);
writememory(mem,'80000000', data,'BurstType','Increment');
B_rd0 = readmemory(mem,'80000000', 1,'BurstType','Increment');
disp("address: "+ num2str(1)+ ", stored: " + dec2hex(B_rd0, 16));

% read the sifting states (base address = 0x8000_0008) (if fast enough we can see the value change from 0X0000_0000_F828_8882 to 0X0000_0000_F888_8882)
B_rd0 = readmemory(mem,'80000008', 1,'BurstType','Increment');
disp("address: "+ num2str(1)+ ", stored: " + dec2hex(B_rd0, 16));

% write to system control (base address = 0x8000_0000)
start_signal = '00000000F8888881';
data = hex2uint64(start_signal);
writememory(mem,'80000000', data,'BurstType','Increment');
B_rd0 = readmemory(mem,'80000000', 1,'BurstType','Increment');
disp("address: "+ num2str(1)+ ", stored: " + dec2hex(B_rd0, 16));
%% read out the secret key (base address = 0x5000_0000)
B_rd0 = readmemory(mem,'50000000', 32768 ,'BurstType','Increment');
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
fileID = fopen('Alice_top_key_HEX.txt','w+');
for i = 1:length(key)
    fprintf(fileID,'%s',key{i});
    fprintf(fileID,'\n');
end
fclose(fileID);

release(mem)
%% AXI manager write test

% mem = aximanager('Xilinx');
% data = ones(1,32768);
% writememory(mem,'50000000', data,'BurstType','Increment');
% B_rd0 = readmemory(mem,'50000000', 32768 ,'BurstType','Increment');
% for i = 1:32768
%     if B_rd0(i) ~= 0
%         disp("address: "+ num2str(i) + ", stored: " + dec2hex(B_rd0(i), 16));
%     end
% end
