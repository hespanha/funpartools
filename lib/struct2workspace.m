function struct2workspace(stru)
% struct2list(stru)
% 
% For each field of the structure creates a variable in the caller's
% workspace, with the name of the field and value of the structure's
% correspnding field
    fs=fields(stru);
    for i=1:length(fs)
        assignin('caller',fs{i},stru.(fs{i}));
    end
end
