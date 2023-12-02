% For purpose of one-hot encoding
top_descript = proc_descript(data);
top_lang = proc_lang(data);
top_topic = proc_topic(data);

% --- Stop Words ---
words = stopWords(); % lower case
cap_words = words; % case sensitve - capital
for i = 1:numel(cap_words)
    cap_words{i}(1) = upper(cap_words{i}(1));
end

stp_wrd = [words, cap_words, "", " ", ""]; % special character due to UTF-8
tmp = data;

% Hot-encoding init - Description
start_col_descript = width(data);
disp(width(data));

temp_data = data;

for i = 1:height(top_descript)
    name = ['descript_' top_descript.Description{i}];
    temp_data.(name) = zeros(height(temp_data), 1); % initialize
end

last_col_descript = width(temp_data);

% Hot-encoding init - Languages
start_col_lang = width(temp_data);
disp(width(temp_data));

for i = 1:height(top_lang)
    name = ['lang_' top_lang.Language{i}];
    temp_data.(name) = zeros(height(temp_data), 1); % initialize
end

last_col_lang = width(temp_data);

% Hot-encoding init - Topics
start_col_topic = width(temp_data);
disp(width(temp_data));

for i = 1:height(top_topic)
    name = ['topic_' top_topic.Topics{i}];
    temp_data.(name) = zeros(height(temp_data), 1); % initialize
end

% Resulting Data table
last_col_topic = width(temp_data);
disp(width(temp_data));

% Start Hot-encoding 
% Description
for i = 1:height(temp_data)
    temp_descript = split(data.Description{i});

    for j = 1:length(temp_descript)
        curr_descript = temp_descript{j};

        % Check if the word is in the range of columns 25 to 54
        col_idx = find(strcmp(temp_data.Properties.VariableNames, ['descript_' curr_descript]));

        if ~isempty(col_idx) && col_idx >= start_col_descript && col_idx <= last_col_descript
            temp_data{i, col_idx} = 1;
        end
    end
end

% Language
for i = 1:height(temp_data)
    temp_lang = split(data.Language{i});

    for j = 1:length(temp_lang)
        curr_lang = temp_lang{j};

        % Check if the word is in the range of columns 25 to 54
        col_idx = find(strcmp(temp_data.Properties.VariableNames, ['lang_' curr_lang]));

        if ~isempty(col_idx) && col_idx >= start_col_lang && col_idx <= last_col_lang
            temp_data{i, col_idx} = 1;
        end
    end
end

% Topics
for i = 1:height(temp_data)
    temp_topic = split(data.Topics{i});

    for j = 1:length(temp_topic)
        curr_topic = temp_topic{j};

        % Check if the word is in the range of columns 25 to 54
        col_idx = find(strcmp(temp_data.Properties.VariableNames, ['topic_' curr_topic]));

        if ~isempty(col_idx) && col_idx >= start_col_topic && col_idx <= last_col_topic
            temp_data{i, col_idx} = 1;
        end
    end
end
