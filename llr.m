function L=llr(y,u_hat,N,i,var)
%函数用来计算最大似然比,函数使用的递归的思路
%参数y,为译码器输入,u_hat为前面的译码结果,N为码长,i为当前要计算的译码输出编号

if N~=1                         %没有满足递归终止条件,递归继续
    if mod(i,2)==1              %i为奇数时
          
        uoe=mod(u_hat(1:2:i-1)+u_hat(2:2:i-1),2);                                                                                                               %i~=1时
        ue=u_hat(2:2:i-1);
    % L=(llr(y(1:N/2),uoe,N/2,(i+1)/2,var)*llr(y(N/2+1:N),ue,N/2,(i+1)/2,var)+1)/(llr(y(1:N/2),uoe,N/2,(i+1)/2,var)+llr(y(N/2+1:N),ue,N/2,(i+1)/2,var));
        L=f_minus( llr(y(1:N/2),uoe,N/2,(i+1)/2,var), llr(y(N/2+1:N),ue,N/2,(i+1)/2,var) );
%             if L>100
%                 L=100;
%             else
%                 if L<1/100
%                     L=1/100;
%                 end
%             end
        
    else                        %i为偶数时
        uoe=mod(u_hat(1:2:i-2)+u_hat(2:2:i-2),2);
        ue=u_hat(2:2:i-2);
%         L=llr(y(1:N/2),uoe,N/2,i/2,var)^(1-2*u_hat(i-1))*llr(y(N/2+1:N),ue,N/2,i/2,var);
        L=f_plus(llr(y(1:N/2),uoe,N/2,i/2,var), llr(y(N/2+1:N),ue,N/2,i/2,var), u_hat(i-1));
%         if L>100
%             L=100;
%         else
%             if L<1/100
%                 L=1/100;
%             end
%         end
    end
else
    L=-2*y/var;
    
end
        
    
end


        
