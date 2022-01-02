function Params = PARAMS_LMS_DFE(Params)
    % For Static case
    Params.Static.LMS_DFE.Lfff = 20;
    Params.Static.LMS_DFE.Lfbf = 10;
    Params.Static.LMS_DFE.alpha = 0.01; 
    
    % For Q_Static case
    Params.Q_Static.LMS_DFE.Lfff = 15;
    Params.Q_Static.LMS_DFE.Lfbf = 5;
    Params.Q_Static.LMS_DFE.alpha = 0.01; 
    
    % For T_Varying case
    Params.T_Varying.LMS_DFE.Lfff = 10;
    Params.T_Varying.LMS_DFE.Lfbf = 5;
    Params.T_Varying.LMS_DFE.alpha = 0.01; 
end