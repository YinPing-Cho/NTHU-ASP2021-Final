function results = shared_utils(Inputs)
    switch Inputs.task
        case 'generate_noise_at_SNR'
            results = generate_noise_at_SNR(Inputs.signal, Inputs.SNR);
        case 'generate_antipodal_signal'
            results = generate_antipodal_signal(Inputs.num_samples);
        case 'calc_BER'
            results = calc_BER(Inputs.pred_seq, Inputs.signal_seq);
        case 'plot_squared_error_curve'
            results = plot_squared_error_curve(Inputs.squared_error_seq, Inputs.title, Inputs.bounds);
        case 'simple_plot'
            results = simple_plot(Inputs.seq, Inputs.title);
        otherwise
            assert(false, 'Not implemented error.')
    end
end

function snr_noise = generate_noise_at_SNR(signal, SNR)
    noise = rand(size(signal));
    norm_noise = noise./max(noise);
    noise_rms = rms(norm_noise);
    amp=10^(SNR/20)*noise_rms;
    snr_noise = norm_noise ./ amp .* rms(signal);
end

function signal_seq = generate_antipodal_signal(num_samples)
    signal_seq = randi([0,1],1,num_samples)*2 - 1;
end

function BER = calc_BER(pred_seq, signal_seq)
    pos_ones = pred_seq > 0;
    neg_ones = pred_seq < 0;
    pred_antipodal = pos_ones - neg_ones;
    match_seq = pred_antipodal == signal_seq;
    BER = 1 - mean(match_seq);
end

function none = plot_squared_error_curve(squared_error_seq, plot_title, bounds)
    figure(1)
    seq_size = size(squared_error_seq);
    seq_length = seq_size(2);
    plot_time_axis = linspace(1,seq_length,seq_length);
    plot(plot_time_axis, moving_average(squared_error_seq, 1));
    ylim(bounds);
    title(plot_title);
    none = [];
end

function none = simple_plot(seq, plot_title)
    figure(1)
    seq_size = size(seq);
    seq_length = seq_size(2);
    plot_time_axis = linspace(1,seq_length,seq_length);
    plot(plot_time_axis, moving_average(seq, 1));
    title(plot_title);
    none = [];
end

function avg_seq = moving_average(seq, M)
    length = size(seq);
    length = length(end);
    kernel = ones(1,M);
    avg_seq = conv(seq, kernel)/M;
    avg_seq = avg_seq(1:length);
end