function top_descript = proc_descript(data)
    % TO BE IMPLEMENTED --> 
    %   (maybe) removal of stop words
    descript_count = containers.Map();
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
    
        % Loop through each descript in the Description row
        for j = 1:length(temp_descript)
            curr_descript = temp_descript{j};
    
            if ~any(strcmp(stp_wrd, curr_descript))
                % Check if key already exists
                if isKey(descript_count, curr_descript)
                    descript_count(curr_descript) = descript_count(curr_descript) + 1;
                else
                    descript_count(curr_descript) = 1;
                end
    
            end
        end
    end
    
    % Convert map to table and sort
    descripts_table = table(keys(descript_count)', values(descript_count)', 'VariableNames', {'Description', 'Count'});
    descripts_table = sortrows(descripts_table, 'Count', 'descend');
    
    % Resulting descripts count
    disp('Top 40 Description Words:');
    disp(head(descripts_table, 40));
    % disp(head(descripts_table, 10));
    
    
    % Check num. of empty Description rows
    disp('Empty Descriptions:');
    disp(empty_descript');
    disp(['Counter: ', num2str(c)]);
    
    
    % Create a bar plot for the top 10 descriptuages
    figure;
    top_descript = head(descripts_table, 15);  % Select the top 10 descriptions
    
    % Convert the 'Count' column to a numeric array
    count_num_top10 = cell2mat(top_descript.Count);
    
    bar(count_num_top10, 'b', 'BarWidth', 0.7);  % Plot only the top 10 counts
    xlabel('Description Index');
    ylabel('Description Count');
    title('Top 10 Description Counts');
    xticks(1:15);
    xticklabels(top_descript.Description);
    xtickangle(45);  % Rotate x-axis labels for better readability
    grid on;
    
    % Display the plot
    disp('Displaying the bar plot for the top 10 descriptions...');
end