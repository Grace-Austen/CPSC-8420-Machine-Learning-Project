fin = "data\repo_data_temp.mat";
fout = "data\one_hot_descript.mat";

load(fin, "-mat", "data")

disp("Loaded data");

% Process and create one-hot encoding of Description
descripts_table = process_descript(data);
one_hot_descript = create_one_hot_descript(descripts_table, data);
disp("Finished creating one hot of descriptions");

descript_features = string(descripts_table);

save(fout, "one_hot_descript", "descript_features", '-mat');


% Process Description Column 
%   - removal of stop words
%   - returns list of individual description words
function descripts_table = process_descript(data)
    % TO BE IMPLEMENTED --> 
    %   (maybe) removal of stop words
    descript_count = containers.Map();
    % --- Stop Words ---
    words = stopWords(); % lower case
    cap_words = words; % case sensitve - capital
    for i = 1:numel(cap_words)
        cap_words{i}(1) = upper(cap_words{i}(1));
    end
    
    stp_wrd = [words, cap_words, "", " ", ""]; % special character due to UTF-8
    
    
    % Loop each row in the Description col.
    for i = 1:height(data)
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
    descripts_table = descripts_table{:, 1};
    % disp(descripts_table);
end


% One-Hot Enconding for Description 
function one_hot_descript = create_one_hot_descript(descripts, data)
    one_hot_descript = false(height(data), numel(descripts));

    for i = 1:height(data)
        temp_descript = split(data.Description{i});

        for j = 1:length(temp_descript)
            curr_descript = temp_descript{j};

            % Check if the word is in descripts
            word_idx = find(strcmp(descripts, curr_descript));

            if ~isempty(word_idx)
                one_hot_descript(i, word_idx) = true;
            end
        end
    end
end
