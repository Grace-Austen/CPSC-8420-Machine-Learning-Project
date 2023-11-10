close all; clear all;

% opts = detectImportOptions("data/test_repositories.csv");
% opts.VariableTypes = "string";
% R = readtable("data/test_repositories.csv", opts);



data = readtable('data/test_repositories.csv');

data.Properties
data.Properties.VariableNames

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

columns_of_interest = ["Name", "Description", "CreatedAt", "CreatedAt", "Homepage"];


data.Name = cellfun(@string, data.Name);
data.Description = cellfun(@string, data.Description);
data.Homepage = cellfun(@length, data.Homepage) > 0;
data.CreatedAt = cellfun(@(input)datetime(c, 'Format','yyyy-MM-dd''T''HH:mm:ssZ'), data.CreatedAt);
data.Language = cellfun(@string, data.Language);
data.HasIssues = cellfun(@(c)strcmp(c, 'True'), data.HasIssues);

data.CreatedAt
