%% parameters
fs = 125;
t = 0:1/125:10;
%N = length(t); %  Powered by Ai
idx1 =  (t >= 0) & (t<=5) ;
idx2 = ( t > 5) & ( t <= 10) ;
%% signal

x1 = 10*sin(2*pi*0.1*t);
x2 = cos(2*pi*20*t);
x_a05 = 4*cos(2*pi*2*t(idx1));
x_a510 = 2*cos(2*pi*10*t(idx2));
x1_a2 = [x_a05 x_a510];
x = x1 + x1_a2 ;
y1 = x .* x2;

%% plot
 % 1.1c
figure;
subplot(2,1,1);
title(' Part 1.1.c');
plot(t,x);
xlabel('Time(s)');
ylabel('x(t)');
grid on;
subplot(2,1,2);
title(' Part 1.1.c');
plot(t,y1);
xlabel('Time(s)');
ylabel('y_1(t)');
grid on;

N1 = length(x);
x_fft = fft(x,N1);
x_fft_sh = fftshift(x_fft);

N2 = length(y1);
y1_fft = fft(y1, N1);
y1_fft_sh = fftshift(y1_fft);

fre1 = (-N1/2:N1/2-1)*(fs/N1);
fre2 = (-N2/2:N2/2-1)*(fs/N2);

%% !!!!!!!!!!!! N1 = N2 = length(t)

figure;
subplot(211);
plot(fre1, abs(x_fft_sh)/N1, "r");
xlabel("f (Hz)"); ylabel("|X(f)|");
subplot(212);
plot(fre2, abs(y1_fft_sh)/N2, "r");
xlabel("f (Hz)"); ylabel("|Y(f)|");

%%  1.2.b 
 x2_fft = fft(x2,N1);
 y2_fft = x_fft .* x2_fft;
 y2_fft_sh = fftshift(y2_fft);

 figure;
 plot(fre1,abs(y2_fft_sh)/(2*N1));
 xlabel("f(Hz)");ylabel("|Y_2(f)|");
 grid on;

 
%% 1.2.c
N = length(x) + length(x2) - 1;

X = fft(x, N);
X2 = fft(x2, N);

Y2 = X .* X2;

y2_time_ifft = ifft(Y2);
y2_time_conv = conv(x, x2);

t_conv = (0:N-1)/fs;

figure;
subplot(2,1,1);
plot(t_conv, real(y2_time_ifft), "r");
xlabel("Time(s)");
ylabel("Y_2 ifft");
grid on;
title("Linear convolution via FFT");

subplot(2,1,2);
plot(t_conv, y2_time_conv, "b");
xlabel("Time(s)");
ylabel("Y_2 conv");
grid on;
title("Linear convolution via conv");