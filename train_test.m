% Training

%% imports
% NOTE!!!
% I couldn't figure out how imports work so I'm copy/pasting regression and
% lasso functions into here

%% Creating dummy data for testing
% points = 1000;
% X1 = 100 .* rand(points,1);
% X2 = 100 .* rand(points,1);
% X3 = 100 .* rand(points,1);
% X4 = 100 .* rand(points,1);
% 
% drift = randn(points, 1);
% 
% y2 = (X1+(drift.*20)).*5 + (X2+drift.*8) + (X3+drift.*80)./80 + 800;
% X = [ones(size(X1)) X1 X2 X3 X4];

%% Creating X and y data from file for testing 
data = readtable('data/repositories.csv');

% Update types for each column of interest
data.Homepage = cellfun(@length, data.Homepage) > 0;
% Doesn't need to update size, stars, forks, or watchers
data.HasIssues = cellfun(@(c)strcmp(c, 'True'), data.HasIssues);
data.HasProjects = cellfun(@(c)strcmp(c, 'True'), data.HasProjects);
data.HasDownloads = cellfun(@(c)strcmp(c, 'True'), data.HasDownloads);
data.HasWiki = cellfun(@(c)strcmp(c, 'True'), data.HasWiki);
data.HasPages = cellfun(@(c)strcmp(c, 'True'), data.HasPages);
data.HasDiscussions = cellfun(@(c)strcmp(c, 'True'), data.HasDiscussions);

X = [data.Homepage data.Size data.HasIssues data.HasProjects data.HasDownloads data.HasWiki data.HasPages data.HasDiscussions];
X = zscore(X);
X = [ones(height(X),1) X];

stars = data.Stars;
forks = data.Forks;
issues = data.Issues;
watchers = data.Watchers;
y = [stars forks issues watchers];
%% split data

[trainX, trainy, testX, testy] = split_data(X, y);
train_stars = trainy(:,1);
test_stars = testy(:,1);
train_forks = trainy(:,2);
test_forks = testy(:,2);
train_issues = trainy(:,3);
test_issues = testy(:,3);
train_watchers = trainy(:,4);
test_watchers = testy(:,4);

%% train using lassoAlg.m or regression.m
weights_cf_reg_stars = closed_form_regression(trainX, train_stars);
weights_cf_reg_forks = closed_form_regression(trainX, train_forks);
weights_cf_reg_issues = closed_form_regression(trainX, train_issues);
weights_cf_reg_watchers = closed_form_regression(trainX, train_watchers);

lambdas = [0 logspace(-10, 10, 10)];
lasso_weights_stars = zeros(size(trainX, 2), length(lambdas));
lasso_weights_forks = zeros(size(trainX, 2), length(lambdas));
lasso_weights_issues = zeros(size(trainX, 2), length(lambdas));
lasso_weights_watchers = zeros(size(trainX, 2), length(lambdas));
for i=1:length(lambdas)
    i
    lasso_weights_stars(:,i) = lasso_regression(trainX, train_stars, lambda=lambdas(i), threshold=10e-5);
    lasso_weights_forks(:,i) = lasso_regression(trainX, train_forks, lambda=lambdas(i), threshold=10e-5);
    lasso_weights_issues(:,i) = lasso_regression(trainX, train_issues, lambda=lambdas(i), threshold=10e-5);
    lasso_weights_watchers(:,i) = lasso_regression(trainX, train_watchers, lambda=lambdas(i), threshold=10e-5);
end

%% test
stars_train_rmse = rmse(trainX*weights_cf_reg_stars, train_stars);
stars_test_rmse = rmse(testX*weights_cf_reg_stars, test_stars);
forks_train_rmse = rmse(trainX*weights_cf_reg_forks, train_forks);
forks_test_rmse = rmse(testX*weights_cf_reg_forks, test_forks);
issues_train_rmse = rmse(trainX*weights_cf_reg_issues, train_issues);
issues_test_rmse = rmse(testX*weights_cf_reg_issues, test_issues);
watchers_train_rmse = rmse(trainX*weights_cf_reg_watchers, train_watchers);
watchers_test_rmse = rmse(testX*weights_cf_reg_watchers, test_watchers, "omitnan");

