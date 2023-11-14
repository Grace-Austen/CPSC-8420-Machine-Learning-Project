tag_count = containers.Map();
empty_topics = {};
c = 0;

% Loop each row in the Topics col.
for i = 1:height(data)
    % Check num. of empty Topics rows
    if isempty(data.Topics{i})
        empty_topics = [empty_topics, data.Name{i}];
        c = c + 1;
    end

    % Loop through each tag in the Topics row
    for j = 1:length(data.Topics{i})
        curr_tag = data.Topics{i}{j};
        
        % Check if key already exists
        if isKey(tag_count, curr_tag)
            tag_count(curr_tag) = tag_count(curr_tag) + 1;
        else
            tag_count(curr_tag) = 1;
        end
    end
end

% Convert map to table and sort
tags_table = table(keys(tag_count)', values(tag_count)', 'VariableNames', {'Tag', 'Count'});
tags_table = sortrows(tags_table, 'Count', 'descend');

% Resulting tags count
disp('Top 10 Tags:');
disp(head(tags_table, 10));


% Check num. of empty Topic rows
disp('Empty Topics Tags:');
disp(empty_topics');
disp(['Counter: ', num2str(c)]);
