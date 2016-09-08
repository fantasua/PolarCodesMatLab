function y=rev_shuffle(x)
N=length(x);
if N==1
    y=x;
else
    y(1:N/2)=x(1:2:N);
    y(N/2+1:N)=x(2:2:N);
end
end
