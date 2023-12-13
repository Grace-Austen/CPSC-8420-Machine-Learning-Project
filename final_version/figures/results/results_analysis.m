close all; clear all;

%% Error normalization
% load("../../models/linear_model_with_PCA_weight.mat")
% 
% s_train_lin = max(trainy)-min(trainy);
% s_test_lin = max(testy)-min(trainy);
% 
% fig_lin = openfig("linear_model_with_PCA_results.fig");
% for i=1:3
%     fig_lin.Children(i).Children.YData(1) = fig_lin.Children(i).Children.YData(1)/s_train_lin(i);
%     fig_lin.Children(i).Children.YData(2) = fig_lin.Children(i).Children.YData(2)/s_test_lin(i);
% end
% 
% saveas(fig_lin, "linear_model_with_PCA_results_scaled.fig")
% saveas(fig_lin, "linear_model_with_PCA_results_scaled.png")
% 
% fig_ridge = openfig("ridge_model_with_PCA_results.fig");
% 
% for i=1:3
%     fig_ridge.Children(2*i).Children(1).YData = fig_ridge.Children(2*i).Children(1).YData/s_test_lin(i);
%     fig_ridge.Children(2*i).Children(2).YData = fig_ridge.Children(2*i).Children(2).YData/s_train_lin(i);
% end
% 
% saveas(fig_ridge, "ridge_model_with_PCA_results_scaled.fig")
% saveas(fig_ridge, "ridge_model_with_PCA_results_scaled.png")

%% Ridge Regression extra analysis
load("../../models/ridge_model_with_PCA_weights.mat")

stars_norm = zeros(1, 11);
forks_norm = zeros(1,11);
issues_norm = zeros(1,11);
lambdas = cell2mat(results_table(:,1));
for i=1:11
    weights_table = results_table(i,2);
    weight_t = weights_table{1};
    stars_norm(i) =     norm(cell2mat(weight_t{"Stars", "weights"}));
    forks_norm(i) =     norm(cell2mat(weight_t{"Forks", "weights"}));
    issues_norm(i) =     norm(cell2mat(weight_t{"Issues", "weights"}));
end

ridge_fig_2 = figure;
loglog(lambdas, stars_norm, "DisplayName","Stars");
hold on
loglog(lambdas, forks_norm, "DisplayName","Forks");
hold on
loglog(lambdas, issues_norm, "DisplayName","Issues");
xlabel("Lambdas")
ylabel("Norm of Weights")
title("Ridge Regression Weights vs Lambda")
