
fprintf('Seeting up path...');
home=[fileparts(which('install_funpartools')),'/lib'];
folders={home;[home,'/serialization']};
      
fprintf('removing old...');
s = warning('OFF', 'MATLAB:rmpath:DirNotFound');
rmpath(folders{:});
warning(s);

fprintf('adding new...');
addpath(folders{:});

fprintf('saving path...');
try
    savepath;
catch me
    fprintf('ATTENTION: unable to save path, add following strings to the matlab path:');
    disp(folders)
    rethrow
end

fprintf('done!\n');