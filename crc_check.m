function result=crc_check(x,G)
%CRC校验函数
%x为待校验的CRC码字，G为CRC生成多项式

crc_length=length(G);               %CRC生成多项式的长度
code_length=length(x);
quotient=[];                             %商多项式
remainder=[];                           %余数多项式
register=[];                                %计算时使用的临时向量
for k=1:code_length-crc_length+1
     if k==1
         register=x(1:crc_length);
     else
         register(1:crc_length-1)=remainder;
         register(crc_length)=x(k+crc_length-1);
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

if(sum(remainder)==0)
    result=0;
else
    result=1;
end
end