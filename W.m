function p=W(y,x,var)
%物理信道转移概率函数W(y|x)
p=1/sqrt(2*pi*var)*exp(-(y-(2*x-1)).^2/(2*var));