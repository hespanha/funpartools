% Copyright 2012-2017 Joao Hespanha

% This file is part of Tencalc.
%
% TensCalc is free software: you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by the
% Free Software Foundation, either version 3 of the License, or (at your
% option) any later version.
%
% TensCalc is distributed in the hope that it will be useful, but
% WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
% General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with TensCalc.  If not, see <http://www.gnu.org/licenses/>.

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

