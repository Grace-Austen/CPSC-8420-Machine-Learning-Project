function []=train_model(varargin)
% Parse args
p = inputParser;

default_model = "linear";
default_pca = false;
default_data_file = "data\test_data.mat";
addOptional(p, 'model', default_model, @check_model);
addOptional(p, 'pca', default_pca, @mustBeNumericOrLogical);
addOptional(p, 'data_file', default_data_file, @mustBeText);

default_train_percent = 0.8;
default_random_seed = 1;
addOptional(p, 'train_percent', default_train_percent, @real);
addOptional(p, 'random_seed', default_random_seed, @isnumeric);

default_lambdas = [0 logspace(-10, 10, 10)];
default_lambda_train_thresh = 10e-5;
addOptional(p, 'lambdas', default_lambdas, @isvector)
addParameter(p, 'lambda_train_thresh', default_lambda_train_thresh, @isnumeric);


parse(p, varargin{:});

model = lower(p.Results.model);
pca = p.Results.pca;
data_file = p.Results.data_file;
train_percent = p.Results.train_percent;
random_seed = p.Results.random_seed;

if ~strcmp(model, "linear")
    lambdas = p.Results.lambdas;
    lambda_train_thresh = p.Results.lambda_train_thresh;
end

% Training and testing with Lasso Regression
%% Load Data
load(data_file, '-mat', "one_hot_name", "one_hot_descript", "other_data", "indicator_data", ...
     "name_features", "descript_features", "other_features", "indicator_features");

%% Data Processing
% deal with PCA if req
if pca
    % apply pca to one_hot_name and one_hot descript
else
    name = one_hot_name;
    descript = one_hot_descript;
end

% rename and put together all data
X = [name descript other_data];
all_y = indicator_data;

% split data
[trainX, trainy, testX, testy] = split_data(X, all_y, train_percent, random_seed);

%% Train
if ~strcmp(model, "linear")
% Regression or lasso model
    lambda_results_table = cell(size(lambdas));
    for i=1:length(lambdas)
        lambda_results_table{i} = table('RowNames', indicator_features, 'VariableNames', ["weights", "train_RMSE", "test_RMSE"]);
        for feature=1:length(indicator_features)
            disp("Computing weights for ", indicator_features(feature), " with lambda ", lambdas(i));
            lambda_results_table{i}.weights(feature) = eval(compose("%s(trainX, trainy(:,%d), %d, %f)", [model, feature, lambdas(i), lambda_train_thresh]));
        end
    end
else
% Linear
    results_table = table('RowNames',indicator_features, 'VariableNames',["weights", "train_RMSE", "test_RMSE"]);
    for feature=1:length(indicator_features)
        disp("Computing weights for ", indicator_features(feature));
        results_table.weights(feature) = eval(compose("%s(trainX, trainy(:,%d))", [model, feature]));
    end
end

%% Test
if ~strcmp(model, "linear")
% Regression or lasso model
    for i=1:length(lambdas)
        for feature=1:length(indicator_features)
            disp("Computing train and test MSE for ", indicator_features(feature), " with lambda ", lambdas(i));
            lambda_results_table{i}.train_MSE(feature) = rmse(trainX*lambda_results_table{i}.weights(feature), trainy(:,feature), "omitnan");
            lambda_results_table{i}.test_MSE(feature) = rmse(testX*lambda_results_table{i}.weights(feature), testy(:,feature), "omitnan");
        end
    end
else
% Linear
    for feature=1:length(indicator_features)
        disp("Computing train and test MSE for ", indicator_features(feature));
        results_table.train_MSE(feature) = rmse(trainX*results_table.weights(feature), trainy(:,feature), "omitnan");
        results_table.test_MSE(feature) = rmse(testX*results_table.weights(feature), testy(:,feature), "omitnan");
    end
end

%% Plotting


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
function [trainX trainy testX testy] = split_data(X, y, varargin)
    p = inputParser;

    default_train_percent = 0.8;
    default_random_seed = 1;

    addRequired(p, 'X', @ismatrix);
    addRequired(p, 'y', @ismatrix);
    addOptional(p, 'train_percent', default_train_percent, @real);
    addOptional(p, 'random_seed', default_random_seed, @isnumeric);

    parse(p, X, y, varargin{:});

    [rows cols] = size(p.Results.X);
    rng(abs(p.Results.random_seed), 'twister');
    perm = randperm(rows);
    
    end_train_index = rows*p.Results.train_percent;
    X_shuffle = p.Results.X(perm,:); y_shuffle = p.Results.y(perm,:);
    trainX = X_shuffle(1:end_train_index, :); testX = X_shuffle(end_train_index+1:end, :);
    trainy = y_shuffle(1:end_train_index, :); testy = y_shuffle(end_train_index+1:end, :);
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

    [rows, cols] = size(X);
    identity = eye(rows);
    weights = (A.'*A + (lambda*identity))\A'*y;
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



