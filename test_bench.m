seed = 0;
rng(seed);

%{
Load test data measurements
%}
DataMeasurements = load_measurements();
DataMeasurements = DataMeasurements.('DataMeasurements');

%{
Here is for parameter definition for the Static test case.
%}
TestCase_Params.Static.NumRepetition = 1;
TestCase_Params.Static.train_length = 1000;
TestCase_Params.Static.data_length = 200000;
TestCase_Params.Static.Algo = 'RLS-DFE';

%{
Here is for parameter definition for the Quasi-Stationary test case.
%}
TestCase_Params.Q_Static.NumRepetition = 200;
TestCase_Params.Q_Static.train_length = 200;
TestCase_Params.Q_Static.data_length = 1000;
TestCase_Params.Q_Static.Algo = 'RLS-DFE';

%{
Here is for parameter definition for the Time-Varying test case
%}
TestCase_Params.T_Varying.NumRepetition = 500;
TestCase_Params.T_Varying.train_length = 50;
TestCase_Params.T_Varying.data_length = 400;
TestCase_Params.T_Varying.Algo = 'RLS-DFE';

%{
Here is for test setup configuration.
%}
TestCase_Params = Init_AdaptiveAlgoParams(TestCase_Params);
TestCase_Params.Test_Runs = 10;
TestCase_Params.plot_bounds = [0, 3.0];

%{
Here is the main execution of the test.
%}
TestResults = MAIN(TestCase_Params, DataMeasurements);

%{###############################
%# BELOW ARE THE FUNCTIONS ######
%}###############################

function TestCase_Params = Init_AdaptiveAlgoParams(TestCase_Params)
    TestCase_Params = PARAMS_LMS(TestCase_Params);
    TestCase_Params = PARAMS_LMS_DFE(TestCase_Params);
    TestCase_Params = PARAMS_NLMS_DFE(TestCase_Params);
    TestCase_Params = PARAMS_RLS_DFE(TestCase_Params);
end

function TestResults = MAIN(TestCase_Params, DataMeasurements)
    TestResults = full_simulation_main(TestCase_Params, DataMeasurements);
    display_test_results(TestResults);
end

function TestResults = full_simulation_main(TestCase_Params, DataMeasurements)
    TestResults = struct();
    test_algos = ["LMS","RLS-DFE"];
    test_cases = ["Static","Q_Static","T_Varying"];
    run_count = 0;
    for algo_index = 1:numel(test_algos)
        for test_index = 1:numel(test_cases)
            TestCase_Params.Test = test_cases(test_index);
            TestCase_Params.(TestCase_Params.Test).Algo = test_algos(algo_index);
            SNR_settings = DataMeasurements.(TestCase_Params.Test);
            TestCase_Params.SNR_settings = SNR_settings;
            SNR_settings = fieldnames(TestCase_Params.SNR_settings);
            for snr_index = 1:numel(SNR_settings)
                fprintf('\n%s Algo:"%s" SNR setting %d \n',...
                    TestCase_Params.Test,TestCase_Params.(TestCase_Params.Test).Algo,snr_index);
                setting_name = cell2mat(SNR_settings(snr_index));
                [avg_prior_BER, avg_post_BER, avg_squared_error_seq] = test_main(TestCase_Params, TestCase_Params.SNR_settings.(setting_name).SNR_seq);

                TestConfig = sprintf('Config%d',run_count);
                run_count = run_count + 1;
                TestResults.(TestConfig).ConfigContents = sprintf('%s; Algo:"%s"; AVG SNR=%.2f',...
                    TestCase_Params.Test,...
                    TestCase_Params.(TestCase_Params.Test).Algo,...
                    mean(TestCase_Params.SNR_settings.(setting_name).SNR_seq));
                TestResults.(TestConfig).avg_prior_BER = avg_prior_BER;
                TestResults.(TestConfig).avg_post_BER = avg_post_BER;
                TestResults.(TestConfig).avg_squared_error_seq = avg_squared_error_seq;
            end
        end
    end
end

function display_test_results(TestResults)
    fprintf('\nBelow are the test results:\n')
    configs = fieldnames(TestResults);
    for config_index = 1:numel(configs)
        config_string = cell2mat(configs(config_index));
        fprintf('%s: %s\nAVG prior BER=%.9f\nAVG post BER=%.9f\n',...
            config_string,...
            TestResults.(config_string).ConfigContents,...
            TestResults.(config_string).avg_prior_BER,...
            TestResults.(config_string).avg_post_BER);
    end
end

