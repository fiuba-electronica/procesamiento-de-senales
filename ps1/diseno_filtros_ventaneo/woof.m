
clear
clc
close all

%% Ejemplo 3
%% Dise�ar un filtro tal que la ganancia sea unitaria cuando w < wp:
wp = pi*0.4;

% la ganancia sea 1/2 si w > ws:
ws = 0.5*pi;

% con un ripple maximo de 
deltad = 0.01;

% Como el salto es de 1/2, el ripple va a ser delta/2, entonces, dise�o
% para un ripple del doble:
delta = 2*deltad;
Deltaw = ws-wp;
omegac = (ws+wp)/2;

deltadB = 20 * log10(delta);

hid = @(n,M,omegac) 0.5*sinc(n-M/2) + 0.5*sinc(omegac/pi*(n-M/2))*omegac/pi;


%% Caso 1: ventana de Hann, que da -44dB en la ventana de paso
M1 = round((8*pi)/Deltaw);

% La ventana queda:
w1 = hanning(M1+1);

% El filtro ideal que vamos a ventanear es (sin factor de fase):
% 1{w<omegac}
n = 0:M1;

hid1 = hid(n,M1,omegac);
f1 = w1.'.*hid1;

%% Caso 2: ventana de Kaiser:
A = -deltadB;

betaK = @(A) (0.5842 *(A-21)^0.4 + 0.07886 *(A-21)) * (A>=21) * (A<=50) + ...
    0.1102 * (A-8.7) * (A>50);

MK = @(A) (A-8)/(2.285*Deltaw);

beta = betaK(A);
fprintf(['Beta de Kaiser es: %.2f\n'], beta)

M2 = MK(A);
fprintf(['M de Kaiser (redondeado hacia arriba) es: %.2f\n'], M2)
disp('M debe ser par porque el filtro es pasa alto');
M2 = floor(M2)+2;

n2 = 0:M2;

hid2 = hid(n2,M2,omegac);
w2 = kaiser(M2+1,beta);
% f2 = hid2;
f2 = w2.'.*hid2;
%% Grafico del filtro y los coeficientes
figure(1)
subplot(2,1,1)
hold off
plot(n,hid1)
hold on
plot(n,w1,'r')
stem(n,f1,'markerfacecolor','b')
legend('Filtro ideal truncado a ventanear','Ventana de Hann','Filtro obtenido por Hann')
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


% Grafico de la respuesta en modulo
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
% ylim([-100, 1])
grid on
legend(['Respuesta del filtro por Blackman - M=' num2str(M1)],...
    ['Respuesta por ventana de Kaiser - M=' num2str(M2)],...
    'location','northeast')
ylabel('Amplitud [dB]')
xlabel('Frecuencia normalizada')


%% Verificacion de la especificacion

maxpband1 = 20 * log10(1+deltad); %valor maximo en banda de paso 1
minpband1= 20 * log10(1-deltad); %valor minimo en banda de paso 1

maxpband2 = 20 * log10(.5+deltad); %valor maximo en banda de paso 2
minpband2 = 20 * log10(.5-deltad); %valor minimo en banda de paso 2

% Amplitudes en las bandas
figure(3)
subplot(2,1,1)
title('Respuesta en la banda de paso')
hold off
plot(omegan,20*log10(abs(F1)),'linewidth',2);
hold on
plot(omegan,20*log10(abs(F2)),'r','linewidth',2)
plot([0,wp/pi,wp/pi,0],[maxpband1,maxpband1,minpband1,minpband1],'k--','linewidth',2)
xlim([0, wp/pi*1.2])
ylim([1.2*minpband1, maxpband1*1.2])
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
plot([1, ws/pi,ws/pi, 1],[maxpband2,maxpband2,minpband2,minpband2],'k--','linewidth',2)
xlim([ws/pi*0.8, 1])
ylim([minpband2*1.1, maxpband2*0.9])
grid on
legend('Respuesta del filtro por Blackman','Respuesta por ventana de Kaiser','Tolerancias','location','northwest')
ylabel('Amplitud [dB]')
xlabel('Frecuencia normalizada')


