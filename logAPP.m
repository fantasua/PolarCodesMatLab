function M=logAPP(y,u_hat,ui,N,i,var)
%码树度量对数logAPP(a posterior probability,后验概率)计算函数
%函数功能是计算出码树的某一层的所有路径的APP值，然后进行选路
%y为接受向量；u_hat为收端对信息的估计,前(i-1)个；N为码长；i为当前APP计算的比特位置

if N~=2             %未满足递归终止条件，递归继续
    if mod(i,2)==1
        if i==1
            M=max_star(logAPP(y(1:N/2),u_hat,mod(ui+0,2),N/2,i,var)+logAPP(y(N/2+1:N),u_hat,0,N/2,i,var),logAPP(y(1:N/2),u_hat,mod(ui+1,2),N/2,i,var)+logAPP(y(N/2+1:N),u_hat,1,N/2,i,var));
        else
            uoe=mod(u_hat(1:2:i-1)+u_hat(2:2:i-1),2);
            ue=u_hat(2:2:i-1);
            M=max_star(logAPP(y(1:N/2),uoe,mod(ui+0,2),N/2,(i+1)/2,var)+logAPP(y(N/2+1:N),ue,0,N/2,(i+1)/2,var),logAPP(y(1:N/2),uoe,mod(ui+1,2),N/2,(i+1)/2,var)+logAPP(y(N/2+1:N),ue,1,N/2,(i+1)/2,var));
        end
    else
        uoe=mod(u_hat(1:2:i-2)+u_hat(2:2:i-2),2);
        ue=u_hat(2:2:i-2);
        M=logAPP(y(1:N/2),uoe,mod(u_hat(i-1)+ui,2),N/2,i/2,var)+logAPP(y(N/2+1:N),ue,ui,N/2,i/2,var);
    end
else
    switch i
        case 1
            M=max_star(logAPP_base(y(1),ui,var)+logAPP_base(y(2),0,var),logAPP_base(y(1),mod(ui+1,2),var)+logAPP_base(y(2),1,var));
        case 2
            M=logAPP_base(y(1),mod(u_hat(1)+ui,2),var)+logAPP_base(y(2),ui,var);
    end
    
end
end