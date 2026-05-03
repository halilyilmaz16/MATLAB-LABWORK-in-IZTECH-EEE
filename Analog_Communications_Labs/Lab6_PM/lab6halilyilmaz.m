%% introduction

fm = 100; %  message frequency fm = 100 Hz
Fs = 10000; % Sampling Frequency Fs = 10khz
Ts = 1/Fs; % Period
fc = 1000; % carrier frequency fc = 1khz
duration = 0.03 ; %  d = 30ms
t  = 0: Ts : duration -Ts ; % time vector
kp = 2*pi; % phase sensivitiy rad/V
kf = 1; %% frequency sensivity kp/2pi
message_signal = sawtooth(2*pi*fm*t+pi/2,1/2);

%% pm signal generation 

s_pm = cos(2*pi*fc*t + kp*message_signal); % a. signal PM

m_dif = diff(message_signal)*Fs; % b. 1
mdif = [0 m_dif];
m_tau = cumsum(mdif)*Ts; 

s_pm_with_fm = cos(2*pi*fc*t + 2*pi*kf*m_tau); % b.2 pm with fm

N = length(t);
f = linspace(-Fs/2,Fs/2,N);

s_pm_fdomain = abs(fftshift(fft(s_pm))/N);
s_pm_with_fm_fdomain = abs(fftshift(fft(s_pm_with_fm))/N);
% c. plot

figure

subplot(2,1,1);
plot(t,s_pm);
hold on 
plot(t,s_pm_with_fm,'--');
title('Time Domain: Direct PM vs PM via FM');
xlabel('Time(s)');ylabel('Amplitude');
xlim([0 0.03]); ylim([-1 1]);
legend('Direct PM','PM via FM');

subplot(2,1,2);
plot(f,s_pm_fdomain);
hold on
plot(f,s_pm_with_fm_fdomain,'--');
title('Frequency Domain:Direct PM via FM');
xlabel('Frequency (Hz)');ylabel('|S(f)|');
xlim([-5000 5000]); ylim([0 0.3]);
legend('Direct PM','PM via FM');




% d  Fm de integral alarak oluşturduğumuz için burada anlık frekansa
% bakıyoruz  fmdek integ(m) deki mesajımızı türevini alıyoruz


%% 1.3 PART 2 PM DEMOLUTİON

z_pm = hilbert(s_pm);
z_pm_viafm = hilbert(s_pm_with_fm);

theta_pm = unwrap(angle(z_pm));
theta_pm_viafm = unwrap(angle(z_pm_viafm));

mdemod_pm = (theta_pm-2*pi*fc*t)/kp;
mdemod_pm_viafm = (theta_pm_viafm-2*pi*fc*t)/kp;

figure 

plot(t,message_signal,Color="black",LineStyle="-",LineWidth=1.3);
hold on;
plot(t,mdemod_pm,Color="b",LineStyle="--",LineWidth=2);
hold on;
plot(t,mdemod_pm_viafm,Color="r",LineStyle=":",LineWidth=2);
title('PM Demodulation: Original vs Recovered');
xlabel('Time(s)');ylabel('Amplitude');
xlim([0 0.03]);ylim([-1 1]);
legend('Original m(t)','Demod (Direct PM)','Demod (PM via FM)');

% aşan -pi +pi  aşma durumlarında unwrapp fonksiyonu bu durumu düzenler













