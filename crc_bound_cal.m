function bound=crc_bound_cal(free_index,K_layer,layer)
%%%%%%%crc分层边界计算函数%%%%%%%%%%
%free_index为信息位向量，分层极化码每层的长度，layer为层数
bound=zeros(1,layer+1);
bound(1)=free_index(1);
for i=1:layer
    bound(i+1)=free_index(K_layer*i);
end
