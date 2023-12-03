name_count = containers.Map();
stars_for_name = containers.Map(); % track # stars for nameuages
empty_name = {};
c = 0;

% Loop each row in the Name col.
for i = 1:height(data)
    curr_name = data.Name{i};
    num_stars = data.Stars(i);

    % Check if empty Name
    if isempty(curr_name)
        empty_name = [empty_name, data.Name{i}];
        c = c + 1;
        % Name unlisted
        % curr_name = 'Other';
    end
    
    if ~isempty(curr_name)
        % Check if key already exists
        if isKey(name_count, curr_name)
            name_count(curr_name) = name_count(curr_name) + 1;
            stars_for_name(curr_name) = stars_for_name(curr_name) + num_stars;
        else
            name_count(curr_name) = 1;
            stars_for_name(curr_name) = num_stars;
        end
    end
end

% Convert map to table and sort
name_table = table(keys(name_count)', values(name_count)', 'VariableNames', {'Name', 'Count'});
name_table = sortrows(name_table, 'Count', 'descend');

stars_table = table(keys(stars_for_name)', values(stars_for_name)', 'VariableNames', {'Name', 'Count'});
stars_table = sortrows(stars_table, 'Count', 'descend');


% Resulting Name count
disp('Top 10 Names:');
disp(head(name_table, 10));


% Check num. of empty Name rows
disp('Empty Name:');
disp(empty_name');
disp(['Counter: ', num2str(c)]);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Create a bar plot for the top k Topics
k = 25; % num. name
figure('Position', [100, 100, 800, 400]);

top_name = head(name_table, k);  % Select the top k nameuages

% Convert the 'Count' column to a numeric array
count_num_top = cell2mat(top_name.Count);

bar(count_num_top, 'b', 'BarWidth', 0.7);  % Plot only the top k counts
xlabel('Name Index');
ylabel('Name Count');
title(['Top ' num2str(k) ' Name Counts']);
xticks(1:k);
xticklabels(top_name.Name);
xtickangle(45);  % Rotate x-axis labels for better readability
grid on;

% Display the plot
disp(['Displaying the bar plot for the top ' num2str(k) ' Names...']);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Create a bar plot for the top k Names
k = 25; % num. name
figure('Position', [100, 100, 800, 400]);

top_name = head(stars_table, k);  % Select the top k Names

% Count col. to a numeric array
count_num_top = cell2mat(top_name.Count);

bar(count_num_top, 'b', 'BarWidth', 0.7);  % Plot only the top k counts
xlabel('Name Index');
ylabel('Stars Count');
title(['Top ' num2str(k) ' Name Star Counts']);
xticks(1:k);
xticklabels(stars_table.Name);
xtickangle(45);  % Rotate x-axis labels for better readability
grid on;

% Display the plot
disp(['Displaying the bar plot for the top ' num2str(k) ' Star Counts per Name...']);


