function varargout = algorithm_RLS_DFE(Pa, known_train, full_noised_signal)

%{         

Possible Output Formats:
[squared_e, pred_data] = algorithm_RLS_DFE()
    -> for test_bench.m
[squared_e, pred_data, pred_train] = algorithm_RLS_DFE()
    -> for checking with project_data2021.mat

                     static   qstatic   varying
Pa.train_length  =     1000       200        50   (Train)
Pa.data_length   =   200000      1000       400   (Data)
Pa.NumRepetition =        1       200       500   (N)

INPUT:
length(known_train)        = Train
length(full_noised_signal) = (Train + Data) * N

OUTPUT:
length(squared_e)          = Train * N
length(pred_data)          =  Data * N
length(pred_train)         = Train * N

%}

unit_length = Pa.train_length + Pa.data_length; 
total_len   = unit_length * Pa.NumRepetition; 
d           = known_train; 
e           = zeros(1, total_len); 
y           = zeros(1, total_len); 
x_full      = [zeros(Pa.RLS_DFE.Lfff-1, 1); full_noised_signal.'];
% RLS-DFE init.
fff         = zeros(Pa.RLS_DFE.Lfff, 1);    % feed forward filter
fbf         = zeros(Pa.RLS_DFE.Lfbf, 1);    % feed back filter
a           = zeros(Pa.RLS_DFE.Lfbf, 1);    % input to fbf
lambda      = Pa.RLS_DFE.lambda;            % forgetting factor
delta       = Pa.RLS_DFE.delta;             % R inverse init.
Rfi         = delta * eye(Pa.RLS_DFE.Lfff); % R inverse (fff)
Rbi         = delta * eye(Pa.RLS_DFE.Lfbf); % R inverse (fbf)
% reserve space for outputs
squared_e   = zeros(1, Pa.NumRepetition * Pa.train_length);
pred_data   = zeros(1, Pa.NumRepetition * Pa.data_length);
pred_train  = zeros(1, Pa.NumRepetition * Pa.train_length);

% adaptive filter
for ind = 1:total_len
    x = x_full(ind : ind + Pa.RLS_DFE.Lfff - 1); 
    y(ind) = x.' * fff - a.' * fbf;
    y_hat = sign(y(ind));
    train_ind = rem(ind, unit_length);
    if and(train_ind <= Pa.train_length, train_ind ~= 0)  % train mode
        e(ind) = d(train_ind) - y(ind);
    else                                        % decision-directed mode
        e(ind) = y_hat - y(ind);
    end
    alpha_f = 1 / (lambda + x.' * Rfi * x);
    fff = fff + alpha_f * e(ind) * Rfi * x;
    Rfi = (1/lambda) * (Rfi - alpha_f * Rfi * x * (x.') * Rfi);
    alpha_b = 1 / (lambda + a.' * Rbi * a);
    fbf = fbf - alpha_b * e(ind) * Rbi * a;
    Rbi = (1/lambda) * (Rbi - alpha_b * Rbi * a * (a.') * Rbi);
    a = [a(2:end); y_hat];
end

% generate output
squared_e_ind = 1; pred_ind = 1;
for ind = 1:total_len
    train_ind = rem(ind, unit_length);
    if and(train_ind <= Pa.train_length, train_ind ~= 0) % train mode
        squared_e(squared_e_ind) = e(ind) ^ 2; 
        pred_train(squared_e_ind) = y(ind);
        squared_e_ind = squared_e_ind + 1;
    else                                        % decision-directed mode
        pred_data(pred_ind) = y(ind);
        pred_ind = pred_ind + 1;
    end
end

if nargout == 2 
    varargout{1} = squared_e;
    varargout{2} = pred_data;
elseif nargout == 3
    varargout{1} = squared_e;
    varargout{2} = pred_data;
    varargout{3} = pred_train;
end
