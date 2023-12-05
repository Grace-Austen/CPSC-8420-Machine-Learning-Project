function []=train_model(varargin)
% Parse args
p = inputParser;

default_model = "linear";
default_pca = true;
addOptional(p, 'model', default_model, @check_model);
addOptional(p, 'pca', default_pca, @mustBeNumericOrLogical);

default_name_data_file = "data/test_data_name.mat";
default_descript_data_file = "data/test_data_descript.mat";
default_other_file = "data/test_data_other.mat";
addOptional(p, 'name_data_file', default_name_data_file, @mustBeFile);
addOptional(p, 'descript_data_file', default_descript_data_file, @mustBeFile);
addOptional(p, 'other_data_file', default_other_file, @mustBeFile);

default_train_percent = 0.8;
default_random_seed = 1;
default_k_name = 50;
default_k_descript = 100;
addOptional(p, 'train_percent', default_train_percent, @real);
addOptional(p, 'random_seed', default_random_seed, @isnumeric);
addOptional(p, 'k_name', default_k_name, @isnumeric);
addOptional(p, 'k_descript', default_k_descript, @isnumeric);


default_lambdas = [0 logspace(-10, 10, 10)];
default_lasso_train_thresh = 10e-5;
addOptional(p, 'lambdas', default_lambdas, @isvector)
addParameter(p, 'lasso_train_thresh', default_lasso_train_thresh, @isnumeric);

parse(p, varargin{:});

model = lower(p.Results.model);
pca = p.Results.pca;
name_data_file = p.Results.name_data_file;
descript_data_file = p.Results.descript_data_file;
other_data_file = p.Results.other_data_file;
train_percent = p.Results.train_percent;
random_seed = p.Results.random_seed;

if ~strcmp(model, "linear")
    lambdas = p.Results.lambdas;
    lasso_train_thresh = p.Results.lasso_train_thresh;
end

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

% center everything by zscore
name_mean = mean(train_name);
name_sd = std(train_name);
descript_mean = mean(train_descript);
descript_sd = std(train_descript);
other_data_mean = mean(train_other_data);
other_data_sd = std(train_other_data);

train_name = (train_name - name_mean)/name_sd;
train_descript = (train_descript - descript_mean)/descript_sd;
train_other_data = (train_other_data - other_data_mean)/other_data_sd;

test_name = (test_name - name_mean)/name_sd;
test_descript = (test_descript - descript_mean)/descript_sd;
test_other_data = (test_other_data - other_data_mean)/other_data_sd;


% deal with PCA if req
if pca
    % apply pca to one_hot_name and one_hot descript
    name_weights = PCA(train_name, k_name);
    descript_weights = PCA(train_descript, k_descript);
    train_name = train_name*name_weights;
    train_descript = train_descript*descript_weights;
    test_name = test_name*name_weights;
    test_descript = test_descript*descript_weights;
end

trainX = [train_name train_descript train_other_data];
testX = [test_name test_descript test_other_data];

disp("Processed data");

%% Train
results_table_columns = ["weights", "train_RMSE", "test_RMSE"];
results_table_variable_types = ["cell", "double", "double"];
results_table_size = [length(indicator_features), length(results_table_columns)];
if strcmp(model, "linear")
% Linear
    results_table = table('Size', results_table_size, 'RowNames',indicator_features, 'VariableTypes', results_table_variable_types, 'VariableNames', results_table_columns);
    for feature=1:length(indicator_features)
        disp(["Computing weights for " indicator_features(feature)]);
        results_table.weights(feature) = {eval(compose("%s(trainX, trainy(:,%d))", model, feature))};
    end
