function []=train_model(varargin)
% Parse args
p = inputParser;

default_model = "linear";
default_pca = true;
addOptional(p, 'model', default_model, @check_model);
addOptional(p, 'pca', default_pca, @mustBeNumericOrLogical);

default_data_file = "../processed_data/1k_train-test_data.mat";
addOptional(p, 'data_file', default_data_file, @mustBeFile);

default_lambdas = [0 logspace(-10, 10, 10)];
default_lasso_train_thresh = 10e-5;
addOptional(p, 'lambdas', default_lambdas, @isvector)
addParameter(p, 'lasso_train_thresh', default_lasso_train_thresh, @isnumeric);

parse(p, varargin{:});

model = lower(p.Results.model);
pca = p.Results.pca;
data_file = p.Results.data_file;

if ~strcmp(model, "linear")
    lambdas = p.Results.lambdas;
    lasso_train_thresh = p.Results.lasso_train_thresh;
end

disp("Parsed input");

% Training and testing with Lasso Regression
%% Load Data
if pca
    load(data_file, '-mat', "trainX", "testX", "trainy", "testy", ...
        "name_features", "descript_features", "other_features", "indicator_features", ...
        "name_weights", "descript_weights");
else
    load(data_file, '-mat', "trainX", "testX", "trainy", "testy", ...
        "name_features", "descript_features", "other_features", "indicator_features");
end

disp("Loaded data");

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
        save(compose("../models/%s_model_with_PCA_weight.mat", model), ...
            "model", "pca", "results_table", ...
            "trainX", "trainy", "testX", "testy", "indicator_features", ...
            "name_features", "descript_features", "other_features", "indicator_features", ...
            "name_weights", "descript_weights", "-mat");
    else
        save(compose("../models/%s_model_with_PCA_weights.mat", model), ...
            "model", "pca", "results_table", ...
            "trainX", "trainy", "testX", "testy", "indicator_features", ...
            "name_features", "descript_features", "other_features", "indicator_features", ...
            "name_weights", "descript_weights", "-mat");
    end
else
    if strcmp(model, "linear")
        save(compose("../models/%s_model_weight.mat", model), ...
            "model", "pca", "results_table", ...
            "trainX", "trainy", "testX", "testy", "indicator_features", ...
            "name_features", "descript_features", "other_features", "indicator_features", "-mat");
    else
        save(compose("../models/%s_model_weights.mat", model), ...
            "model", "pca", "results_table", ...
            "trainX", "trainy", "testX", "testy", "indicator_features", ...
            "name_features", "descript_features", "other_features", "indicator_features", "-mat");
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



