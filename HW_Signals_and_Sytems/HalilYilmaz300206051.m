clc; clear; close all;

%%  Load audio
file = "signal.mp4";          % 
[x, Fs] = audioread(file);

% Stereo ise mono yap
if size(x,2) > 1
    x = mean(x, 2);
end

N = length(x);
T = N/Fs;
t = (0:N-1)/Fs;

fprintf("Fs = %d Hz | N = %d samples | Duration = %.3f s\n", Fs, N, T);
soundsc(x, Fs);
pause(T + 0.2);


%% 4.2 (5) Time-Domain Representation of the Recorded Signal

figure;
theme light;
plot(t, x);
grid on;
xlabel("Time (s)");
ylabel("Amplitude");
title(sprintf("Original signal (time domain) - 0 to %.2f s", T));

% short time
figure;
theme light;
sgtitle("Short time segments of each note (time domain)");

% do
t_start_do = 0.47 ; t_end_do = 2.6;
idx_do = (t >= t_start_do) & (t <= t_end_do);
subplot(4,2,1)
plot(t(idx_do),x(idx_do));
grid on;
xlabel('Time(s)');ylabel('Amplitude');
title(sprintf("  Do (%.2f–%.2f s)",t_start_do, t_end_do));

%re
t_start_re = 2.7 ; t_end_re = 4.6 ;
idx_re = (t >= t_start_re) & (t <= t_end_re);
subplot(4,2,2);
plot(t(idx_re),x(idx_re));
grid on;
xlabel('Time(s)');ylabel('Amplitude');
title(sprintf(" Re (%.2f–%.2f s)",t_start_re, t_end_re));

%mi
t_start_mi = 4.8 ; t_end_mi =6.8;
idx_mi = (t >= t_start_mi) & (t <= t_end_mi);
subplot(4,2,3)
plot(t(idx_mi),x(idx_mi));
grid on;
xlabel('Time(s)');ylabel('Amplitude');
title(sprintf("  Mi (%.2f–%.2f s)",t_start_mi, t_end_mi));

%fa
t_start_fa = 6.9 ; t_end_fa = 8.9 ;
idx_fa = (t >= t_start_fa) & (t <= t_end_fa);
subplot(4,2,4);
plot(t(idx_fa),x(idx_fa));
grid on;
xlabel('Time(s)');ylabel('Amplitude');
title(sprintf("  Fa (%.2f–%.2f s)",t_start_fa, t_end_fa));

%sol
t_start_sol = 9 ; t_end_sol = 10.6;
idx_sol = (t >= t_start_sol) & (t <= t_end_sol);
subplot(4,2,5)
plot(t(idx_sol),x(idx_sol));
grid on;
xlabel('Time(s)');ylabel('Amplitude');
title(sprintf(" Sol (%.2f–%.2f s)",t_start_sol, t_end_sol));

%la
t_start_la = 10.7 ; t_end_la = 12.4 ;
idx_la = (t >= t_start_la) & (t <= t_end_la);
subplot(4,2,6);
plot(t(idx_la),x(idx_la));
grid on;
xlabel('Time(s)');ylabel('Amplitude');
title(sprintf(" La (%.2f–%.2f s)",t_start_la, t_end_la));

%si
t_start_si = 12.7 ; t_end_si =14;
idx_si = (t >= t_start_si) & (t <= t_end_si);
subplot(4,2,7)
plot(t(idx_si),x(idx_si));
grid on;
xlabel('Time(s)');ylabel('Amplitude');
title(sprintf("  Si (%.2f–%.2f s)",t_start_si, t_end_si));

%ince do
t_start_do2 = 14.2 ; t_end_do2 = 16.2 ;
idx_do2 = (t >= t_start_do2) & (t <= t_end_do2);
subplot(4,2,8);
plot(t(idx_do2),x(idx_do2));
grid on;
xlabel('Time(s)');ylabel('Amplitude');
title(sprintf(" Do (%.2f–%.2f s)",t_start_do2, t_end_do2));


%% 4.2 (6) Rough Segmentation of Individual Notes

nota1 = x(idx_do); t_note_1 =t(idx_do)-t_start_do;
nota2 = x(idx_re); t_note_2 =t(idx_re)-t_start_re;
nota3 = x(idx_mi); t_note_3 =t(idx_mi)-t_start_mi;
nota4 = x(idx_fa); t_note_4 =t(idx_fa)-t_start_fa;
nota5 = x(idx_sol);t_note_5 =t(idx_sol)-t_start_sol;
nota6 = x(idx_la); t_note_6 =t(idx_la)-t_start_la;
nota7 = x(idx_si); t_note_7 =t(idx_si)-t_start_si;
nota8 = x(idx_do2); t_note_8 =t(idx_do2)-t_start_do2;


%% 4.2 (7) Frequency-Domain Analysis (Magnitude & Phase) of Each Note


my_notes = {nota1, nota2, nota3, nota4, nota5, nota6, nota7, nota8};

figure;
theme light;
sgtitle("Magnitude Spectra of Segmented Notes (Positive Frequencies)");

for k = 1:8
    xk = my_notes{k};

    % Remove DC and apply window to reduce spectral leakage
    xk = xk - mean(xk);
    Nk = length(xk);
    w  = hann(Nk);
    xk = xk .* w;

    % FFT
    Xk = fft(xk);
    f  = (0:Nk-1)*(Fs/Nk);          % frequency axis (Hz)

    % Use only positive frequencies up to Nyquist
    half = 1:floor(Nk/2);
    fpos = f(half);
    Xpos = Xk(half);

    mag = abs(Xpos)/Nk;
    mag_dB = 20*log10(mag + 1e-12);

    subplot(4,2,k);
    plot(fpos, mag_dB);
    grid on;
    xlim([0 4000]);                 % adjust if needed (e.g., [0 2000])
    xlabel("Frequency (Hz)");
    ylabel("Magnitude (dB)");
    title(sprintf("note%d - Magnitude", k));
