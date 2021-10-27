criterias = criteriaWeights();

% test return is of expected type
assert(isequal(class(criterias), 'double'))

% Test struct gets returned with default values set
assert(isequal(criterias(:,1), 1))
assert(isequal(criterias(:,2), 1))
assert(isequal(criterias(:,3), 0))
assert(isequal(criterias(:,4), 0))
assert(isequal(criterias(:,5), 0))
assert(isequal(criterias(:,6), 0))
assert(isequal(criterias(:,7), 1))
assert(isequal(criterias(:,8), 0))
assert(isequal(criterias(:,9), 1))
