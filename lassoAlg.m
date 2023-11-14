% Lasso 

rng default;

points = 1000;
X1 = linspace(0, 100, points)';
X2 = linspace(80, 100, points)';
X3 = linspace(90, 150, points)';
X4 = linspace(0, 250, points)';

drift = randn(points, 1);

y = (X1+(drift.*20)).*5 + (X2+drift.*8) + (X3+drift.*80)./80 + 800;
X = [ones(size(X1)) X1 X2 X3 X4];

r1 = lasso_regression(X, y, lambda=1)
r2 = lasso_regression(X, y, lambda=10)
r3 = lasso_regression(X, y, lambda=100)
r4 = lasso_regression(X, y, lambda=1000)

rmse(X*r1, y)
rmse(X*r2, y)
rmse(X*r3, y)
rmse(X*r4, y)

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
