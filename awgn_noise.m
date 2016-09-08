function y=awgn_noise(x,var)
%二进制输入awgn信道,x表示输入,var表示信道的噪声方差,y为信道输出
N=length(x);
rng('shuffle')
z=sqrt(var)*randn(1,N);
y=2*x-1+z;
end