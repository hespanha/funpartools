function list=struct2list(stru)
% list=struct2list(stru)
% 
% Converts the structure |stru| to a cell array of the form
%   {'fieldname1', value1, 'fieldname2', value2, ... }
    fs=fields(stru);
    list=cell(1,2*length(fs));
    for i=1:length(fs)
        list{2*i-1}=fs{i};
        list{2*i}=stru.(fs{i});
    end
end
