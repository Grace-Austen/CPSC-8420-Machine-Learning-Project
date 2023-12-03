fin = "data\repo_data_temp.mat";
fout = "data\other_data.mat";

load(fin, "-mat", "data")

disp("Loaded data");

% Create one-hot encoding of Language
[one_hot_lang, terms_lang] = create_one_hot(data.Language, '-', 10);
disp("Finished creating one hot of language");

% Process and create one-hot encoding of Topic
topic_table = process_topic(data);
topic_table = topic_table(1:10);
one_hot_topic = create_one_hot_topic(topic_table, data);
disp("Finished creating one hot of topics");

other_data = [data.CreatedAt data.UpdatedAt data.Size data.Homepage one_hot_lang one_hot_topic ...
    data.HasIssues data.HasProjects data.HasDownloads data.HasWiki data.HasPages data.HasDiscussions];
indicator_data = [data.Stars, data.Forks, data.Issues, data.Watchers];

other_features = ["CreatedAt", "UpdatedAt", "Size", string(terms_lang)', string(topic_table)', ...
    "HasIssues", "HasProjects", "HasDownloads", "HasWiki", "HasPages", "HasDiscussions"];
indicator_features = ["Stars", "Forks", "Issues", "Watchers"];

save(fout, "other_data", "indicator_data", "other_features", "indicator_features", '-mat');


% % % % %
% Topic %
% % % % % 

% Process Topics Column 
%   - removal of stop words
%   - returns list of individual topic words
function topic_table = process_topic(data)
    topic_count = containers.Map();
    
    % Loop each row in the Topics col.
    for i = 1:height(data)
        curr_descript = split(data.Topics{i});
    
        % Loop through each descript in the Topics row
        for j = 1:length(curr_descript)
            curr_topic = curr_descript{j};
            % Check if key already exists
            if isKey(topic_count, curr_topic)
                topic_count(curr_topic) = topic_count(curr_topic) + 1;
            else
                topic_count(curr_topic) = 1;
            end
        end
    end
    
    % Convert map to table and sort
    topic_table = table(keys(topic_count)', values(topic_count)', 'VariableNames', {'Topics', 'Count'});
    topic_table = sortrows(topic_table, 'Count', 'descend');
    topic_table = topic_table{:, 1};
    % disp(topic_table);
end


% One-Hot Enconding for Topics 
function one_hot_topic = create_one_hot_topic(topic, data)
    one_hot_topic = false(height(data), numel(topic));

    for i = 1:height(data)
        temp_topic = split(data.Topics{i});

        for j = 1:length(temp_topic)
            curr_topic = temp_topic{j};

            % Check if the word is in topic
            word_idx = find(strcmp(topic, curr_topic));

            if ~isempty(word_idx)
                one_hot_topic(i, word_idx) = true;
            end
        end
    end
end
