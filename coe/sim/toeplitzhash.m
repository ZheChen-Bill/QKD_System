function keyout=toeplitzhash(keyin,seed)
keyin=gpuArray(keyin);
seed=gpuArray(seed);
n = length(keyin);
keyoutlength=length(seed)-length(keyin)+1;
keyout=zeros([1,keyoutlength]);

for i=1:keyoutlength
    if (i==1) 
        random_vector = seed(i:i+length(keyin)-1);
    else
        A = seed(n+1:n+i-1);
        B = seed(1:n-i+1);
        random_vector = [fliplr(A)  , B];
    end

    keyout(i)=mod(sum(keyin.*random_vector),2);
end