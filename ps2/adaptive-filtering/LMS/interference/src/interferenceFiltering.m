close all;
clear all;

load('ECGSignal.mat');
load('NotchCoeff.mat');
load('PeakingCoeff60.mat');
load('PeakingCoeff70.mat');
load('LPCoeff.mat');

%ECG_signal1 = ECG_signal1(1:10000);
Fs = 8192;
largo = length(ECG_signal1);
n = 1:largo;
mitadLargo = largo/2;

%Ruido de 60 Hz
A = 1;
omega = 2*pi*60/Fs;
omega_70 = 2*pi*70/Fs;
tita = pi/4;
ruido_60hz = zeros(1,largo);
ruido_60hz(1:mitadLargo) = A*sin(omega*(1:mitadLargo)+tita);
ruido_60hz(mitadLargo+1:largo) = A*sin(omega_70*(mitadLargo+1:largo)+tita);

%Referencia
B = 0.1*A;
referencias = zeros(1,largo);
referencia(1:mitadLargo) = B*sin(omega*(1:mitadLargo));
referencia(mitadLargo+1:largo) = B*sin(omega_70*(mitadLargo+1:largo));

sigma_v = sqrt(1/200)*A;

SNRref_dB = 10*log(B^2/(2*sigma_v^2));
referencia = awgn(referencia,SNRref_dB,'measured');

%Ruido gaussiano aditivo

ruido_blanco = randn(1,length(ECG_signal1))*sigma_v;

%Señal total observada
observada = ECG_signal1+ruido_60hz+ruido_blanco;

%LMS
N=50;
w=zeros(N,1);
mu = 0.1;
filtrado = zeros(1,length(observada));
err = zeros(1,length(observada));
estim = zeros(1,length(observada));

%Filtrado de referencia
figure
plot(referencia);

referencia = filter(filtroLPNum, filtroLPDen, referencia);
%referencia = filter(filtroPeakingNum, filtroPeakingDen, referencia);
figure
plot(referencia);

%%

figure
hold all;
for i=N:length(observada)-N
    x = referencia(i-N+1:i)';
    d = observada(i);
    

    
    %for j=1:1
        e = observada(i) - x'*w;  
        w = w + mu*x*e;
    %end
    
    filtrado(i) = observada(i) - x'*w;
    err(i) = filtrado(i)-ECG_signal1(i);
    estim(i) = x'*w;
    if mod(i,100000) == 0
        %Rx_estimado = x*x';
        %Rxd_estimado = d*x;
        %Wopt = inv(Rx_estimado)*Rxd_estimado;
        
        plot(w);
       % plot(Wopt);
       pause(eps);
    end
end
%% 
figure('name','Estimación de interferencia');
title('Estimación de interferencia');
hold all;
plot(estim);
plot(ruido_60hz);

figure('name','Error de estimación de interferencia');
title('Error de estimación de interferencia');
hold all;
plot(estim-ruido_60hz);

%%
figure('name','Error de ECG estimada');
title('Error de ECG estimada');
hold all;
plot(err);
plot(err-ruido_blanco(1:length(err)));
%% Distancia entre señal original y filtrada
figure('name','Distancia entre ECG estimada y real');
title('Distancia entre ECG estimada y real');
hold all;
plot(abs(err-ruido_blanco(1:length(err))));

%%
figure('name','ECG real, señal observada y filtrada');
hold all;
title('ECG real, señal observada y filtrada');
plot(((1:length(filtrado)))/Fs, filtrado);
plot((1:length(observada))/Fs,observada);
plot((1:length(observada))/Fs,ECG_signal1);

%% Filtrado IIR
filtradaIIR = filter(filtroNotchNum, filtroNotchDen, observada);
figure('name','Señal filtrada con Notch IIR');
hold all;
title('Señal filtrada con Notch IIR');
plot(filtradaIIR);

figure('name','Error de señal filtrada con Notch IIR');
hold all;
title('Error de señal filtrada con Notch IIR');
plot(abs(filtradaIIR-ECG_signal1));

