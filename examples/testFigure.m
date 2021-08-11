x% This file is part of Tencalc.
%
% Copyright (C) 2012-21 The Regents of the University of California
% (author: Dr. Joao Hespanha).  All rights reserved.

close all;

subplots=[5,8];
%renderer='opengl';
renderer='painters';

% just create/erase figures folder
folder=sprintf('testFigures-%s',renderer);
saveFigure('folder',folder,...
           'createFolder',true,'eraseFigures','force','saveFormat','none');



psz=[1,2,4]
for j=1:length(psz)
    if 0
        papersize=1;
        fontscaling=1/psz(j);
    else
        papersize=psz(j);
        fontscaling=1;
    end

    clearFigure('figureNumber',j,'figureName',...
                sprintf('Name: paper size %g, font scaling %g, renderer %s',...
                        papersize,fontscaling,renderer),...
                'orientation','landscape',...
                'paperSize',papersize,...
                'subplots',subplots);

    drawnow
    s = RandStream('mt19937ar','Seed',0);
    RandStream.setGlobalStream(s);
    for i=1:prod(subplots)
        subplot(subplots(1),subplots(2),i);
        N=300000;
        x=10*(randn(N,1)-.5);
        y=10*(randn(N,1)-.5);
        plot(x,y,'.');
        axis square
        h=title(sprintf('%d %d very very very very long title',j,i));
    end
    drawnow

    if 1
        saveFigure('folder',folder,...
                   'fontScaling',fontscaling,...
                   'renderer',renderer,...
                   'figureNumber',j,'saveFormat','tiff');
    end
    saveFigure('folder',folder,...
               'fontScaling',fontscaling,...
               'renderer',renderer,...
               'figureNumber',j,'saveFormat','eps');
end
