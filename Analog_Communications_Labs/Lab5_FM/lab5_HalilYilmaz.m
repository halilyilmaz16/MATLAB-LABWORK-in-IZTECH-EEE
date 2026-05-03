%% 1.1 Frequency Modulation

% a. Construct a message signal
Fs = 1000;         % Sampling frequency 1khz
t = 0:1/Fs:0.5-1/Fs;    % Time duration
fc = 200;          % Carrier frequency
fm = 10;           % Modulating frequency
N = length(t);     % Nyquist Rate
     
m = sin(2*pi*fm*t); % message signal
dt = t(2)-t(1);
% b. Construct the frequency modulated signal

kf = 40;                           % frequency sensivity
int_m = cumsum(m)*dt;               % integration of message 
s = cos(2*pi*fc*t +2*pi*kf*int_m); % s(t)

% c. plot m(t) and s(t)

figure
subplot(2,1,1);
plot(t,m); % m(t)
title('Message Signal m(t)');
xlabel('Time(s)');
ylabel('Amplitude');
grid on;

subplot(2,1,2);
plot(t,s); % s(t) 
title(' Signal s(t)');
xlabel('Time(s)');
ylabel('Amplitude');
grid on;

% d. plot the magnitude response
 
f = (-N/2:N/2-1)*(Fs/N);     % frequency vector
m_mag = abs(fftshift(fft(m)));
s_mag = abs(fftshift(fft(s)));

figure
subplot(2,1,1);
plot(f,m_mag); % M(F)
title('Magnitude Spectrum of m(t)');
xlabel('Frequency (Hz)');
ylabel('|M(f)|');
grid on;

subplot(2,1,2);
plot(f,s_mag); % S(F) 
title(' Magnitude Spectrum of s(t)');
xlabel('Frequency (Hz)');
ylabel('|S(f)|');
grid on;
xlim([-500 500]);ylim([0 0.25]);

%% 1.2 Frequency Demodulation

delta_f = kf * max(abs(m));
f1 = fc + delta_f;
f2 = fc - delta_f;
BW = 140; % verilen
n_order = 4; % verilen

lower1 = f1 - BW/2;upper1 = f1 + BW/2;
lower2 = f2 - BW/2;upper2 = f2 + BW/2;

Wn1 = [lower1 upper1] / (Fs/2);
Wn2 = [lower2 upper2] / (Fs/2);

[b1, a1] = butter(n_order,Wn1,'bandpass');
[b2, a2] = butter(n_order,Wn2,'bandpass');

[H1,w] = freqz(b1,a1,1024,Fs);
[H2,w] = freqz(b2,a2,1024,Fs);

figure

plot(w,abs(H1));
hold on;
plot(w, abs(H2));
title('Magnitude Response of Bandpass Filters');
xlabel('Frequency (Hz)');
ylabel('Magnitude');
legend('BPF1', 'BPF2');
grid on;
hold off;

s_filtered_1 = filtfilt(b1,a1,s);
s_filtered_2 = filtfilt(b2,a2,s);

figure 

plot(t,s_filtered_1);
title('Output of BPF');
hold on 
plot(t,s_filtered_2);
xlabel('Time(s)');
ylabel('Amplitude');
legend('hpf_1(t)','hpf_2(t)');

%% 1.2.2 envelope detector design

env1 = abs(hilbert(s_filtered_1));
env2 = abs(hilbert(s_filtered_2));

% a. Plot the envelopes of the filtered signals
figure
plot(t, env1);
hold on
plot(t,env2);
title('Envelope Detector Outputs');
xlabel('Time (s)');
ylabel('Amplitude');
grid on;

%% 1.2.3 message recovery
f_cut = 2*fm;
Wn = f_cut/(Fs/2);
recov = (env1-env2) - mean(env1-env2);
Wn3 = 40/(Fs);
[b3, a3] =butter(n_order,Wn3,'low');
m_mod = filtfilt(b3, a3,recov);
m_mod = m_mod / max(abs(m_mod));

figure
plot(t,m);
hold on
plot(t,m_mod,'--');
title('Original and Recovered Message');
xlabel('Time (s)');
ylabel('Amplitude');
grid on;
xlim([0 0.5]);ylim([-1 1]);
legend('Original m(t)','Recovered m(t)');

%% 1.2.4 Delta Variation

delta_vals = [20 40 120];

figure

for k = 1:length(delta_vals)

    delta_f = delta_vals(k);

    % Center frequencies
    f1 = fc + delta_f;
    f2 = fc - delta_f;

    % Band-pass limits
    lower1 = f1 - BW/2; upper1 = f1 + BW/2;
    lower2 = f2 - BW/2; upper2 = f2 + BW/2;

    % Normalize
    Wn1 = [lower1 upper1] / (Fs/2);
    Wn2 = [lower2 upper2] / (Fs/2);

    % Band-pass filters
    [b1,a1] = butter(n_order, Wn1, 'bandpass');
    [b2,a2] = butter(n_order, Wn2, 'bandpass');

    % Filter outputs
    y1 = filtfilt(b1,a1,s);
    y2 = filtfilt(b2,a2,s);

    % Envelope detection
    e1 = abs(hilbert(y1));
    e2 = abs(hilbert(y2));

    % Message recovery
    recov = e1 - e2;
    recov = recov - mean(recov);

    [b3,a3] = butter(n_order, (2*fm)/(Fs/2), 'low');
    m_rec = filtfilt(b3,a3,recov);

    % Normalize
    m_rec = m_rec / max(abs(m_rec));

    % Plot
    subplot(3,1,k)
    plot(t,m,'LineWidth',1.2); hold on;
    plot(t,m_rec,'--','LineWidth',1.2);
    title(['Original and Recovered Message for \Delta = ', num2str(delta_f)]);
    xlabel('Time (s)');
    ylabel('Amplitude');
    grid on;
    xlim([0 0.5]);
    ylim([-1.2 1.2]);
    legend('Original m(t)','Recovered m(t)');
end