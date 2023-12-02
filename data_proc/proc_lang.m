function top_lang = proc_lang(data)
    lang_count = containers.Map();
    empty_lang = {};
    c = 0;
    
    % Loop each row in the Language col.
    for i = 1:height(data)
        curr_lang = data.Language{i};
    
        % Check if empty Language
        if isempty(curr_lang)
            empty_lang = [empty_lang, data.Name{i}];
            c = c + 1;
            % Language unlisted
            curr_lang = 'Other';
        end
    
        % Check if key already exists
        if isKey(lang_count, curr_lang)
            lang_count(curr_lang) = lang_count(curr_lang) + 1;
        else
            lang_count(curr_lang) = 1;
        end
    end
    
    % Convert map to table and sort
    lang_table = table(keys(lang_count)', values(lang_count)', 'VariableNames', {'Language', 'Count'});
    lang_table = sortrows(lang_table, 'Count', 'descend');
    
    % Resulting Language count
    disp('Top 10 Languages:');
    disp(head(lang_table, 10));
    
    
    % Check num. of empty Language rows
    disp('Empty Language:');
    disp(empty_lang');
    disp(['Counter: ', num2str(c)]);
    
    
    % Create a bar plot for the top 10 languages
    figure;
    top_lang = head(lang_table, 15);  % Select the top 10 languages
    
    % Convert the 'Count' column to a numeric array
    count_num_top10 = cell2mat(top_lang.Count);
    
    bar(count_num_top10, 'b', 'BarWidth', 0.7);  % Plot only the top 10 counts
    xlabel('Language Index');
    ylabel('Language Count');
    title('Top 10 Language Counts');
    xticks(1:15);
    xticklabels(top_lang.Language);
    xtickangle(45);  % Rotate x-axis labels for better readability
    grid on;
    
    % Display the plot
    disp('Displaying the bar plot for the top 10 languages...');
end