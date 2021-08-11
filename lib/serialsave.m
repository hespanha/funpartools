function serialsave(filename,data)
% serialsave(filename,data)
%   Serializw a data structure and save it as a byte stream.
%
% This file is part of Tencalc.
%
% Copyright (C) 2012-21 The Regents of the University of California
% (author: Dr. Joao Hespanha).  All rights reserved.
    
    bytes=hlp_serialize(data);
    
    % needs extension?
    if isempty(regexp(filename,'\.[^/]*$','match'))
        filename=sprintf('%s.serialmatlab',filename);
    end
    fid=fopen(filename,'w');
    fwrite(fid,bytes);
    fclose(fid);
end

