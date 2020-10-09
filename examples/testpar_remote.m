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



