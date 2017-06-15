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

callAndStore();

tic,z=callAndStore(@plus,1,2),toc
tic,z=callAndStore(@plus,2,3),toc
tic,z=callAndStore(@plus,1,2),toc
tic,z=plus(1,2),toc


tic,[m,k]=callAndStore(@max,[1,2,4]),toc
tic,[m,k]=callAndStore(@max,[2,4,3]),toc
tic,[m,k]=callAndStore(@max,[1,2,4]),toc
tic,[m,k]=max([1,2,4]),toc
