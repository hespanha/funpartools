function filename=myTempName();
% returns a temporary filename in the current folder, startingwith 'tmp_' and with extension '.tmp'
%
% This file is part of Tencalc.
%
% Copyright (C) 2012-21 The Regents of the University of California
% (author: Dr. Joao Hespanha).  All rights reserved.

    filename=tempname('.');
    [~,filename,extension]=fileparts(filename);
    filename=['tmp_',filename,'.tmp'];

end