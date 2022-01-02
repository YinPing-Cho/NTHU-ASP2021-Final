clear all;

mfile_name          = mfilename('fullpath');
[pathstr,name,ext]  = fileparts(mfile_name);
cd(pathstr);
fileparts(matlab.desktop.editor.getActiveFilename)

load project_data2021.mat

%{
Test data hyperparameters
%}
DataParams.Static.NumRepetition = 1;
DataParams.Static.TrainSeqLength = get_length(trainseq_static_1);
DataParams.Static.EachFullSeqLength = get_length(data_static_1)/DataParams.Static.NumRepetition;
DataParams.Static.EachDataSeqLength = DataParams.Static.EachFullSeqLength-DataParams.Static.TrainSeqLength;

DataParams.Q_Static.NumRepetition = 200;
DataParams.Q_Static.TrainSeqLength = get_length(trainseq_qstatic_1);
DataParams.Q_Static.EachFullSeqLength = get_length(data_qstatic_1)/DataParams.Q_Static.NumRepetition;
DataParams.Q_Static.EachDataSeqLength = DataParams.Q_Static.EachFullSeqLength-DataParams.Q_Static.TrainSeqLength;

DataParams.T_Varying.NumRepetition = 500;
DataParams.T_Varying.TrainSeqLength = get_length(trainseq_varying_1);
DataParams.T_Varying.EachFullSeqLength = get_length(data_varying_1)/DataParams.T_Varying.NumRepetition;
DataParams.T_Varying.EachDataSeqLength = DataParams.T_Varying.EachFullSeqLength-DataParams.T_Varying.TrainSeqLength;

%{
Test data measurements
%}
plot_props = false;

[Static.Seq1.SNR_seq,Static.Seq1.prior_BER_seq] = measure_static_data(DataParams.Static, trainseq_static_1, data_static_1);
[Static.Seq2.SNR_seq,Static.Seq2.prior_BER_seq] = measure_static_data(DataParams.Static, trainseq_static_2, data_static_2);
DataMeasurements.('Static') = Static;

[Q_Static.Seq1.SNR_seq,Q_Static.Seq1.prior_BER_seq] = measure_non_static_data(DataParams.Q_Static, trainseq_qstatic_1, data_qstatic_1, 'Q-static Seq 1', plot_props);
[Q_Static.Seq2.SNR_seq,Q_Static.Seq2.prior_BER_seq] = measure_non_static_data(DataParams.Q_Static, trainseq_qstatic_2, data_qstatic_2, 'Q-static Seq 2', plot_props);
DataMeasurements.('Q_Static') = Q_Static;

[T_Varying.Seq1.SNR_seq,T_Varying.Seq1.prior_BER_seq] = measure_non_static_data(DataParams.T_Varying, trainseq_varying_1, data_varying_1, 'T-varying Seq 1', plot_props);
[T_Varying.Seq2.SNR_seq,T_Varying.Seq2.prior_BER_seq] = measure_non_static_data(DataParams.T_Varying, trainseq_varying_2, data_varying_2, 'T-varying Seq 2', plot_props);
DataMeasurements.('T_Varying') = T_Varying;

save('Measurements.mat','DataMeasurements');

% Configure adaptive algorithm params
AlgoParams.Static.NumRepetition = DataParams.Static.NumRepetition;
AlgoParams.Static.train_length = DataParams.Static.TrainSeqLength;
AlgoParams.Static.data_length = DataParams.Static.EachDataSeqLength;

AlgoParams.Q_Static.NumRepetition = DataParams.Q_Static.NumRepetition;
AlgoParams.Q_Static.train_length = DataParams.Q_Static.TrainSeqLength;
AlgoParams.Q_Static.data_length = DataParams.Q_Static.EachDataSeqLength;

AlgoParams.T_Varying.NumRepetition = DataParams.T_Varying.NumRepetition;
AlgoParams.T_Varying.train_length = DataParams.T_Varying.TrainSeqLength;
AlgoParams.T_Varying.data_length = DataParams.T_Varying.EachDataSeqLength;

