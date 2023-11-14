% Could be possible to create arbitrary ranges to classify a repo's
% issues col. (i.e. small (0-25th), medium (25th-75th), large (75th-1))
% vals = quantile(data.Issues, [0, 1/3, 2/3, 1]);
% vals = floor(vals);
% 
% % Issues thresholds
% disp('Quantiles:');
% disp(vals);

issues_count = containers.Map({'small', 'medium', 'large'}, [0, 0, 0]);
empty_issues = {};
c = 0;

% Loop each row in the Issues col.
for i = 1:height(data)
    curr_issues = '';

    % Check if empty Issues --> IGNORE
    if isempty(data.Issues(i))
        empty_issues = [empty_issues, data.Name{i}];
        c = c + 1;
    else
        % Classify the repo's Issues
        if data.Issues(i) < 20
            curr_issues = 'small';
            % disp(['small: ', num2str(data.Issues(i)), ' < ', num2str(vals(2))]);
        elseif data.Issues(i) <= 75
            curr_issues = 'medium';
            % disp(['medium: ', num2str(data.Issues(i))]);
        else
            curr_issues = 'large';
            % disp(['large: ', num2str(vals(3)),' < ', num2str(data.Issues(i))]);
        end

        % Increment repo Issues
        if isKey(issues_count, curr_issues)
            issues_count(curr_issues) = issues_count(curr_issues) + 1;
        else
            issues_count(curr_issues) = 1;
        end
    end
end

% Convert map to table
issues_table = table(keys(issues_count)', values(issues_count)', 'VariableNames', {'Issues', 'Count'});

% Resulting Issues count
disp('Repo Issues:');
disp(issues_table);

% Check num. of empty Issues rows
disp('Empty Issues:');
disp(empty_issues');
disp(['Counter: ', num2str(c)]);
