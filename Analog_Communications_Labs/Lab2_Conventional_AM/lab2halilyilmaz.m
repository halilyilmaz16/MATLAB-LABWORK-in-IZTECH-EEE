clc;
clear;
close all;

%% Parameters
A1 = 1;
A2 = 2;
Ac = 2;

f1 = 10;
f2 = 15;
fc = 500;

Fs = 4000;
T = 0.4;

t = 0:1/Fs:T-1/Fs;
N = length(t);

% parametreleri oluşturduk


%% Message and carrier signals
m = A1*sin(2*pi*f1*t) + A2*sin(2*pi*f2*t);
c = Ac*sin(2*pi*fc*t);

%% Plot message signal
figure;
plot(t, m, 'LineWidth', 1.2);
grid on;
xlabel('Time (s)');
ylabel('m(t)');
title('Message Signal m(t)');

%% AM modulation for ka = 0.2 and ka = 0.6
ka1 = 0.2;
ka2 = 0.6;

s1 = Ac * (1 + ka1*m) .* cos(2*pi*fc*t);
s2 = Ac * (1 + ka2*m) .* cos(2*pi*fc*t);

figure;
subplot(2,1,1);
plot(t, s1, 'LineWidth', 1.1);
grid on;
xlabel('Time (s)');
ylabel('s_1(t)');
title('AM Signal for k_a = 0.2');

subplot(2,1,2);
plot(t, s2, 'LineWidth', 1.1);
grid on;
xlabel('Time (s)');
ylabel('s_2(t)');
title('AM Signal for k_a = 0.6');

%% FFT of modulated signals
S1 = fftshift(abs(fft(s1, N))/N); %%fft atıyor N =len(t) sonra abs kaydırma bölü N
S2 = fftshift(abs(fft(s2, N))/N);
f = (-N/2:N/2-1)*(Fs/N); % t ->len(x)->-1/2:1/2-1 -> Fs/N t->f fourier donuşumu

figure;
subplot(2,1,1);
plot(f, S1, 'LineWidth', 1.1);
grid on;
xlabel('Frequency (Hz)');
ylabel('|S_1(f)|');
title('Magnitude Spectrum of s_1(t), k_a = 0.2');
xlim([-700 700]);

subplot(2,1,2);
plot(f, S2, 'LineWidth', 1.1);
grid on;
xlabel('Frequency (Hz)');
ylabel('|S_2(f)|');
title('Magnitude Spectrum of s_2(t), k_a = 0.6');
xlim([-700 700]);

%% Square-Law Envelope Detector
% Step a: square the modulated signals
sq1 = s1.^2;
sq2 = s2.^2;

% Step b: construct 5th-order LPF using butter()
% Highest message frequency = 15 Hz, so cutoff can be chosen slightly above it
fcut = 30;                     % proper cutoff frequency
Wn = fcut/(Fs/2);              % normalized cutoff frequency
[b, a] = butter(5, Wn, 'low');  % filtreyi tasarladık

% hazır verilen cutofu normalize etmemiz gerekiyor örneklememızle

% Step c: apply LPF and take square root
lpf1 = filter(b, a, sq1); %filtreyi uyguladık
lpf2 = filter(b, a, sq2);

% avoid numerical issues before sqrt
lpf1(lpf1 < 0) = 0; % değer sıfırdan küçükse  0 ver kök içinde
lpf2(lpf2 < 0) = 0;

m1_prime = sqrt(lpf1); % s lerin karekökü aldık
m2_prime = sqrt(lpf2);

% Step d: convert m'(t) to estimated message signal m''(t)
% From derivation:
% m'(t) = (Ac/sqrt(2)) * (1 + ka*m(t))
% => m(t) = (sqrt(2)/Ac * m'(t) - 1)/ka

m1_est = ((sqrt(2)/Ac) * m1_prime - 1) / ka1;
m2_est = ((sqrt(2)/Ac) * m2_prime - 1) / ka2;

%% Step e: plot original and estimated message on same axis
figure;
plot(t, m, 'LineWidth', 1.5);
hold on;
plot(t, m1_est, '--', 'LineWidth', 1.2);
grid on;
xlabel('Time (s)');
ylabel('Amplitude');
title('Original Message and Estimated Message for k_a = 0.2');
legend('m(t)', 'm''''(t)');

figure;
plot(t, m, 'LineWidth', 1.5);
hold on;
plot(t, m2_est, '--', 'LineWidth', 1.2);
grid on;
xlabel('Time (s)');
ylabel('Amplitude');
title('Original Message and Estimated Message for k_a = 0.6');
legend('m(t)', 'm''''(t)');

%% Modulation index mu = 1
% mu = ka * mp
% Peak of message signal:
mp = A1 + A2;   % maximum possible peak = 3

ka_mu1 = 1/mp;  % mu = 1
mu = ka_mu1 * mp;

s_mu1 = Ac * (1 + ka_mu1*m) .* cos(2*pi*fc*t);

figure;
plot(t, s_mu1, 'LineWidth', 1.1);
grid on;
xlabel('Time (s)');
ylabel('s_{\mu=1}(t)');
title(['AM Signal for \mu = 1, k_a = ', num2str(ka_mu1)]);

%% Demodulation for mu = 1 case
sq_mu1 = s_mu1.^2;
lpf_mu1 = filter(b, a, sq_mu1);
lpf_mu1(lpf_mu1 < 0) = 0;
m_mu1_prime = sqrt(lpf_mu1);
m_mu1_est = ((sqrt(2)/Ac) * m_mu1_prime - 1) / ka_mu1;

figure;
plot(t, m, 'LineWidth', 1.5);
hold on;
plot(t, m_mu1_est, '--', 'LineWidth', 1.2);
grid on;
xlabel('Time (s)');
ylabel('Amplitude');
title('Original and Estimated Message for \mu = 1');
legend('m(t)', 'm''''(t)');

%% Display results
fprintf('Peak message signal mp = %.2f\n', mp);
fprintf('ka for mu = 1 is %.4f\n', ka_mu1);
fprintf('Modulation index for ka1 = 0.2 --> mu = %.2f\n', ka1*mp);
fprintf('Modulation index for ka2 = 0.6 --> mu = %.2f\n', ka2*mp);