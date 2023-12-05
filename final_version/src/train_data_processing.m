function [] = train_data_processing(varargin)

% Parse args
p = inputParser;

default_pca = true;
addOptional(p, 'pca', default_pca, @mustBeNumericOrLogical);

default_name_data_file = "../processed_data/1k_data_name.mat";
default_descript_data_file = "../processed_data/1k_data_descript.mat";
default_other_file = "../processed_data/1k_data_other.mat";
addOptional(p, 'name_data_file', default_name_data_file, @mustBeFile);
addOptional(p, 'descript_data_file', default_descript_data_file, @mustBeFile);
addOptional(p, 'other_data_file', default_other_file, @mustBeFile);

default_train_percent = 0.8;
default_random_seed = 1;
default_k_name = 171;
default_k_descript = 13499;
addOptional(p, 'train_percent', default_train_percent, @real);
addOptional(p, 'random_seed', default_random_seed, @isnumeric);
addOptional(p, 'k_name', default_k_name, @isnumeric);
addOptional(p, 'k_descript', default_k_descript, @isnumeric);

parse(p, varargin{:});

pca = p.Results.pca;
name_data_file = p.Results.name_data_file;
descript_data_file = p.Results.descript_data_file;
other_data_file = p.Results.other_data_file;
train_percent = p.Results.train_percent;
random_seed = p.Results.random_seed;

if pca
    k_name = p.Results.k_name;
    k_descript = p.Results.k_descript;
end

disp("Parsed input");

% Training and testing with Lasso Regression
%% Load Data
load(name_data_file, '-mat', "one_hot_name", "name_features");
load(descript_data_file, '-mat', "one_hot_descript", "descript_features");
load(other_data_file, '-mat', "other_data", "indicator_data", "other_features", "indicator_features");

disp("Loaded data");

%% Data Processing
% rename and put together all data
% X = [name descript other_data];
all_y = indicator_data;

% split data
[train_name, train_descript, train_other_data, trainy, ...
    test_name, test_descript, test_other_data, testy] = split_data(one_hot_name, one_hot_descript, other_data, all_y, train_percent, random_seed);

disp("Done split data")

% center everything by zscore
name_mean = mean(train_name, "omitnan");
name_sd = std(train_name, "omitnan");
descript_mean = mean(train_descript, "omitnan");
descript_sd = std(train_descript, "omitnan")+1e-6;
other_data_mean = mean(train_other_data, "omitnan");
other_data_sd = std(train_other_data, "omitnan");

train_name = (train_name - name_mean)./name_sd;
train_descript = (train_descript - descript_mean)./descript_sd;
train_other_data = (train_other_data - other_data_mean)./other_data_sd;

test_name = (test_name - name_mean)./name_sd;
test_descript = (test_descript - descript_mean)./descript_sd;
test_other_data = (test_other_data - other_data_mean)./other_data_sd;


disp("Done zscore")

% deal with PCA if req
if pca
    % apply pca to one_hot_name and one_hot descript
    all(descript_sd)
    name_weights = PCA(train_name, k_name);
    descript_weights = PCA(train_descript, k_descript);
    train_name = train_name*name_weights;
    train_descript = train_descript*descript_weights;
    test_name = test_name*name_weights;
    test_descript = test_descript*descript_weights;
end

trainX = [train_name train_descript train_other_data];
testX = [test_name test_descript test_other_data];

if pca
    save("../processed_data/1k_train-test_data.mat", "trainX", "testX", "trainy", "testy", ...
        "name_features", "descript_features", "other_features", "indicator_features", ...
        "name_weights", "descript_weights", '-mat', '-v7.3');
else
    save("../processed_data/1k_train-test_data.mat", "trainX", "testX", "trainy", "testy", ...
        "name_features", "descript_features", "other_features", "indicator_features",'-mat', '-v7.3');
end

disp("Processed data");

end

%% Data Processing Functions
function [train_name, train_descript, train_other, trainy, test_name, test_descript, test_other, testy] = split_data(name, descript, other, y, varargin)
    p = inputParser;

    default_train_percent = 0.8;
    default_random_seed = 1;

    addRequired(p, 'name', @ismatrix);
    addRequired(p, 'descript', @ismatrix);
    addRequired(p, 'other', @ismatrix);
    addRequired(p, 'y', @ismatrix);
    addOptional(p, 'train_percent', default_train_percent, @real);
    addOptional(p, 'random_seed', default_random_seed, @isnumeric);

    parse(p, name, descript, other, y, varargin{:});

    [rows, ~] = size(p.Results.y);
    rng(abs(p.Results.random_seed), 'twister');
    perm = randperm(rows);
    
    end_train_index = rows*p.Results.train_percent;
    name_shuffle = p.Results.name(perm,:);
    descript_shuffle = p.Results.descript(perm,:);
    other_shuffle = p.Results.other(perm,:);
    y_shuffle = p.Results.y(perm,:);
    
    train_name = name_shuffle(1:end_train_index, :); test_name = name_shuffle(end_train_index+1:end, :);
    train_descript = descript_shuffle(1:end_train_index, :); test_descript = descript_shuffle(end_train_index+1:end, :);
    train_other = other_shuffle(1:end_train_index, :); test_other = other_shuffle(end_train_index+1:end, :);
    trainy = y_shuffle(1:end_train_index, :); testy = y_shuffle(end_train_index+1:end, :);
end

function pca_weights = PCA(X, k)
    % Eigendecomp.
    [~, S, V] = svds(X, k);
    [~, indices] = sort(diag(S), 'descend');
    V = V(:, indices);
    
    pca_weights = V;
end