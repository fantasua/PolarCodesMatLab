function x=encoder(u)
%编码函数,输入为一已经按照freebit和frozenbit拍好顺序的uc
N=length(u);
n=log2(N);
if n==1
    x(1)=mod(u(1)+u(2),2);
    x(2)=u(2);
else
    temp(1:2:N)=mod(u(1:2:N)+u(2:2:N),2);
    temp(2:2:N)=u(2:2:N);
    temp=rev_shuffle(temp);
    
    x1=encoder(temp(1:N/2));
    x2=encoder(temp(N/2+1:N));
    x=[x1,x2];
end



end

