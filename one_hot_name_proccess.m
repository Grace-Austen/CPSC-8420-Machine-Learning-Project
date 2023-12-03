fin = "data\repo_data_temp.mat";
fout = "data\one_hot_name.mat";

load(fin, "-mat", "data")

disp("Loaded data");

% Create one-hot encoding of Names
[one_hot_name, terms_name] = create_one_hot(data.Name, '-');
disp("Finished creating one hot of names");

name_features = string(terms_name');

save(fout, "one_hot_name", "name_features", '-mat');

function [one_hot, terms] = create_one_hot(strings, delimiter, one_hot_word_limit)
    terms = containers.Map();
    % Loop through each string
    for i = 1:height(strings)
        if isempty(strings{i})
            continue;
        end
        if exist('delimiter', 'var')
            term_split = split(strings{i}, delimiter);
        else
            term_split = split(strings{i});
        end
    
        % add all terms
        
        for j = 1:length(term_split)
            if isKey(terms, term_split{j})
                terms(term_split{j}) = terms(term_split{j}) + 1;
            else
                terms(term_split{j}) = 1;
            end
        end
    end

    if exist('one_hot_word_limit', 'var')
        tbl = table(keys(terms)', values(terms)', 'VariableNames', {'Terms', 'Count'});
        tbl = sortrows(tbl, 'Count', 'descend');
        terms = tbl{1:one_hot_word_limit,1};
    else
        terms = keys(terms);
    end
    one_hot = false(size(strings,1), length(terms));
    
    % for every string, add 1 if it contains term
    for i=1:size(strings,1)
        if isempty(strings{i})
            continue;
        end
        if exist('delimiter', 'var')
            term_split = split(strings{i}, delimiter);
        else
            term_split = split(strings{i});
        end
        one_hot(i, :) = contains(terms, term_split);
    end
end
