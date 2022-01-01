function Params = PARAMS_NLMS_DFE(Params)
    % For Static case
    Params.Static.NLMS_DFE.Lfff = 20;
    Params.Static.NLMS_DFE.Lfbf = 20;
    Params.Static.NLMS_DFE.alpha = 0.05; 
    Params.Static.NLMS_DFE.c = 0.001;
    
    % For Q_Static case
    Params.Q_Static.NLMS_DFE.Lfff = 15;
    Params.Q_Static.NLMS_DFE.Lfbf = 10;
    Params.Q_Static.NLMS_DFE.alpha = 0.05; 
    Params.Q_Static.NLMS_DFE.c = 0.001;
    
    % For T_Varying case
    Params.T_Varying.NLMS_DFE.Lfff = 15;
    Params.T_Varying.NLMS_DFE.Lfbf = 10;
    Params.T_Varying.NLMS_DFE.alpha = 0.05; 
    Params.T_Varying.NLMS_DFE.c = 0.001;

end