end


figure;
theme light;
sgtitle("Phase Spectra of Segmented Notes (Positive Frequencies)");

for k = 1:8
    xk = my_notes{k};

    % Remove DC and apply window
    xk = xk - mean(xk);
    Nk = length(xk);
    w  = hann(Nk);
    xk = xk .* w;

    % FFT
    Xk = fft(xk);
    f  = (0:Nk-1)*(Fs/Nk);

    % Positive frequencies
    half = 1:floor(Nk/2);
    fpos = f(half);
    Xpos = Xk(half);

    % Phase (unwrap for smoother plot)
    ph = unwrap(angle(Xpos));

    subplot(4,2,k);
    plot(fpos, ph);
    grid on;
    xlim([0 600]);                 % adjust if needed
    xlabel("Frequency (Hz)");
    ylabel("Phase (rad)");
    title(sprintf("note%d - Phase", k));
end




%% 4.2 (8) Fundamental Frequency Estimation and Error Analysis

measured_f0 = zeros(8,1);

for k = 1:8
    xk = my_notes{k};
    Nk = length(xk);

    Xk = fft(xk);
    freq = (0:Nk-1) * (Fs/Nk);

    mag = abs(Xk)/Nk;

    % Use only 0..Fs/2
    L = round(Nk/2);
    freq_pos = freq(1:L);
    mag_pos  = mag(1:L);

    % --- Corrected search band for f0 ---
    % Fundamental is expected in a low-frequency band for these notes.
    fmin = 20;      % Hz (ignore DC / drift)
    fmax = 600;     % Hz (covers C4..C5 safely)
    idx_band = (freq_pos >= fmin) & (freq_pos <= fmax);

    % Find peak inside the band
    [~, idx_peak] = max(mag_pos(idx_band));
    freq_band = freq_pos(idx_band);

    measured_f0(k) = freq_band(idx_peak);
end

% Theoretical frequencies: C4 D4 E4 F4 G4 A4 B4 C5
theoretical_f0 = [261.63; 293.66; 329.63; 349.23; 392.00; 440.00; 493.88; 523.25];

error_percent = abs(measured_f0 - theoretical_f0) ./ theoretical_f0 * 100;

Note = (1:8).';
ResultsTable = table(Note, measured_f0, theoretical_f0, error_percent, ...
    'VariableNames', {'Note','Measured_Hz','Theoretical_Hz','Error_percent'});

disp(ResultsTable);


%% 4.3 (9.1) Filter Design


f0_2 = 293.68;     % measured fundamental of note2 (Hz)
Df  = 20;          % bandwidth half-width (Hz)

fc1 = f0_2 - Df;   % lower cutoff (Hz)
fc2 = f0_2 + Df;   % upper cutoff (Hz)

n = 4;             % filter order (start with 4)

Wn = [fc1 fc2] / (Fs/2);      % normalized cutoffs

[b2, a2] = butter(n, Wn, "bandpass");   % note2 filter

figure;
theme light;
freqz(b2, a2, 2048, Fs);
grid on;
title(sprintf("Note2 Band-pass Butterworth: %.1f–%.1f Hz (n=%d)", fc1, fc2, n));

y2 = filter(b2, a2, nota2);

soundsc(nota2, Fs); pause(length(nota2)/Fs + 0.2);
soundsc(y2, Fs);


%% 4.3 (9.2) Filtering and Comparative Analysis


% Apply the designed Note2 band-pass filter to the full recording
y_full = filter(b2, a2, x);

%% --- Time-domain comparison (overlay) ---
figure;
theme light;
plot(t, x, 'b'); hold on;
plot(t, y_full, 'Color', [0.8500 0.3250 0.0980]); % MATLAB orange
grid on;
xlabel("Time (s)");
ylabel("Amplitude");
title("Time-domain comparison (Original vs Filtered)");
legend("Original signal","Filtered signal (Note2 band-pass)");

%% --- Magnitude spectrum comparison (overlay, dB scale) ---
Nfull = length(x);

X = fft(x);
Y = fft(y_full);

freq = (0:Nfull-1) * (Fs/Nfull);
L = round(Nfull/2);

magX = abs(X)/Nfull;
magY = abs(Y)/Nfull;

magX_dB = 20*log10(magX + 1e-12);
magY_dB = 20*log10(magY + 1e-12);

figure;
theme light;
plot(freq(1:L), magX_dB(1:L), 'b'); hold on;
plot(freq(1:L), magY_dB(1:L), 'Color', [0.8500 0.3250 0.0980]);
grid on;
xlabel("Frequency (Hz)");
ylabel("Magnitude (dB)");
title("Magnitude spectrum comparison (Original vs Filtered)");
legend("Original signal","Filtered signal (Note2 band-pass)");
xlim([0 4000]);
ylim([-120 10]);


%% 4.3 (12) Listening test (Full recording)
disp("Playing ORIGINAL full recording...");
soundsc(x, Fs); pause(T + 0.3);

disp("Playing FILTERED full recording (Note2 band-pass)...");
soundsc(y_full, Fs); pause(T + 0.3);


