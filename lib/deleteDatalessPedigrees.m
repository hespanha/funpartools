function deleteDatalessPedigrees(path)
% deleteOrphanPedigrees(path)
%
% Removes pedigree files without "child" data files in the class
%
% Attention: Should NOT be called between calling
%    filename=createPedigree(...)
% and using the returned filename to create the data file.
%
% (This is especially important to keep in mind for files that may be
% manually created much later.)
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

%% get key formating parameters for filenames
[filename,pedigreeName,pedigreeNameMat,pedigreeSuffix,pedigreeSuffixMat,dateFormat,basenameUniqueRegexp,timeStampFormat,pedigreeWildcard]=createPedigree();

%% get list of pedigree files
wildcard=sprintf(pedigreeWildcard,path,'/*',pedigreeSuffix);
pedigrees=dir(wildcard);

%% Erase -pedigree.html files
for thisPedigree=1:length(pedigrees)
    thisName=[path,'/',pedigrees(thisPedigree).name];
    fprintf('Analysing pedigree: %s\n',pedigrees(thisPedigree).name);

    thisWildcard=regexprep(thisName,[pedigreeSuffix,'$'],'*');
    matchFiles=dir(thisWildcard);

    match=false;
    for i=1:length(matchFiles)
        if ~isempty(regexp(matchFiles(i).name,[pedigreeSuffix,'$'])) || ...
                ~isempty(regexp(matchFiles(i).name,[pedigreeSuffixMat,'$']))
            %            fprintf('   same (ignored)\n');
            continue;
        end
        if verboseLevel>1
            fprintf('         data file: %s\n',matchFiles(i).name)
        end
        match=true;
    end

    if ~match
        filename=thisName;
        fprintf('***      NO DATA, will delete %s\n',filename);
        delete(filename)
    end
end

wildcard=sprintf(pedigreeWildcard,path,'/*',pedigreeSuffixMat);
pedigrees=dir(wildcard);

%% Erase -pedigree.mat files
for thisPedigree=1:length(pedigrees)
    thisName=[path,'/',pedigrees(thisPedigree).name];
    fprintf('Analysing pedigree: %s\n',pedigrees(thisPedigree).name);

    thisWildcard=regexprep(thisName,[pedigreeSuffixMat,'$'],'*');
    matchFiles=dir(thisWildcard);

    match=false;
    for i=1:length(matchFiles)
        if ~isempty(regexp(matchFiles(i).name,[pedigreeSuffix,'$'])) || ...
                ~isempty(regexp(matchFiles(i).name,[pedigreeSuffixMat,'$']))
            %            fprintf('   same (ignored)\n');
            continue;
        end
        if verboseLevel>1
            fprintf('         data file: %s\n',matchFiles(i).name)
        end
        match=true;
    end

    if ~match
        filename=thisName;
        fprintf('***      NO DATA, will delete %s\n',filename);
        delete(filename)
    end
end
