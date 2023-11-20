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
