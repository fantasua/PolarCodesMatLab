clear
SNR_dB=[1.5 (1.6:0.2:2.4) 2.5]
R=0.5
N=512
K=N*R
for j=1:length(SNR_dB)
%利用SNR_dB计算出误码率，利用误码率递归关系计算     
SNR_not_dB(j)=10^(SNR_dB(j)/10);         %转化成非dB形式
var(j)=1/(2*R*SNR_not_dB(j));                       %得到噪声方差sigma^2
eb=exp(-1/(2*var(j)));
frame_error=0;

Z=get_bec_bhattacharyya(N,eb);                   %信道的Bhattacharyya参数矩阵
uc(1:N)=0;
[Zw,index]=sort(Z,'descend');       %按照降序排列矩阵Z
free_index(j,:)=index(N-K+1:N);          %信息比特的位置
%[free_index,~]=sort(free_index,'ascend');

frozen_index(j,:)=index(1:N-K);          %frozenbit的位置


free_index_sort(j,:) = sort(free_index(j,:),'descend');
Channel(j,:)=Z(free_index(j,:));
end

for j = 1:length(SNR_dB)
    for k = 1:K
        if(free_index_sort(j,k) == free_index_sort(4,k))
            unequal(j,k)=0;
        else
            unequal(j,k)=1;
        end
    end
end