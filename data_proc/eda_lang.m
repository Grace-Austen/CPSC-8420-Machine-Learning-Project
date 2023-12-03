lang_count = containers.Map();
stars_for_lang = containers.Map(); % track # stars for languages
empty_lang = {};
c = 0;

% Loop each row in the Language col.
for i = 1:height(data)
    curr_lang = data.Language{i};
    num_stars = data.Stars(i);

    % Check if empty Language
    if isempty(curr_lang)
        empty_lang = [empty_lang, data.Name{i}];
        c = c + 1;
        % Language unlisted
        % curr_lang = 'Other';
    end
    
    if ~isempty(curr_lang)
        % Check if key already exists
        if isKey(lang_count, curr_lang)
            lang_count(curr_lang) = lang_count(curr_lang) + 1;
            stars_for_lang(curr_lang) = stars_for_lang(curr_lang) + num_stars;
        else
            lang_count(curr_lang) = 1;
            stars_for_lang(curr_lang) = num_stars;
        end
    end
end

% Convert map to table and sort
lang_table = table(keys(lang_count)', values(lang_count)', 'VariableNames', {'Language', 'Count'});
lang_table = sortrows(lang_table, 'Count', 'descend');

stars_table = table(keys(stars_for_lang)', values(stars_for_lang)', 'VariableNames', {'Language', 'Count'});
stars_table = sortrows(stars_table, 'Count', 'descend');


% Resulting Language count
disp('Top 10 Languages:');
disp(head(lang_table, 10));


% Check num. of empty Language rows
disp('Empty Language:');
disp(empty_lang');
disp(['Counter: ', num2str(c)]);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Create a bar plot for the top k Topics
k = 25; % num. lang
figure('Position', [100, 100, 800, 400]);

top_lang = head(lang_table, k);  % Select the top k languages

% Convert the 'Count' column to a numeric array
count_num_top = cell2mat(top_lang.Count);

bar(count_num_top, 'b', 'BarWidth', 0.7);  % Plot only the top k counts
xlabel('Language Index');
ylabel('Language Count');
title(['Top ' num2str(k) ' Language Counts']);
xticks(1:k);
xticklabels(top_lang.Language);
xtickangle(45);  % Rotate x-axis labels for better readability
grid on;

% Display the plot
disp(['Displaying the bar plot for the top ' num2str(k) ' descriptions...']);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Create a bar plot for the top k Languages
k = 25; % num. lang
figure('Position', [100, 100, 800, 400]);

top_lang = head(stars_table, k);  % Select the top k Languages

% Count col. to a numeric array
count_num_top = cell2mat(top_lang.Count);

bar(count_num_top, 'b', 'BarWidth', 0.7);  % Plot only the top k counts
xlabel('Language Index');
ylabel('Stars Count');
title(['Top ' num2str(k) ' Language Star Counts']);
xticks(1:k);
xticklabels(stars_table.Language);
xtickangle(45);  % Rotate x-axis labels for better readability
grid on;

% Display the plot
disp(['Displaying the bar plot for the top ' num2str(k) ' Star Counts per Language...']);


