def_interv = interventionDetails();

% Test returned type is of table
assert(isequal(class(def_interv), 'table'))

% Test table gets returned with default bounds set
assert(all(def_interv{1, "raw_bounds"}{1} == [0 1]), "Guided bounds incorrect!")
assert(all(def_interv{2, "raw_bounds"}{1} == [1 3]), "PrSites bounds incorrect!")
assert(all(def_interv{3, "raw_bounds"}{1} == [0 1.0000e-03]), "Seed1 bounds incorrect!")
assert(all(def_interv{4, "raw_bounds"}{1} == [0 1]), "Seed2 bounds incorrect!")
assert(all(def_interv{5, "raw_bounds"}{1} == [0 1]), "SRM bounds incorrect!")
assert(all(def_interv{6, "raw_bounds"}{1} == [6 12]), "Aadpt bounds incorrect!")
assert(all(def_interv{7, "raw_bounds"}{1} == [0.0100 0.1000]), "Natad bounds incorrect!")
assert(all(def_interv{8, "raw_bounds"}{1} == [10 15]), "Seedyrs bounds incorrect!")
assert(all(def_interv{9, "raw_bounds"}{1} == [1 5]), "Shadeyrs bounds incorrect!")
