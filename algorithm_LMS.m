function [overall_squared_error_seq, overall_pred_signal] = algorithm_LMS(Params, known_train_seq, full_noised_signal_seq)
    %{
    I/O:
    -'Params' is a struct that includes most of the information you need.
        the most useful parameters are:
            -'.NumRepetition': how many paris of (1, train_seq+data_seq)
                sequences there are.
            -'.train_length': the length of each training sequence.
            -'.data_length': the length of each data sequence.
    -'known_train_seq': the (1, train_L) sequence that is known and should be 
        used in the training phase as the target signal.
    -'full_noised_signal': the (1, (train_L+data_L)*N) sequence that include 
        both the training sequence(s) and data sequence(s).
    General pipeline:
        -Initialize 'filter coefficient'
    	-For each (train_seq+data_seq) sequence:
            Train and update 'filter coefficient'
            Use 'filter coefficient' to predict the data_seq part
            record training error and predicted data_seq
        -Return training error sequence and predicted data sequence
    %}

    overall_squared_error_seq = zeros(1,Params.NumRepetition*Params.train_length);
    overall_pred_signal = zeros(1,Params.NumRepetition*Params.data_length);
    start_index = 1;
    
    filter_coeffs = zeros(1, Params.LMS.L);
    %{
    Repeat for 'NumRepetition' pairs of (1, train_seq+data_seq) sequences
    %}
    for repetition = 1:Params.NumRepetition
        % Training phase update filter coefficients
        [error_seq,filter_coeffs] = ...
            LMS_train(Params, filter_coeffs, known_train_seq, ...
            full_noised_signal_seq(1,start_index:-1+start_index+Params.train_length+Params.LMS.L));
        squared_error_seq = error_seq .^ 2;
        
        % Prepare data for decision-directed phase
        noised_signal = zeros(1,Params.data_length+Params.LMS.L);

        noised_signal(1,1:Params.data_length) = ...
            full_noised_signal_seq(1,start_index+Params.train_length:-1+start_index+Params.train_length+Params.data_length);
        noised_signal(1,Params.data_length:-1+Params.data_length+Params.LMS.L) = ...
            full_noised_signal_seq(1,start_index:-1+start_index+Params.LMS.L);

        % Prediction/inference/decision-directed phase
        pred_signal = LMS_inference(filter_coeffs, noised_signal);

        % Record results
        overall_squared_error_seq(1,(repetition-1)*Params.train_length+1:repetition*Params.train_length)=squared_error_seq;
        overall_pred_signal(1,1+(repetition-1)*Params.data_length:repetition*Params.data_length)=pred_signal;
        
        start_index = start_index + Params.train_length + Params.data_length;
    end
    
    overall_pred_signal = sign(overall_pred_signal);
end

function [error_seq, filter_coeffs] = LMS_train(Params, filter_coeffs, known_train_seq, full_noised_signal_seq)
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
    signal_length = get_length(noised_signal);
    filter_length = get_length(filter_coeffs);
    
    pred_signal = zeros(1, signal_length-filter_length);
    for iteration = 1:(signal_length-filter_length)
        pred_signal(iteration) = sum(filter_coeffs .* ...
            noised_signal(1,iteration:iteration+filter_length-1));
    end
end

function length = get_length(seq)
    seq_size = size(seq);
    length = seq_size(end);
end