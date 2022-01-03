function Params = PARAMS_NLMS_DFE(Params)
    % For Static case
    Params.Static.NLMS_DFE.Lfff = 20;
    Params.Static.NLMS_DFE.Lfbf = 20;
    Params.Static.NLMS_DFE.alpha = 0.1; 
    Params.Static.NLMS_DFE.epsilon = 1e-2;
    
    % For Q_Static case
    Params.Q_Static.NLMS_DFE.Lfff = 15;
    Params.Q_Static.NLMS_DFE.Lfbf = 10;
    Params.Q_Static.NLMS_DFE.alpha = 0.02;
    Params.Q_Static.NLMS_DFE.epsilon = 2e-2;
    
    % For T_Varying case
    Params.T_Varying.NLMS_DFE.Lfff = 15;
    Params.T_Varying.NLMS_DFE.Lfbf = 10;
    Params.T_Varying.NLMS_DFE.alpha = 0.01;
    Params.T_Varying.NLMS_DFE.epsilon = 1e-2;
end
