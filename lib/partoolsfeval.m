classdef partoolsfeval < handle;
% Class to support the execution of many function evaluations in in parallel

    properties;
        % folder where the files associated with all the functions to be evaluated will be stored
        allTasksFolder 
        
        % time to sleep, while waiting
        waitTimeSec=1;
    end
    
    methods;
        
        %%%%%%%%%%%%%%%%%%%%%
        %% Object creation %%
        %%%%%%%%%%%%%%%%%%%%%
        
        function obj=partoolsfeval(folder,create)
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
            
            if nargin<2
                create=false;
            end
            
            if exist(folder,'dir')
                obj.allTasksFolder=folder;
            elseif create
                [suc,msg]=mkdir(folder);
                if suc 
                    obj.allTasksFolder=folder;
                else
                    disp(msg);
                    error('partoolsfeval: unable to create folder ''%s''\n',folder);                    
                end
            else
                error('partoolsfeval: folder ''%s'' does not exist\n',folder);
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% filenames used for saving data (and locking!) %%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function fn=taskFoldername(obj,h)
        % returns folder filename, given the task handle
            fn=fullfile(obj.allTasksFolder,sprintf('%d',h));
        end
        function h=taskFolder2handle(obj,folder,name)
        % returns task handle, given task folder filename
            h=str2double(name);
        end
        function wc=taskFolderWildCard(obj)
        % returns wildcard to look for existing task folders
            wc=obj.allTasksFolder;
        end
        function wc=waitingWildcard(obj)
        % returns wildcard to look for tasks waiting to be executed
            wc=fullfile(obj.allTasksFolder,'*','waiting.mat');
        end
        function wc=executingWildcard(obj)
        % returns wildcard to look for tasks waiting to be executed
            wc=fullfile(obj.allTasksFolder,'*','executing.mat');
        end
        function fn=creationFilename(obj,h)
        % returns creation filename, given the task handle
            fn=fullfile(taskFoldername(obj,h),'created.mat');
        end
        function fn=waitingFilename(obj,h)
        % returns waiting filename, given creation filename
            fn=fullfile(taskFoldername(obj,h),'waiting.mat');
        end
        function fn=waiting2executing(obj,folder,filename)
        % returns executing filename, given waiting filename
            fn=fullfile(folder,'executing.mat');
        end
        function fn=waiting2executed(obj,folder,filename)
        % returns executed filename, given waiting filename
            fn=fullfile(folder,'executed.mat');
        end
        function fn=waiting2done(obj,folder,filename)
        % returns done filename, given waiting filename
            fn=fullfile(folder,'done.mat');
        end
        function fn=doneFilename(obj,h)
        % returns waiting filename, given creation filename
            fn=fullfile(taskFoldername(obj,h),'done.mat');
        end
        
        %%%%%%%%%%%%%%%%%%%%%
        %% Task scheduling %%
        %%%%%%%%%%%%%%%%%%%%%
        
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
            
            task.fun=fun;
            task.in=in;
            c=0;
            while 1
                wc=taskFolderWildCard(obj);
                f=dir(wc);
                h=1;
                for i=1:length(f)
                    hi=taskFolder2handle(obj,f(i).folder,f(i).name);
                    h=max(h,1+hi);
                end
                tf=taskFoldername(obj,h);
                %% try to create a new task
                suc=mkdir(tf);
                if suc
                    % success!
                    fprintf('addTask: created task %d "%s"\n',h,tf)
                    task.h=h;
                    cn=creationFilename(obj,h);
                    % create with a temporary same 
                    save(cn,'task');
                    % use atomicity of 'mv' to make sure the whole file appears "atomically"
                    wn=waitingFilename(obj,h);
                    cmd=sprintf('mv %s %s',cn,wn);
                    rc=system(cmd);
                    if rc
                        disp(cmd);
                        error('addTask failed to mv "%s" to "%s" with rc=%d, this should not happen!\n',cn,wn,rc);
                    end
                    return
                end
                c=c+1;
                if c>1000
                    break
                end
                % some other process already took this handle, try again
                fprintf('addTask failed attempt %d, trying again\n',c);
                pause(rand(.5));
            end
            error('addTask failed too many times (%d)\n',c);
        end
        
        function waitForTasks(obj)
        % waitForTasks(obj)
        %
        % Waits until all the tasks have been completed
            t0=clock();
            while 1
                wc=waitingWildcard(obj);
                wf=dir(wc);
                wc=executingWildcard(obj);
                ef=dir(wc);
                if isempty(wf) && isempty(ef)
                    fprintf('waitForTasks: done (%.2f sec)\n',etime(clock,t0));
                    return
                end
                fprintf('waitForTasks: %d task waiting, %d tasks executing (%.2f sec)\n',...
                        length(wf),length(ef),etime(clock,t0));
                pause(obj.waitTimeSec);
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%
        %% Task executing %%
        %%%%%%%%%%%%%%%%%%%%
        
        function h=executeTasks(obj)
        % h=executeTask(obj)
        % 
        % Executes tasks in the set of tasks to be executed until no
        % more tasks remain pendings. Returns an array with the
        % handles of all the tasks executed.

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
                en=waiting2executing(obj,f(1).folder,f(1).name);
                cmd=sprintf('mv %s %s 2>/dev/null',wn,en);
                rc=system(cmd);
                if rc
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
                    h(end+1,1)=task.h;
                    task.timing.preLoad=clock();
                    task.timing.postLoad=clock();
                    task.out=feval(task.fun,task.in,task.h);
                    %task=rmfield(task,'in'); % could save space
                    task.timing.finished=clock();
                catch me
                    task.err=me;
                    disp(me);
                end
                d1n=waiting2executed(obj,f(1).folder,f(1).name);
                % create with a temporary same 
                save(d1n,'task')
                % use atomicity of 'mv' to make sure the whole file appears "atomically"
                d2n=waiting2done(obj,f(1).folder,f(1).name);
                cmd=sprintf('mv %s %s',d1n,d2n);
                rc=system(cmd);
                if rc
                    disp(cmd);
                    error('addTask failed to mv "%s" to "%s" with rc=%d, this should not happen!\n',d1n,d2n,rc);
                end
                % delete "executing file"
                delete(en);
                dt=etime(task.timing.finished,task.timing.preLoad);
                if dt>.01
                    fprintf('executeTasks: finished task %d (%.3f sec)\n',task.h,dt);
                else
                    fprintf('executeTasks: finished task %d (%.3f msec)\n',task.h,1e3*dt);
                end
                f=dir(wc);
            end
        end
        
        function [out,timing,task]=getTaskOutput(obj,h)
        % task=getTaskOutput(obj,h)
        %
        % get the output of a task, given its handle
            fn=doneFilename(obj,h);
            ld=load(fn);
            task=ld.task;
            out=task.out;
            timing=task.timing;
        end
    end
    
end