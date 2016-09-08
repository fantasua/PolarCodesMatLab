%awgn信道下的长度自适应极化码性能仿真
%基本参数
%N为码长,n为log2(N),k为信息长度,Zw为信道Bhattacharyya值,b为frozenbit的值，M是puncturing之后的码长 retrans_ability为最大重传次数
clear
% FRAMES=input('frames=');
% MAX_FRAME_ERROR=input('max frame error=');
% 
% n=input('n=');N=2^n;                            %参数的初始化
% k=input('k=');                                  %
% R=k/N;                                          %
% SNR_dB=input('SNR_dB=');                       %
FRAMES=1;
MAX_FRAME_ERROR=20;
n=4;
N=2^n;                            %参数的初始化
M=16;                      %punctured码字长度
k=8;                                  %
R=k/M;                                          %
SNR_dB=2;                       %
b=0;                         %         %
retrans_ability=1; %设置最大重传次数retrans_ability 


for j=1:length(SNR_dB)
%利用SNR_dB计算出误码率，利用误码率递归关系计算     
SNR_not_dB(j)=10^(SNR_dB(j)/10);         %转化成非dB形式
var(j)=1/(2*R*SNR_not_dB(j));                       %得到噪声方差sigma^2
Z=get_awgn_bhattacharyya(N,var(j));                   %信道的Bhattacharyya参数矩阵

%%     %%%%%%%先对Z进行bit翻转，根据FN和翻转后Z值求frozenbits位置，令其Z=1.1；再bit翻转回来

tic
%%%%求比特翻转后的Z序列
Z_rev=zeros(1,N);
for i=1:N
   Z_rev(i)=Z(bin2dec(fliplr(dec2bin(i-1,n)))+1);           %%bit翻转后极化信道的Bhattacharyya参数
end

%%%构造bit翻转后的矩阵FN
FN=eye(1);             
F0=[1 0;1 1];
for i=1:n
    FN=kron(FN,F0);
end
% GN=zeros(1,N);
% for i=1:N
%     GN(i,:)=FN(bin2dec(fliplr(dec2bin(i-1,n)))+1,:);           %%生成矩阵GN
% end

%% 选择frozen bits集合F，puncture bits集合P，置frozenbit对应的Z值=1.1 
indeP=zeros(1,N-M);
puncFN=FN;
for i=1:(N-M)
  candiF=find (sum(puncFN)==1);   %%%寻找列重为1的列（1在对角线位置，所以1的行列号相等），其1所在行作为候选frozen bit位 
  if length(candiF)==1   %%FN只有1列重为1，直接作为frozen bit位；否则按Z由大到小选择
      indeP(i)=candiF;
  else
      indeP(i)=candiF(find(Z_rev((candiF))==max(Z_rev(candiF))));      
  end
      Z_rev(indeP(i))=1.1;
      puncFN(indeP(i),:)=0;
      puncFN(:,indeP(i))=0;
end
%% 
%%%对得到的Z_rev进行bit翻转，得到
Z_rev_rev=zeros(1,N);
for i=1:N
    Z_rev_rev(i)=Z_rev(bin2dec(fliplr(dec2bin(i-1,n)))+1);           %%bit翻转后极化信道的Bhattacharyya参数
end
toc
%% 

frame_error=0;
bit_err_num=zeros(1,FRAMES);
[Zw,index]=sort(Z_rev_rev,'descend');       %按照降序排列矩阵Z
free_index=index(N-k+1:N);          %信息比特的位置
frozen_index=index(1:N-k);          %frozenbit的位置  
puncture_index=indeP;               %puncturebit的位置
rechans_index=index(N-k+1:N-k+1+retrans_ability );          %重传信息比特的位置
uc(frozen_index)=b;      
     


tic
for frame=1:FRAMES
     
%信息的生成
%u为信息向量
u=randsrc(1,k,[0 1]);

%信息的编码
%%%%%%%%%%%%%%%%%%%编码之前的准备工作%%%%%%%%%%%%%%%%%%%%%%%%%
uc(free_index)=u;

%编码得到的码字为x
x=encoder(uc);

%AWGN信道
y=awgn_noise(x,var(j));
y(puncture_index)=-1;%%punctured bit已知为0
%译码
[u_hat,index]=decoder(y,Z_rev_rev,k,b,var(j));
%%input_data=u_hat(index)
%误码率

bit_err_num(frame)=biterr(u,u_hat(free_index));
if bit_err_num(frame)~=0
    ACK=0;  %设置接收标志，0表示拒绝，1表示接受
else
    ACK=1;    
end
%% 重传
L_recev=ones(1,N);
retrans_cnt = 0; %设置重传次数计数器
%% 
while ACK == 0 && retrans_cnt < retrans_ability  
    retrans_cnt = retrans_cnt+1;
    %重传信息位经过AWGN信道
    y_recev=awgn_noise(u(retrans_cnt),var(j));   %%第i次重传
    L_recev(free_index(retrans_cnt))=exp(-2*y_recev/var);
    %译码
%     [u_hat,index]=decoder(y,Z_rev_rev,k,b,var(j));
    [u_hat,index]=harq_decoder(y,L_recev,Z_rev_rev,k,b,var(j)); %%%  有harq重传的译码：将重传bit的软信息合并后译码
    bit_err_num(frame)=biterr(u,u_hat(free_index));    
    if bit_err_num(frame)~=0
        ACK=0;  %设置接收标志，0表示拒绝，1表示接受
    else ACK=1;
    end  
end

bit_err_num(frame)=biterr(u,u_hat(free_index));
if bit_err_num(frame)~=0
    frame_error=frame_error+1;
end

     
  %% 


frame
retrans_cnt
if frame_error==MAX_FRAME_ERROR
    break;
end

end
toc
FER(j)=frame_error/frame
BER(j)=sum(bit_err_num)/(k*frame)
dlmwrite('polar_awgn_punc_harq.txt',FER(j),'-append');
end
%semilogy(SNR_dB,BER,'-+r',SNR_dB,FER,'-*b')