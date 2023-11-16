% Lasso 
rng default;

points = 1000;
X1 = 100 .* rand(points,1);
X2 = 100 .* rand(points,1);
X3 = 100 .* rand(points,1);
X4 = 100 .* rand(points,1);

drift = randn(points, 1);

y = (X1+(drift.*20)).*5 + (X2+drift.*8) + (X3+drift.*80)./80 + 800;
X = [ones(size(X1)) X1 X2 X3 X4];

X'*X\X'*y
r0 = lasso_regression(X, y, lambda=0, threshold=10e-5)
r1 = lasso_regression(X, y, lambda=1, threshold=10e-5)
r2 = lasso_regression(X, y, lambda=10, threshold=10e-5)
r3 = lasso_regression(X, y, lambda=100, threshold=10e-5)
r4 = lasso_regression(X, y, lambda=1000, threshold=10e-5)
r5 = lasso_regression(X, y, lambda=10e4, threshold=10e-5)

% rmse(X*r1, y)
% rmse(X*r2, y)
% rmse(X*r3, y)
% rmse(X*r4, y)

B = lasso(X, y);
B(:,1)

function weights = lasso_regression(X, y, varargin)
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
