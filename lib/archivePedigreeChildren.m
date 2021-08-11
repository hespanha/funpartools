function archivePedigreeChildren(pedigree,archiveFolder,selectData,selectParameters)
% archivePedigreesChildren(pedigree,archiveFolder,selectData,selectParameters)
%
% Copies to the given folder 'archiveFolder' all the data files
% corresponding to a given pedigree and also all their children (all
% in the same folder as the pedigree) .
%
% Input:
% ------
%
% pedigree - Base pedigree whose data files and children will be archived
%
% archiveFolder - Folder where all files will be copied. If this folder
%                 does not exist, it will be created.
%
% selectData (optional) - Regular expression that permits the selection
%                         of data files to archive based on their name.
%                         E.g.,
%                           selectData='\.(tab|cod|bmu|html)$'
%                         will only allow data files with the 4 given
%                         extensions to be archived.
%
%                         By default selectData='.+', which means that
%                         all data files with non-empty names will
%                         be archived.
%
% selectParameters (optional) - Regular expression that permits the pruning
%                         of parameters to include in the pedigree files
%                         that will be copies, based on the parameters
%                         names. E.g.,
%                           selectParameters='^(nTopics|clusterMethod)$'
%                         will only allow the 2 given parameters to
%                         appear in the pedigree files.
%
%                         By default selectParameters='.+', which
%                         means that all parameters with non-empty
%                         names will be included.
%
% This file is part of Tencalc.
%
% Copyright (C) 2012-21 The Regents of the University of California
% (author: Dr. Joao Hespanha).  All rights reserved.

    verboseLevel=0;
    
    %% get key formating parameters for filenames
    [filename,pedigreeName,pedigreeSuffix,dateFormat,basenameUniqueRegexp,timeStampFormat,pedigreeWildcard]=createPedigree();
    
    if nargin<3
        selectData='.+';
    end
    
    S=regexp(pedigree,'^(.*/|)([^/]+)$','tokens');
    pedigree_path=S{1}{1};
    pedigree_filename=S{1}{2};
    
    if isempty(pedigree_path)
        pedigree_path='./';
    end
    
    fprintf('Archiving pedigree ''%s''\n',pedigree_filename);
    
    %% pedrigree and its data files
    
    if ~exist(pedigree,'file')
        error('archivePedigreeChildren: pedigree file ''%s'' not found\n',pedigree);
    end
    
    files2move=addDataFiles(pedigreeSuffix,{},...
                            pedigree_path,pedigree_filename);
    
    %% pedigree descendents
    fprintf('Looking for descendents in folder ''%s''\n',pedigree_path);
    % get list of pedigree files
    wildcard=sprintf(pedigreeWildcard,pedigree_path,'/*',pedigreeSuffix);
    pedigrees=dir(wildcard);
    
    for thisPedigree=1:length(pedigrees)
        thisName=[pedigree_path,pedigrees(thisPedigree).name];
        if verboseLevel>=2
            fprintf('   analysing pedigree: %s\n',pedigrees(thisPedigree).name);
        end
        
        txt=fileread(thisName);
        found=strfind(txt,pedigree_filename);
        if ~isempty(found)
            if verboseLevel>=2
                fprintf('\t\tfound reference!\n',pedigrees(thisPedigree).name);
            end
            files2move=addDataFiles(pedigreeSuffix,files2move,...
                                    pedigree_path,pedigrees(thisPedigree).name);
        end
    end
    
    %% creating archive folder if it does not exist
    if ~exist(archiveFolder,'dir')
        fprintf('archivePedigreeChildren: archive folder ''%s'' not found, creating it\n',archiveFolder);
        cmd=sprintf('mkdir "%s"',archiveFolder);
        [status,result]=system(cmd);
        if status~=0
            disp(cmd)
            error('archivePedigreeChildren: mkdir failed with status %d\n\t%s\n',status,result);
        end
    end
    
    %% copying
    if verboseLevel>=1
        fprintf('\nArchiving files:\n');
    end
    for i=1:length(files2move)
        if ~isempty(regexp(files2move{i},selectData))
            filein=[pedigree_path,files2move{i}];
            fileout=[archiveFolder,'/',files2move{i}];
            if ~isempty(regexp(files2move{i},[basenameUniqueRegexp,pedigreeSuffix]))
                if verboseLevel>=0
                    fprintf('   archiving pedigree  ''%s''\n',files2move{i});
                end
                % is pedigree
                fin=fopen(filein,'r');
                fout=fopen(fileout,'w');
                if fout<0
                    error('archivePedigreeChildren: unable to create file %s\n',fileout);
                end
                txtout=[];
                include=1;
                while (1)
                    txt=fgets(fin);
                    if ~ischar(txt)
                        break;
                    end
                    if ~isempty(regexp(txt,'^<A NAME='))
                        % start of new file?
                        if include
                            fprintf(fout,'%s',txtout);
                        end
                        txtout=[];
                        include=0;
                    end
                    parname=regexp(txt,'^ *(<LI>)?<EM>([^< ]*) *</EM> = ','tokens');
                    if ~isempty(parname)
                        % parameter name
                        if ~isempty(regexp(parname{1}{2},selectParameters))
                            %fprintf('\tincluding parameter %s\n',parname{1}{2});
                            txtout=[txtout,txt];
                            include=1;
                        else
                            %fprintf('\texcluding parameter %s\n',parname{1}{2});
                        end
                    else
                        % other line
                        txtout=[txtout,txt];
                    end
                end
                if include
                    fprintf(fout,txtout);
                end
                fclose(fin);
                fclose(fout);
            else
                if verboseLevel>=0
                    fprintf('   archiving data file ''%s''\n',files2move{i});
                end
                % is data file
                cmd=sprintf('cp -nv "%s" "%s"',filein,fileout);
                [status,result]=system(cmd);
                if status~=0
                    disp(cmd)
                    error('archivePedigreeChildren: cp failed with status %d\n\t%s\n',status,result);
                end
            end
        else
            %        fprintf('   not archiving ''%s''\n',files2move{i});
        end
    end
    
    fprintf('   done!\n');
    
    function files2move=addDataFiles(pedigreeSuffix,files2move,pedigree_path,pedigree_filename)
        
        verboseLevel=0;
        
        %% add pedigree itself
        files2move(end+1)={pedigree_filename};
        
        if verboseLevel>0
            fprintf('Looking for data of ''%s''\n',pedigree_filename);
        end
        
        %% add data files
        thisWildcard=regexprep(pedigree_filename,[pedigreeSuffix,'$'],'*');
        matchFiles=dir([pedigree_path,thisWildcard]);
        for i=1:length(matchFiles)
            thisName=[pedigree_path,matchFiles(i).name];
            if strcmp(matchFiles(i).name,pedigree_filename)
                %            fprintf('   same (ignored)\n');
                continue;
            end
            if verboseLevel>0
                fprintf('         data file: ''%s''\n',matchFiles(i).name)
            end
            files2move(end+1)={matchFiles(i).name};
        end
    end
end