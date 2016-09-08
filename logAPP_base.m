function M=logAPP_base(y,x,var)
%logAPP的N=1的表达式
M=log(W(y,x,var)/(W(y,0,var)+W(y,1,var)));
