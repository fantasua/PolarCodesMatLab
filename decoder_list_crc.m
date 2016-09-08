function [u_hat, crc_checked]=decoder_list_crc(y,free_index,frozen_index,b,var,L,G)
%译码函数
%输入y为信道输出,Z为信道Bhattacharyya矩阵,k为信息长度,b为frozenbit的值,var为噪声方差/功率
%L为保留的译码路径数目
%G为CRC生成矩阵
%程序在路径扩展是，只在信息比特的位置进行路径扩展，在冻结比特位置不进行路径扩展
N=length(y);                        %码长N


isfrozen(frozen_index)=1;           %frozenbit标记
isfrozen(free_index)=0;             %信息比特

%下面为SCL译码部分
selections(L,N)=0;                            %候选路径
node(1:2*L)=0;                           %每个父节点下的2个子节点的APP值，在候选路径填满之后用于选路比较
                                                %第(2i-1)列代表第i个节点取0的logAPP，第(2i)列代表第i个节点取1的logAPP
flag=0;                                     %用来记录当前译码译到了的信息比特的位置
for i=1:N
    if isfrozen(i)==0                                                             %遇到信息比特，进行路径扩展
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
%下面是CRC校验部分
for kk=1:L
    result=crc_check(selections(kk,free_index),G);
    if result==0
        u_hat=selections(kk,:);      %CRC校验通过
        crc_checked = 1;
        break;                          
    end
end
if kk==L                                  %CRC校验未通过
    u_hat=selections(1,:);
    crc_checked = 0;
end
end
        

