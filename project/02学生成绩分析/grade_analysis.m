% 学生成绩数据分析与可视化工具
% 进行统计分析并生成多种可视化图表

% 清除工作区变量、命令行窗口和现有图形
clear; clc; close all;

%% 1. 生成学生成绩数据（不依赖统计工具箱）
student_names = {'John', 'Alice', 'Bob', 'Diana', 'Ethan', 'Frank', 'Grace', 'Henry'};
num_students = length(student_names);

% 生成符合正态分布的成绩，使用基础MATLAB函数替代normrnd
% 使用randn生成标准正态分布，再进行缩放和平移
math = round(75 + 10 * randn(1, num_students));
english = round(80 + 8 * randn(1, num_students));
physics = round(70 + 12 * randn(1, num_students));
chemistry = round(78 + 9 * randn(1, num_students));

% 确保成绩在0-100分范围内
math = max(0, min(100, math));
english = max(0, min(100, english));
physics = max(0, min(100, physics));
chemistry = max(0, min(100, chemistry));

% 创建成绩表格
grade_table = table(...
    math', english', physics', chemistry', ...
    'RowNames', student_names, ...
    'VariableNames', {'Math', 'English', 'Physics', 'Chemistry'});

% 显示所有学生的成绩
disp('学生成绩：');
disp(grade_table);

%% 2. 计算各科目统计量
stats_table = table(...
    [mean(math); mean(english); mean(physics); mean(chemistry)], ...
    [max(math); max(english); max(physics); max(chemistry)], ...
    [min(math); min(english); min(physics); min(chemistry)], ...
    [std(math); std(english); std(physics); std(chemistry)], ...
    [mean(math>=60); mean(english>=60); mean(physics>=60); mean(chemistry>=60)]*100, ...
    'RowNames', {'Math', 'English', 'Physics', 'Chemistry'}, ...
    'VariableNames', {'Mean', 'Max', 'Min', 'Std', 'PassRatePercent'});

% 显示统计结果
disp(' ');
disp('各科目统计数据：');
disp(stats_table);

%% 3. 数据可视化分析

% 3.1 改进的散点图 - 展示各科目成绩分布
figure('Name', '科目成绩分布', 'Position', [100, 100, 800, 600]);

% 为每个数据点创建偏移位置，确保X和Y长度匹配
positions = [1 2 3 4];  % 四个科目的位置
num_points = num_students;  % 每个科目的数据点数

% 创建科目与数据的映射关系
subject_data = {math, english, physics, chemistry};

% 绘制每个科目的所有成绩点
colors = lines(4);
for i = 1:4
    % 获取对应科目的成绩
    scores = subject_data{i};
    
    % 为每个数据点创建微小偏移，避免重叠（确保X和Y长度相同）
    x_offsets = positions(i) + 0.2 * (rand(1, num_points) - 0.5);
    
    % 绘制散点展示分布
    scatter(x_offsets, scores, 50, colors(i,:), 'filled', 'MarkerEdgeColor', 'k');
    hold on;
end

% 添加平均值参考线
plot(positions, stats_table.Mean, 'ro-', 'MarkerSize', 8, 'LineWidth', 1.5);

% 设置图表属性
title('各科目成绩分布', 'FontSize', 14, 'FontWeight', 'bold');
ylabel('成绩分数', 'FontSize', 12);
xlabel('科目', 'FontSize', 12);
set(gca, 'XTick', positions, 'XTickLabel', stats_table.Properties.RowNames, 'FontSize', 12);
legend([stats_table.Properties.RowNames; '平均值'], 'Location', 'best');
grid on;
ylim([0, 105]);
xlim([0.5, 4.5]);  % 调整X轴范围
hold off;

% 3.2 柱状图 - 各科目平均分对比
figure('Name', '科目平均分对比', 'Position', [200, 200, 700, 500]);
bar_heights = stats_table.Mean;
% 为每个科目使用不同颜色
bar(bar_heights, 'FaceColor', 'flat');
colormap(jet(4));  % 使用渐变色
set(gca, 'XTickLabel', stats_table.Properties.RowNames, 'FontSize', 12);
title('各科目平均分对比', 'FontSize', 14, 'FontWeight', 'bold');
ylabel('平均分', 'FontSize', 12);

% 使用不同垂直偏移量优化文本标签位置，避免重叠
offset = [2, 1, 3, 0]; % 每个柱子的不同偏移量
for i = 1:4
    text(i, bar_heights(i) + offset(i), ...
         num2str(bar_heights(i), '%.1f'), ...
         'HorizontalAlignment', 'center', 'FontSize', 10, ...
         'FontWeight', 'bold');
end

grid on;
ylim([0, max(bar_heights) + 5]);  % 调整Y轴范围以适应标签

