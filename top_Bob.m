%% 
clc
close all
clear 
%% setup vivado path
hdlsetuptoolpath('ToolName','Xilinx Vivado','ToolPath','E:\xilinx\xilinx\Vivado\2022.1\bin\vivado.bat')
%% program FPGA
filProgramFPGA('Xilinx Vivado','Bob_top_test3.bit',1);
%% set up aximanager
mem = aximanager('Xilinx');
%% write input data
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
start_signal = '00000000F8888881';
data = hex2uint64(start_signal);

% write to system control (base address = 0x0000_0000)
writememory(mem,'00000000', data,'BurstType','Increment');
B_rd0 = readmemory(mem,'00000000', 1,'BurstType','Increment');
disp("address: "+ num2str(1)+ ", stored: " + dec2hex(B_rd0, 16));

