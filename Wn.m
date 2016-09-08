function M=Wn(y,u_hat,ui,N,i,var)
%码树度量信道转移函数
%函数功能是计算出码树的某一层的所有路径的APP值，然后进行选路
%y为接受向量；u_hat为收端对信息的估计,前(i-1)个；N为码长；i为当前APP计算的比特位置

if N~=2             %未满足递归终止条件，递归继续
    if mod(i,2)==1
        if i==1
            M=0.5*(Wn(y(1:N/2),u_hat,mod(ui+0,2),N/2,i,var)*Wn(y(N/2+1:N),u_hat,0,N/2,i,var)+Wn(y(1:N/2),u_hat,mod(ui+1,2),N/2,i,var)*Wn(y(N/2+1:N),u_hat,1,N/2,i,var));
        else
            uoe=mod(u_hat(1:2:i-1)+u_hat(2:2:i-1),2);
            ue=u_hat(2:2:i-1);
            M=0.5*(Wn(y(1:N/2),uoe,mod(ui+0,2),N/2,(i+1)/2,var)*Wn(y(N/2+1:N),ue,0,N/2,(i+1)/2,var)+Wn(y(1:N/2),uoe,mod(ui+1,2),N/2,(i+1)/2,var)*Wn(y(N/2+1:N),ue,1,N/2,(i+1)/2,var));
        end
    else
        uoe=mod(u_hat(1:2:i-2)+u_hat(2:2:i-2),2);
        ue=u_hat(2:2:i-2);
        M=0.5*Wn(y(1:N/2),uoe,mod(u_hat(i-1)+ui,2),N/2,i/2,var)*Wn(y(N/2+1:N),ue,ui,N/2,i/2,var);
    end
else
    switch i
        case 1
            M=0.5*(W(y(1),ui,var)*W(y(2),0,var)+W(y(1),mod(ui+1,2),var)*W(y(2),1,var));
        case 2
            M=0.5*W(y(1),mod(u_hat(1)+ui,2),var)*W(y(2),ui,var);
    end
    
end
end