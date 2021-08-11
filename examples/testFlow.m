% This file is part of Tencalc.
%
% Copyright (C) 2012-21 The Regents of the University of California
% (author: Dr. Joao Hespanha).  All rights reserved.

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
