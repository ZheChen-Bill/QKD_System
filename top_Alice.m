%% 
clc
close all
clear 
%% setup vivado path
hdlsetuptoolpath('ToolName','Xilinx Vivado','ToolPath','D:\xilinx\Vivado\2022.1\bin\vivado.bat')
%% program FPGA
filProgramFPGA('Xilinx Vivado','Alice_top_test3.bit',1);
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
start_signal = '00000000F8888881';
data = hex2uint64(start_signal);

% write to system control (base address = 0x8000_0000)
writememory(mem,'80000000', data,'BurstType','Increment');
B_rd0 = readmemory(mem,'80000000', 1,'BurstType','Increment');
disp("address: "+ num2str(1)+ ", stored: " + dec2hex(B_rd0, 16));


