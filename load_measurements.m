function DataMeasurements = load_measurements()
    mfile_name          = mfilename('fullpath');
    [pathstr,name,ext]  = fileparts(mfile_name);
    cd(pathstr);
    fileparts(matlab.desktop.editor.getActiveFilename);

    DataMeasurements = load ('Measurements.mat','DataMeasurements');
end

