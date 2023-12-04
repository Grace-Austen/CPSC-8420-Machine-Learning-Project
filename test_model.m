function []=test_model(model_data_file, varargin)
% Parse args
p = inputParser;
addRequired(model_data_file, @mustBeFile)

parse(p, model_data_file, varargin{:});

model_data_file = p.Results.model_data_file;

load(model_data_file, "-mat", "model", "pca", "results_table", "trainX", "trainy", "testX", "testy");

%% Test
if ~strcmp(model, "linear")
% Regression or lasso model
    for i=1:length(lambdas)
        for feature=1:length(indicator_features)
            disp("Computing train and test MSE for ", indicator_features(feature), " with lambda ", lambdas(i));
            results_table{i}.train_MSE(feature) = rmse(trainX*results_table{i}.weights(feature), trainy(:,feature), "omitnan");
            results_table{i}.test_MSE(feature) = rmse(testX*results_table{i}.weights(feature), testy(:,feature), "omitnan");
        end
    end
else
% Linear
    for feature=1:length(indicator_features)
        disp("Computing train and test MSE for ", indicator_features(feature));
        results_table.train_MSE(feature) = rmse(trainX*results_table.weights(feature), trainy(:,feature), "omitnan");
        results_table.test_MSE(feature) = rmse(testX*results_table.weights(feature), testy(:,feature), "omitnan");
    end
end

%% Plotting
if ~strcmp(model, "linear")
% Regression or lasso model
    for i=1:length(lambdas)
        for feature=1:length(indicator_features)
            disp("Computing train and test MSE for ", indicator_features(feature), " with lambda ", lambdas(i));
            lambda_results_table{i}.train_MSE(feature) = rmse(trainX*lambda_results_table{i}.weights(feature), trainy(:,feature), "omitnan");
            lambda_results_table{i}.test_MSE(feature) = rmse(testX*lambda_results_table{i}.weights(feature), testy(:,feature), "omitnan");
        end
    end
else
% Linear
    indicator_features = results_table.
    for feature=1:length(indicator_features)
        disp(["Computing train and test MSE for " indicator_features(feature)]);
        results_table.train_MSE(feature) = rmse(trainX*results_table.weights(feature), trainy(:,feature), "omitnan");
        results_table.test_MSE(feature) = rmse(testX*results_table.weights(feature), testy(:,feature), "omitnan");
    end
end



end