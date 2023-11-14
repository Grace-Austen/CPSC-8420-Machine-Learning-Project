% Regression

rng default;

% points = 1000;
% A = linspace(0, 100, points)';
% 
% drift = randn(points, 1);
% 
% y1 = (X+(drift.*20)).*5 + 800;
% A = [ones(size(A)) A];
% 
% closed_form_regression(A, y1)
% gradient_descent_regression(A, y1, threshold=0)

points = 1000;
X1 = linspace(0, 100, points)';
X2 = linspace(80, 100, points)';
X3 = linspace(90, 150, points)';
X4 = linspace(0, 250, points)';

drift = randn(points, 1);

y2 = (X1+(drift.*20)).*5 + (X2+drift.*8) + (X3+drift.*80)./80 + 800;
X = [ones(size(X1)) X1 X2 X3 X4];

r1 = closed_form_regression(X, y2)
r2 = gradient_descent_regression(X, y2, threshold=0)

rmse(X*r1, y2)
rmse(X*r2, y2)

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