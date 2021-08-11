% This file is part of Tencalc.
%
% Copyright (C) 2012-21 The Regents of the University of California
% (author: Dr. Joao Hespanha).  All rights reserved.

callAndStore();

tic,z=callAndStore(@plus,1,2),toc
tic,z=callAndStore(@plus,2,3),toc
tic,z=callAndStore(@plus,1,2),toc
tic,z=plus(1,2),toc


tic,[m,k]=callAndStore(@max,[1,2,4]),toc
tic,[m,k]=callAndStore(@max,[2,4,3]),toc
tic,[m,k]=callAndStore(@max,[1,2,4]),toc
tic,[m,k]=max([1,2,4]),toc
