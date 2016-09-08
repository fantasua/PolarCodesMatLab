%awgn信道下的极化码性能仿真
%使用了平均分层SCL-CRC译码
%基本参数  N为码长,n为log2(N),k为信息长度,Zw为信道Bhattacharyya值,b为frozenbit的值
%G为CRC生成矩阵，K为信息进行CRC之后的长度
%layer_bound为每层结束位置,layer_number分层的层数
clear
FRAMES=100%input('frames=');
MAX_FRAME_ERROR=FRAMES%input('max frame error=');
G=[1 0 0 0 1 0 0 0 0 0 0 1 0 0 0 0 1]
L=16
n=10%input('n=');
N=2^n                                                  %参数的初始化
K=320%input('K=');                                         %信息加CRC之后的长度
k=K+1-length(G)                                   %信息长度
M=640
T=6     %最大重传次数
repeatNumber = 1        %重传的比特数目
R=K/M                                                   %码率，根据陈凯论文，码率使用K/N来计算
SNR_dB=input('SNR_dB=');                       %
b=0;                        
err_position=zeros(length(SNR_dB),k);    %每个比特位置的错误数目

P0=[zeros(1,N-M) ones(1,M)];
for i=1:N
    P0_v(:,i)=P0(1,bin2dec(fliplr(dec2bin(i-1,n)))+1);           %%bit-reversal
end
indeP=find(P0_v==0);%打孔位置
indeR=find(P0_v==1);%保留位置


for j=1:length(SNR_dB)
%利用SNR_dB计算出误码率，利用误码率递归关系计算     
SNR_not_dB(j)=10^(SNR_dB(j)/10);         %转化成非dB形式
var(j)=1/(2*R*SNR_not_dB(j));                       %得到噪声方差sigma^2
%eb=exp(-1/(2*var(j)));
frame_error=0;
bit_err_num=zeros(1,FRAMES);
bit_err_pos=zeros(FRAMES,k);
[Z, M]=get_punc_awgn_Pb(N, var(j),indeR);                   %信道的Bhattacharyya参数矩阵
uc(1:N)=0;
[~,index]=sort(Z,'descend');       %按照降序排列矩阵Z

free_index_Z=index(N-K+1:N);          %信息比特的位置

[free_index, infoOrder]=sort(free_index_Z,'ascend');

frozen_index=index(1:N-K);          %frozenbit的位置
uc(frozen_index)=b;


for frame=1:FRAMES
free_index_harq=free_index_Z; 
M_info=M(free_index_Z);
Z_info=Z(free_index_Z);
tic
%信息的生成
%u为信息向量
rng('shuffle')
u=randsrc(1,k,[0 1]);
u_crc=crc_gen(u,G,K);                                   %生成CRC校验码
%信道的选择
%根据Bhattacharyya参数进行选择


%信息的编码
uc(free_index)=u_crc;
%编码得到的码字为x
x=encoder(uc);

%AWGN信道

y=awgn_noise(x,var(j));
yp(indeP)=0;
yp(indeR)=y(indeR);
%译码
% [u_hat_crc,crc_checked]=decoder_tree_crc(yp, free_index, frozen_index, b, var(j), G);
u_hat_crc=decoder_list_crc(y,free_index,frozen_index,b,var,L,G);
%HARQ过程
t = 1;
Z_harq=Z;
%     while(crc_checked ~= 1 && t<=T)
%        
%        repeatPos = free_index_harq(1)
%        y_repeat = awgn_noise(uc(repeatPos),var(j));
%        y_repeat_ll = (-2*y_repeat./var(j));
%        M_info(1)=(M_info(1)+2/var(j));
%        Z_info=1-qfunc(sqrt(M_info./2)*(-1));
%        [u_hat_crc,crc_checked]=harq_decoder_sc(yp,y_repeat_ll,var(j),repeatPos,u_hat_crc,free_index,frozen_index,G);
%        [Z_info, ppp]=sort(Z_info, 'descend');
%        M_info=M_info(ppp);
%        free_index_harq=free_index_harq(ppp);
%        t=t+1;
%        
%     end

%误帧率（直接统计误帧率了，不统计误码率）
if isempty(u_hat_crc)==1
    frame_error=frame_error+1;
else
    [bit_err_num(frame),~,bit_err_pos(frame,:)]=biterr(u,u_hat_crc(free_index(1:k)));
    if bit_err_num(frame)~=0
        frame_error=frame_error+1;
    end
end
err_position(j,:)=err_position(j,:)+bit_err_pos(frame,:);
frame
if frame_error==MAX_FRAME_ERROR
    break;
end

end
BER(j)=sum(bit_err_num)/(k*FRAMES)
FER(j)=frame_error/frame
toc
%dlmwrite('SC_1024_CRC_24.txt',FER(j),'-append');
end



%semilogy(SNR_dB,FER,'-*b')