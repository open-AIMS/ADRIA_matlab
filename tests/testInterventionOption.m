default_interventions = interventionSpecification();

% Test returned type is of struct
assert(isequal(class(default_interventions), 'struct'))

% Test struct gets returned with default values set
assert(all(default_interventions.Guided == [0, 1]))
assert(isequal(default_interventions.PrSites, 3))
assert(all(default_interventions.Seed1 == [0, 0.0005, 0.0010]))
assert(isequal(default_interventions.Seed2, 0))
assert(isequal(default_interventions.SRM, 0))
assert(all(default_interventions.Aadpt == [6, 12]))
assert(isequal(default_interventions.Natad, 0.05))
assert(isequal(default_interventions.Seedyrs, 10))
assert(isequal(default_interventions.Shadeyrs, 1))
assert(isequal(default_interventions.sims, 50))
