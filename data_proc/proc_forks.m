% % Could be possible to create arbitrary ranges to classify a repo's
% % forks col. (i.e. small (0-25th), medium (25th-75th), large (75th-1))
% vals = quantile(data.Forks, [0, 1/3, 2/3, 1]);
% vals = floor(vals);
% 
% % Forks thresholds
% disp('Quantiles:');
% disp(vals);

forks_count = containers.Map({'small', 'medium', 'large'}, [0, 0, 0]);
empty_forks = {};
c = 0;

% Loop each row in the Forks col.
for i = 1:height(data)
    curr_forks = '';

    % Check if empty Forks --> IGNORE
    if isempty(data.Forks(i))
        empty_forks = [empty_forks, data.Name{i}];
        c = c + 1;
    else
        % Classify the repo's Forks
        if data.Forks(i) < 2000
            curr_forks = 'small';
        elseif data.Forks(i) <= 7500
            curr_forks = 'medium';
        else
            curr_forks = 'large';
        end

        % Increment repo Forks
        if isKey(forks_count, curr_forks)
            forks_count(curr_forks) = forks_count(curr_forks) + 1;
        else
            forks_count(curr_forks) = 1;
        end
    end
end

% Convert map to table
forks_table = table(keys(forks_count)', values(forks_count)', 'VariableNames', {'Forks', 'Count'});

% Resulting Forks count
disp('Repo Forks:');
disp(forks_table);

% Check num. of empty Forks rows
disp('Empty Forks:');
disp(empty_forks');
disp(['Counter: ', num2str(c)]);
