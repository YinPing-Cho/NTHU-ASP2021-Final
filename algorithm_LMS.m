function [squared_error_seq, pred_signal] = algorithm_LMS(Params, known_train_seq, full_noised_signal_seq)
    [error_seq,filter_coeffs] = LMS_train(Params, known_train_seq, full_noised_signal_seq);
    
    noised_signal = zeros(1,Params.train_length+Params.LMS.L);
    noised_signal(1,1:Params.data_length) = full_noised_signal_seq(1,1+Params.train_length:end);
    noised_signal(1,1+Params.data_length:Params.data_length+Params.LMS.L) = full_noised_signal_seq(1,1:Params.LMS.L);
    
    squared_error_seq = error_seq .^ 2;
    pred_signal = LMS_inference(filter_coeffs, noised_signal);
end

function [error_seq, filter_coeffs] = LMS_train(Params, known_train_seq, full_noised_signal_seq)
    filter_coeffs = zeros(1, Params.LMS.L);
    error_seq = zeros(1, Params.train_length);
    
    for iteration = 1:Params.train_length
        signal_pred = sum(filter_coeffs .* ...
            full_noised_signal_seq(1,iteration:iteration+Params.LMS.L-1));
        error_seq(iteration) = known_train_seq(1,iteration)-signal_pred;
        
        filter_coeffs = filter_coeffs + ...
            Params.LMS.alpha*error_seq(iteration)*...
            full_noised_signal_seq(iteration:iteration+Params.LMS.L-1);
    end
end

function pred_signal = LMS_inference(filter_coeffs, noised_signal)
    input_signal_size = size(noised_signal);
    signal_length = input_signal_size(2);
    
    filter_size = size(filter_coeffs);
    filter_length = filter_size(2);
    
    pred_signal = zeros(1, signal_length-filter_length);
    for iteration = 1:(signal_length-filter_length)
        pred_signal(iteration) = sum(filter_coeffs .* ...
            noised_signal(1,iteration:iteration+filter_length-1));
    end
end