else
% Regression or lasso model
    results_table = cell(size(lambdas'));
    for i=1:length(lambdas)
        results_table{i, 1} = table('Size', results_table_size, 'RowNames', indicator_features, 'VariableTypes', results_table_variable_types,'VariableNames', results_table_columns);
        for feature=1:length(indicator_features)
            disp(["Computing weights for ", indicator_features(feature), " with lambda ", lambdas(i)]);
            if strcmp(model, "ridge")
                results_table{i, 1}.weights(feature) = {eval(compose("%s(trainX, trainy(:,%d), lambda=%d)", model, feature, lambdas(i)))};
            else
                results_table{i, 1}.weights(feature) = {eval(compose("%s(trainX, trainy(:,%d), lambda=%d, threshold=%f)", model, feature, lambdas(i), lasso_train_thresh))};
            end
        end
    end
    results_table = [num2cell(lambdas') results_table];
end

disp("Trained model(s)")

if pca
    if strcmp(model, "linear")
        save(compose("models/%s_model_with_PCA_weight.mat", model), "model", "pca", "results_table", "trainX", "trainy", "testX", "testy", "indicator_features", "-mat");
    else
        save(compose("models/%s_model_with_PCA_weights.mat", model), "model", "pca", "results_table", "trainX", "trainy", "testX", "testy", "indicator_features", "-mat");
    end
else
    if strcmp(model, "linear")
            save(compose("models/%s_model_weight.mat", model), "model", "pca", "results_table", "trainX", "trainy", "testX", "testy", "indicator_features", "-mat");
    else
        save(compose("models/%s_model_weights.mat", model), "model", "pca", "results_table", "trainX", "trainy", "testX", "testy", "indicator_features", "-mat");
    end
end

disp("Saved models")

end

%% Parsing Functions
function TF = check_model(model)
    valid_models = ["linear", "ridge", "lasso"];
    TF = any(ismember(valid_models, lower(model)));
    if ~TF
       error('Model must be one of the following: linear, ridge, lasso, PCA');
    end

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
    train_descript = name_shuffle(1:end_train_index, :); test_descript = name_shuffle(end_train_index+1:end, :);
    train_other = name_shuffle(1:end_train_index, :); test_other = name_shuffle(end_train_index+1:end, :);
    trainy = y_shuffle(1:end_train_index, :); testy = y_shuffle(end_train_index+1:end, :);
end

function pca_weights = PCA(X, k)
    % Eigendecomp.
    [~, S, V] = svds(X, k);
    [~, indices] = sort(diag(S), 'descend');
    V = V(:, indices);
    
    pca_weights = V;
end

%% Model Training Functions
function weights = linear(X, y)
    weights = X'*X\X'*y;
end

function weights = ridge(X, y, varargin)
    p = inputParser;

    default_lambda = 1;

    addRequired(p, 'X', @ismatrix);
    addRequired(p, 'y', @isvector);
    addParameter(p, 'lambda', default_lambda, @isnumeric);

    parse(p, X, y, varargin{:});

    X = p.Results.X;
    y = p.Results.y;
    lambda = p.Results.lambda;

    [~, cols] = size(X);
    identity = eye(cols);
    weights = (X'*X + (lambda*identity))\X'*y;
end

function weights = lasso(X, y, varargin)
% LASSO_REGRESSION  Determines the weights for lasso regression given X and y.
%   weights = LASSO_REGRESSION(X, y) Determines weights for X and y with lambda = 1, a weight change threshold of 1/1000, and starting weights of all 1's.
%
%   weights = LASSO_REGRESSION(X, y, lambda=lambda) Determines weights for X and y with provided lambda, a weight change threshold of 1/1000, and starting weights of all 1's.
%

    p = inputParser;

    default_lambda = 1;
    default_threshold = 10e-3;
    default_starting_weights = ones(size(X, 2), 1);

    addRequired(p, 'X', @ismatrix);
    addRequired(p, 'y', @isvector);
    addParameter(p, 'lambda', default_lambda, @isnumeric);
    addParameter(p, 'threshold', default_threshold, @isnumeric);
    addParameter(p, 'starting_weights', default_starting_weights, @isvector);

    parse(p, X, y, varargin{:});

    X = p.Results.X;
    y = p.Results.y;
    lambda = p.Results.lambda;
    threshold = p.Results.threshold;

    weights = p.Results.starting_weights;
    weights_old = weights+ones(size(weights));
    loss = weights - weights_old;

    while norm(loss) > threshold
        weights_old = weights;    % need to store the previous iteration of weights
        for i = 1:length(weights)
            x = X(:,i);     % get column of x
            p = (norm(x,2))^2; %step size
            df_dweights =  x*weights(i) + y - X*weights; 
            q = x'*df_dweights;
            % update xi
            weights(i) = (1/p) * sign(q) * max(abs(q)-lambda, 0);
        end
        loss = weights - weights_old;     % update loss 
    end
end



