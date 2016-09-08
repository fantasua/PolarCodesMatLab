%awgn信道下的极化码性能仿真
%使用了平均分层SCL-CRC译码
%基本参数  N为码长,n为log2(N),k为信息长度,Zw为信道Bhattacharyya值,b为frozenbit的值
%G为CRC生成矩阵，K为信息进行CRC之后的长度
%layer_bound为每层结束位置,layer_number分层的层数
%保留一条通过crc校验的路径
clear
FRAMES=input('frames=');
MAX_FRAME_ERROR=input('max frame error=');
layer=input('layer=');                              %分层层数
G=[1 0 0 0 0 0 1 1 1]
n=input('n=');
N=2^n                                                  %参数的初始化
K=input('K=');                                         %信息加CRC之后的长度
k=K-(length(G)-1)*layer                              %信息长度
K_layer=K/layer                                     %每个分段CRC码字长度
k_layer=k/layer                                      %平均分段之后每段信息的长度
crc_length_layer=length(G)-1                 %每个分段CRC部分长度
R=K/N                                                   %码率，
SNR_dB=input('SNR_dB=');                    %
b=0;                        
L=32%input('L=');
err_position=zeros(length(SNR_dB),k);    %每个比特位置的错误数目



for j=1:length(SNR_dB)
%利用SNR_dB计算出误码率，利用误码率递归关系计算     
    SNR_not_dB(j)=10^(SNR_dB(j)/10);         %转化成非dB形式
    var(j)=1/(2*R*SNR_not_dB(j));                       %得到噪声方差sigma^2
    eb=exp(-1/(2*var(j)));
    Z=get_awgn_Pb(N,var(j));                   %信道的Bhattacharyya参数矩阵
    uc(1:N)=0;
    %信道的选择
    %根据Bhattacharyya参数进行选择
    [Zw,index]=sort(Z,'descend');       %按照降序排列矩阵Z
    free_index=index(N-K+1:N);          %信息比特的位置
    frozen_index=index(1:N-K);          %frozenbit的位置
    [free_index,~]=sort(free_index,'ascend');%分段crc与polar码级联时，信息比特位置需要进行一下调整
    uc(frozen_index)=b;              
    frame_error=0;
    bit_err_num=zeros(1,FRAMES);
    bit_err_pos=zeros(FRAMES,k);
    %%%%%%%%%分层边界的计算%%%%%%%%%
    crc_bound=crc_bound_cal(free_index,K_layer,layer);
    for frame=1:FRAMES


        %信息的生成
        %u为信息向量
        rng('shuffle')
        u=randsrc(1,k,[0 1]);
        %生成CRC校验码
        for kk=1:layer
            u_crc_layer(1+(kk-1)*K_layer:kk*K_layer)=crc_gen(u(1+(kk-1)*k_layer:kk*k_layer),G,K_layer);
        end




        %信息的编码
        uc(free_index)=u_crc_layer;
        %编码得到的码字为x
        x=encoder(uc);

        %AWGN信道
        y=awgn_noise(x,var(j));
        %译码
        %u_hat_crc=decoder_list_crc_layer_ver1(y,free_index,frozen_index,b,var(j),L,G,layer,crc_bound);
        u_hat_crc=decoder_list_crc_layer(y,free_index,frozen_index,b,var(j),L,G,layer,crc_bound);
        for jj=1:layer
            u_hat(1+(jj-1)*k_layer:jj*k_layer)=u_hat_crc(free_index(1+(jj-1)*K_layer:jj*K_layer-crc_length_layer));
        end

        %误帧率（直接统计误帧率了，不统计误码率）
        if isempty(u_hat_crc)==1
            frame_error=frame_error+1;
        else
            [bit_err_num(frame),~,bit_err_pos(frame,:)]=biterr(u,u_hat);
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
    FER(j)=frame_error/frame
    %dlmwrite('SC_1024_CRC_24.txt',FER(j),'-append');
end

%semilogy(SNR_dB,FER,'-*b')