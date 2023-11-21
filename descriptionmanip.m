close all; clear all;


data = readtable('data/test_repositories.csv');

data.Description = cellfun(@string, data.Description);
data.Description = tokenizedDocument(data.Description)
data.Description = removeStopWords(data.Description)
data.Description{1}



function one_hot = create_one_hot(strings, delimiter)
    terms = containers.Map();
    % Loop through each string
    for i = 1:height(strings)
        if exist('delimiter', 'var')
            term_split = split(strings{i}, delimiter);
        else
            term_split = split(strings{i});
        end
    
        % add all terms
        for j = 1:length(term_split)
            terms(term_split{j}) = 1;
        end
    end
    
    one_hot = zeros(size(strings,1), size(terms,1));
    
    % for every string, add 1 if it contains term
    for i=1:size(strings,1)
        if exist('delimiter', 'var')
            term_split = split(strings{i}, delimiter);
        else
            term_split = split(strings{i});
        end
        one_hot(i, :) = contains(keys(terms), term_split);
    end
end