close all; clear all;


data = readtable('data/test_repositories.csv');

data.Description = cellfun(@string, data.Description);
data.Description = tokenizedDocument(data.Description);
data.Description = removeStopWords(data.Description);
temp = data.Description(1);
temp.tokenDetails

temp2 = "duck duck duck duck";
temp3 = removeStopWords(tokenizedDocument(temp2));
temp3.tokenDetails;

detokenizer(temp3.tokenDetails)

function new_string = detokenizer(tokenDetails_table)
    new_string = "";
    tokens = tokenDetails_table.Token;
    for i=1:length(tokens)
        new_string = new_string + tokens(i);
    end
end



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