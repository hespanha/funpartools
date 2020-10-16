classdef partoolsfeval < handle;
% Class to support the execution of many function evaluations in in parallel

    properties;
        % folder where the files associated with all the functions to be evaluated will be stored
        allTasksFolder 
        
        % time to sleep, while waiting
        waitTimeSec=1;
        
        verboseLevel=20;
    end
    
    methods;
        
        %%%%%%%%%%%%%%%%%%%%%
        %% Object creation %%
        %%%%%%%%%%%%%%%%%%%%%
        
        function obj=partoolsfeval(folder,create,verboseLevel)
        % obj=partoolsfeval(folder)
        %
        % obj=partoolsfeval(folder,create)
        %
        % Creates an object associated with a set of tasks to be
        % executed in parallel. All informaton about the given set of
        % tasks is stored in the given folder.
        %
        % When the input parameter |create| is present and true, the
        % folder is created in case it does not exists. 
        %
        % When the input parameter |create| is not present or it is
        % false and the folder does not exists, an error is generated.
            
            obj.allTasksFolder=folder;
            if nargin<2
                create=false;
            end
            if nargin>=3
                obj.verboseLevel=verboseLevel;
            end
            
            [isLocal,computer,filename]=parseName(obj,obj.allTasksFolder);
            
            if isLocal
                % local filesysytem
                if exist(folder,'dir')
                    if obj.verboseLevel>1
                        fprintf('partoolsfeval: reusing existing local tasks folder "%s"\n',folder);
                    end
                else
                    if create
                        [suc,msg]=mkdir(folder);
                        if ~suc 
                            disp(msg);
                            error('partoolsfeval: unable to create local folder ''%s''\n',folder);                    
                        end
                    if obj.verboseLevel>1
                        fprintf('partoolsfeval: successfully created local tasks folder "%s"\n',folder);
                    end
                    else
                        error('partoolsfeval: local folder ''%s'' does not exist\n',folder);
                    end
                end
            else
                % remote filesystem
                cmd=sprintf('ssh %s cd "%s"',computer,filename);
                [rc,resul]=system(cmd);
                exists=(rc==0);
                if exists
                    if obj.verboseLevel>1
                        fprintf('partoolsfeval: reusing existing local tasks folder "%s"\n',folder);
                    end
                else
                    if create
                        cmd=sprintf('ssh %s mkdir "%s"',computer,filename);
                        [rc,result]=system(cmd);
                        suc=(rc==0);
                        if ~suc
                            disp(result)
                            error('partoolsfeval: unable to create remote folder ''%s''\n',folder);                    
                        end
                    if obj.verboseLevel>1
                        fprintf('partoolsfeval: successfully created remote tasks folder "%s"\n',folder);
                    end
                    else
                        error('partoolsfeval: local folder ''%s'' does not exist\n',folder);
                    end
                end
            end                
        
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% filenames used for saving data (and locking!) %%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function fn=taskFoldername(obj,h)
        % returns folder filename, given the task handle
            fn=fullfile(obj.allTasksFolder,sprintf('%06d',h));
        end
        function h=taskFolder2handle(obj,folder,name)
        % returns task handle, given task folder filename
            h=str2double(name);
        end
        function h=taskDone2handle(obj,folder,name)
        % returns task handle, given task folder filename
            [fl,fn]=fileparts(folder);
            h=taskFolder2handle(obj,fl,fn);
        end
        
        % Wildcards
        function wc=taskFolderWildCard(obj)
        % returns wildcard to look for existing task folders
            wc=obj.allTasksFolder;
        end
        function wc=waitingWildcard(obj)
        % returns wildcard to look for tasks waiting to be executed
            wc=fullfile(obj.allTasksFolder,'*','waiting.mat');
        end
        function wc=executingWildcard(obj)
        % returns wildcard to look for tasks being executed
            wc=fullfile(obj.allTasksFolder,'*','executing.mat');
        end
        function wc=doneWildcard(obj)
        % returns wildcard to look for tasks completed
            wc=fullfile(obj.allTasksFolder,'*','done.mat');
        end
        
        % Filenames
        function fn=creationFilename(obj,h)
        % returns creation filename, given the task handle
            fn=fullfile(taskFoldername(obj,h),'created.mat');
        end
        function fn=waitingFilename(obj,h)
        % returns waiting filename, given creation filename
            fn=fullfile(taskFoldername(obj,h),'waiting.mat');
        end
        function fn=waiting2executingFilename(obj,folder,filename)
        % returns executing filename, given waiting filename
            fn=fullfile(folder,'executing.mat');
        end
        function fn=executing2waitingFilename(obj,folder,filename)
        % returns executing filename, given waiting filename
            fn=fullfile(folder,'waiting.mat');
        end
        function fn=waiting2executedFilename(obj,folder,filename)
        % returns executed filename, given waiting filename
            fn=fullfile(folder,'executed.mat');
        end
        function fn=waiting2doneFilename(obj,folder,filename)
        % returns done filename, given waiting filename
            fn=fullfile(folder,'done.mat');
        end
        function fn=doneFilename(obj,h)
        % returns done filename, given creation filename
            fn=fullfile(taskFoldername(obj,h),'done.mat');
        end
        
        function [isLocal,computer,filename]=parseName(obj,name)
        % parses name to find out if it points to a remote file system
            tokens=regexp(name,'^([\w\.]+@[\w\.-]+):(.*)$','tokens');
            isLocal=isempty(tokens);
            if isLocal
                computer='';
                filename=name;
            else
                computer=tokens{1}{1};
                filename=tokens{1}{2};
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% Atomic file system operations %%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function [success,cmd,rc,result]=atomicCreateFolder(obj,name)
        % Atomically create a folder with given name.
        %
        % Names starting with 'username@domain:' are executed on a
        % remote filesystem
            
            [isLocal,computer,filename]=parseName(obj,name);            
            if isLocal
                % local filesysytem
                success=mkdir(name);
                cmd='';
                rc=nan;
                result='';
            else
                % remote filesystem
                cmd=sprintf('ssh %s mkdir "%s"',computer,filename);
                [rc,result]=system(cmd);
                success=(rc==0);
            end
        end
        
        function [success,cmd,rc,result]=atomicRename(obj,oldName,newName)
        % Atomically rename a file
        % 
        % When the old name starts with 'username@domain:', the rename
        % operation is performed remotely. The new file need not start
        % with 'username@domain:'
            
            [isLocal,computer,filename]=parseName(obj,oldName);            
            [isLocal2,computer2,filename2]=parseName(obj,newName);            
            if ~isLocal2 && ~strcmp(computer,computer2)
                error('atomicRename: remote rename but be within same filesystem ("%s"~="%s")',computer,computer2)
            end
            if isLocal
                % local filesysytem
                cmd=sprintf('mv "%s" "%s"',oldName,newName);
                [rc,result]=system(cmd);
                success=(rc==0);
            else
                cmd=sprintf('ssh %s mv "%s" "%s"',computer,filename,filename2);
                [rc,result]=system(cmd);
                success=(rc==0);                
            end
        end
        
        function [success,cmd,rc,result]=nonatomicCopyToRemote(obj,local,remote);
        % Copy file from local to remote file systems. No guarantee is
        % made that this will be an atomic operation, so locking must
        % be providing by other means.
            [isLocal,computer,filename]=parseName(obj,remote);            
            if isLocal
                error('nonatomicCopyToRemote: cannot parse remote name "%s"',remote);
            end
            cmd=sprintf('scp "%s" "%s:%s"',local,computer,filename);
            if 0
                [rc,result]=system(cmd);
            else
                rc=system(cmd);
                result='';
            end
            success=(rc==0);                
            if ~success
                %disp(result)
                error('nonatomicCopyToRemote: copy "%s" failed\n',cmd);
            end
        end
        
        function [success,cmd,rc,result]=nonatomicCopyFromRemote(obj,remote,local);
        % Copy file from remote to local file systems. No guarantee is
        % made that this will be an atomic operation, so locking must
        % be providing by other means.
            [isLocal,computer,filename]=parseName(obj,remote);            
            if isLocal
                error('nonatomicCopyFromRemote: cannot parse remote name "%s"',remote);
            end
            cmd=sprintf('scp "%s:%s" "%s"',computer,filename,local);
            %[rc,result]=system(cmd);
            rc=system(cmd);
            success=(rc==0);                
            if ~success
                %disp(result)
                error('nonatomicCopyFromRemote: copy "%s" failed\n',cmd);
            end
        end
        
        function [files,cmd,rc,result]=dirLimited(obj,name)
        % Get remove directory of a given folder. Only implemented for
        % simple filename and does not support wildcards
            
            [isLocal,computer,filename]=parseName(obj,name);            
            if isLocal
                files=dir(name);
                cmd='';
                rc=nan;
                result='';
                return
            end
            cmd=sprintf('ssh %s ls -l "%s"',computer,filename);
            [rc,result]=system(cmd);
            success=(rc==0);                
            % when using wildcards, an error is generated if the file does not exist
            if false %~success
                disp(result)
                error('dirLimited: ls -l failed\n');
            end
            lines=split(result,char(10));
            tokens=regexp(lines,'^([d-])([rwx-]+) (.*) ([^ ]*)$','tokens');
            k=find(~cellfun('isempty',tokens));
            files=struct('name',{},'folder',{},'date',{},'bytes',{},'isdir',{},'datenum',{});
            for i=1:length(k)
                if tokens{k(i)}{1}{4}(1)=='/'
                    % name includes path
                    [files(i).folder,nm,ext]=fileparts(tokens{k(i)}{1}{4});
                    files(i).name=[nm,ext];
                else
                    files(i).name=tokens{k(i)}{1}{4};
                    files(i).folder=name;
                end
                files(i).isdir=(tokens{k(i)}{1}{1}=='d');   
            end
            if obj.verboseLevel>2
                fprintf('dirLimited: "%s" folder has %d files\n',name,length(files));
            end            
        end
        
        %%%%%%%%%%%%%%%%%%%%%
        %% Task scheduling %%
        %%%%%%%%%%%%%%%%%%%%%
        
        function success=addTaskGivenHandle(obj,fun,in,h)

            taskFolder=taskFoldername(obj,h);
            %% try to create a new task
            [success,cmd,rc]=atomicCreateFolder(obj,taskFolder);
            if ~success
                if obj.verboseLevel>1
                    fprintf('addTaskGivenHandle: unable to create task h=%d in "%s"\n',h,taskFolder);
                end            
                return
            end

            % success!
            if obj.verboseLevel>1
                fprintf('addTaskGivenHandle: created task h=%d in "%s"\n',h,taskFolder);
            end
            cn=creationFilename(obj,h);
            % create with a temporary same 
            [isLocal,computer,filename]=parseName(obj,cn);            
            if obj.verboseLevel>2
                t0=clock();
                fprintf('addTaskGivenHandle: saving parameters... ');                
            end
            task.fun=fun;
            task.in=in;
            task.h=h;
            if isLocal
                save(cn,'task');
                if obj.verboseLevel>2
                    fprintf('saved locally (%.3f sec)... ',etime(clock,t0));                
                end
            else
                localname=[tempname('.'),'.mat'];
                save(localname,'task');
                if obj.verboseLevel>2
                    fprintf('saved locally (%.3f sec)... ',etime(clock,t0));                
                end
                nonatomicCopyToRemote(obj,localname,cn);
                if obj.verboseLevel>2
                    fprintf('copied to remote (%.3f sec)... ',etime(clock,t0));                
                end
            end
            % use atomicity of 'mv' to make sure the whole file appears "atomically"
            wn=waitingFilename(obj,h);
            [success,cmd,rc,result]=atomicRename(obj,cn,wn);
            if obj.verboseLevel>2
                fprintf('done (%.3f sec)\n',etime(clock,t0));                
            end
            if ~success
                disp(result)
                error('addTaskGivenHandle: command "%s" failed with rc=%d, this should not happen!\n',cmd,rc);
            end
            if obj.verboseLevel>0
                if length(taskFolder)<=30
                    fprintf('addTaskGivenHandle: successfully created task h=%d in "%s"\n',h,taskFolder);
                else
                    fprintf('addTaskGivenHandle: successfully created task h=%d in\n\t"%s"\n',h,taskFolder);
                end
            end            
        end
        
        function h=addTask(obj,fun,in)
        % addTask(obj,fun,in)
        %
        % Adds a function to the executed to the set of task. The
        % function will be called as
        %
        %       out=fun(in,h)
        %
        % with a single input parameter and a single output
        % parameter. Multiple inputs and outputs are supported by
        % setting |in| and |out| to be structures with multiple fields
        % (one per parameter).
        %
        % Returns a unique handle |h| that identifies the task. This
        % handle is also passed to the function as a second input
        % parameters.
            
        %% Exclusivity based on atomicity of 'mkdir' & 'mv'
            
            c=0;
            wc=taskFolderWildCard(obj);
            f=dirLimited(obj,wc);
            h=1;
            for i=1:length(f)
                hi=taskFolder2handle(obj,f(i).folder,f(i).name);
                h=max(h,1+hi);
            end
            while c<100
                success=addTaskGivenHandle(obj,fun,in,h);
                if success
                    return
                end
                % some other process already took this handle, try again
                fprintf('addTask: failed for h=%d (attempt %d), trying again\n',h,c);
                
                %fprintf('paused');pause
                
                % try again with next h
                h=h+1;
                pause(.5*rand);
                c=c+1; 
           end
           error('addTask failed too many times (%d)\n',c);
        end
        
        function waitForTasks(obj,timeout)
        % waitForTasks(obj)
        %
        % Waits until all the tasks have been completed
            if nargin<2
                timeout=inf;
            end
            
            t0=clock();
            waitingWC=waitingWildcard(obj);
            executingWC=executingWildcard(obj);
            [isLocal,computer,filename]=parseName(obj,waitingWC);
            if isLocal
                thisDir=@dir;
            else
                thisDir=@(pth)dirLimited(obj,pth);
            end
            
            t1=clock();
            while etime(clock,t1)<timeout
                wf=thisDir(waitingWC);
                ef=thisDir(executingWC);
                if isempty(wf) && isempty(ef)
                    fprintf('waitForTasks: done (%.2f sec)\n',etime(clock,t0));
                    return
                end
                if obj.verboseLevel>0
                    fprintf('waitForTasks: %d task waiting, %d tasks executing (%.2f sec)\n',...
                            length(wf),length(ef),etime(clock,t0));
                end
                pause(obj.waitTimeSec);
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%
        %% Task executing %%
        %%%%%%%%%%%%%%%%%%%%
        
        function h=executeTasksOneWorker(obj)
        % h=executeTask(obj)
        % 
        % Executes tasks for execution until no more tasks remain
        % pendings. Returns an array with the handles of all the tasks
        % executed.

        %% Exclusivity based on atomicity of 'mv'

        % find task to execute and "reserve" it
            h=[];
            wc=waitingWildcard(obj);
            f=dir(wc);
            while 1
                if isempty(f)
                    return
                end
                wn=fullfile(f(1).folder,f(1).name);
                en=waiting2executingFilename(obj,f(1).folder,f(1).name);
                [success,cmd,rc]=atomicRename(obj,wn,en);
                if ~success
                    % error, someone else grabed this one for execution, try next one
                    f(1)=[];
                    if isempty(f)
                        f=dir(wc);
                    end
                    continue;
                end
                fprintf('executeTasks: starting task "%s"\n',en);
                try
                    t0=clock();
                    ld=load(en);
                    task=ld.task;
                    task.timing.preLoad=t0;
                    h(end+1,1)=task.h;
                    task.timing.postLoad=clock();
                    task.out=feval(task.fun,task.in);
                    %task=rmfield(task,'in'); % could save space
                    task.timing.postCompute=clock();
                catch me
                    task.timing.postCompute=clock();
                    task.err=me;
                    disp(me);
                end
                d1n=waiting2executedFilename(obj,f(1).folder,f(1).name);
                task.timing.elapsedLoad=etime(task.timing.postLoad,task.timing.preLoad);
                task.timing.elapsedCompute=etime(task.timing.postCompute,task.timing.postLoad);
                % create with a temporary same 
                save(d1n,'task');
                d2n=waiting2doneFilename(obj,f(1).folder,f(1).name);
                [success,cmd,rc]=atomicRename(obj,d1n,d2n);
                % past this, task timings will not be saved
                task.timing.postSave=clock();
                task.timing.elapsedTotal=etime(task.timing.postSave,task.timing.preLoad);
                task.timing.elapsedSave=etime(task.timing.postSave,task.timing.postCompute);
                % use atomicity of 'mv' to make sure the whole file appears "atomically"
                if ~success
                    error('addTask command "%s" failed with rc=%d, this should not happen!\n',cmd,rc);
                end
                % delete "executing file"
                delete(en);
                if task.timing.elapsedTotal>.01
                    fprintf('executeTasks: finished task %d (%.3f sec)\n',task.h,task.timing.elapsedTotal);
                else
                    fprintf('executeTasks: finished task %d (%.3f msec)\n',task.h,1e3*task.timing.elapsedTotal);
                end
                f=dir(wc);
            end
        end
        
        function h=executeTasksParallel(obj,blocking,numWorkers)
        % executeTasksParallel(obj,blocking)
        % 
        % Lauches several workers to execute pending tasks, with no
        % more than the given number of workers
            
            if blocking && numWorkers==1
                h{1}=executeTasksOneWorker(obj);
                return;
            end
            
            % check if a pool exists
            pool=gcp('nocreate');
            if isempty(pool)
                % if not, create one with as many workers as possible, up to numWorkers
                pc=parcluster('local');
                pc.NumWorkers=numWorkers;
                joblocation=tempname(obj.allTasksFolder);
                joblocation=regexprep(joblocation,'^~/',[getenv('HOME'),'/']);
                [fo,fi]=fileparts(joblocation);
                joblocation=fullfile(fo,['tmp_',fi]);
                [success,cmd,rc,result]=atomicCreateFolder(obj,joblocation);                
                pc.JobStorageLocation=joblocation;
                pool=parpool(pc,numWorkers);
                disp(pool)
            end
            h=cell(numWorkers,1);
            if blocking
                % parallel execution with parfor, only returns when all workers are done
                parfor i=1:numWorkers
                    h{i,1}=executeTasksOneWorker(obj);
                    % avoid race conditions, e.g., in selecting pedigree names
                    pause(1.5+2*rand(1)); 
                end 
                if exist(joblocation,'dir')
                    rmdir(joblocation);
                end
            else
                % parallel execution with parfeval, nonblocking
                for i=1:numWorkers
                    h{i,1}=parfeval(pool,@executeTasksOneWorker,1,obj);
                    % avoid race conditions, e.g., in selecting pedigree names
                    pause(1.5+2*rand(1)); 
                end
                fprintf('executeTasksParallel: temporary folder "%s" will eventually need to be removed\n',joblocation);
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%
        %% Task executing %%
        %%%%%%%%%%%%%%%%%%%%
                
        function [out,timing,task]=getTaskOutput(obj,h)
        % task=getTaskOutput(obj,h)
        %
        % get the output of a task, given its handle
            fn=doneFilename(obj,h);
            [isLocal,computer,filename]=parseName(obj,fn);
            t0=clock();
            try
                if isLocal
                    ld=load(fn);
                else
                    localname=[tempname('.'),'.mat'];
                    nonatomicCopyFromRemote(obj,fn,localname);
                    ld=load(localname);
                    delete(localname);
                end
            catch me
                fprintf('getOutput: file "%s" not found\n',fn);
                ld.task.err=me;
                ld.task.timing=struct();
            end
            task=ld.task;
            timing=task.timing;
            timing.preRetrieve=t0;
            timing.postRetrieve=clock();
            timing.elapsedRetrieve=etime(timing.postRetrieve,timing.preRetrieve);
            if ~isfield(task,'out')
                task.out=struct();
            end
            out=task.out;
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% Task executing in cluster %%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
        function createQsubScript(obj,numWorkers,executePath,email)
            
            qsubName=fullfile(obj.allTasksFolder,'qsubTaskExecution.sh');
            [isLocal,computer,filename]=parseName(obj,obj.allTasksFolder);
            if isLocal
                fh=fopen(qsubName,'w');
            else
                localname=tempname('.');
                fh=fopen(localname,'w');
            end
            fprintf(fh,'### Job name\n');
            fprintf(fh,'#PBS -N pbsjob_qsubTaskExecution\n');
            fprintf(fh,'### Output and error paths\n');
            if isLocal
                pth=regexprep(filename,'^~/',getenv('HOME'));
                % qsub interpretes "relative" paths from working
                % directory, so we add executePath
                if pth(1)~='/'
                    pth=fullfile(executePath,pth);
                end
                fprintf(fh,'#PBS -o %s\n',pth);
                fprintf(fh,'#PBS -e %s\n',pth);
            else
                % qsub interpretes "relative" paths from home
                % directory, and does not understand ~/
                if filename(1)=='~'
                    cmd=sprintf('ssh %s echo $HOME',computer);
                    [rc,result]=system(cmd);
                    if rc
                        disp(rc)
                        disp(result)
                        error('createQsubScript: taskFolders "%s" contains ~, but unable to get $HOME using "%s"',obj.allTasksFolder,cmd);
                    end
                    result(end)='/'; % replace final newline by '/'
                    pth=regexprep(filename,'^~/',result);
                end
                fprintf(fh,'#PBS -o %s\n',pth);
                fprintf(fh,'#PBS -e %s\n',pth);
            end
            fprintf(fh,'### Termination warning\n');
            fprintf(fh,'#PBS -m e\n');
            fprintf(fh,'#PBS -M %s\n',email);
            fprintf(fh,'### Resources\n');
            fprintf(fh,'#PBS -l select=1:ncpus=%d -lplace=excl\n',2*numWorkers);
            fprintf(fh,'module list\n');
            fprintf(fh,'qstat -u $USER\n');
            fprintf(fh,'matlab -nosplash -noFigureWindows -r "cd(''%s'');obj=partoolsfeval(''%s'');executeTasksParallel(obj,true,%d); quit"\n',executePath,filename,numWorkers);
            fprintf(fh,'qstat -u $USER\n');
            fclose(fh);
            if ~isLocal
                [success,cmd,rc,result]=nonatomicCopyToRemote(obj,localname,qsubName);
                delete(localname);
                if ~success
                    disp(cmd);
                    disp(result);
                    error('createQsubScript: unable to create "%s"\n',obj.allTasksFolder);
                end
            end

        end
        
        function [success,cmd,rc,result]=callQsubScript(obj)
            qsubName=fullfile(obj.allTasksFolder,'qsubTaskExecution.sh');
            [isLocal,computer,filename]=parseName(obj,qsubName);
            cmd=sprintf('qsub %s',filename);
            lcmd=cmd;
            if ~isLocal
                cmd=sprintf('ssh %s ''bash -c "%s"''',computer,regexprep(lcmd,'^~/',''));
                if obj.verboseLevel>1
                    fprintf('callQsubScript: remote execution at "%s"\n',computer);
                end
            end
            [rc,result]=system(cmd);
            success=(rc==0);
            if ~success
                disp(cmd);
                disp(result);
                error('callQsubScript: error in executing "%s"\n',cmd);
            end            
            fprintf('callQsubScript: success in running "%s"\n',lcmd);
            fprintf('                qsub returned "%s"\n',regexprep(result,'\n$',''));
        end
        
        function allExecuting2waiting(obj)
        % turns all files 'executing' into 'waiting' to be
        % executed. This is needed if the workers died.
            
            t0=clock();
            executingWC=executingWildcard(obj);
            [isLocal,computer,filename]=parseName(obj,executingWC);
            if isLocal
                thisDir=@dir;
            else
                thisDir=@(pth)dirLimited(obj,pth);
            end
            
            we=thisDir(executingWC);
            fprintf('executing2waiting: %d files need to be renamed\n',length(we));
            for i=1:length(we)
                if ~isLocal
                    we(i).folder=[computer,':',we(i).folder];
                end
                oldName=fullfile(we(i).folder,we(i).name);
                newName=executing2waitingFilename(obj,we(i).folder,we(i).name);
                [success,cmd,rc,result]=atomicRename(obj,oldName,newName);
                if success
                    fprintf('executing2waiting: %4d/%4d successfully moved "%s"\n',...
                            i,length(we),oldName);
                    fprintf('                                             to "%s"\n',newName);
                else
                    disp(result)
                    error('executing2waiting: command "%s" failed with rc=%d (task may havecompleted)\n',cmd,rc);
                end
            end
        end
   
        function done2waiting(obj,h)
        % turns one task from 'done' into 'waiting' to be
        % executed. This is needed if the output needs to be reocmputed
            
            t0=clock();
            for i=1:length(h)
                fw=waitingFilename(obj,h(i));
                [fl,fn]=fileparts(fw);
                fd=waiting2doneFilename(obj,fl,fn);
                
                [success,cmd,rc,result]=atomicRename(obj,fd,fw);
                if success
                    fprintf('done2waiting: %4d/%4d successfully moved "%s"\n',...
                            i,length(h),fd);
                    fprintf('                                        to "%s"\n',fw);
                else
                    disp(result)
                    fprintf('done2waiting: command "%s" failed with rc=%d\n',cmd,rc);
                end
            end
        end
   
        function h=getTasksDone(obj)
        % h=getTasksDone(obj)
        %
        % for handles of all tasks done
            t0=clock();
            doneWC=doneWildcard(obj);
            [isLocal,computer,filename]=parseName(obj,doneWC);
            if isLocal
                thisDir=@dir;
            else
                thisDir=@(pth)dirLimited(obj,pth);
            end
            
            files=thisDir(doneWC);
            h=nan(length(files),1);
            for i=1:length(files)
                h(i)=taskDone2handle(obj,files(i).folder,files(i).name);
            end
            h=sort(h);
        end
        
    end
    
end