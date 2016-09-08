function Z=get_bec_bhattacharyya(N,e)
%函数用来计算BEC信道的Bhattacharyya参数
%输入为信道个数N,BEC擦除概率e
%输出为Bhattacharyya参数矩阵

n=log2(N);
temp=e;
for i=1:n
    for ii=1:2^(i-1)
        temp1(2*ii-1)=2*temp(ii)-temp(ii)*temp(ii);
        temp1(2*ii)=temp(ii)*temp(ii);
    end
    temp=temp1;
end

Z=temp;

end