function [avg_prior_BER, avg_post_BER, avg_squared_error_seq] = test_main(TestCase_Params, SNR_seq)
    avg_prior_BER = 0;
    avg_post_BER = 0;
    avg_squared_error_seq = zeros(1,TestCase_Params.(TestCase_Params.Test).NumRepetition*...
        TestCase_Params.(TestCase_Params.Test).train_length);
    if ~strcmp(TestCase_Params.Test, 'Static')
        avg_prior_BER_seq = zeros(1,TestCase_Params.(TestCase_Params.Test).NumRepetition);
        avg_post_BER_seq = zeros(1,TestCase_Params.(TestCase_Params.Test).NumRepetition);
    end
    
    for run = 1:TestCase_Params.Test_Runs
        switch TestCase_Params.Test
            case 'Static'
                [prior_BER, post_BER, squared_error_seq] = static_test_case(TestCase_Params, SNR_seq);
            case 'Q_Static'
                [prior_BER_seq, post_BER_seq, squared_error_seq] = q_static_test_case(TestCase_Params, SNR_seq);
                avg_prior_BER_seq = cumulative_avg(avg_prior_BER_seq,prior_BER_seq,run);
                avg_post_BER_seq = cumulative_avg(avg_post_BER_seq,post_BER_seq,run);
                prior_BER = mean(prior_BER_seq);
                post_BER = mean(post_BER_seq);
            case 'T_Varying'
                [prior_BER_seq, post_BER_seq, squared_error_seq] = t_varying_test_case(TestCase_Params, SNR_seq);
                avg_prior_BER_seq = cumulative_avg(avg_prior_BER_seq,prior_BER_seq,run);
                avg_post_BER_seq = cumulative_avg(avg_post_BER_seq,post_BER_seq,run);
                prior_BER = mean(prior_BER_seq);
                post_BER = mean(post_BER_seq);
            otherwise
                assert(false, 'Not implemented error.')
        end
        
        avg_prior_BER = cumulative_avg(avg_prior_BER,prior_BER,run);
        avg_post_BER = cumulative_avg(avg_post_BER,post_BER,run);
        avg_squared_error_seq = cumulative_avg(avg_squared_error_seq,squared_error_seq,run);
    end
    
    if ~strcmp(TestCase_Params.Test, 'Static')
        utils_inputs.task = 'simple_plot';
        utils_inputs.seq = avg_prior_BER_seq;
        utils_inputs.bounds = [min(avg_prior_BER_seq) max(avg_prior_BER_seq)];
        utils_inputs.title = sprintf('%s AVG SNR=%.2f; avged over %d runs prior BER plot',...
            TestCase_Params.Test,mean(SNR_seq), TestCase_Params.Test_Runs);
        shared_utils(utils_inputs);
        pause(2.0);
        utils_inputs.task = 'simple_plot';
        utils_inputs.seq = avg_post_BER_seq;
        utils_inputs.bounds = [min(avg_post_BER_seq) max(avg_post_BER_seq)];
        utils_inputs.title = sprintf('%s AVG SNR=%.2f; avged over %d runspost BER plot',...
            TestCase_Params.Test,mean(SNR_seq), TestCase_Params.Test_Runs);
        shared_utils(utils_inputs);
        pause(2.0);
    end
        
    utils_inputs.task = 'plot_squared_error_curve';
    utils_inputs.squared_error_seq = avg_squared_error_seq;
    utils_inputs.title = sprintf('%s Case avg squared-error over %d runs for %s algo; SNR=%.2f', ...
        TestCase_Params.Test, TestCase_Params.Test_Runs, TestCase_Params.Static.Algo, mean(SNR_seq));
    utils_inputs.bounds = TestCase_Params.plot_bounds;
    shared_utils(utils_inputs);
    pause(1);
    
    fprintf('%s test case; %s; SNR=%.2f;\n',...
        TestCase_Params.Test,TestCase_Params.Static.Algo, mean(SNR_seq));
    fprintf('Prior BER: %.6f \n', avg_prior_BER);
    fprintf('Post BER: %.6f \n', avg_post_BER);
end

function avg = cumulative_avg(avg_old, new_val, count)
    avg = (avg_old * (count-1) + new_val) / count;
end

function [prior_BER, post_BER, squared_error_seq] = static_test_case(TestCase_Params, SNR)
    utils_inputs.task = 'generate_antipodal_signal';
    utils_inputs.num_samples = TestCase_Params.Static.train_length+...
        TestCase_Params.Static.data_length;
    signal = shared_utils(utils_inputs);
    utils_inputs.task = [];
    
    utils_inputs.task = 'generate_noise_at_SNR';
    utils_inputs.signal = signal;
    utils_inputs.SNR = SNR;
    noise = shared_utils(utils_inputs);
    utils_inputs.task = [];
    
    noised_signal = signal + noise;
    measured_SNR = snr(signal, noised_signal-signal);
    assert (abs(measured_SNR-SNR) < 1.0)
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

function [prior_BER_seq, post_BER_seq, squared_error_seq] = q_static_test_case(TestCase_Params, SNR_seq)
    [prior_BER_seq, post_BER_seq, squared_error_seq] = non_static_test_case(TestCase_Params.Q_Static, SNR_seq);
