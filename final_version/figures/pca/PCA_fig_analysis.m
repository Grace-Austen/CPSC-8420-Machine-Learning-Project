


descript_pca = openfig("1k_descript_pca.fig");
name_pca = openfig("1k_name_pca.fig");

"Descript"
% descript_pca.Children.Children(1)
% descript_pca.Children.Children(2)
desc_cum = descript_pca.Children.Children(1);
% desc_cum.YData(600:650)
desc_cum.YData(610)

"Name"
% name_pca.Children.Children(1)
% name_pca.Children.Children(2)
name_cum = name_pca.Children.Children(1);

% name_cum.YData(450:500)
name_cum.YData(461)


% fig = openfig("pca_figures\descript_pca_scree_50k.fig")
% 
% axObjs = fig.Children
% dataObjs = axObjs.Children
% 
% 
% fig2 = copy(fig)
% fig2.Children.Children.YData = cumsum(fig2.Children.Children.YData);
% 
% format default

% fig2.Children.Children.YData(1:10)
% fig2.Children.ChildrenYData(13499)
% dataObjs(171)


