function rci = RCISummary(TC, E, SV, juveniles)
% Convert summarized Total Coral Cover, Evenness, Shelter Volume and
% Juvenile metrics into equivalent summarized Reef Condition Indices.
%
% See also: 
%   - `summarizeMetrics()`
%
% Inputs:
%   TC        : struct, Summary stats for Total Coral Cover
%   E         : struct, Summary stats for Evenness
%   SV        : struct, Summary stats for Shelter Volume
%   juveniles : struct, Summary stats for Juveniles
%
% Outputs:
%   rci, summary stats for Reef Condition Index
rci = struct();
f_names = string(fieldnames(TC));
for fn = f_names'
    TC_i = TC.(fn);
    E_i = E.(fn);
    SV_i = SV.(fn);
    juv_i = juveniles.(fn);
    
    rci.(fn) = ReefConditionIndex(TC_i, E_i, SV_i, juv_i);
end

end