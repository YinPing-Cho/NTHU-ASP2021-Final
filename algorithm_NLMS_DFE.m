function [overall_squared_error_seq, overall_pred_signal] = algorithm_NLMS_DFE(Params, known_train_seq, full_noised_signal_seq)

    overall_squared_error_seq = zeros(1,Params.NumRepetition*Params.train_length);
    overall_pred_signal = zeros(1,Params.NumRepetition*Params.data_length);
    start_index = 1;
    
    ff_filter_coeffs = zeros(1, Params.NLMS_DFE.Lfff);
    fb_filter_coeffs = zeros(1, Params.NLMS_DFE.Lfbf);
    %{
    Repeat for 'NumRepetition' pairs of (1, train_seq+data_seq) sequences
    %}
    for repetition = 1:Params.NumRepetition
        % Training phase update filter coefficients
        [error_seq, ff_filter_coeffs, fb_filter_coeffs] = ...
            NLMS_DFE_train(Params, ff_filter_coeffs, fb_filter_coeffs, known_train_seq, ...
            full_noised_signal_seq(1,start_index:-1+start_index+Params.train_length+Params.NLMS_DFE.Lfff));
        squared_error_seq = error_seq .^ 2;
        
        % Prepare data for decision-directed phase
        noised_signal = zeros(1,Params.data_length+Params.NLMS_DFE.Lfff);

        noised_signal(1,1:Params.data_length) = ...
            full_noised_signal_seq(1,start_index+Params.train_length:-1+start_index+Params.train_length+Params.data_length);
        noised_signal(1,Params.data_length:-1+Params.data_length+Params.NLMS_DFE.Lfff) = ...
            full_noised_signal_seq(1,start_index:-1+start_index+Params.NLMS_DFE.Lfff);

        % Prediction/inference/decision-directed phase
        pred_signal = NLMS_DFE_inference(ff_filter_coeffs, fb_filter_coeffs, noised_signal);

        % Record results
        overall_squared_error_seq(1,(repetition-1)*Params.train_length+1:repetition*Params.train_length)=squared_error_seq;
        overall_pred_signal(1,1+(repetition-1)*Params.data_length:repetition*Params.data_length)=pred_signal;
        
        start_index = start_index + Params.train_length + Params.data_length;
    end
end

function [error_seq, ff_filter_coeffs, fb_filter_coeffs] = NLMS_DFE_train(Params, ff_filter_coeffs, fb_filter_coeffs, known_train_seq, full_noised_signal_seq)
    error_seq = zeros(1, Params.train_length);
    
    ff_input = zeros(1, Params.NLMS_DFE.Lfff);
    fb_input = zeros(1, Params.NLMS_DFE.Lfbf);
    fb_pred = 0;
    
    for iteration = 1:Params.train_length
        % Forward pred
        ff_input(2:end) = ff_input(1:end-1);
        ff_input(1) = full_noised_signal_seq(iteration);
        
        ff_pred = sum(ff_filter_coeffs .* ff_input);
        signal_pred = ff_pred - fb_pred;
        error_seq(iteration) = known_train_seq(1,iteration)-signal_pred;
        decision_pred = sign(signal_pred);
        
        % Update
        ff_filter_coeffs = ff_filter_coeffs + ...
            Params.NLMS_DFE.alpha*error_seq(iteration).*ff_input /...
            (Params.NLMS_DFE.epsilon + sum(ff_input.*ff_input));
        fb_filter_coeffs = fb_filter_coeffs - ...
            Params.NLMS_DFE.alpha*error_seq(iteration).*fb_input /...
            (Params.NLMS_DFE.epsilon + sum(fb_input.*fb_input));
        
        % Backforward
        fb_input(2:end) = fb_input(1:end-1);
        fb_input(1) = decision_pred;
        
        fb_pred = sum(fb_filter_coeffs .* fb_input);
    end
end

function pred_signal = NLMS_DFE_inference(ff_filter_coeffs, fb_filter_coeffs, noised_signal)
    signal_length = get_length(noised_signal);
    ff_length = get_length(ff_filter_coeffs);
    fb_length = get_length(fb_filter_coeffs);
    
    ff_input = zeros(1, ff_length);
    fb_input = zeros(1, fb_length);
    fb_pred = 0;
    
    pred_signal = zeros(1, signal_length-ff_length);
    for iteration = 1:(signal_length-ff_length)
        ff_input(2:end) = ff_input(1:end-1);
        ff_input(1) = noised_signal(iteration);
        ff_pred = sum(ff_filter_coeffs .* ff_input);
        
        signal_pred = ff_pred - fb_pred;
        pred_signal(iteration) = signal_pred;
        decision_pred = sign(signal_pred);
        
        % Backforward
        fb_input(2:end) = fb_input(1:end-1);
        fb_input(1) = decision_pred;
        
        fb_pred = sum(fb_filter_coeffs .* fb_input);
    end
end

function length = get_length(seq)
    seq_size = size(seq);
    length = seq_size(end);
end