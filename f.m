function y=f(x)
%alpha=-0.4527;
%beta=0.0218;
%gama=0.86;



    

    if x<10
            y=exp(-0.4527*x^0.86+0.0218);
        else
        if  x>=10
            y=0.5*(sqrt(pi/x).*exp(-x/4)*(1-3/x)+sqrt(pi/x).*exp(-x/4)*(1+1/(7*x)));
        end
    end
 
 
end


