function [filename,pedigreeName,pedigreeNameMat,...
          pedigreeSuffix,pedigreeSuffixMat,...
          dateFormat,basenameUniqueRegexp,timeStampFormat,pedigreeWildcard,...
          reusingPedigree...
         ]=createPedigree(fileClass,parameters,caller)
% [filename,pedigreeName,pedigreeNameMat]=createPedigree(fileClass,parameters)
%
% This function helps manage file classes.
%
% File classes:
% ------------
%
% Files of the same class arise when a function produces output files
% based a set of input parameters. As one executes the function
% repeatedly passing different input parameters, the function
% produces files of the same class.
%
% Each file in a class is characterized by its 'pedigree' which
% consists of all the input parameters that were used to generate
% the file.
% 
% The goal of this function is to help organize several files in
% each class by 
%    1) Keeping track of the pedigree of each file .
%
%       The actualy pedigree information is saved in an ASCII file
%       with extension '-pedigree.html'
%
%    2) Avoid keeping duplicate copies of files with the same pedigree
%
%       When the function is asked to create a pedigree that already
%       exists in the same folder, the function will return the
%       filename of the existing file and use the existing pedigree.
%
% Input parameters:
% ----------------
% 
% fileClass - Name of the file class, which may have a path and an
%             extension.
%
% parameters - structure with all the parameters ('pedigree') that
%              were used to create the file. Typically created by
%              the function setParameters() or manually constructed
%              by the user
%
% Output parameters:
% -----------------
%
% filename - Actual filename that should be used to create the
%            file. This filename will be of the form
%               {fileClass base name}_{unique code}.{fileClass extension}
%            where the 'unique code' is essentially the date & time
%            of creation
%
% The actual pedigree will be saved in ASCII in a file called
%         {fileClass base name}_{unique code}+pedigree.html
% and also in a .mat file
%         {fileClass base name}_{unique code}+pedigree.mat
% (the later contains the following variables::
%         'parameters',
%         'basename','basenameUnique',
%         'pedigreeName','pedigreeNameMat'
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


verboseLevel=0;  % 0 none, 1 less, 2 more

if nargin<3 & nargin>1
    caller=fileClass;
end

callerName=dbstack(1);
if length(callerName)<1
    callerName='matlabPrompt';
else
    callerName=callerName(1).name;
end

%% Parameters
pedigreeSuffix='-pedigree.html';
pedigreeSuffixMat='-pedigree.mat';
dateFormat='yyyymmdd-HHMMSS';
basenameUniqueRegexp='^(.*\+TS=\d\d\d\d\d\d\d\d-\d\d\d\d\d\d-\d\d\d\d\d\d)';
timeStampFormat='%s+TS=%s-%06.0f'; % for sprintf(.,basename,datestr,subsecond);
pedigreeWildcard='%s%s+TS=*-*-*%s'; % for sprintf(.,path,basename,pedigreeSuffix);

if nargin<1
    % without arguments returns key formating parameters for filenames (above)
    filename=NaN;
    pedigreeName=NaN;
    pedigreeNameMat=NaN;
    return
end

%% Parse fileClass
basename=fileClass;
k=max(find(basename=='/'));
if isempty(k)
    path='.';
    basename=['/',basename];
else
    path=basename(1:k-1);
    basename=basename(k:end);
end
k=max(find(basename=='.'));
if isempty(k)
    extension='';
else
    extension=basename(k:end);
    basename=basename(1:k-1);
end

%path
%basename
%extension

%% Creates unique filename
timestamp=clock;
basenameUnique=sprintf(timeStampFormat,basename,...
                 datestr(floor(timestamp),dateFormat),...
                 1e6*(timestamp(end)-floor(timestamp(end))));
filename=sprintf('%s%s%s',path,basenameUnique,extension);
pedigreeName=sprintf('%s%s%s',path,basenameUnique,pedigreeSuffix);

%% Creates pedrigree file

fid=fopen(pedigreeName,'w+');
if fid<0
    error('createPedigree: unable to create file ''%s''\n',pedigreeName);
end
fprintf(fid,'<STRONG>%s = %s(...)</STRONG>',fileClass,caller);
fprintf(fid,'\n<UL>\n   <LI><EM>~</EM> = "%s"<BR>\n',path);
% display structure
names=fieldnames(parameters);
pedigrees2include={};
for i=1:length(names)
    if ismember(names{i},{'executeScript','verboseLevel'})
        continue
    end 
    fprintf(fid,'   <LI><EM>%-16s</EM> = ',names{i});
    value=getfield(parameters,names{i});
    
    % display value
    switch class(value) 
      case 'table'
        value='<table>';
      case 'function_handle'
        value=char(value);
      case 'struct'
        value=struct2cell(value);
    end
    if ischar(value)
        value={value};
    end
    if strcmp(class(value),'Tcalculus')
        value={value};
    end
    if length(value)==0
        fprintf(fid,'[empty array]<BR>\n');
    end

    for j=1:length(value);
        if iscell(value)
            vj=value{j};
        else
            vj=value(j);
        end
        if iscell(vj) && length(vj)==1
            vj=vj{1};
        end
        if strcmp(class(vj),'Tcalculus')
            vj=str(vj);
        end
        if strcmp(class(vj),'csparse')
            vj=str(vj);
        end
        if isfloat(vj)
            if j==1
                fprintf(fid,'[');
            end
            if vj==floor(vj)
                fprintf(fid,'%8d ',vj);
            else
                fprintf(fid,'%8g ',vj);
            end
            if j==length(value)
                fprintf(fid,']<BR>\n');
            end
        elseif islogical(vj)
            if j==1
                fprintf(fid,'[');
            end
            if vj
                fprintf(fid,' true ');
            else
                fprintf(fid,' false ');
            end
            if j==length(value)
                fprintf(fid,']<BR>\n');
            end
            
        elseif iscell(vj) && all(cellfun(@(x)strcmp(class(x),'outputWithPedigree'),vj)) 
            error('createPedigree: Array of pedigrees not yet implemented\n');
            
        elseif ischar(vj) || strcmp(class(vj),'outputWithPedigree')
            % is the parameter a filename with pedigree?
            if j==1 & length(value)>1
                fprintf(fid,'<UL>');
            end
            if strcmp(class(vj),'outputWithPedigree')
                pedigree=vj.pedigreeName;
                vj=vj.fileName;
            else
                pedigree=[regexp(vj,basenameUniqueRegexp,'match','once'),pedigreeSuffix];
            end
            if exist(pedigree,'file')
                if verboseLevel>1
                    fprintf('createPedigree: found pedigree for parameter value ''%s''\n',vj)
                end
                pedigrees2include(end+1)={pedigree};
                vj=strrep_start(vj,path,'~');
                if j==1
                    fprintf(fid,'"%s"<BR>',vj);
                else
                    fprintf(fid,'<BR>\n         "%s"<BR>',vj);
                end
                fprintf(fid,'\n       <EM>pedigree</EM> = <A HREF="#%s">"%s"</A>\n',...
                        pedigree,strrep_start(pedigree,path,'~'));
                % fp=fopen(pedigree,'r');
                % tline=fgetl(fp); % ignore first line
                % while 1
                %     tline=fgetl(fp);
                %     if ~ischar(tline), break, end
                %     fprintf(fid,'\n         %s',tline);
                % end
                % fclose(fp);
                if j==length(value) 
                    if length(value)>1
                        fprintf(fid,'</UL>\n');
                    else
                        fprintf(fid,'<BR>\n');
                    end
                end
            else
                if isempty(vj)
                    vj='[empty string]';
                else
                    vj=['"',vj,'"'];
                end
                if j==1
                    fprintf(fid,'%s',vj);
                else
                    fprintf(fid,'<BR>%s',vj);
                end
                if j==length(value) 
                    if length(value)>1
                        fprintf(fid,'</UL>\n');
                    else
                        fprintf(fid,'<BR>\n');
                    end
                end
            end
        elseif strcmp(class(vj),'table')
            if j==1
                fprintf(fid,'[');
            end
            fprintf(fid,'[table]');
            if j==length(value)
                fprintf(fid,']<BR>\n');
            end
        elseif strcmp(class(vj),'cell')
            error('createPedigree: cell of cells not yet implemented\n');
        else
            error('createPedigree: unknown parameter type ''%s'' for ''%s''\n',class(vj),names{i});
        end
    end
end
fprintf(fid,'</UL>\n');
pedigrees2include=unique(pedigrees2include);
for i=1:length(pedigrees2include)
    if verboseLevel>0
        fprintf('createPedigree: including %s\n',pedigrees2include{i})
    end
    fprintf(fid,'\n<A NAME="%s"></A>\n',pedigrees2include{i});
    fprintf(fid,'<EM>pedigree</EM>="%s"<BR>',pedigrees2include{i});
    fp=fopen(pedigrees2include{i},'r');
    while 1
        tline=fgetl(fp);
        if ~ischar(tline), break, end
        fprintf(fid,'\n%s',tline);
    end
    fclose(fp);
end
fclose(fid);

%% Look for existing pedigree
wildcard=sprintf(pedigreeWildcard,path,basename,pedigreeSuffix);
files=dir(wildcard);
thisPedigree=fileread(pedigreeName);
reusingPedigree=false;
for i=1:length(files)
    thisName=[path,'/',files(i).name];
    if strcmp(pedigreeName,thisName) 
        % same file?
        continue;
    end
    if verboseLevel>1
        fprintf('createPedigree: testing\n\t  ''%s''\n\t==''%s''\n',pedigreeName,thisName)
    end
    pedigree=fileread(thisName);
    if strcmp(thisPedigree,pedigree)
        % same content
        if verboseLevel>0
            fprintf('createPedigree: pedigree already exists, reusing it\n');
        end
        delete(pedigreeName);
        pedigreeName=thisName;
        basenameUnique=['/',files(i).name(1:end-length(pedigreeSuffix))];
        filename=sprintf('%s%s%s',path,basenameUnique,extension);
        reusingPedigree=true;
        break
    else
        if verboseLevel>1
            fprintf('\t different pedigrees\n');
            disp(thisPedigree)
            disp(pedigree)
        end
    end
end

%% Remove tables from parameters
for i=1:length(names)
    switch class(parameters.(names{i}))
      case 'function_handle'
        parameters.(names{i})=char(parameters.(names{i}));

      case 'table'
        parameters.(names{i})='<TABLE>';
    end
end

pedigreeNameMat=sprintf('%s%s%s',path,basenameUnique,pedigreeSuffixMat);
save(pedigreeNameMat,'-v7.3',...
     'parameters','basename','basenameUnique','pedigreeName','pedigreeNameMat');

return


end

function modifiedstr=strrep_start(origstr,oldstart,newstart)
% modifiedstr=strrep_start(origstr,oldstart,newstart)
% Replace string oldstart by newstart, if the string origstr starts
% with origstart
    
if strncmp(origstr,oldstart,length(oldstart))
    modifiedstr=[newstart,origstr(length(oldstart)+1:end)];
else
    modifiedstr=origstr;
end



end

