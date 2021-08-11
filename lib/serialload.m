function data=serialload(filename)
% data=serialload(filename)
%   Retrives data save with serialsave.
%
% This file is part of Tencalc.
%
% Copyright (C) 2012-21 The Regents of the University of California
% (author: Dr. Joao Hespanha).  All rights reserved.

% needs extension?
    if isempty(regexp(filename,'\.[^/]*$','match'))
        filename=sprintf('%s.serialmatlab',filename);
    end
    
    fid=fopen(filename,'r');
    if fid<0
        error('\nserialload: ''%s'' file not found\n',filename);
    end
    bytes=fread(fid,inf);
    fclose(fid);
    
    data=hlp_deserialize(bytes);
end

