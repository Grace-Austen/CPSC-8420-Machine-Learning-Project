close all; clear all;

% opts = detectImportOptions("data/test_repositories.csv");
% opts.VariableTypes = "string";
% R = readtable("data/test_repositories.csv", opts);

tic;

data = readtable('data/test_repositories.csv');

% data = readtable('repositories.csv', Range = 'A2:X1001');
% data.Properties.VariableNames = {'Name', 'Description', 'URL', 'CreatedAt', 'UpdatedAt', 'Homepage', 'Size', 'Stars', 'Forks', 'Issues', 'Watchers', 'Language', 'License', 'Topics', ...
%     'HasIssues', 'HasProjects', 'HasDownloads', 'HasWiki', 'HasPages', 'HasDiscussions', 'IsFork', 'IsArchived', 'IsTemplate', 'DefaultBranch'};

disp("Finished readtable()");

data.Properties;
data.Properties.VariableNames;

% data.Properties.VariableUnits = {   'string',   ... name
%                                     'string',   ... description
%                                     'string',   ... url
%                                     'datetime', ... created at
%                                     'datetime', ... updated at 
%                                     'string',   ... homepage
%                                     'int',      ... size
%                                     'int',      ... stars
%                                     'int',      ... forks
%                                     'int',      ... issues
%                                     'int',      ... watchers
%                                     'string',   ... language
%                                     'string',   ... license
%                                     'string',   ... topics (technically not a string, parse later :c)
%                                     'bool',     ... has issues
%                                     'bool',     ... has projects
%                                     'bool',     ... has downloads
%                                     'bool',     ... has wiki
%                                     'bool',     ... has pages
%                                     'bool',     ... has discussions
%                                     'bool',     ... is fork
%                                     'bool',     ... is archive
%                                     'bool',     ... is template
%                                     'string',   ... default branch
%                                     };

topics = data.Topics;
% class(data.Watchers)

columns_of_interest = [ "Name", "Description", "Homepage", "CreatedAt", "UpdatedAt", "Size", ...
                        "Stars", "Forks", "Issues", "Watchers" ...
                        "Language", "HasIssues", "HasProjects", "HasDownloads", "HasWiki", "HasPages", "HasDiscussions"];

% Update types for each column of interest
data.Name = cellfun(@string, data.Name);
data.Description = cellfun(@string, data.Description);
data.CreatedAt = cellfun(@(c)datetime(c, "InputFormat","uuuu-MM-dd'T'HH:mm:ssZ", TimeZone="UTC"), data.CreatedAt);
data.UpdatedAt = cellfun(@(c)datetime(c, "InputFormat","uuuu-MM-dd'T'HH:mm:ssZ", TimeZone="UTC"), data.UpdatedAt);
data.Homepage = cellfun(@length, data.Homepage) > 0;
% Doesn't need to update size, stars, forks, or watchers
data.Language = cellfun(@string, data.Language);
data.Topics = cellfun(@string, data.Topics);
data.HasIssues = cellfun(@(c)strcmp(c, 'True'), data.HasIssues);
data.HasProjects = cellfun(@(c)strcmp(c, 'True'), data.HasProjects);
data.HasDownloads = cellfun(@(c)strcmp(c, 'True'), data.HasDownloads);
data.HasWiki = cellfun(@(c)strcmp(c, 'True'), data.HasWiki);
data.HasPages = cellfun(@(c)strcmp(c, 'True'), data.HasPages);
data.HasDiscussions = cellfun(@(c)strcmp(c, 'True'), data.HasDiscussions);


disp("Finished updating types");

% Parse out Topics
data.Topics = arrayfun(@parse_tags, data.Topics, 'un', false);
disp("Finished Parsing Topics");

tot_time = toc;
disp(['Total Time: ', num2str(tot_time), ' sec.']);

% Create one-hot encoding of names and descriptions
[one_hot_name, terms_name] = create_one_hot(data.Name, '-');
% [process_descript, terms_descript] = create_one_hot(data.Description, '-');

% arr_terms_name = keys(terms_name);
% arr_terms_descript = keys(terms_descript);
descripts_table = process_descript(data);
one_hot_descript = create_one_hot_descript(descripts_table, data);
disp(one_hot_descript);


function tags = parse_tags(tag_string)
    string_split = cellfun(@string, split(tag_string, "'"));
    keep_inds = ~cellfun(@(c)contains(c,","), string_split);
    keep_inds(1) = 0;
    keep_inds(end) = 0;
    tags = string_split(keep_inds);
end

function [one_hot, terms] = create_one_hot(strings, delimiter)
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
    disp(descripts_table);
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