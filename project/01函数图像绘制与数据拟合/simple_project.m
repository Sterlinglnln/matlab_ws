clear; clc;

%% 1. 绘制函数图像
x = linspace(0, 10, 100);
y = sin(x) + 0.5 * cos(2*x);

figure
plot(x, y, 'b-', 'LineWidth', 2);
title('函数 y = sin(x) + 0.5 * cos(2*x) 的图像');    %图形标题
xlabel('x');
ylabel('y');
grid on;

%% 2. 生成带噪声的数据并且拟合
noise = 0.2 * randn(size(x));
y_noise = y + noise;

p = polyfit(x, y_noise, 4);
y_fit = polyval(p, x);

figure;
plot(x, y_noise, 'ro', 'MarkerSize', 5);
hold on;
plot(x, y_fit, 'g-', 'LineWidth', 2);
title('带噪声数据与多项式拟合');
xlabel('x');
ylabel('y');
legend('带噪声数据', '4次多项式拟合');
grid on;