% 3.3 饼图 - 各科目及格率
figure('Name', '科目及格率', 'Position', [300, 300, 600, 500]);
subjects = stats_table.Properties.RowNames;
pass_rates = stats_table.PassRatePercent;

% 生成百分比文本
percentages = arrayfun(@(x) sprintf('%.1f%%', x), pass_rates, 'UniformOutput', false);

% 生成标签
pie_labels = cell(length(subjects), 1);
for i = 1:length(subjects)
    pie_labels{i} = [subjects{i} ' ' percentages{i}];
end

% 使用自定义颜色
pie_colors = [0.4 0.7 0.9; 0.9 0.7 0.4; 0.7 0.9 0.4; 0.9 0.4 0.7];
pie(pass_rates, pie_labels);
colormap(pie_colors);
title('各科目及格率分布', 'FontSize', 14, 'FontWeight', 'bold');

% 3.4 水平条形图 - 学生总分排名
total_scores = sum(grade_table{:,:}, 2);
[~, sorted_indices] = sort(total_scores, 'descend');
sorted_names = student_names(sorted_indices);
sorted_scores = total_scores(sorted_indices);

figure('Name', '学生总分排名', 'Position', [400, 400, 700, 500]);
barh(sorted_scores, 'FaceColor', [0.2, 0.5, 0.8]);
set(gca, ...
    'YTickLabel', sorted_names, ...
    'FontSize', 11, ...
    'YDir', 'reverse');
title('学生总分排名', 'FontSize', 14, 'FontWeight', 'bold');
xlabel('总分', 'FontSize', 12);
% 只为每个学生显示总分数值
for i = 1:length(sorted_scores)
    text(sorted_scores(i) + 5, i, num2str(sorted_scores(i)), ...
         'VerticalAlignment', 'middle', 'FontSize', 10);
end
grid on;
xlim([0, max(sorted_scores) + 20]);  % 调整X轴范围

% 3.5 雷达图 - 学生个人成绩对比
figure('Name', '学生个人成绩雷达图', 'Position', [500, 100, 700, 600]);
ax = polaraxes;  % 使用专用极坐标 axes

% 定义雷达图角度
theta = linspace(0, 2*pi, 4);  % 四个科目四个角度

% 生成不同颜色
colors = lines(num_students);  

% 为每个学生绘制雷达图
plot_handles = zeros(num_students, 1);
for i = 1:num_students
    % 获取学生各科成绩
    scores = [grade_table{i,1}, grade_table{i,2}, grade_table{i,3}, grade_table{i,4}];
    
    % 绘制雷达线（闭合图形）
    plot_handles(i) = polarplot(ax, [theta, theta(1)], [scores, scores(1)], ...
                                'LineWidth', 2, 'Color', colors(i,:));
    hold on;
end

% 设置坐标轴和标签
rticks(ax, 0:20:100);
rticklabels(ax, {'0', '20', '40', '60', '80', '100'});
thetaticks(ax, theta);
thetaticklabels(ax, stats_table.Properties.RowNames);
title(ax, '学生各科成绩雷达图', 'FontSize', 14, 'FontWeight', 'bold');

% 使用绘图句柄创建图例，确保数量匹配
legend(ax, plot_handles, student_names, 'Location', 'bestoutside');
hold off;

% 3.6 直方图 - 各科目成绩分布
figure('Name', '科目成绩分布直方图', 'Position', [600, 200, 800, 600]);
bins = 0:10:100;  % 分数区间
subplot(2,2,1);
histogram(math, bins, 'FaceColor', [0.2, 0.5, 0.8]);
title('数学成绩分布', 'FontSize', 12);
xlabel('分数'); ylabel('学生数');
grid on; xlim([0,100]);

subplot(2,2,2);
histogram(english, bins, 'FaceColor', [0.5, 0.2, 0.8]);
title('英语成绩分布', 'FontSize', 12);
xlabel('分数'); ylabel('学生数');
grid on; xlim([0,100]);

subplot(2,2,3);
histogram(physics, bins, 'FaceColor', [0.8, 0.5, 0.2]);
title('物理成绩分布', 'FontSize', 12);
xlabel('分数'); ylabel('学生数');
grid on; xlim([0,100]);

subplot(2,2,4);
histogram(chemistry, bins, 'FaceColor', [0.2, 0.8, 0.5]);
title('化学成绩分布', 'FontSize', 12);
xlabel('分数'); ylabel('学生数');
grid on; xlim([0,100]);

sgtitle('各科目成绩分布直方图', 'FontSize', 14, 'FontWeight', 'bold');

%% 4. 保存结果
writetable(grade_table, 'student_grades.csv');
disp(' ');
disp('成绩数据已保存为 student_grades.csv');
disp('所有分析图表已生成，可在图形窗口查看');
