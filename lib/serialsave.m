function serialsave(filename,data)
% serialsave(filename,data)
%   Serializw a data structure and save it as a byte stream.
%
%
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

bytes=hlp_serialize(data);

% needs extension?
if isempty(regexp(filename,'\.[^/]*$','match'))
    filename=sprintf('%s.serialmatlab',filename);
end
fid=fopen(filename,'w');
fwrite(fid,bytes);
fclose(fid);

