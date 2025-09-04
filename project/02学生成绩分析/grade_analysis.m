% Student Grade Data Analysis and Visualization Tool
% Function: Generate simulated grade data, perform statistical analysis,
% and generate various visualizations

% Clear workspace variables, command window, and existing figures
clear; clc; close all;

%% 1. Generate student grade data
student_names = {'John', 'Alice', 'Bob', 'Diana', 'Ethan', 'Frank', 'Grace', 'Henry'};
num_students = length(student_names);

% Generate grades for four subjects using normal distribution
math = round(normrnd(75, 10, [1, num_students]));
english = round(normrnd(80, 8, [1, num_students]));
physics = round(normrnd(70, 12, [1, num_students]));
chemistry = round(normrnd(78, 9, [1, num_students]));

% Ensure grades are within 0-100 range
math = max(0, min(100, math));
english = max(0, min(100, english));
physics = max(0, min(100, physics));
chemistry = max(0, min(100, chemistry));

% Create grade table
grade_table = table(...
    math', english', physics', chemistry', ...
    'RowNames', student_names, ...
    'VariableNames', {'Math', 'English', 'Physics', 'Chemistry'});

% Display all student grades
disp('Student Grades:');
disp(grade_table);

%% 2. Calculate subject statistics
stats_table = table(...
    [mean(math); mean(english); mean(physics); mean(chemistry)], ...
    [max(math); max(english); max(physics); max(chemistry)], ...
    [min(math); min(english); min(physics); min(chemistry)], ...
    [std(math); std(english); std(physics); std(chemistry)], ...
    [mean(math>=60); mean(english>=60); mean(physics>=60); mean(chemistry>=60)]*100, ...
    'RowNames', {'Math', 'English', 'Physics', 'Chemistry'}, ...
    'VariableNames', {'Mean', 'Max', 'Min', 'Std', 'PassRatePercent'});

% Display statistical results
disp(' ');
disp('Subject Statistics:');
disp(stats_table);

%% 3. Data visualization analysis

% 3.1 Box plot - Show subject grade distribution
figure('Name', 'Subject Grade Distribution', 'Position', [100, 100, 800, 600]);
boxplot([math; english; physics; chemistry]', ...
        'Labels', {'Math', 'English', 'Physics', 'Chemistry'}, ...
        'Notch', 'on', ...
        'Colors', [0.2 0.5 0.8]);  % Set uniform color
title('Boxplot of Subject Grades', 'FontSize', 14, 'FontWeight', 'bold');
ylabel('Grade Score', 'FontSize', 12);
grid on;

% Add mean reference line and store handle
hold on;
h_mean = plot(1:4, stats_table.Mean, 'ro-', 'MarkerSize', 8, 'LineWidth', 1.5);

% Fix legend warning by ensuring exact match between handles and labels
% Get boxplot median line handles (one per subject)
box_medians = findobj(gca, 'Type', 'line', 'Tag', 'BoxplotMedian');

% Only use the first boxplot median handle to represent all boxplots
if ~isempty(box_medians)
    legend_handles = [box_medians(1); h_mean];
    legend_labels = {'Data Distribution', 'Mean Value'};
    legend(legend_handles, legend_labels, 'Location', 'best');
end

% 3.2 Bar chart - Subject average comparison
figure('Name', 'Subject Average Comparison', 'Position', [200, 200, 700, 500]);
bar_heights = stats_table.Mean;
% Use different colors for each subject
bar(bar_heights, 'FaceColor', 'flat');
colormap(jet(4));  % Use gradient colors
set(gca, 'XTickLabel', stats_table.Properties.RowNames, 'FontSize', 12);
title('Average Score by Subject', 'FontSize', 14, 'FontWeight', 'bold');
ylabel('Average Score', 'FontSize', 12);

% Optimize text label position to avoid overlap with different vertical offsets
offset = [2, 1, 3, 0]; % Different offsets for each bar
for i = 1:4
    text(i, bar_heights(i) + offset(i), ...
         num2str(bar_heights(i), '%.1f'), ...
         'HorizontalAlignment', 'center', 'FontSize', 10, ...
         'FontWeight', 'bold');
end

grid on;
ylim([0, max(bar_heights) + 5]);  % Adjust Y-axis range to fit labels

% 3.3 Pie chart - Subject pass rates
figure('Name', 'Subject Pass Rates', 'Position', [300, 300, 600, 500]);
subjects = stats_table.Properties.RowNames;
pass_rates = stats_table.PassRatePercent;

