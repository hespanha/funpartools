function struct2workspace(stru)
% struct2list(stru)
%
% For each field of the structure creates a variable in the caller's
% workspace, with the name of the field and value of the structure's
% correspnding field
%
% This file is part of Tencalc.
%
% Copyright (C) 2012-21 The Regents of the University of California
% (author: Dr. Joao Hespanha).  All rights reserved.

    fs=fields(stru);
    for i=1:length(fs)
        assignin('caller',fs{i},stru.(fs{i}));
    end
end
