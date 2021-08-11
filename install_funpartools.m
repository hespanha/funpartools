% This file is part of Tencalc.
%
% Copyright (C) 2012-21 The Regents of the University of California
% (author: Dr. Joao Hespanha).  All rights reserved.

fprintf('Seeting up path:\n');
home=[fileparts(which('install_funpartools')),'/lib'];
folders={home;[home,'/serialization']};
      
s=path;
if ispc
    old=regexp(s,'[^;]*(funpartools.lib.serialization|funpartools.lib.)[^/;]*','match');
else
    old=regexp(s,'[^:]*(funpartools.lib.serialization|funpartools.lib.)[^/:]*','match');
end
if ~isempty(old)
    fprintf('  removing from path:\n');
    disp(old')
    rmpath(old{:})
end

fprintf('  adding to path:\n');
addpath(folders{:});
disp(folders)

fprintf('  saving path...');
try
    savepath;
catch me
    fprintf('ATTENTION: unable to save path. This was probably caused because of insufficient permissions. Either change the permissions of your ''matlabroot'' folder or add following strings to the matlab path:');
    disp(folders)
    rethrow(me)
end
fprintf('done with path!\n');