stars_lasso_train_rmses = zeros(size(lambdas));
stars_lasso_test_rmses = zeros(size(lambdas));
forks_lasso_train_rmses = zeros(size(lambdas));
forks_lasso_test_rmses = zeros(size(lambdas));
issues_lasso_train_rmses = zeros(size(lambdas));
issues_lasso_test_rmses = zeros(size(lambdas));
watchers_lasso_train_rmses = zeros(size(lambdas));
watchers_lasso_test_rmses = zeros(size(lambdas));
for i=1:length(lambdas)
    stars_lasso_train_rmses(i) = rmse(trainX*lasso_weights_stars(:,i), train_stars);
    stars_lasso_test_rmses(i) = rmse(testX*lasso_weights_stars(:,i), test_stars);
    forks_lasso_train_rmses(i) = rmse(trainX*lasso_weights_forks(:,i), train_forks);
    forks_lasso_test_rmses(i) = rmse(testX*lasso_weights_forks(:,i), test_forks);
    issues_lasso_train_rmses(i) = rmse(trainX*lasso_weights_issues(:,i), train_issues);
    issues_lasso_test_rmses(i) = rmse(testX*lasso_weights_issues(:,i), test_issues);
    watchers_lasso_train_rmses(i) = rmse(trainX*lasso_weights_watchers(:,i), train_watchers);
    watchers_lasso_test_rmses(i) = rmse(testX*lasso_weights_watchers(:,i), test_watchers);
end

linear_figure = figure;
subplot(141)
bar(["Train", "Test"], [stars_train_rmse, stars_test_rmse])
title("RMSE for Stars")
subplot(142)
bar(["Train", "Test"], [forks_train_rmse, forks_test_rmse])
title("RMSE for Forks")
subplot(143)
bar(["Train", "Test"], [issues_train_rmse, issues_test_rmse])
title("RMSE for Issues")
subplot(144)
bar(["Train", "Test"], [watchers_train_rmse, watchers_test_rmse])
title("RMSE for Watchers")

linear_figure.Position = [0 0 1250 300]; 

lasso_figure = figure;
subplot(141)
loglog(lambdas, stars_lasso_train_rmses,"DisplayName","Train RMSE","LineWidth", 1.5)
hold on
loglog(lambdas, stars_lasso_test_rmses,"DisplayName","Test RMSE","LineWidth", 1.5)
title('Star RMSE vs Lambda')
xlabel('Log Lambda')
ylabel('RMSE')
legend()
subplot(142)
loglog(lambdas, forks_lasso_train_rmses,"DisplayName","Train RMSE","LineWidth", 1.5)
hold on
loglog(lambdas, forks_lasso_test_rmses,"DisplayName","Test RMSE","LineWidth", 1.5)
title('Forks RMSE vs Lambda')
xlabel('Log Lambda')
ylabel('RMSE')
legend()
subplot(143)
loglog(lambdas, issues_lasso_train_rmses,"DisplayName","Train RMSE","LineWidth", 1.5)
hold on
loglog(lambdas, issues_lasso_test_rmses,"DisplayName","Test RMSE","LineWidth", 1.5)
title('Issues RMSE vs Lambda')
xlabel('Log Lambda')
ylabel('RMSE')
legend()
subplot(144)
loglog(lambdas, watchers_lasso_train_rmses,"DisplayName","Train RMSE","LineWidth", 1.5)
hold on
loglog(lambdas, watchers_lasso_test_rmses,"DisplayName","Test RMSE","LineWidth", 1.5)
title('Watchers RMSE vs Lambda', FontSize=9.5)
xlabel('Log Lambda')
ylabel('RMSE')
legend()

lasso_figure.Position = [0 0 1500 300]; 



%% Functions
function [trainX trainy testX testy] = split_data(X, y, varargin)
    p = inputParser;

    default_train_percent = 0.8;
    default_random_seed = 1;

    addRequired(p, 'X', @ismatrix);
    addRequired(p, 'y', @ismatrix);
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