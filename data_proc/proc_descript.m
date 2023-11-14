% TO BE IMPLEMENTED --> 
%   (maybe) removal of stop words
descript_count = containers.Map();
empty_descript = {};
c = 0;

% Loop each row in the Description col.
for i = 1:height(data)
    % Check num. of empty Description rows
    if isempty(data.Description{i})
        empty_descript = [empty_descript, data.Name{i}];
        c = c + 1;
    end
    temp_descript = split(data.Description{i});

    % Loop through each descript in the Description row
    for j = 1:length(temp_descript)
        curr_descript = temp_descript{j};

        % Check if key already exists
        if isKey(descript_count, curr_descript)
            descript_count(curr_descript) = descript_count(curr_descript) + 1;
        else
            descript_count(curr_descript) = 1;
        end
    end
end

% Convert map to table and sort
descripts_table = table(keys(descript_count)', values(descript_count)', 'VariableNames', {'Tag', 'Count'});
descripts_table = sortrows(descripts_table, 'Count', 'descend');

% Resulting descripts count
disp('Top 40 Description Words:');
disp(head(descripts_table, 40));
% disp(head(descripts_table, 10));


% Check num. of empty Description rows
disp('Empty Descriptions:');
disp(empty_descript');
disp(['Counter: ', num2str(c)]);
