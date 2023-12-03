% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % Refer back to wikipedia explanation of Principal Component Regression:  %
% %       - https://en.wikipedia.org/wiki/Principal_component_regression    %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% 
% % Combine all one-hot encodings
% X = one_hot_name;
X = one_hot_descript;
% X = [one_hot_name, one_hot_lang, one_hot_descript, one_hot_topic];
% X = [other_data, one_hot_name, one_hot_descript];

% craft as function where i specify the k for the svd to save more time
% and pass the data (aka one_hot_name, etc.)

% Center the data
mu = mean(X);
X_cent = X - mu;

% Eigendecomp.
[U, S, V] = svd(cov(X_cent));
[S, indices] = sort(diag(S), 'descend');
V = V(:, indices);

% Calculate principal components
p_comp = X_cent * V;

% Plot 2 components
figure;
scatter(p_comp(:, 1), p_comp(:, 2));
title('Principal Components');
xlabel('PC1');
ylabel('PC2');

% PCR Estimator
PCR_estimator = (p_comp / (V' * V)) * V' * X_cent';

% Display PCR Estimator
disp("PCR Estimator:");
disp(PCR_estimator);


% Feature number list
k = [2, 3, 5, 10, 20, 30];
for i = 1:size(k, 2)
    % Top columns of V
    W = V(:, 1:k(i));
    % Reconstruction data via W*W'*X plus the mean
    data_reconst = W * W' * X_cent' + mu';
    % Plot the reconstruction
    figure;
    scatter3(data_reconst(1, :), data_reconst(2, :), data_reconst(3, :));
    title(['Reconstruction with ', num2str(k(i)), ' components']);
    xlabel('PC1');
    ylabel('PC2');
    zlabel('PC3');
end

% Covariance vs. Num. components
figure;
num_components = min(length(S), 1000); % Set a limit on the number of components
plot(1:num_components, cumsum(S(1:num_components)) / sum(S), 'o-');
title('Covariance vs. Number of Components');
xlabel('Number of Components (k)');
ylabel('Cumulative Covariance Explained');
grid on;
