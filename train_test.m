% Training

%% imports
% NOTE!!!
% I couldn't figure out how imports work so I'm copy/pasting regression and
% lasso functions into here

close all; clear all;

%% Creating dummy data for testing
points = 1000;
X1 = 100 .* rand(points,1);
X2 = 100 .* rand(points,1);
X3 = 100 .* rand(points,1);
X4 = 100 .* rand(points,1);

drift = randn(points, 1);

y2 = (X1+(drift.*20)).*5 + (X2+drift.*8) + (X3+drift.*80)./80 + 800;
X = [ones(size(X1)) X1 X2 X3 X4];

%% split data

[trainX trainy testX testy] = split_data(X, y2);

% train using lassoAlg.m or regression.m
weights_cf_reg = closed_form_regression(trainX, trainy);

lambdas = [0 logspace(-10, 10, 10)];
lasso_weights = zeros(size(trainX, 2), length(lambdas));
for i=1:length(lambdas)
    i
    W = lasso_regression(trainX, trainy, lambda=lambdas(i), threshold=10e-5);
    lasso_weights(:,i) = W;
end

%% test
rmse(trainX*weights_cf_reg, trainy)
rmse(testX*weights_cf_reg, testy)

lasso_train_rmses = zeros(size(lambdas));
lasso_test_rmses = zeros(size(lambdas));
for i=1:length(lambdas)
    lasso_train_rmses(i) = rmse(trainX*lasso_weights(:,i), trainy);
    lasso_test_rmses(i) = rmse(testX*lasso_weights(:,i), testy);
end

figure
loglog(lambdas, lasso_train_rmses,"DisplayName","Train RMSE","LineWidth", 1.5)
hold on
loglog(lambdas, lasso_test_rmses,"DisplayName","Test RMSE","LineWidth", 1.5)
title('RMSE vs Lambda')
xlabel('Log Lambda')
ylabel('RMSE')
legend()


%% Functions
function [trainX trainy testX testy] = split_data(X, y, varargin)
    p = inputParser;

    default_train_percent = 0.8;
    default_random_seed = 1;

    addRequired(p, 'X', @ismatrix);
    addRequired(p, 'y', @isvector);
    addParameter(p, 'train_percent', default_train_percent, @real);
    addParameter(p, 'random_seed', default_random_seed, @isnumeric);

    parse(p, X, y, varargin{:});

    [rows cols] = size(p.Results.X);
    rng(abs(p.Results.random_seed), 'twister');
    perm = randperm(rows);
    
    end_train_index = rows*p.Results.train_percent;
    X_shuffle = p.Results.X(perm,:); y_shuffle = p.Results.y(perm,:);
    trainX = X_shuffle(1:end_train_index, :); testX = X_shuffle(end_train_index+1:end, :);
    trainy = y_shuffle(1:end_train_index, :); testy = y_shuffle(end_train_index+1:end, :);
end

function weights = closed_form_regression(X, y)
    weights = X'*X\X'*y;
end

function weights = gradient_descent_regression(X, y, varargin)
    p = inputParser;

    default_step_size = 1/ max( eig(X'*X));
    default_threshold = 10e-3;
    default_starting_weights = ones(size(X, 2), 1);

    addRequired(p, 'X', @ismatrix);
    addRequired(p, 'y', @isvector);
    addParameter(p, 'step_size', default_step_size, @isnumeric);
    addParameter(p, 'threshold', default_threshold, @isnumeric);
    addParameter(p, 'starting_weights', default_starting_weights, @isvector);

    parse(p, X, y, varargin{:});

    X = p.Results.X;
    y = p.Results.y;
    step_size = p.Results.step_size;

    weights = p.Results.starting_weights;

    weights_old = weights+ones(size(weights));
    loss = weights - weights_old;

    while norm(loss) > p.Results.threshold
        weights_old = weights;    % need to store the previous iteration of weights
        df_dweights = X'*(X*weights_old-y); % calculate step direction
        weights = weights - (step_size * df_dweights); % calculate new weights
        loss = weights - weights_old;     % update loss 
    end
end

function weights = lasso_regression(X, y, varargin)
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