%{
% Here is the main execution of adaptive filtering
%}
AlgoParams = Init_AdaptiveAlgoParams(AlgoParams);
AlgoParams.Static.Algo = 'RLS-DFE';
AlgoParams.Q_Static.Algo = 'RLS-DFE';
AlgoParams.T_Varying.Algo = 'RLS-DFE';

% Static
DataProperty = 'Static';
Algo = AlgoParams.Static.Algo;
[squared_error_seq_static_1, ans_static_1] = adaptive_filtering(...
    AlgoParams, trainseq_static_1, data_static_1, DataProperty, Algo);
[squared_error_seq_static_2, ans_static_2] = adaptive_filtering(...
    AlgoParams, trainseq_static_2, data_static_2, DataProperty, Algo);
save('ans_static.mat','ans_static_1','ans_static_2');

% Q_Static
DataProperty = 'Q_Static';
Algo = AlgoParams.Q_Static.Algo;
[squared_error_seq_qstatic_1, ans_qstatic_1] = adaptive_filtering(...
    AlgoParams, trainseq_qstatic_1, data_qstatic_1, DataProperty, Algo);
[squared_error_seq_qstatic_2, ans_qstatic_2] = adaptive_filtering(...
    AlgoParams, trainseq_qstatic_2, data_qstatic_2, DataProperty, Algo);
save('ans_qstatic.mat','ans_qstatic_1','ans_qstatic_2');

% T_Varying
DataProperty = 'T_Varying';
Algo = AlgoParams.T_Varying.Algo;
[squared_error_seq_varying_1, ans_varying_1] = adaptive_filtering(...
    AlgoParams, trainseq_varying_1, data_varying_1, DataProperty, Algo);
[squared_error_seq_varying_2, ans_varying_2] = adaptive_filtering(...
    AlgoParams, trainseq_varying_2, data_varying_2, DataProperty, Algo);
save('ans_varying.mat','ans_varying_1','ans_varying_2');

%{
% Plot squared-error curves
%}
clf;

tiledlayout(3,2);

DataProperty = 'Static';
Algo = AlgoParams.Static.Algo;
bounds = get_bounds(squared_error_seq_static_1,squared_error_seq_static_2);
seq_num = 1;
nexttile;
plot_squared_error_curves(DataProperty, Algo, seq_num, squared_error_seq_static_1, bounds);
seq_num = 2;
nexttile;
plot_squared_error_curves(DataProperty, Algo, seq_num, squared_error_seq_static_2, bounds);

DataProperty = 'Q_Static';
Algo = AlgoParams.Q_Static.Algo;
bounds = get_bounds(squared_error_seq_qstatic_1,squared_error_seq_qstatic_2);
seq_num = 1;
nexttile;
plot_squared_error_curves(DataProperty, Algo, seq_num, squared_error_seq_qstatic_1, bounds);
seq_num = 2;
nexttile;
plot_squared_error_curves(DataProperty, Algo, seq_num, squared_error_seq_qstatic_2, bounds);

DataProperty = 'T_Varying';
Algo = AlgoParams.T_Varying.Algo;
bounds = get_bounds(squared_error_seq_varying_1,squared_error_seq_varying_2);
seq_num = 1;
nexttile;
plot_squared_error_curves(DataProperty, Algo, seq_num, squared_error_seq_varying_1, bounds);
seq_num = 2;
nexttile;
plot_squared_error_curves(DataProperty, Algo, seq_num, squared_error_seq_varying_2, bounds);

set(gcf,'WindowState','maximized');
saveas(gcf,[pwd '/MainFigs/Results.jpg']);

%{###############################
%# BELOW ARE THE FUNCTIONS ######
%}###############################

function bounds = get_bounds(seq1, seq2)
    bounds = [min(cat(2,seq1,seq2)) max(cat(2,seq1,seq2))];
end

