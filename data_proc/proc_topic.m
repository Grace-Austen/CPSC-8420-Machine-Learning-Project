function top_topic = proc_topic(data)
    % TO BE IMPLEMENTED --> 
    %   (maybe) removal of stop words
    descript_count = containers.Map();
    empty_descript = {};
    c = 0;
    
    % % --- Stop Words ---
    % words = stopWords(); % lower case
    % cap_words = words; % case sensitve - capital
    % for i = 1:numel(cap_words)
    %     cap_words{i}(1) = upper(cap_words{i}(1));
    % end
    % 
    % stp_wrd = [words, cap_words, "", " ", ""]; % special character due to UTF-8
    % 
    % 
    % Loop each row in the Topics col.
    for i = 1:height(data)
        % Check num. of empty Topics rows
        if isempty(data.Topics{i})
            empty_descript = [empty_descript, data.Name{i}];
            c = c + 1;
        end
        temp_descript = split(data.Topics{i});
    
        % Loop through each descript in the Topics row
        for j = 1:length(temp_descript)
            curr_descript = temp_descript{j};
    
        % if ~any(strcmp(stp_wrd, curr_descript))
            % Check if key already exists
            if isKey(descript_count, curr_descript)
                descript_count(curr_descript) = descript_count(curr_descript) + 1;
            else
                descript_count(curr_descript) = 1;
            end

        % end
        end
    end
    
    % Convert map to table and sort
    topic_table = table(keys(descript_count)', values(descript_count)', 'VariableNames', {'Topics', 'Count'});
    topic_table = sortrows(topic_table, 'Count', 'descend');
    
    % Resulting topic count
    disp('Top 40 Topics Words:');
    disp(head(topic_table, 40));
    % disp(head(topic_table, 10));
    
    
    % Check num. of empty Topics rows
    disp('Empty Topicss:');
    disp(empty_descript');
    disp(['Counter: ', num2str(c)]);
    
    
    % Create a bar plot for the top 10 descriptuages
    figure;
    top_topic = head(topic_table, 15);  % Select the top 10 descriptions
    
    % Convert the 'Count' column to a numeric array
    count_num_top10 = cell2mat(top_topic.Count);
    
    bar(count_num_top10, 'b', 'BarWidth', 0.7);  % Plot only the top 10 counts
    xlabel('Topics Index');
    ylabel('Topics Count');
    title('Top 10 Topics Counts');
    xticks(1:15);
    xticklabels(top_topic.Topics);
    xtickangle(45);  % Rotate x-axis labels for better readability
    grid on;
    
    % Display the plot
    disp('Displaying the bar plot for the top 10 descriptions...');
end