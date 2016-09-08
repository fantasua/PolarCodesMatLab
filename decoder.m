function [u_hat,free_index]=decoder(y,Z,k,b,var)
%译码函数
%输入y为信道输出,Z为信道Bhattacharyya矩阵,k为信息长度,b为frozenbit的值,var为噪声方差/功率

N=length(y);                        %码长N
[Zw,index]=sort(Z,'descend');       %信道Bhattacharyya参数排序
frozen_index=index(1:N-k);          %frozenbit位置
free_index=index(N-k+1:N);          %信息比特位置

isfrozen(frozen_index)=1;           %frozenbit标记
isfrozen(free_index)=0;             %信息比特


u_hat(1:N)=0;
for i=1:N
    if isfrozen(i)==1;
        u_hat(i)=b;
    else
        h=llr_new(y,u_hat,N,i,var);
        if h>=1
            u_hat(i)=0;
        else
            u_hat(i)=1;
        end
    end
end

end
        

