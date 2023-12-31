function []=full_data_preprocessing(varargin)

% Parse args
p = inputParser;

default_fin = "../data/1k_repositories.csv";
default_fout = "../processed_data/1k_data.mat";

addOptional(p, 'fin', default_fin, @mustBeFile);
addOptional(p, 'fout', default_fout, @mustBeText);

parse(p, varargin{:});

fin = p.Results.fin;
fout = p.Results.fout;

tic;

data = readtable(fin);

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

% columns_of_interest = [ "Name", "Description", "Homepage", "CreatedAt", "UpdatedAt", "Size", ...
%                         "Stars", "Forks", "Issues", "Watchers" ...
%                         "Language", "HasIssues", "HasProjects", "HasDownloads", "HasWiki", "HasPages", "HasDiscussions"];

% Update types for each column of interest
% data.Name = cellfun(@string, data.Name);
% disp("Finished updating name");
% data.Description = cellfun(@string, data.Description);
% disp("Finished updating description");
data.CreatedAt = cellfun(@(c)datetime(c, "InputFormat","uuuu-MM-dd'T'HH:mm:ssZ", TimeZone="UTC"), data.CreatedAt);
disp("Finished updating createdat");
data.UpdatedAt = cellfun(@(c)datetime(c, "InputFormat","uuuu-MM-dd'T'HH:mm:ssZ", TimeZone="UTC"), data.UpdatedAt);
disp("Finished updating updatedat");
data.CreatedAt = arrayfun(@(c)convertTo(c, "datenum"), data.CreatedAt);
disp("Finished updating createdat to datenum");
data.UpdatedAt = arrayfun(@(c)convertTo(c, "datenum"), data.UpdatedAt);
disp("Finished updating updatedat to datenum");
data.Homepage = cellfun(@length, data.Homepage) > 0;
disp("Finished updating homepage");
% Doesn't need to update size, stars, forks, issues, or watchers
% data.Language = cellfun(@string, data.Language);
% disp("Finished updating language");
% data.Topics = cellfun(@string, data.Topics);
% disp("Finished updating topics");
data.HasIssues = cellfun(@(c)strcmp(c, 'True'), data.HasIssues);
disp("Finished updating hasissues");
data.HasProjects = cellfun(@(c)strcmp(c, 'True'), data.HasProjects);
disp("Finished updating hasprojects");
data.HasDownloads = cellfun(@(c)strcmp(c, 'True'), data.HasDownloads);
disp("Finished updating hasdownloads");
data.HasWiki = cellfun(@(c)strcmp(c, 'True'), data.HasWiki);
disp("Finished updating haswiki");
data.HasPages = cellfun(@(c)strcmp(c, 'True'), data.HasPages);
disp("Finished updating haspages");
data.HasDiscussions = cellfun(@(c)strcmp(c, 'True'), data.HasDiscussions);
disp("Finished updating hasdiscussions");

disp("Finished updating types");

% Parse out Topics
data.Topics = arrayfun(@parse_tags, data.Topics, 'un', false);
disp("Finished Parsing Topics");

temp_data_split = split(fout, ".");
l_temp_data = length(temp_data_split);
if l_temp_data > 1
    temp_data_split(l_temp_data-1) = compose("%s_temp", temp_data_split(l_temp_data-1));
else
    temp_data_split(l_temp_data) = compose("%s_temp", temp_data_split(l_temp_data));
end
temp_data_path = join(temp_data_split, ".");
save(temp_data_path, "data", "-mat");

tot_time = toc;
disp(['Total Time: ', num2str(tot_time), ' sec.']);

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
indicator_data = [data.Stars, data.Forks, data.Issues];

other_features = ["CreatedAt", "UpdatedAt", "Size", string(terms_lang)', string(topic_table)', ...
    "HasIssues", "HasProjects", "HasDownloads", "HasWiki", "HasPages", "HasDiscussions"];
indicator_features = ["Stars", "Forks", "Issues"];

temp_data_split = split(fout, ".")';
l_temp_data = length(temp_data_split);
if l_temp_data > 1
    temp_data_split(l_temp_data-1) = compose("%s_other", temp_data_split(l_temp_data-1));
else
    temp_data_split(l_temp_data) = compose("%s_other", temp_data_split(l_temp_data));
end
out_data_path = join(temp_data_split, ".");
save(out_data_path, "other_data", "indicator_data", "other_features", "indicator_features", "-mat");

% Create one-hot encoding of Names
[one_hot_name, terms_name] = create_one_hot(data.Name, '-');
disp("Finished creating one hot of names");

name_features = string(terms_name');

temp_data_split = split(fout, ".")';
l_temp_data = length(temp_data_split);
if l_temp_data > 1
    temp_data_split(l_temp_data-1) = compose("%s_name", temp_data_split(l_temp_data-1));
else
    temp_data_split(l_temp_data) = compose("%s_name", temp_data_split(l_temp_data));
end
name_data_path = join(temp_data_split, ".");
save(name_data_path, "one_hot_name", "name_features", '-mat');

% Process and create one-hot encoding of Description
descripts_table = process_descript(data);
one_hot_descript = create_one_hot_descript(descripts_table, data);
disp("Finished creating one hot of descriptions");

descript_features = string(descripts_table);

temp_data_split = split(fout, ".")';
l_temp_data = length(temp_data_split);
if l_temp_data > 1
    temp_data_split(l_temp_data-1) = compose("%s_descript", temp_data_split(l_temp_data-1));
else
    temp_data_split(l_temp_data) = compose("%s_descript", temp_data_split(l_temp_data));
end
descript_data_path = join(temp_data_split, ".");
save(descript_data_path, "one_hot_descript", "descript_features", '-mat', '-v7.3');

% save(fout, "one_hot_name", "one_hot_descript", "other_data", "indicator_data", ...
%     "name_features", "descript_features", "other_features", "indicator_features", '-mat');

disp(compose("Saved fully processed data to %s", fout));

end


%% Helper Functions

function tags = parse_tags(tag_string)
    string_split = cellfun(@string, split(tag_string, "'"));
    keep_inds = ~cellfun(@(c)contains(c,","), string_split);
    keep_inds(1) = 0;
    keep_inds(end) = 0;
    tags = string_split(keep_inds);
end

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


% % % % % % % %
% Description %
% % % % % % % % 

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
