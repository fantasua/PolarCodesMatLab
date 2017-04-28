function res=f_plus(alpha, beta, u)
%%function used in log-likelihood calculation

res = sign(-2*u+1) *alpha+beta;

end
