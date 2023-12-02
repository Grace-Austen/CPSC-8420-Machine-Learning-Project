% Relavent columns in temp_data
col_names = {
    'Size', 'Stars', 'Forks', 'Issues', 'Watchers', 'HasIssues', 'HasProjects', 'HasDownloads', 'HasWiki', 'HasPages', 'HasDiscussions', ...
    'descript_JavaScript', 'descript_web', 'descript_framework', 'descript_list', 'descript_UI', 'descript_software', 'descript_CSS', 'descript_Java', ...
    'descript_Python', 'descript_React', 'descript_awesome', 'descript_collection', 'descript_easy', 'descript_free', 'descript_programming', ...
    'lang_Other', 'lang_JavaScript', 'lang_Python', 'lang_TypeScript', 'lang_Java', 'lang_C++', 'lang_Go', 'lang_Shell', 'lang_HTML', 'lang_Rust', ...
    'lang_C', 'lang_C#', 'lang_CSS', 'lang_Clojure', 'lang_Dart', 'topic_javascript', 'topic_python', 'topic_hacktoberfest', 'topic_awesome-list', ...
    'topic_react', 'topic_awesome', 'topic_computer-science', 'topic_css', 'topic_nodejs', 'topic_programming', 'topic_typescript', 'topic_education', ...
    'topic_go', 'topic_interview', 'topic_java'
    };

% Extract relevant columns for PCA
in_use_data = temp_data{:, col_names};

% Center data
mu = mean(in_use_data);
data_cent = in_use_data - mu;

% PCA
[coeff, latent] = svd(cov(data_cent));
[latent, ind] = sort(diag(latent), 'descend');
explained = 100 * latent / sum(latent);
coeff = coeff(:, ind);
score = data_cent * coeff';

% Plotting
figure;
plot(score(:, 1), score(:, 2), 'r*')
xlabel('First component')
ylabel('Second component ')