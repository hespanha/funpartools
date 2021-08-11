function finalizePedigree(pedigreeName,pedigreeNameMat)
% finalizePedigree(pedigreeName,pedigreeNameMat)
%
% Makes permanent a pedigree created using
%
% temporary=true;
% [filename,pedigreeName,pedigreeNameMat]=createPedigree(fileClass,parameters,caller,temporary)
%
% This file is part of Tencalc.
%
% Copyright (C) 2012-21 The Regents of the University of California
% (author: Dr. Joao Hespanha).  All rights reserved.

    old=[pedigreeNameMat,'~'];
    [success,message]=movefile(old,pedigreeNameMat);
    if ~success
        disp(message)
        error('finalizePedigree: unable to movefile(''%s'',''%s'')\n',old,pedigreeNameMat);
    end

    old=[pedigreeName,'~'];
    [success,message]=movefile(old,pedigreeName);
    if ~success
        disp(message)
        error('finalizePedigree: unable to movefile(''%s'',''%s'')\n',old,pedigreeName);
    end

end