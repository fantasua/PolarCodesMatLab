function u_crc=crc_gen(x,G,N)
%crc校验码生成函数
%x为输入 G为生成多项式 N为最后的码长

crc_length=length(G);               %CRC生成多项式的长度
info_length=length(x);
quotient=[];                             %商多项式
remainder=[];                           %余数多项式
u_crc(1:info_length)=x;
u_crc(info_length+1:N)=0;
register=[];                                %计算时使用的临时向量
for k=1:info_length
     if k==1
         register=u_crc(1:crc_length);
     else
         register(1:crc_length-1)=remainder;
         register(crc_length)=u_crc(k+crc_length-1);
     end
     if register(1)~=1
         quotient(k)=0;
         remainder=register(2:crc_length);
         continue
     else
         quotient(k)=1;
         temp=bitxor(register,G);
         remainder=temp(2:crc_length);
     end
     
end
u_crc(info_length+1:N)=remainder;
end