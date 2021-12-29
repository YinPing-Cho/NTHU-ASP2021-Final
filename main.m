mfile_name          = mfilename('fullpath');
[pathstr,name,ext]  = fileparts(mfile_name);
cd(pathstr);
fileparts(matlab.desktop.editor.getActiveFilename)

load project_data2021.mat