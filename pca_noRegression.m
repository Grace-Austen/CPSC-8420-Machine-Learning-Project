function scores = pca_noRegression(X)
    % X = X(:, 1:10)
    % mu = mean(X);
    % X_cent = X - mu;
    X_cent = X(:, 1:10); % PROBLEM: There is no distinct elbow point with just the one_hot_(descript or name) but is with
                         %          pca_noRegression([indicator_data one_hot_name]) at K = 2  

    [~, S, V] = svd(cov(X_cent));
    [~, indices] = sort(diag(S), 'descend');
    V = V(:, indices);
    
    scores = X_cent * V;

    figure('Position', [100, 100, 800, 400]);
    total_var = sum(diag(S));
    exp_var = cumsum(diag(S)) / total_var;
    
    % Scree Plot
    plot(1:length(exp_var),(1 - exp_var), 'o-', 'LineWidth', 2);
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
