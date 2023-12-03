 % TO BE IMPLEMENTED --> 
%   (maybe) removal of stop words
descript_count = containers.Map();
stars_for_descript = containers.Map(); % track # stars for descript words
empty_descript = {};
c = 0;

% --- Stop Words ---
words = stopWords(); % lower case
cap_words = words; % case sensitve - capital
for i = 1:numel(cap_words)
    cap_words{i}(1) = upper(cap_words{i}(1));
end

stp_wrd = [words, cap_words, "", " ", ""]; % special character due to UTF-8


% Loop each row in the Description col.
for i = 1:height(data)
    % Check num. of empty Description rows
    if isempty(data.Description{i})
        empty_descript = [empty_descript, data.Name{i}];
        c = c + 1;
    end
    temp_descript = split(data.Description{i});
    num_stars = data.Stars(i);

    % Loop through each descript in the Description row
    for j = 1:length(temp_descript)
        curr_descript = temp_descript{j};
        curr_descript = regexprep(curr_descript, '[^a-zA-Z0-9]', '');

        if ~any(strcmp(stp_wrd, curr_descript))
            % Check if key already exists
            if isKey(descript_count, curr_descript)
                descript_count(curr_descript) = descript_count(curr_descript) + 1;
                stars_for_descript(curr_descript) = stars_for_descript(curr_descript) + num_stars;
            else
                descript_count(curr_descript) = 1;
                stars_for_descript(curr_descript) = num_stars;
            end

        end
    end
end

% Convert map to table and sort
descripts_table = table(keys(descript_count)', values(descript_count)', 'VariableNames', {'Description', 'Count'});
descripts_table = sortrows(descripts_table, 'Count', 'descend');

stars_table = table(keys(stars_for_descript)', values(stars_for_descript)', 'VariableNames', {'Description', 'Count'});
stars_table = sortrows(stars_table, 'Count', 'descend');

% Resulting descripts count
disp('Top 40 Description Words:');
disp(head(descripts_table, 40));
% disp(head(descripts_table, 10));


% Check num. of empty Description rows
disp('Empty Descriptions:');
disp(empty_descript');
disp(['Counter: ', num2str(c)]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Create a bar plot for the top k description
k = 25; % num. descript
figure('Position', [100, 100, 800, 400]);
top_descript = head(descripts_table, k);  % Select the top k descriptions

% Cout col. to a numeric array
count_num_top = cell2mat(top_descript.Count);

bar(count_num_top, 'b', 'BarWidth', 0.7);  % Plot only the top 10 counts
xlabel('Description Index');
ylabel('Description Count');
title(['Top ' num2str(k) ' Description Counts']);
xticks(1:k);
xticklabels(top_descript.Description);
xtickangle(45);  % Rotate x-axis labels for better readability
grid on;

% Display the plot
disp(['Displaying the bar plot for the top ' num2str(k) ' descriptions...']);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Create a bar plot for the top k star counts for description words
k = 25; % num. stars
figure('Position', [100, 100, 800, 400]);
top_stars = head(stars_table, k);  % Select the top k descriptions

% Count col. to a numeric array
top_star_count = cell2mat(top_stars.Count);

bar(top_star_count, 'b', 'BarWidth', 0.7); 
xlabel('Description Index');
ylabel('Stars Count');
title(['Top ' num2str(k) ' Description Star Counts']);
xticks(1:k);
xticklabels(top_stars.Description);
xtickangle(45);  % Rotate x-axis labels for better readability
grid on;

% Display the plot
disp(['Displaying the bar plot for the top ' num2str(k) ' Star Counts per Descriptions...']);



