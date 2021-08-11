% Apply a regexprep substitution to the contents of a groups of files
% that match a given wildcard, in a given folder The substitution is
% performed in the file as a whole
%
% This file is part of Tencalc.
%
% Copyright (C) 2012-21 The Regents of the University of California
% (author: Dr. Joao Hespanha).  All rights reserved.

%% which files
% '/'-terminated folder
folder='./'

% wildcard
wildcard = '*.html'

% regexprep substitution
%regexp='(TS=2010)-(\d\d)-(\d\d)-(\d\d)-(\d\d)-(\d\d)-(\d\d\d\d\d\d)(\d\d)';
%rep   ='$1$2$3-$4$5$6-$7';

%regexp='\|nIter'
%rep='+nIter'

%regexp='<A NAME=';
%rep=sprintf('\n<A NAME=');

regexp='html"</EM><BR>';
rep='html"<BR>';

%% Loop over files
files=dir([folder,wildcard]);
nChanges=0;
for i=1:length(files)
    filename=sprintf('%s%s',folder,files(i).name);
    bakname =sprintf('%s%s.bak',folder,files(i).name);

    olddata=fileread(filename);
    newdata=regexprep(olddata,regexp,rep);

    if ~strcmp(olddata,newdata)
        nChanges=nChanges+1;
        fprintf(['regexprepFiles:\tchanging file   ''%s''\n\t\trenaming old to ''%s''\n'],filename,bakname);
        if 1
            cmd=sprintf('mv -nv "%s" "%s"',filename,bakname);
            [status,result]=system(cmd);
            if status~=0
                disp(cmd)
                error('regexprepFiles: mv failed with status %d\n\t%s\n',status,result);
            end
            fout=fopen(filename,'w');
            fprintf(fout,'%s',newdata);
            fclose(fout);
        end
    end
end
fprintf('regexprepFiles:\t%d files changed\n',nChanges);
