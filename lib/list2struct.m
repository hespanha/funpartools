function stru=list2struct(list)
% stru=list2struct(list)
%
% Converts the cell array |list| of the form
%   {'fieldname1', value1, 'fieldname2', value2, ... }
% into a structure |stru| with the given field names and values.
%   
% This function behaves somewhat similar to struct, except that it
% does *not* create an array of structures if the values are cell
% arrays.
%
% This file is part of Tencalc.
%
% Copyright (C) 2012-21 The Regents of the University of California
% (author: Dr. Joao Hespanha).  All rights reserved.

    if ~iscell(list)
        list,
        error('list2struct: input argument must be a cell array')
    end
    if mod(numel(list),2)~=0
        list,
        error('list2struct: input cell array must have an even number of elements')
    end
    fn=reshape(list(1:2:end),1,[]);
    val=reshape(list(2:2:end),1,[]);
    if ~all(cellfun(@ischar,fn))
        list,
        error('list2struct: odd elements of input cell array must by strings')        
    end
    stru=cell2struct(val,fn,2);
end
