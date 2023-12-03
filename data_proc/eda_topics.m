 % TO BE IMPLEMENTED --> 
%   (maybe) removal of stop words
topic_count = containers.Map();
stars_for_topic = containers.Map(); % track # stars for topic words
empty_topic = {};
c = 0;


% Loop each row in the Topic col.
for i = 1:height(data)
    % Check num. of empty Topic rows
    if isempty(data.Topics{i})
        empty_topic = [empty_topic, data.Name{i}];
        c = c + 1;
    end
    temp_descript = split(data.Topics{i});
    num_stars = data.Stars(i);

    % Loop through each descript in the Topic row
    for j = 1:length(temp_descript)
        curr_descript = temp_descript{j};
        curr_descript = regexprep(curr_descript, '[^a-zA-Z0-9]', '');

        % Check if key already exists
        if isKey(topic_count, curr_descript)
            topic_count(curr_descript) = topic_count(curr_descript) + 1;
            stars_for_topic(curr_descript) = stars_for_topic(curr_descript) + num_stars;
        else
            topic_count(curr_descript) = 1;
            stars_for_topic(curr_descript) = num_stars;
        end
    end
end

% Convert map to table and sort
topics_table = table(keys(topic_count)', values(topic_count)', 'VariableNames', {'Topics', 'Count'});
topics_table = sortrows(topics_table, 'Count', 'descend');

stars_table = table(keys(stars_for_topic)', values(stars_for_topic)', 'VariableNames', {'Topics', 'Count'});
stars_table = sortrows(stars_table, 'Count', 'descend');

% Resulting Topics count
disp('Top 40 Topics Words:');
disp(head(topics_table, 40));
% disp(head(topics_table, 10));


% Check num. of empty Topic rows
disp('Empty Topics:');
disp(empty_topic');
disp(['Counter: ', num2str(c)]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Create a bar plot for the top k Topics
k = 25; % num. descript
figure('Position', [100, 100, 800, 400]);
top_topics = head(topics_table, k);  % Select the top k Topics

% Cout col. to a numeric array
count_num_top = cell2mat(top_topics.Count);

bar(count_num_top, 'b', 'BarWidth', 0.7);  % Plot only the top 10 counts
xlabel('Topic Index');
ylabel('Topic Count');
title(['Top ' num2str(k) ' Topic Counts']);
xticks(1:k);
xticklabels(top_topics.Topics);
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
xlabel('Topic Index');
ylabel('Stars Count');
title(['Top ' num2str(k) ' Topic Star Counts']);
xticks(1:k);
xticklabels(top_stars.Topics);
xtickangle(45);  % Rotate x-axis labels for better readability
grid on;

% Display the plot
disp(['Displaying the bar plot for the top ' num2str(k) ' Star Counts per Topics...']);



