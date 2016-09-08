%awgn信道下的极化码性能仿真
%基本参数  N为码长,n为log2(N),k为信息长度,Zw为信道Bhattacharyya值,b为frozenbit的值
clear
FRAMES=input('frames=');
MAX_FRAME_ERROR=input('max frame error=');

n=input('n=');N=2^n;                            %参数的初始化
k=input('k=');                                  %
R=k/N;                                          %
SNR_dB=input('SNR_dB=');                       %
b=0;                         %
for j=1:length(SNR_dB)
%利用SNR_dB计算出误码率，利用误码率递归关系计算     
SNR_not_dB(j)=10^(SNR_dB(j)/10);         %转化成非dB形式
var(j)=1/(2*R*SNR_not_dB(j));                       %得到噪声方差sigma^2

Z=get_awgn_bhattacharyya(N,var(j));                   %信道的Bhattacharyya参数矩阵
frame_error=0;
bit_err_num=zeros(1,FRAMES);
[Zw,index]=sort(Z,'descend');       %按照降序排列矩阵Z
free_index=index(N-k+1:N);          %信息比特的位置
frozen_index=index(1:N-k);          %frozenbit的位置
uc(frozen_index)=b;                 

tic
for frame=1:FRAMES
 
 
%信息的生成
%u为信息向量
rng('shuffle')
u=randsrc(1,k,[0 1]);

%信道的选择
%根据Bhattacharyya参数进行选择

%信息的编码
%%%%%%%%%%%%%%%%%%%编码之前的准备工作%%%%%%%%%%%%%%%%%%%%%%%%%
uc(free_index)=u;

%编码得到的码字为x
x=encoder(uc);

%AWGN信道
y=awgn_noise(x,var(j));
%译码
[u_hat,index]=decoder(y,Z,k,b,var(j));
%%input_data=u_hat(index);

%误码率

bit_err_num(frame)=biterr(u,u_hat(free_index));
if bit_err_num(frame)~=0
    frame_error=frame_error+1;
end

frame
if frame_error==MAX_FRAME_ERROR
    break;
end

end
toc
FER(j)=frame_error/frame
BER(j)=sum(bit_err_num)/(k*frame)
dlmwrite('SC_1024.txt',FER(j),'-append');
end
%semilogy(SNR_dB,BER,'-+r',SNR_dB,FER,'-*b')