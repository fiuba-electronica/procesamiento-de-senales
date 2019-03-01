
clear
clc
close all

%% Ejemplo 2
%% Hallar un filtro pasa altos con:
wp = pi*.8;
ws = pi*.6;
deltap = 0.005;
deltas = 0.0005;

Deltaw = abs(wp-ws);
omegac = (ws+wp)/2;
 
% delta en dB. Trabajamos con el minimo porque el ripple es simetrico
deltadB = 20 * log10(min(deltap,deltas))

% Filtro pasaltos que vamos a ventanear
hid = @(n,M,omegac) sinc(n-M/2) - sinc(omegac/pi*(n-M/2))*omegac/pi;

%% Caso 1: ventana de Blackman, que da -74dB de sobre pico
M1 = round((12*pi)/Deltaw);

fprintf('\n\n1) Ventana de Blackman:\n\n')
fprintf('El orden del filtro por ventana de Blackman es: %d\n\n',M1)

% La ventana queda:
w1 = blackman(M1+1);

% El filtro ideal que vamos a ventanear es (sin factor de fase):
% 1{w<omegac}
n = 0:M1;

hid1 = hid(n,M1,omegac); % filtro ideal a ventanar (ya truncado al largo)
f1 = w1.'.*hid1; % filtro diseñado

%% Caso 2: ventana de Kaiser:
A = -deltadB;

% funcion beta de Kaiser
betaK = @(A) (0.5842 *(A-21)^0.4 + 0.07886 *(A-21)) * (A>=21) * (A<=50) + ...
    0.1102 * (A-8.7) * (A>50);

% funcion para estimar el orden Kaiser
MK = @(A) (A-8)/(2.285*Deltaw);

beta = betaK(A);

fprintf('\n\n2) Ventana de Kaiser:\n\n')

fprintf(['Beta de Kaiser es: %.2f\n'], beta)

M2 = MK(A);
fprintf(['M de Kaiser es: %.2f\n'], M2)

fprintf('Como el filtro es pasa altos, debemos tomar M par (filtro tipo I)')
M2 = floor(MK(A)); 

fprintf('\nTomamos M= %d \t(podria ser un valor mayor tb\n\n)',M2);
n2 = 0:M2;

hid2 = hid(n2,M2,omegac);
w2 = kaiser(M2+1,beta);
f2 = w2.'.*hid2;

%% Grafico de los filtros diseñados
figure(1)
subplot(2,1,1)
hold off
plot(n,hid1)
hold on
plot(n,w1,'r')
stem(n,f1,'markerfacecolor','b')
legend('Filtro ideal truncado a ventanear','Ventana de Blackman','Filtro obtenido por Blakckman')
grid on
xlabel('Tiempo discreto')
ylabel('Amplitud')

subplot(2,1,2)
hold off
plot(n2,hid2)
hold on
plot(n2,w2,'r')
stem(n2,f2,'markerfacecolor','b')
legend('Filtro ideal truncado a ventanear','Ventana de Kaiser','Filtro obtenido por Kaiser')
grid on
xlabel('Tiempo discreto')
ylabel('Amplitud')

%% Grafico de la respuesta en modulo
nfft = 1024;
omegan = 0:2/nfft:2*(nfft-1)/nfft;
F1 = fft(f1,nfft);
F2 = fft(f2,nfft);
F1 = F1(1:nfft/2+1);
F2 = F2(1:nfft/2+1);
omegan = omegan(1:nfft/2+1);

figure(2)
hold off
plot(omegan,20*log10(abs(F1)),'linewidth',2);
hold on
plot(omegan,20*log10(abs(F2)),'r','linewidth',2)
axis tight
ylim([-100, 1])
grid on
legend(['Respuesta del filtro por Blackman - M=' num2str(M1)],...
    ['Respuesta por ventana de Kaiser - M=' num2str(M2)],...
    'location','northwest')
ylabel('Amplitud [dB]')
xlabel('Frecuencia normalizada')


%% Verificacion de la especificacion
maxpband = 20 * log10(1+min(deltap,deltas)); %valor maximo en banda de paso
minpband = 20 * log10(1-min(deltap,deltas)); %valor minimo en banda de paso

figure(3)
subplot(2,1,1)
title('Respuesta en la banda de paso')
hold off
plot(omegan,20*log10(abs(F1)),'linewidth',2);
hold on
plot(omegan,20*log10(abs(F2)),'r','linewidth',2)
plot([1,wp/pi,wp/pi,1],[maxpband,maxpband,minpband,minpband],'k--','linewidth',2)
xlim([wp/pi*0.8, 1])
ylim([1.2*minpband, maxpband*1.2])
grid on
legend('Respuesta del filtro por Blackman','Respuesta por ventana de Kaiser','Tolerancias','location','northwest')
ylabel('Amplitud [dB]')
xlabel('Frecuencia normalizada')

subplot(2,1,2)
title('Respuesta en la banda de atenuacion')
hold off
plot(omegan,20*log10(abs(F1)),'linewidth',2);
hold on
plot(omegan,20*log10(abs(F2)),'r','linewidth',2)
plot([0,ws/pi,ws/pi],[deltadB,deltadB,-130],'k--','linewidth',2)
xlim([0, ws/pi*1.2])
ylim([-130,deltadB*0.8])
grid on
legend('Respuesta del filtro por Blackman','Respuesta por ventana de Kaiser','Tolerancias','location','northwest')
ylabel('Amplitud [dB]')
xlabel('Frecuencia normalizada')