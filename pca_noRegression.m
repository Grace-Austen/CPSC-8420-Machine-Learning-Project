function pca_noRegression(X)
    % X = X(:, 1:10)
    % mu = mean(X);
    % X_cent = X - mu;
    X_cent = X; % PROBLEM: There is no distinct elbow point with just the one_hot_(descript or name) but is with
                         %          pca_noRegression([indicator_data one_hot_name]) at K = 2  

    [~, S, V] = svd(cov(X_cent));
    [~, indices] = sort(diag(S), 'descend');
    V = V(:, indices);
    
    scores = X_cent * V;

    figure('Position', [100, 100, 800, 400]);
    % total_var = sum(diag(S));
    % exp_var = cumsum(diag(S)) / total_var;
    total_var = sum(diag(S));
    var = diag(S)/total_var;
    exp_var = cumsum(var);
    
    % Scree Plot
    plot(1:length(exp_var),(var), 'o-', 'LineWidth', 1, 'MarkerSize', 5);
    title('Scree Plot');
    xlabel('Principal Component');
    ylabel('Proportion of Explained Variance');
    
    % Scatter plot
    figure;
    scatter(scores(:, 1), scores(:, 2));
    title('Principal Components');
    xlabel('PC1');
    ylabel('PC2');
end
