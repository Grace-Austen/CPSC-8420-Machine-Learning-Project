close all; clear all;

% opts = detectImportOptions("data/test_repositories.csv");
% opts.VariableTypes = "string";
% R = readtable("data/test_repositories.csv", opts);



data = readtable('data/test_repositories.csv');

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

% Parse out Topics
data.Topics = arrayfun(@parse_tags, data.Topics, 'un', false);

% Create one-hot encoding of names and descriptions
one_hot_name = create_one_hot(data.Name, '-');



function tags = parse_tags(tag_string)
    string_split = cellfun(@string, split(tag_string, "'"));
    keep_inds = ~cellfun(@(c)contains(c,","), string_split);
    keep_inds(1) = 0;
    keep_inds(end) = 0;
    tags = string_split(keep_inds);
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

