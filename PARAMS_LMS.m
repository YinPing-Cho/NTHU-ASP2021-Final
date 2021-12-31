function Params = PARAMS_LMS(Params)
    % For Static case
    Params.Static.LMS.L = 20;
    Params.Static.LMS.alpha = 0.01;
    
    % For Q_Static case
    Params.Q_Static.LMS.L = 20;
    Params.Q_Static.LMS.alpha = 0.01;
    
    % For T_Varying case
    Params.T_Varying.LMS.L = 20;
    Params.T_Varying.LMS.alpha = 0.01;
end