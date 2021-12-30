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
[Static.Seq1.SNR_seq,Static.Seq1.prior_BER_seq] = measure_static_data(DataParams.Static, trainseq_static_1, data_static_1);
[Static.Seq2.SNR_seq,Static.Seq2.prior_BER_seq] = measure_static_data(DataParams.Static, trainseq_static_2, data_static_2);
DataMeasurements.('Static') = Static;

[Q_Static.Seq1.SNR_seq,Q_Static.Seq1.prior_BER_seq] = measure_non_static_data(DataParams.Q_Static, trainseq_qstatic_1, data_qstatic_1, 'Q-static Seq 1');
[Q_Static.Seq2.SNR_seq,Q_Static.Seq2.prior_BER_seq] = measure_non_static_data(DataParams.Q_Static, trainseq_qstatic_2, data_qstatic_2, 'Q-static Seq 2');
DataMeasurements.('Q_Static') = Q_Static;

[T_Varying.Seq1.SNR_seq,T_Varying.Seq1.prior_BER_seq] = measure_non_static_data(DataParams.T_Varying, trainseq_varying_1, data_varying_1, 'T-varying Seq 1');
[T_Varying.Seq2.SNR_seq,T_Varying.Seq2.prior_BER_seq] = measure_non_static_data(DataParams.T_Varying, trainseq_varying_2, data_varying_2, 'T-varying Seq 2');
DataMeasurements.('T_Varying') = T_Varying;

save('Measurements.mat','DataMeasurements');

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

function [SNR_seq, prior_BER_seq] = measure_non_static_data(DataParams_NonStatic, train_seq, full_seq, seq_name)
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
    
    fprintf('%s AVG SNR: %.6f \n',seq_name,mean(SNR_seq));
    fprintf('%s AVG prior-BER: %.6f \n',seq_name,mean(prior_BER));
end