function AlgoParams = Init_AdaptiveAlgoParams(AlgoParams)
    AlgoParams = PARAMS_LMS(AlgoParams);
    AlgoParams = PARAMS_LMS_DFE(AlgoParams);
    AlgoParams = PARAMS_NLMS_DFE(AlgoParams);
    AlgoParams = PARAMS_RLS_DFE(AlgoParams);
end

function [squared_error_seq, pred_signal] = adaptive_filtering(AlgoParams, training_seq, full_noised_seq, DataProperty, Algo)
    
    switch Algo
        case 'LMS'
            [squared_error_seq, pred_signal] = ...
                algorithm_LMS(AlgoParams.(DataProperty),training_seq,full_noised_seq);
        case 'LMS-DFE'
            [squared_error_seq, pred_signal] = ...
                algorithm_LMS_DFE(AlgoParams.(DataProperty),training_seq,full_noised_seq);
        case 'RLS-DFE'
            [squared_error_seq, pred_signal] = ...
                algorithm_RLS_DFE(AlgoParams.(DataProperty),training_seq,full_noised_seq);
        case 'NLMS-DFE'
            [squared_error_seq, pred_signal] = ...
                algorithm_NLMS_DFE(AlgoParams.(DataProperty),training_seq,full_noised_seq);
        otherwise
            assert(false, 'Not implemented error.')
    end
end

function plot_squared_error_curves(DataProperty, algo, seq_num, squared_error_seq, bounds)
    utils_inputs.task = 'plot_squared_error_curve';
    utils_inputs.squared_error_seq = squared_error_seq;
    utils_inputs.title = sprintf('%s case seq %d; squared-error with %s algo', ...
        DataProperty, seq_num, algo);
    utils_inputs.bounds = bounds;
    shared_utils(utils_inputs);
end

function length = get_length(seq)
    seq_size = size(seq);
    length = seq_size(end);
end

function [SNR, prior_BER] = calc_SNR_BER(signal, noised_signal)
    SNR = snr(signal, noised_signal-signal);
    
    utils_inputs.task = 'calc_BER';
    utils_inputs.pred_seq = noised_signal;
    utils_inputs.signal_seq = signal;
    prior_BER = shared_utils(utils_inputs);
end

function [SNR, prior_BER] = measure_static_data(DataParams_Static, train_seq, full_seq)
    noised_train_seq = full_seq(1:DataParams_Static.TrainSeqLength);
    [SNR, prior_BER] = calc_SNR_BER(train_seq, noised_train_seq);
    
    fprintf('Static seq SNR: %.6f \n', SNR);
    fprintf('Static Prior BER: %.6f \n', prior_BER);
end

function [SNR_seq, prior_BER_seq] = measure_non_static_data(DataParams_NonStatic, train_seq, full_seq, seq_name, plot_props)
    SNR_seq = zeros(1, DataParams_NonStatic.TrainSeqLength);
    prior_BER_seq = zeros(1, DataParams_NonStatic.TrainSeqLength);
    start_index = 1;
    for seq_count = 1:DataParams_NonStatic.NumRepetition
        noised_train_seq = full_seq(start_index:-1+start_index+DataParams_NonStatic.TrainSeqLength);
        [SNR, prior_BER] = calc_SNR_BER(train_seq, noised_train_seq);
        SNR_seq(seq_count) = SNR;
        prior_BER_seq(seq_count) = prior_BER;
        
        start_index = start_index + DataParams_NonStatic.EachFullSeqLength;
    end
    
    if plot_props
        utils_inputs.task = 'simple_plot';
        utils_inputs.seq = SNR_seq;
        utils_inputs.bounds = [];
        utils_inputs.title = sprintf('%s SNR plot',seq_name);
        shared_utils(utils_inputs);
        %pause();
        utils_inputs.seq = prior_BER_seq;
        utils_inputs.bounds = [];
        utils_inputs.title = sprintf('%s prior-BER plot',seq_name);
        shared_utils(utils_inputs);
        %pause();
    end
    
    fprintf('%s AVG SNR: %.6f \n',seq_name,mean(SNR_seq));
    fprintf('%s AVG prior-BER: %.6f \n',seq_name,mean(prior_BER));
end