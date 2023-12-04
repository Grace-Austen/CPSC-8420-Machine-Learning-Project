function []=test_model(model_data_file)
% Parse args
p = inputParser;
addRequired(p, "model_data_file", @mustBeFile)

parse(p, model_data_file);

model_data_file = p.Results.model_data_file;

load(model_data_file, "-mat", "model", "pca", "results_table", "trainX", "trainy", "testX", "testy", "indicator_features");

num_features = length(indicator_features);

%% Test
disp("Testing models");
if strcmp(model, "linear")
    % Linear
    for feature=1:num_features
        disp(strcat("Computing train and test MSE for ", indicator_features(feature)));
        weights = cell2mat(results_table.weights(feature));
        results_table.train_MSE(feature) = rmse(trainX*weights, trainy(:,feature), "omitnan");
        results_table.test_MSE(feature) = rmse(testX*weights, testy(:,feature), "omitnan");
    end
else
    % Regression or lasso model
    lambdas = cell2mat(results_table(:,1))';
    for i=1:length(lambdas)
        for feature=1:num_features
            disp(compose("Computing train and test MSE for %s with lambda %d", indicator_features(feature), lambdas(i)));
            weights = cell2mat(results_table{i, 2}.weights(feature));
            results_table{i, 2}.train_MSE(feature) = rmse(trainX*weights, trainy(:,feature), "omitnan");
            results_table{i, 2}.test_MSE(feature) = rmse(testX*weights, testy(:,feature), "omitnan");
        end
    end
end

%% Plotting
disp("Plotting results");
results_fig = figure;
if strcmp(model, "linear")
    % Linear
    for feature=1:num_features
        subplot(1, num_features, feature)
        bar(["Train", "Test"], [results_table.train_MSE(feature), results_table.test_MSE(feature)]);
        title(strcat(indicator_features(feature), " RMSE"));
    end
else
    % Regression or lasso model
    for feature=1:num_features
        subplot(1, num_features, feature)
        % extract RMSE
        train_RMSEs = zeros(size(lambdas));
        test_RMSEs = zeros(size(lambdas));
        for i=1:length(lambdas)
            train_RMSEs(i) = results_table{i, 2}.train_MSE(feature);
            test_RMSEs(i) = results_table{i, 2}.test_MSE(feature);
        end
        % plot! finally!
        semilogx(lambdas, train_RMSEs,"DisplayName","Train RMSE","LineWidth", 1.5)
        hold on
        loglog(lambdas, test_RMSEs,"DisplayName","Test RMSE","LineWidth", 1.5)
        title(strcat(indicator_features(feature), ' RMSE vs Lambda'))
        xlabel('Log Lambda')
        ylabel('RMSE')
        legend()
    end
end

results_fig.Position = [0 0 1500 350];  

if pca
    saveas(results_fig, compose("figures/%s_model_with_PCA_results.png", model), 'png');
else
    saveas(results_fig, compose("figures/%s_model_PCA_results.png", model), 'png');
end

end