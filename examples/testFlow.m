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

clear all
!rm -f *+TS=*.*

m=1000;
n=500;

disp('1) Running without saving results')
A=createMatrix('sz',[m,n],'rang',[-10,10]);
B=createMatrix('sz',[m,n],'rang',[-1,1]);
C=sumMatrices('inputMatrix1',A,'inputMatrix2',B);

disp('2) Running saving results')
    A=createMatrix('pedigreeClass','01createA','executeScript','asneeded',...
                   'sz',[m,n],'rang',[-10,10]);
    B=createMatrix('pedigreeClass','02createB','executeScript','asneeded',...
                   'sz',[m,n],'rang',[-1,1]);
    C=sumMatrices('pedigreeClass','03sumAB','executeScript','asneeded',...
                  'inputMatrix1',A,'inputMatrix2',B);

disp('3) Running re-using results')

A=createMatrix('pedigreeClass','01createA','executeScript','asneeded',...
               'sz',[m,n],'rang',[-10,10]);
B=createMatrix('pedigreeClass','02createB','executeScript','asneeded',...
               'sz',[m,n],'rang',[-1,1]);
C=sumMatrices('pedigreeClass','03sumAB','executeScript','asneeded',...
              'inputMatrix1',A,'inputMatrix2',B);

disp('4) Erasing results')
delete *+TS=*.*
