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
    if numel(s1)==1 && numel(s2)==1
        fns=fieldnames(s2);
        for i=1:length(fns)
            if isfield(s1,fns{i}) && ~replaceExisting
                error('mergestruct: field ''%s'' exists in both structures\n',fns{i});
            end
            s1.(fns{i})=s2.(fns{i});
        end
    elseif isequal(size(s1),size(s2))
        if replaceExisting
            error('mergestruct: replaceExisting=true not supported for structure arrays');
        end
        fn1=fields(s1);
        c1=struct2cell(s1);
        fn2=fields(s2);
        c2=struct2cell(s2);
        fn=[fn1;fn2];
        c=cat(1,c1,c2);
        s1=cell2struct(c,fn,1);
    else
        if length(s1)>1
            error('mergestruct: 1st structure is an array');
        end
        if length(s2)>1
            error('mergestruct: 2nd structure is an array');
        end
    end
end
