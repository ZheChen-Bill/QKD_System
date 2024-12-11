function out = bin2uint64(in)
d   = uint64(in - '0');  % Vector of doubles containing the bits
out = sum(d .* bitshift(uint64(1), 63:-1:0), 'native');
end