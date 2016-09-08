function p = logAPPBase(y, x, var)
%物理信道对数后验概率函数logAPP(x|y)

p = log(W(y, x, var)/(W(y, 0, var)+W(y, 1, var)));
