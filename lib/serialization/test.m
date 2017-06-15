N=50;

x=32+32*rand(N,500);
x=char(x);
x=cellstr(x);
x(end-5:end)=repmat({''},6,1);

y=rand(N,3);

z=categorical(round(10*rand(N,1)));

t=table();
t.x=x;
t.y=y;
t.z=z;

size(t)

tic
serialsave('ttt',t);
toc

ls -l


tic
tt=serialload('ttt');
toc