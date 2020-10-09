!cleantmp

folder='hespanha@ssh-iam.intel-research.net:systemid/matlab/tmp_tasks'; 
create=true';
verboseLevel=2;
tasks=partoolsfeval(folder,create,verboseLevel)

%profile on
%% Create tasks
hi=[];
for i=1:10
    hi(end+1,1)=addTask(tasks,@(x,h)sin(x),rand(100,100));
end

%profile viewer

%% Execute tasks
remoteTaskExecution(tasks,5);


waitForTasks(tasks);
    
[out,timing,task]=getTaskOutput(tasks,1);

return

t0=clock();
p=gcp;
if 1
    for i=1:p.NumWorkers
        ho{i,1}=parfeval(p,@executeTasks,1,tasks);
    end
else
    parfor i=1:p.NumWorkers
        ho{i,1}=executeTasks(tasks);
    end 
end
waitForTasks(tasks);
fprintf('finished all executions in %.2f sec\n',etime(clock,t0));


%dir(fullfile(folder,'*','*'))

[out,timing,task]=getTaskOutput(tasks,hi(1));
disp(task)

%profile viewer;

