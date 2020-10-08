!cleantmp

folder='tmp_tasks'; 
create=true';
tasks=partoolsfeval(folder,create)

profile on
hi=[];
for i=1:30
    hi(end+1,1)=addTask(tasks,@(x,h)sin(x),rand(1000,1000));
end
ho=cell(0,1);
t0=clock();
p=gcp;
if 0
    % no parallel execution
    for i=1:p.NumWorkers
        ho{i,1}=executeTasks(tasks);
    end
elseif 0
    % parallel execution with parfor, only returns when all workers are done
    parfor i=1:p.NumWorkers
        ho{i,1}=executeTasks(tasks);
    end 
elseif 1
    % parallel execution with parfeval, nonblocking
    for i=1:p.NumWorkers
        ho{i,1}=parfeval(p,@executeTasks,1,tasks);
    end
end
waitForTasks(tasks);
fprintf('finished all executions in %.2f sec\n',etime(clock,t0));


%dir(fullfile(folder,'*','*'))

[out,timing,task]=getTaskOutput(tasks,hi(1));
disp(task)

profile viewer;


