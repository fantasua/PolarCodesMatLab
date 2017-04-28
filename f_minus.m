function res=f_minus(alpha, beta)
%%log-likelihood calculation uses this function

res=sign(alpha) * sign(beta) * min( abs(alpha), abs(beta) );
