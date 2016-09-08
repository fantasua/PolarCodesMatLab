function u_hat=decoder_list_crc_layer_new_ver1(y,free_index,frozen_index,b,var,L,G,layer,crc_bound)
%译码函数
%输入y为信道输出,Z为信道Bhattacharyya矩阵,k为信息长度,b为frozenbit的值,var为噪声方差/功率
%L为保留的译码路径数目
%G为CRC生成矩阵
%layer为分成的层数
N=length(y);                        %码长N
stack=L;                            %每层保留的路径个数,终于可以随意指定了

isfrozen(frozen_index)=1;           %frozenbit标记
isfrozen(free_index)=0;             %信息比特

u_hat=[];                                   %译码结果
u_hat_temp=zeros(1,N);                      %分段的保留路径
u_hat_temp_num=1;                           %分段路径数目
%下面为SCL译码部分
selections=zeros(1,N);                            %候选路径
selections_temp=zeros(1,N);
node=0;                           %每个父节点下的2个子节点的APP值，在候选路径填满之后用于选路比较，第(2i-1)列代表第i个节点取0的logAPP，第(2i)列代表第i个节点取1的logAPP
flag=[0,crc_bound(2:layer+1)];          %路径标志

                                      
for ii=1:layer
    freeflag=u_hat_temp_num;                                                                                         %用来记录当前信息比特译码译到的位置
    for i=flag(ii)+1:flag(ii+1)
        if isfrozen(i)==0
            
            
            if freeflag*2 <= L                                                                     %在后选路径被填满之前，程序没有对logAPP进行计算
                
                selections_temp=selections;
                for j=1:freeflag
                    selections(2*j-1,:)=selections_temp(j,:);
                    selections(2*j,:)=selections_temp(j,:);

                    selections(2*j-1,i)=0;                                          %路径更新
                    selections(2*j,i)=1;   
                end
                freeflag=freeflag*2;

                
            else
                if(freeflag<L)
                    Li=freeflag;
                else
                    Li=L;                    
                end
                for j=1:Li
                    selections_temp(2*j-1,:)=selections(j,:);
                    selections_temp(2*j,:)=selections(j,:);
                    selections_temp(2*j-1,i)=0;
                    selections_temp(2*j,i)=1;
                    
                    node(2*j-1)=logAPP1(y,selections(j,:),0,N,i,var);   %logAPP的计算
                    node(2*j)=logAPP1(y,selections(j,:),1,N,i,var);       %
                   
                end
                [~,I]=sort(node,'descend');
                selections=selections_temp(I(1:L),:);
                selections_temp=zeros(1,N);
            end
        end
        
            
    end
    %下面是CRC校验部分
    free_layer=find(isfrozen(flag(ii)+1:flag(ii+1))~=1)+flag(ii);
    jjj=1;
    for kk=1:L
        result=crc_check(selections(kk,free_layer),G{ii});
        if result==0
            u_hat_temp(jjj,:)=selections(kk,:);      %CRC校验通过
             jjj=jjj+1;
             break;
%              if(jjj==stack+1)
%                  break;                  %保留路径填满
%              end
        end
    end
u_hat_temp_num=size(u_hat_temp,1);    
    if jjj==1
       for pp=1:u_hat_temp_num
           u_hat_temp(pp,:)=selections(pp,:);%若没有路径通过校验
       end
    end
  if ii~=layer
    selections=u_hat_temp;          %路径变量恢复初始化
    u_hat_temp=zeros(1,N);
    node=0; 
    selections_temp=zeros(1,N);
  end
end
u_hat=u_hat_temp(1,:);
end
        

