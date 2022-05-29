function s1=mergestruct(s1,s2,replaceExisting)
% Merges two structures:
%
%  
%  mergestruct(s1,s2):
%
%    returns a structure with the all the fields of structure s1 and
%    s2. The two structures s1 and s2 cannot be arrays of structures
%    and cannot have fields with the same names.
%
%  mergestruct(s1,s2,replaceExisting):
%    
%    same as before, but when `replaceExisting=true` if the two
%    structures have the same field, the value in `s2` is used (and
%    the value in `s1` is discarded).
%  
%
% This file is part of Tencalc.
%
% Copyright (C) 2012-21 The Regents of the University of California
% (author: Dr. Joao Hespanha).  All rights reserved.

    if nargin<3
        replaceExisting=false;
    end
    if length(s1)>1
        error('mergestruct: 1st structure is an array');
    end
    if length(s2)>1
        error('mergestruct: 2nd structure is an array');
    end
    fns=fieldnames(s2);
    for i=1:length(fns)
        if isfield(s1,fns{i}) && ~replaceExisting
            error('mergestruct: field ''%s'' exists in both structures\n',fns{i});
        end
        s1.(fns{i})=s2.(fns{i});
    end
end
