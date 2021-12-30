clear; close all; 

load project_data2021.mat;

%{
    test_bench_project_data2021.m

    this program tests the algorithms using the data from eeclass

    OUTPUT:

    (1) learning curve plot
    (2) prior BER vs post BER

    NOTE:
       
    Your function algorithm_*.m must have these outputs
    squared_e:  size (1, train_length * NumRepetition)
    pred_train: size (1, train_length * NumRepetition)
%}

%% test case setting
Algo     = 'RLS_DFE'; % RLS_DFE % LMS_DFE % NLMS_DFE
TestCase = 'Varying';  % Static  % QStatic % Varying
SNR      = "Low";     % High    % Low

%% parameters setting
Pa.Static.NumRepetition = 1;
Pa.Static.train_length = 1000;
Pa.Static.data_length = 200000;
% BELOW: RLS_DFE parameters
Pa.Static.RLS_DFE.Lfff = 15;
Pa.Static.RLS_DFE.Lfbf = 10;
Pa.Static.RLS_DFE.lambda = 0.993; 
Pa.Static.RLS_DFE.delta = 1;
% ABOVE: RLS_DFE parameters
%{
    set Pa.Static.LMS_DFE here
    set Pa.Static.NLMS_DFE here
%}

Pa.Q_Static.NumRepetition = 200;
Pa.Q_Static.train_length = 200;
Pa.Q_Static.data_length = 1000;
% BELOW: RLS_DFE parameters
Pa.Q_Static.RLS_DFE.Lfff = 15;
Pa.Q_Static.RLS_DFE.Lfbf = 10;
Pa.Q_Static.RLS_DFE.lambda = 0.993; 
Pa.Q_Static.RLS_DFE.delta = 1;
% ABOVE: RLS_DFE parameters
%{
    set Pa.Q_Static.LMS_DFE here
    set Pa.Q_Static.NLMS_DFE here
%}

Pa.T_Varying.NumRepetition = 500;
Pa.T_Varying.train_length = 50;
Pa.T_Varying.data_length = 400;
% BELOW: RLS_DFE parameters
Pa.T_Varying.RLS_DFE.Lfff = 15;
Pa.T_Varying.RLS_DFE.Lfbf = 10;
Pa.T_Varying.RLS_DFE.lambda = 0.993; 
Pa.T_Varying.RLS_DFE.delta = 1;
% ABOVE: RLS_DFE parameters
%{
    set Pa.T_Varying.LMS_DFE here
    set Pa.T_Varying.NLMS_DFE here
%}

%% Adaptive filter
switch TestCase
    case 'Static'
        if SNR == "Low"
            full_noised_signal = data_static_1;
            known_train        = trainseq_static_1;
        elseif SNR == "High"
            full_noised_signal = data_static_2;
            known_train        = trainseq_static_2;
        end
        try
            [squared_e, ~, pred_train]  = ...
                eval(['algorithm_',Algo,'(Pa.Static, known_train, full_noised_signal);']);
        catch ME
            switch ME.identifier
                case 'MATLAB:UndefinedFunction'
                    error(['no function named algorithm_',num2str(Algo),'.m']);
                otherwise
                    rethrow(ME)
            end
        end         
    case 'QStatic'
        if SNR == "Low"
            full_noised_signal = data_qstatic_1;
            known_train        = trainseq_qstatic_1;
        elseif SNR == "High"
            full_noised_signal = data_qstatic_2;
            known_train        = trainseq_qstatic_2;
        end        
        try
            [squared_e, ~, pred_train]  = ...
                eval(['algorithm_',Algo,'(Pa.Q_Static, known_train, full_noised_signal);']);
        catch ME
            switch ME.identifier
                case 'MATLAB:UndefinedFunction'
                    error(['no function named algorithm_',num2str(Algo),'.m']);
                otherwise
                    rethrow(ME)
            end
        end        
    case 'Varying'
        if SNR == "Low"
            full_noised_signal = data_varying_1;
            known_train        = trainseq_varying_1;
        elseif SNR == "High"
            full_noised_signal = data_varying_2;
            known_train        = trainseq_varying_2;
        end      
        try
            [squared_e, ~, pred_train]  = ...
                eval(['algorithm_',Algo,'(Pa.T_Varying, known_train, full_noised_signal);']);
        catch ME
            switch ME.identifier
                case 'MATLAB:UndefinedFunction'
                    error(['no function named algorithm_',num2str(Algo),'.m']);
                otherwise
                    rethrow(ME)
            end
        end
end

%% BER & plot learning curve 
utils_inputs.task = 'calc_BER';
utils_inputs.pred_seq = pred_train;

switch TestCase
    case 'Static'
        utils_inputs.signal_seq = known_train;
        plot(squared_e);
        title('e^2');
    case 'QStatic'
        utils_inputs.signal_seq = repmat(known_train, 1, Pa.Q_Static.NumRepetition);
        avg_squared_e = zeros(1, Pa.Q_Static.train_length);
        for ind = 1:length(squared_e)
            ind2 = rem(ind, Pa.Q_Static.train_length);
            if ind2 == 0
                ind2 = Pa.Q_Static.train_length;
            end
            avg_squared_e(ind2) = avg_squared_e(ind2) + squared_e(ind);
        end
        avg_squared_e = avg_squared_e / Pa.Q_Static.NumRepetition;
        plot(avg_squared_e);
        title(['e^2 (averaged over ',num2str(Pa.Q_Static.NumRepetition),' train seq)']);
    case 'Varying'
        utils_inputs.signal_seq = repmat(known_train, 1, Pa.T_Varying.NumRepetition);
        avg_squared_e = zeros(1, Pa.T_Varying.train_length);
        for ind = 1:length(squared_e)
            ind2 = rem(ind, Pa.T_Varying.train_length);
            if ind2 == 0
                ind2 = Pa.T_Varying.train_length;
            end
            avg_squared_e(ind2) = avg_squared_e(ind2) + squared_e(ind);
        end
        avg_squared_e = avg_squared_e / Pa.T_Varying.NumRepetition;
        plot(avg_squared_e);        
        title(['e^2 (averaged over ',num2str(Pa.T_Varying.NumRepetition),' train seq)']);
end

post_BER = shared_utils(utils_inputs);
utils_inputs.task = [];
% fprintf('Post BER is %f\n', post_BER);

%% average BER: before and after
DataMeasurements = load_measurements(); 
DataMeasurements = DataMeasurements.DataMeasurements;
switch TestCase
    case 'Static'
        if SNR == "Low"
            prior_BER = ...
                DataMeasurements.Static.Seq1.prior_BER;
        elseif SNR == "High"
            prior_BER = ...
                DataMeasurements.Static.Seq2.prior_BER;        
        end
    case 'QStatic'
        if SNR == "Low"
            prior_BER = ...
                mean(DataMeasurements.Q_Static.Seq1.prior_BER_seq);
        elseif SNR == "High"
            prior_BER = ...
                mean(DataMeasurements.Q_Static.Seq2.prior_BER_seq);        
        end        
    case 'Varying'
        if SNR == "Low"
            prior_BER = ...
                mean(DataMeasurements.T_Varying.Seq1.prior_BER_seq);
        elseif SNR == "High"
            prior_BER = ...
                mean(DataMeasurements.T_Varying.Seq2.prior_BER_seq);        
        end          
end

%% print results
fprintf('Algorithm: %s\n', Algo);
fprintf('Test case: %s\n', TestCase);
fprintf('SNR: %s\n', SNR);
fprintf('Prior averaged BER: %.5f\n', prior_BER);
fprintf('Post averaged BER: %.5f\n', post_BER);



