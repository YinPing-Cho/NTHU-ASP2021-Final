function Params = PARAMS_RLS_DFE(Params)
    % For Static case
    Params.Static.RLS_DFE.Lfff = 20;
    Params.Static.RLS_DFE.Lfbf = 20;
    Params.Static.RLS_DFE.lambda = 0.999; 
    Params.Static.RLS_DFE.delta = 1;
    
    % For Q_Static case
    Params.Q_Static.RLS_DFE.Lfff = 15;
    Params.Q_Static.RLS_DFE.Lfbf = 10;
    Params.Q_Static.RLS_DFE.lambda = 0.993; 
    Params.Q_Static.RLS_DFE.delta = 1;
    
    % For T_Varying case
    Params.T_Varying.RLS_DFE.Lfff = 15;
    Params.T_Varying.RLS_DFE.Lfbf = 10;
    Params.T_Varying.RLS_DFE.lambda = 0.993; 
    Params.T_Varying.RLS_DFE.delta = 1;
end