!cleantmp

folder='tmp_tasks'; 
create=true';
tasks=partoolsfeval(folder,create)

profile on;
%% Create tasks
hi=[];
for i=1:30
    hi(end+1,1)=addTask(tasks,@(x,h)sin(x),rand(1000,1000));
end

%% Execute tasks
t0=clock();
if 0
    % no parallel execution
    ho=executeTasksOneWorker(tasks);
elseif 0
    % parallel execution blocking
    ho=executeTasksParallel(tasks,true,3);
elseif 1
    % parallel execution with parfeval, nonblocking
    ho=executeTasksParallel(tasks,false,3);
    waitForTasks(tasks);
end
fprintf('finished all executions in %.2f sec\n',etime(clock,t0));


%dir(fullfile(folder,'*','*'))

[out,timing,task]=getTaskOutput(tasks,hi(1));
disp(task)
disp(timing)

profile viewer;


