function [u_hat,u_hat_llr]=harq_decoder_sc_test(y,L_recev,var,repeatPos,u_hat,u_hat_llr,free_index,frozen_index,G)
%译码函数
%输入y为信道输出,Z为信道Bhattacharyya矩阵,k为信息长度,b为frozenbit的值,var为噪声方差/功率
N = length(y);


%u_lr = sqrt(L_recev*lr_new(y,u_hat,N,repeatPos,var));
u_hat_llr(repeatPos) = L_recev+u_hat_llr(repeatPos);
if(u_hat_llr(repeatPos) >=0)
    u_hat(repeatPos) = 0;
else
    u_hat(repeatPos) = 1;
end




isfrozen(free_index)=0;
isfrozen(frozen_index)=1;

for i=repeatPos+1:N
    if isfrozen(i)==1;
        u_hat(i)=0;
        u_hat_llr(i)=100000;
    else
       M0=logAPP1(y,u_hat,0,N,i,var);
       M1=logAPP1(y,u_hat,1,N,i,var);
        if M0>=M1
            u_hat(i)=0;
        else
            u_hat(i)=1;
        end
        u_hat_llr(i)=M0-M1;
    end
end

result=crc_check(u_hat(free_index),G);
if result==0
    crc_checked = 1;       %CRC校验通过
else
    crc_checked=0;

    

end
        

