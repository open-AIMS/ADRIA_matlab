def_interv = interventionDetails();

% Test returned type is of table
assert(isequal(class(def_interv), 'table'))

% Test table gets returned with default bounds set
assert(all(def_interv{1, "raw_bounds"} == [0 4]), "Guided bounds incorrect!")
assert(all(def_interv{2, "raw_bounds"} == [100 10000]), "Seed1 bounds incorrect!")
assert(all(def_interv{3, "raw_bounds"} == [100 10000]), "Seed2 bounds incorrect!")
assert(all(def_interv{4, "raw_bounds"} == [0 12]), "SRM bounds incorrect!")
assert(all(def_interv{5, "raw_bounds"} == [0 12]), "Aadpt bounds incorrect!")
assert(all(def_interv{6, "raw_bounds"} == [0.0 0.1]), "Natad bounds incorrect!")
assert(all(def_interv{7, "raw_bounds"} == [10 15]), "Seedyrs bounds incorrect!")
assert(all(def_interv{8, "raw_bounds"} == [10 25]), "Shadeyrs bounds incorrect!")