% Generate percentage text
percentages = arrayfun(@(x) sprintf('%.1f%%', x), pass_rates, 'UniformOutput', false);

% Generate labels
pie_labels = cell(length(subjects), 1);
for i = 1:length(subjects)
    pie_labels{i} = [subjects{i} ' ' percentages{i}];
end

% Use custom colors
pie_colors = [0.4 0.7 0.9; 0.9 0.7 0.4; 0.7 0.9 0.4; 0.9 0.4 0.7];
pie(pass_rates, pie_labels);
colormap(pie_colors);
title('Pass Rate Distribution by Subject', 'FontSize', 14, 'FontWeight', 'bold');

% 3.4 Horizontal bar chart - Student total score ranking
total_scores = sum(grade_table{:,:}, 2);
[~, sorted_indices] = sort(total_scores, 'descend');
sorted_names = student_names(sorted_indices);
sorted_scores = total_scores(sorted_indices);

figure('Name', 'Student Total Score Ranking', 'Position', [400, 400, 700, 500]);
barh(sorted_scores, 'FaceColor', [0.2, 0.5, 0.8]);
set(gca, ...
    'YTickLabel', sorted_names, ...
    'FontSize', 11, ...
    'YDir', 'reverse');
title('Student Ranking by Total Score', 'FontSize', 14, 'FontWeight', 'bold');
xlabel('Total Score', 'FontSize', 12);
% Only display the total score for each student
for i = 1:length(sorted_scores)
    text(sorted_scores(i) + 5, i, num2str(sorted_scores(i)), ...
         'VerticalAlignment', 'middle', 'FontSize', 10);
end
grid on;
xlim([0, max(sorted_scores) + 20]);  % Adjust X-axis range

% 3.5 Radar chart - Individual student performance comparison
figure('Name', 'Student Individual Grade Radar Chart', 'Position', [500, 100, 700, 600]);
ax = polaraxes;  % Use dedicated polar axes

% Define radar chart angles
theta = linspace(0, 2*pi, 4);  % Four angles for four subjects

% Generate different colors
colors = lines(num_students);  

% Plot radar chart for each student
plot_handles = zeros(num_students, 1);
for i = 1:num_students
    % Get student's scores in each subject
    scores = [grade_table{i,1}, grade_table{i,2}, grade_table{i,3}, grade_table{i,4}];
    
    % Plot radar line (closed shape)
    plot_handles(i) = polarplot(ax, [theta, theta(1)], [scores, scores(1)], ...
                                'LineWidth', 2, 'Color', colors(i,:));
    hold on;
end

% Set axes and labels
rticks(ax, 0:20:100);
rticklabels(ax, {'0', '20', '40', '60', '80', '100'});
thetaticks(ax, theta);
thetaticklabels(ax, stats_table.Properties.RowNames);
title(ax, 'Student Subject Grade Radar Chart', 'FontSize', 14, 'FontWeight', 'bold');

% Create legend using plot handles with exact match
legend(ax, plot_handles, student_names, 'Location', 'bestoutside');
hold off;

% 3.6 Histogram - Subject grade distribution
figure('Name', 'Subject Grade Distribution Histogram', 'Position', [600, 200, 800, 600]);
bins = 0:10:100;  % Score intervals
subplot(2,2,1);
histogram(math, bins, 'FaceColor', [0.2, 0.5, 0.8]);
title('Math Grade Distribution', 'FontSize', 12);
xlabel('Score'); ylabel('Number of Students');
grid on; xlim([0,100]);

subplot(2,2,2);
histogram(english, bins, 'FaceColor', [0.5, 0.2, 0.8]);
title('English Grade Distribution', 'FontSize', 12);
xlabel('Score'); ylabel('Number of Students');
grid on; xlim([0,100]);

subplot(2,2,3);
histogram(physics, bins, 'FaceColor', [0.8, 0.5, 0.2]);
title('Physics Grade Distribution', 'FontSize', 12);
xlabel('Score'); ylabel('Number of Students');
grid on; xlim([0,100]);

subplot(2,2,4);
histogram(chemistry, bins, 'FaceColor', [0.2, 0.8, 0.5]);
title('Chemistry Grade Distribution', 'FontSize', 12);
xlabel('Score'); ylabel('Number of Students');
grid on; xlim([0,100]);

sgtitle('Subject Grade Distribution Histograms', 'FontSize', 14, 'FontWeight', 'bold');

%% 4. Save results
writetable(grade_table, 'student_grades.csv');
disp(' ');
disp('Grade data saved as student_grades.csv');
disp('All analysis charts have been generated and can be viewed in the figure windows');
