function []=train_model(model_type)
% Parse args
p = inputParser;

default_model = "linear";
default_data_file = "data\data";

addOptional(p, 'model', default_model, @check_model);
addOptional(p, 'data_file', default_data_file);

% Training and testing with Lasso Regression
%% Load Data
load(data_file, "");

end

%% Parsing Functions
function TF = check_model(model)
    valid_models = ["linear", "ridge", "lasso", "pca"];
    TF = any(ismember(valid_models, lower(model)));
    if ~TF
       error('Model must be one of the following: linear, ridge, lasso, PCA');
    end

end