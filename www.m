function createfigure(X1, Y1, X2, Y2)
%CREATEFIGURE(X1, Y1, X2, Y2)
%  X1:  x 数据的矢量
%  Y1:  y 数据的矢量
%  X2:  x 数据的矢量
%  Y2:  y 数据的矢量

%  由 MATLAB 于 31-Mar-2016 16:15:50 自动生成

% 创建 figure
figure1 = figure;

% 创建 axes
axes1 = axes('Parent',figure1,'YScale','log','YMinorTick','on');
box(axes1,'on');
hold(axes1,'all');

% 创建 semilogy
semilogy(X1,Y1,'Parent',axes1,'Marker','*','Color',[0 0 1],'DisplayName','k=512');

% 创建 semilogy
semilogy(X2,Y2,'Parent',axes1,'Marker','*','Color',[1 0 0],'DisplayName','k=171');

% 创建 xlabel
xlabel({'SNR dB'});

% 创建 ylabel
ylabel({'BER'});

% 创建 legend
legend(axes1,'show');

