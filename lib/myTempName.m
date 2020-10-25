function filename=myTempName();
% returns a temporary filename in the current folder, startingwith 'tmp_' and with extension '.tmp'

    filename=tempname('.');
    [~,filename,extension]=fileparts(filename);
    filename=['tmp_',filename,'.tmp'];

end