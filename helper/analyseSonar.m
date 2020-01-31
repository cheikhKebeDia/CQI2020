function analysed = analyseSonar(signal, start, ending, threshold)
    % Create output vector
    analysed = zeros(100, 1);

    % Calculate signal length by square
    step = floor(length(signal)/100);

    % Create filter (in Frequency domain)
    filter = zeros(step, 1);
    filter_val = start:ending;
    % Use hanning window to give more importance 
    % to frequency in middle of filter
    filter(filter_val) = hann(length(filter_val));

    j = 1;
    % Analyse every signal corresponding to a square
    for i = 1:step:length(signal) - step
        % Transform signal to frequency domain
        signal_fft = abs(fft(signal(i:i+step-1)))';
        % Apply filter
        filtered_freqs = signal_fft.*filter;
        % Sum values and compare to treshold
        analysed(j) = sum(filtered_freqs) > threshold;
        j = j + 1;
    end

end