end

function [prior_BER_seq, post_BER_seq, squared_error_seq] = t_varying_test_case(TestCase_Params, SNR_seq)
    [prior_BER_seq, post_BER_seq, squared_error_seq] = non_static_test_case(TestCase_Params.T_Varying, SNR_seq);
end

function [prior_BER_seq, post_BER_seq, squared_error_seq] = non_static_test_case(NonStaticTestCase_Params, SNR_seq)
    prior_BER_seq = zeros(1,NonStaticTestCase_Params.NumRepetition);
    post_BER_seq = zeros(1,NonStaticTestCase_Params.NumRepetition);
    squared_error_seq = zeros(1,NonStaticTestCase_Params.NumRepetition*NonStaticTestCase_Params.train_length);
    
    one_training_data_seq_length = NonStaticTestCase_Params.train_length+NonStaticTestCase_Params.data_length;
    full_seq_length = NonStaticTestCase_Params.NumRepetition*one_training_data_seq_length;
    full_noised_signal_seq = zeros(1,full_seq_length);
    full_data_seq = zeros(1,NonStaticTestCase_Params.NumRepetition*NonStaticTestCase_Params.data_length);
    one_training_data_seq = zeros(1,NonStaticTestCase_Params.train_length+NonStaticTestCase_Params.data_length);
    
    utils_inputs.task = 'generate_antipodal_signal';
    utils_inputs.num_samples = NonStaticTestCase_Params.train_length;
    known_train_seq = shared_utils(utils_inputs);
    utils_inputs.task = [];
    
    % Generate noised training+data sequence
    for repetition = 1:NonStaticTestCase_Params.NumRepetition
        utils_inputs.task = 'generate_antipodal_signal';
        utils_inputs.num_samples = NonStaticTestCase_Params.data_length;
        data_signal = shared_utils(utils_inputs);
        utils_inputs.task = [];
        full_data_seq(1,1+(repetition-1)*NonStaticTestCase_Params.data_length:(repetition)*NonStaticTestCase_Params.data_length)...
            = data_signal(1,1:end);
        
        one_training_data_seq(1,1:NonStaticTestCase_Params.train_length)=known_train_seq;
        one_training_data_seq(1,NonStaticTestCase_Params.train_length+1:end)=data_signal;
        
        utils_inputs.task = 'generate_noise_at_SNR';
        utils_inputs.signal = one_training_data_seq;
        utils_inputs.SNR = SNR_seq(repetition);
        noise = shared_utils(utils_inputs);
        utils_inputs.task = [];
        
        noised_seq = one_training_data_seq + noise;
        
        utils_inputs.task = 'calc_BER';
        utils_inputs.pred_seq = noised_seq;
        utils_inputs.signal_seq = one_training_data_seq;
        prior_BER = shared_utils(utils_inputs);
        utils_inputs.task = [];
        prior_BER_seq(repetition) = prior_BER;
        
        full_noised_signal_seq(1,1+(repetition-1)*one_training_data_seq_length:...
            (repetition)*one_training_data_seq_length) = noised_seq;
    end
    
    % Adaptive filtering
    switch NonStaticTestCase_Params.Algo
        case 'LMS'
            [squared_error_seq, pred_signal] = ...
                algorithm_LMS(NonStaticTestCase_Params,known_train_seq,full_noised_signal_seq);
        case 'LMS-DFE'
            assert(false, 'Not implemented error.')
            [squared_error_seq, pred_signal] = ...
                algorithm_LMS_DFE(NonStaticTestCase_Params,known_train_seq,full_noised_signal_seq);
        case 'RLS-DFE'
            [squared_error_seq, pred_signal] = ...
                algorithm_RLS_DFE(NonStaticTestCase_Params,known_train_seq,full_noised_signal_seq);
        case 'NLMS-DFE'
            assert(false, 'Not implemented error.')
            [squared_error_seq, pred_signal] = ...
                algorithms_NLMS_DFE(NonStaticTestCase_Params,known_train_seq,full_noised_signal_seq);
        otherwise
        assert(false, 'Not implemented error.')
    end
    
    % Calculate sequence-wise BER
    for repetition = 1:NonStaticTestCase_Params.NumRepetition
        utils_inputs.task = 'calc_BER';
        utils_inputs.pred_seq = ...
            pred_signal(1,1+(repetition-1)*NonStaticTestCase_Params.data_length:(repetition)*NonStaticTestCase_Params.data_length);
        utils_inputs.signal_seq = ...
            full_data_seq(1,1+(repetition-1)*NonStaticTestCase_Params.data_length:(repetition)*NonStaticTestCase_Params.data_length);
        post_BER = shared_utils(utils_inputs);
        utils_inputs.task = [];
        post_BER_seq(repetition) = post_BER;
    end
end
