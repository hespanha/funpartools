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
% This file is part of Tencalc.
%
% Copyright (C) 2012-21 The Regents of the University of California
% (author: Dr. Joao Hespanha).  All rights reserved.

    verboseLevel=1;

    %% get key formating parameters for filenames
    [filename,pedigreeName,pedigreeNameMat,pedigreeSuffix,pedigreeSuffixMat,...
     dateFormat,basenameUniqueRegexp,timeStampFormat,pedigreeWildcard]=createPedigree();

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
end
