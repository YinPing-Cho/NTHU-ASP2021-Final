function Params = PARAMS_RLS_DFE(Params)
    % For Static case
    Params.Static.RLS_DFE.Lfff = 10;
    Params.Static.RLS_DFE.Lfbf = 10;
    Params.Static.RLS_DFE.lambda = 0.997; 
    Params.Static.RLS_DFE.delta = 1;
    
    % For Q_Static case
    Params.Q_Static.RLS_DFE.Lfff = 10;
    Params.Q_Static.RLS_DFE.Lfbf = 10;
    Params.Q_Static.RLS_DFE.lambda = 0.9992; 
    Params.Q_Static.RLS_DFE.delta = 1;
    
    % For T_Varying case
    Params.T_Varying.RLS_DFE.Lfff = 8;
    Params.T_Varying.RLS_DFE.Lfbf = 7;
    Params.T_Varying.RLS_DFE.lambda = 0.995; 
    Params.T_Varying.RLS_DFE.delta = 1;
end