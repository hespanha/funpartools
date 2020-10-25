% Renames all files that match a given wildcard, in a given folder
% by performing a regexprep substitution in the file names.
%
% Copyright 2012-2017 Joao Hespanha

% This file is part of Tencalc.
%
% TensCalc is free software: you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by the
% Free Software Foundation, either version 3 of the License, or (at your
% option) any later version.
%
% TensCalc is distributed in the hope that it will be useful, but
% WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
% General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with TensCalc.  If not, see <http://www.gnu.org/licenses/>.


% which files
folder='./'
wildcard = '*.*'

% regexprep substitution ($N for tokens in rep)
%regexp='(TS=2010)-(\d\d)-(\d\d)-(\d\d)-(\d\d)-(\d\d)-(\d\d\d\d\d\d)(\d\d)';
%rep   ='$1$2$3-$4$5$6-$7';

%% Loop over files
files=dir([folder,wildcard]);
nChanges=0;
for i=1:length(files)
    oldname=files(i).name;
    newname=regexprep(oldname,regexp,rep);
    if ~strcmp(oldname,newname)
        nChanges=nChanges+1;
        cmd=sprintf('mv -nvi "%s%s" "%s%s"',folder,oldname,folder,newname);
        if 1
            system(cmd);
        else
            disp(cmd)
        end
    end
end
fprintf('regexprepFiles:\t%d files changed\n',nChanges);
