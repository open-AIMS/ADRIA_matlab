criterias = criteriaDetails();

% test return is of expected type
assert(isequal(class(criterias), 'table'))

% Test table gets returned with default bounds set
assert(all(criterias{1, "raw_bounds"} == [0 1]), "wave_stress bounds incorrect!")
assert(all(criterias{1, "raw_bounds"} == [0 1]), "heat_stress bounds incorrect!")
assert(all(criterias{1, "raw_bounds"} == [0 1]), "shade_connectivity bounds incorrect!")
assert(all(criterias{1, "raw_bounds"} == [0 1]), "seed_connectivity bounds incorrect!")
assert(all(criterias{1, "raw_bounds"} == [0 1]), "coral_cover_high bounds incorrect!")
assert(all(criterias{1, "raw_bounds"} == [0 1]), "coral_cover_low bounds incorrect!")
assert(all(criterias{1, "raw_bounds"} == [0 1]), "seed_priority bounds incorrect!")
assert(all(criterias{1, "raw_bounds"} == [0 1]), "shade_priority bounds incorrect!")
assert(all(criterias{1, "raw_bounds"} == [0 1]), "deployed_coral_risk_tol bounds incorrect!")