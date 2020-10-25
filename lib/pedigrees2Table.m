function pedigrees2Table(path,exclude)
% pedigrees2Table(path,exclude)
%
% Combines all the pedigrees in a given path into a single table
% that highlights the differences between them.
%
% path - path of the foler to look into
% exclude - exclude pedigrees that match this regular expression
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

    verboseLevel=1;

    if nargin<2
        exclude=[];
    end

    fprintf('pedigrees2Table...\n');
    t0=clock();

    %% get key formating parameters for filenames
    [filename,pedigreeName,pedigreeNameMat,pedigreeSuffix,pedigreeSuffixMat,...
     dateFormat,basenameUniqueRegexp,timeStampFormat,pedigreeWildcard]=createPedigree();

    %% get list of pedigree files
    wildcard=sprintf(pedigreeWildcard,path,'/*',pedigreeSuffixMat);
    pedigreeFiles=dir(wildcard);

    pedigrees=struct(...
        'name',{},...
        'basename',{},...
        'parameters',{},...
        'childrenName',{});

    %% Read pedigree files
    columnNames={};
    variableNames={};
    for thisPedigree=1:length(pedigreeFiles)

        if ~isempty(regexp(pedigreeFiles(thisPedigree).name,exclude))
            fprintf('Excluding pedigree: %s\n',pedigreeFiles(thisPedigree).name);
            continue;
        end

        thisName=[path,'/',pedigreeFiles(thisPedigree).name];
        load(thisName);
        fprintf('Analysing pedigree %d: %-20s: %s\n',thisPedigree,basename,pedigreeFiles(thisPedigree).name);

        pedigrees(end+1,1).name=pedigreeName;
        pedigrees(end).basename=basename;
        pedigrees(end).parameters=parameters;
        pedigrees(end).children={};


        names=fieldnames(parameters);
        for i=1:length(names)
            value=parameters.(names{i});
            % update column names
            [columnName,variableName]=getFullNames(basename,names{i});
            if ~ismember(columnName,columnNames)
                columnNames{end+1,1}=columnName;
                variableNames{end+1,1}=variableName;
            end
            % find children pedigrees
            if strcmp(class(value),'function_handle')
                value=char(value);
            end
            if ischar(value)
                value={value};
            end
            for j=1:length(value);
                vj=value(j);
                if iscell(vj) && length(vj)==1
                    vj=vj{1};
                end
                if ischar(vj) || strcmp(class(vj),'outputWithPedigree')
                    if strcmp(class(vj),'outputWithPedigree')
                        pedigree=vj.pedigreeName;
                        vj=vj.fileName;
                    else
                        pedigree=[regexp(vj,basenameUniqueRegexp,'match','once'),pedigreeSuffix];
                        %disp(pedigree)
                    end
                    if exist(pedigree,'file')
                        if verboseLevel>1
                            fprintf('createPedigree: found pedigree for parameter value ''%s''\n',vj)
                        end
                        pedigrees(end).children{end+1,1}=pedigree;
                    end
                end
            end
        end
    end
    %columnNames

    %% link children & create dependents list (row depends on all columns)
    dependents=zeros(length(pedigrees),length(pedigrees));
    for thisPedigree=1:length(pedigrees)
        for thisChild=1:length(pedigrees(thisPedigree).children)
            childName=pedigrees(thisPedigree).children{thisChild};
            for i=1:length(pedigrees)
                %disp(pedigrees(i).name)
                if strcmp(childName,pedigrees(i).name)
                    %fprintf('found children pedigree ''%s''\n',childName);
                    dependents(thisPedigree,i)=1;
                    break
                end
            end
        end
    end

    %% Find out full dependencies
    allDependents=dependents;
    old=allDependents;
    while 1
        allDependents=allDependents+allDependents*allDependents;
        allDependents(allDependents>0)=1;
        if isequal(old,allDependents)
            break;
        end
        old=allDependents;
    end

    % allDependents
    % diag(allDependents)
    % any(allDependents,1)
    % any(allDependents,2)

    % check regexp
    noChildren=find(any(allDependents,1)==0);

    % save all parameters to table (initially a structure)
    tbl=cell2struct(cell(0,length(variableNames)+1),[{'pedigreeName'};variableNames],2);

    for row=1:length(noChildren)
        pedigree=pedigrees(noChildren(row)).name;
        children=union(noChildren(row),find(allDependents(noChildren(row),:)));
        fprintf('Writing parameters for %d: %-70s (%d children)\n',...
                noChildren(row),pedigree,length(children));
        % initiliza row with emptry strings
        n=fields(tbl);
        for k=1:length(n)
            tbl(row,1).(n{k})='';
        end
        tbl(row,1).pedigreeName=pedigree;
        %find(dependents(noChildren(row),:))
        %find(allDependents(noChildren(row),:))
        for k=1:length(children)
            name=pedigrees(children(k)).name;
            basename=pedigrees(children(k)).basename;
            parameters=pedigrees(children(k)).parameters;
            names=fieldnames(parameters);
            fprintf('   depends on: %-70s\n',name);
            for i=1:length(names)
                [columnName,variableName]=getFullNames(basename,names{i});
                if isfield(tbl,variableName) && ~isempty(tbl(row,1).(variableName))
                    %tbl(row)
                    fprintf('pedigree2Table: pedigree %s (row %d)\n',...
                          pedigree,row);
                    fprintf('                has 2 values for column %s (basename=%s, parameter=%s)\n',...
                          columnName,basename,names{i});
                    fprintf('  Old:\n');
                    disp(tbl(row,1).(variableName))
                    fprintf('  New:\n');
                    disp(parameters.(names{i}))
                    error('cannot convert to table with these basenames\n')
                end
                tbl(row,1).(variableName)=tableFriendly(parameters.(names{i}));
            end
        end
    end
    tbl=struct2table(tbl);
    tbl.Properties.VariableDescriptions=[{'pedigreeName'};columnNames];
    tbl=tableCheckClasses(tbl,true,true);
    filename=fullfile(path,'pedigrees');
    tableMultiWrite('outputTable',fullfile(path,'pedigrees'),...
                    'tbl',tbl,'quoteCells',true,...
                    'outputFormats','tab');
    fprintf('done pedigree2table (%.2f sec)\n',etime(clock(),t0));
end

function [columnName,variableName]=getFullNames(basename,parametername)

    columnName=sprintf('%s_%s',basename,parametername);

    if nargout<2
        return
    end
    if verLessThan('matlab','8.3')
        variableName=regexprep(columnName,'^/','')               % remove leading /
        variableName=regexprep(variableName,'[^A-Za-z0-9_]','_') % remove characters not allowed
        variableName=regexprep(variableName,'^([0-9])','_$1')    % prevent leading numeric
        variableName=regexprep(variableName,'^_','x_')           % prevent leading _
    else
        variableName=matlab.lang.makeValidName(columnName);
    end

end

function value=tableFriendly(value)
% Try to convert arbitrary value to a format that can be written by tableMultiWrite
    switch class(value)
      case 'function_handle'
        value=char(value);
      case 'outputWithPedigree'
        value=value.fileName;
    end
end