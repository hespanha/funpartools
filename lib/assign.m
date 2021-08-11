function assign(variableName,value)
% assign(variableName,value)
%
% assigns the given value to the variablename 'variableName'
%
% This file is part of Tencalc.
%
% Copyright (C) 2012-21 The Regents of the University of California
% (author: Dr. Joao Hespanha).  All rights reserved.
    assignin('caller',variableName,value);
end
