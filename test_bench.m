seed = 0;
rng(seed);
%{
Here is for parameter definition for the Static test case.
%}
TestCase_Params.Static.NumRepetition = 1;
TestCase_Params.Static.train_length = 1000;
TestCase_Params.Static.data_length = 200000;
TestCase_Params.Static.Algo = 'LMS';
TestCase_Params.Static.LMS.L = 20;
TestCase_Params.Static.LMS.alpha = 0.01;
% BELOW: RLS_DFE parameters
TestCase_Params.Static.RLS_DFE.Lfff = 20;
TestCase_Params.Static.RLS_DFE.Lfbf = 20;
TestCase_Params.Static.RLS_DFE.lambda = 0.999; 
TestCase_Params.Static.RLS_DFE.delta = 1;
% ABOVE: RLS_DFE parameters

%{
Here is for parameter definition for the Quasi-Stationary test case.
%}
TestCase_Params.Q_Static.NumRepetition = 200;
TestCase_Params.Q_Static.train_length = 200;
TestCase_Params.Q_Static.data_length = 1000;

%{
Here is for parameter definition for the Time-Varying test case
%}
TestCase_Params.T_Varying.NumRepetition = 500;
TestCase_Params.T_Varying.train_length = 50;
TestCase_Params.T_Varying.data_length = 400;

%{
Here is for test setup configuration.
%}
TestCase_Params.Test = 'Static';
TestCase_Params.Test_Runs = 10;
TestCase_Params.SNR = -1;
TestCase_Params.plot_bounds = [0, 1.6];

%{
Here is the main execution of the test.
%}
results = test_main(TestCase_Params);

function [avg_prior_BER, avg_post_BER, avg_squared_error_seq] = test_main(TestCase_Params)
    avg_prior_BER = 0;
    avg_post_BER = 0;
    avg_squared_error_seq = zeros(1,TestCase_Params.Static.train_length);
    for run = 1:TestCase_Params.Test_Runs
        switch TestCase_Params.Test
            case 'Static'
                [prior_BER, post_BER, squared_error_seq] = static_test_case(TestCase_Params);
            case 'Q_Static'
                assert(false, 'Not implemented error.')
                [prior_BER, post_BER, squared_error_seq] = q_static_test_case(TestCase_Params);
            case 'T_Varying'
                assert(false, 'Not implemented error.')
            otherwise
                assert(false, 'Not implemented error.')
        end
        
        avg_prior_BER = cumulative_avg(avg_prior_BER,prior_BER,run);
        avg_post_BER = cumulative_avg(avg_post_BER,post_BER,run);
        avg_squared_error_seq = cumulative_avg(avg_squared_error_seq,squared_error_seq,run);
    end
    
    utils_inputs.task = 'plot_squared_error_curve';
    utils_inputs.squared_error_seq = avg_squared_error_seq;
    utils_inputs.title = sprintf('%s Case avg squared-error over %d runs for %s algo', ...
        TestCase_Params.Test, TestCase_Params.Test_Runs, TestCase_Params.Static.Algo);
    utils_inputs.bounds = TestCase_Params.plot_bounds;
    shared_utils(utils_inputs);
    
    fprintf('%s test case; %s; SNR=%.2f;\n',...
        TestCase_Params.Test,TestCase_Params.Static.Algo, TestCase_Params.SNR);
    fprintf('Prior BER: %.6f \n', avg_prior_BER);
    fprintf('Post BER: %.6f \n', avg_post_BER);
end

function avg = cumulative_avg(avg_old, new_val, count)
    avg = (avg_old * (count-1) + new_val) / count;
end

function [prior_BER, post_BER, squared_error_seq] = static_test_case(TestCase_Params)
    utils_inputs.task = 'generate_antipodal_signal';
    utils_inputs.num_samples = TestCase_Params.Static.train_length+...
        TestCase_Params.Static.data_length;
    signal = shared_utils(utils_inputs);
    utils_inputs.task = [];
    
    utils_inputs.task = 'generate_noise_at_SNR';
    utils_inputs.signal = signal;
    utils_inputs.SNR = TestCase_Params.SNR;
    noise = shared_utils(utils_inputs);
    utils_inputs.task = [];
    
    noised_signal = signal + noise;
    measured_SNR = snr(signal, noised_signal-signal);
    assert (abs(measured_SNR-TestCase_Params.SNR) < 1.0)
    %fprintf('Measured SNR: %.2f \n', measured_SNR);
    
    utils_inputs.task = 'calc_BER';
    utils_inputs.pred_seq = noised_signal;
    utils_inputs.signal_seq = signal;
    prior_BER = shared_utils(utils_inputs);
    utils_inputs.task = [];
    
    known_train_seq = signal(1,1:TestCase_Params.Static.train_length);
    full_noised_signal_seq = noised_signal;
    switch TestCase_Params.Static.Algo
        case 'LMS'
            [squared_error_seq, pred_signal] = ...
                algorithm_LMS(TestCase_Params.Static,known_train_seq,full_noised_signal_seq);
        case 'LMS-DFE'
            assert(false, 'Not implemented error.')
            [squared_error_seq, pred_signal] = ...
                algorithm_LMS_DFE(TestCase_Params.Static,known_train_seq,full_noised_signal_seq);
        case 'RLS-DFE'
            assert(false, 'Not implemented error.')
            [squared_error_seq, pred_signal] = ...
                algorithm_RLS_DFE(TestCase_Params.Static,known_train_seq,full_noised_signal_seq);
        case 'NLMS-DFE'
            assert(false, 'Not implemented error.')
            [squared_error_seq, pred_signal] = ...
                algorithms_NLMS_DFE(TestCase_Params.Static,known_train_seq,full_noised_signal_seq);
        otherwise
        assert(false, 'Not implemented error.')
    end
    
    utils_inputs.task = 'calc_BER';
    utils_inputs.pred_seq = pred_signal;
    utils_inputs.signal_seq = signal(1,TestCase_Params.Static.train_length+1:end);
    post_BER = shared_utils(utils_inputs);
end

function [prior_BER, post_BER, squared_error_seq] = q_static_test_case(TestCase_Params)
    DataMeasurements = load_measurements();
end
