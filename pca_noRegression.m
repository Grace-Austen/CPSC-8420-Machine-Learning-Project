function scores = pca_noRegression(X)    
    % mu = mean(X);
    % X_cent = X - mu;
    X_cent = X; % not acutally centered 
    
    [~, S, V] = svd(cov(X_cent));
    [~, indices] = sort(diag(S), 'descend');
    V = V(:, indices);
    
    scores = X_cent * V;

    figure('Position', [100, 100, 800, 400]);
    total_var = sum(diag(S));
    exp_var = cumsum(diag(S)) / total_var;
    
    % Scree Plot
    plot(1:length(exp_var), exp_var, 'o-', 'LineWidth', 2);
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
