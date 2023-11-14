% % Could be possible to create arbitrary ranges to classify a repo's
% % size col. (i.e. small (0-25th), medium (25th-75th), large (75th-1))
% vals = quantile(data.Size, [0, 1/3, 2/3, 1]);
% vals = floor(vals);
% 
% % Size thresholds
% disp('Quantiles:');
% disp(vals);

size_count = containers.Map({'small', 'medium', 'large'}, [0, 0, 0]);
empty_size = {};
c = 0;

% Loop each row in the Size col.
for i = 1:height(data)
    curr_size = '';

    % Check if empty Size --> IGNORE
    if isempty(data.Size(i))
        empty_size = [empty_size, data.Name{i}];
        c = c + 1;
    else
        % Classify the repo's Size
        if data.Size(i) < 1500
            curr_size = 'small';
        elseif data.Size(i) <= 10000
            curr_size = 'medium';
        else
            curr_size = 'large';
        end

        % Increment repo size
        if isKey(size_count, curr_size)
            size_count(curr_size) = size_count(curr_size) + 1;
        else
            size_count(curr_size) = 1;
        end
    end
end

% Convert map to table
size_table = table(keys(size_count)', values(size_count)', 'VariableNames', {'Size', 'Count'});

% Resulting Size count
disp('Repo Sizes:');
disp(size_table);

% Check num. of empty Size rows
disp('Empty Size:');
disp(empty_size');
disp(['Counter: ', num2str(c)]);
