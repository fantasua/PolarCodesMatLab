function [u_hat,free_index]=decoder_list(y,free_index,frozen_index,b,var,L)
%译码函数
%输入y为信道输出,free_index为信息比特位置，frozen_index为冻结比特位置,k为信息长度,b为frozenbit的值,var为噪声方差/功率
%L为保留的译码路径数目
N=length(y);                        %码长N


isfrozen(frozen_index)=1;           %frozenbit标记
isfrozen(free_index)=0;             %信息比特

%下面为SCL译码部分
selections(L,N)=0;                            %候选路径
node(1:2*L)=0;                           %每个父节点下的2个子节点的APP值，在候选路径填满之后用于选路比较
                                                %第(2i-1)列代表第i个节点取0的logAPP，第(2i)列代表第i个节点取1的logAPP
flag=0;                                     %当前译到的信息比特
for i=1:N
    if isfrozen(i)==0
    flag=flag+1;
        if 2^flag <= L                                                                     %在后选路径被填满之前，程序没有对logAPP进行计算
            if flag == 1
                selections(1,i) = 0;
                selections(2,i) = 1;
            else
                temp=selections;
                for j=1:2^(flag-1)
                    selections(2*j-1,:)=temp(j,:);
                    selections(2*j,:)=temp(j,:);

                    selections(2*j-1,i)=0;                                          %路径更新
                    selections(2*j,i)=1;   
                end

            end
        else

            for j=1:L
                selections_temp(2*j-1,:)=selections(j,:);
                selections_temp(2*j,:)=selections(j,:);
                selections_temp(2*j-1,i)=0;
                selections_temp(2*j,i)=1;
                
                node(2*j-1)=logAPP1(y,selections(j,:),0,N,i,var);%logAPP的计算
                node(2*j)=logAPP1(y,selections(j,:),1,N,i,var);%
                
            end
        [~,I]=sort(node,'descend');
        selections=selections_temp(I(1:L),:);
        end
    end
end
u_hat=selections(1,:);      
end
        

