clear
close all
clc

% Seniales de entrada
frec1 = 2e3; % frec1 = 2kHz
frec2 = 4e3; % frec2 = 4kHz

%% Grafico de las seniales en tiempo continuo:
fsampcont = 1000e3; % muestreo cada 1us
t = 0:2000; % grafico 1ms
x1c = cos(2 * pi * frec1 * t/fsampcont);
x2c = cos(2 * pi * frec2 * t/fsampcont);
xc = x1c+x2c;

figure(1)
hold off
plot(t/1000,x1c,'linewidth',2)
hold on
plot(t/1000,x2c,'r','linewidth',2)
plot(t/1000,xc,'m-','linewidth',2)
grid on
xlabel('Tiempo (ms)');
ylabel('Amplitud')
legend('f_1=2kHz','f_1=4kHz','x(t) - Entrada')
title('Entrada al conversor A/D - x_1(t)+x_2(t)')


%% Seniales luego del muestreo
fsamp = 24e3; % sampling frequency >= 2 max(frec1, frec2);
Nmax = 24e3;
n = 0:Nmax; % Nmax / fsamp = total time
x1 = cos(2 * pi * frec1 * n/fsamp);
x2 = cos(2 * pi * frec2 * n/fsamp);
xd = x1 + x2;


figure(2)
plot(t(1:1000)*24/1000,xc(1:1000),'-.','linewidth',1)
hold on
stem(n(1:25),xd(1:25),'linewidth',2,'markerfacecolor','b')
xlabel('Tiempo discreto');
ylabel('Amplitud')
title('Senial de entrada muestreada - f_s = 24kHz')
grid on

%% Filtro en tiempo discreto, respuesta en frecuencia

b = [-0.5, 1];
a = [1, -0.5];
% fvtool(b,a)
yd = filter(b,a,xd);

figure(3)
stem(n(10:30),yd(10:30),'linewidth',2,'markerfacecolor','b')
xlabel('Amplitud')
ylabel('Tiempo discreto')
grid on
title('Señal discreta a la salida del sistema (100 muestras)')
axis tight

%% Retardo de fase del filtro pasa todo

H = @(z) (z.^(-1) - 1/2) ./ (1 - (2*z).^(-1));  % function handle/puntero
omega = linspace(0,pi,1e5);
phvec = angle(H(exp(1i*omega))); % fase, valor principal, no hay saltos

phdelay = -phvec./omega;
figure(4)
plot(omega/pi,phdelay,'linewidth',2)
ylabel('Retardo de fase (muestras)')
xlabel('Frecuencia normalizada (\times \pi radianes)')
title('Retardo del fase del sistema h[n]')
grid on
axis tight

%% Respuesta a las frecuencias separadas
y1 = filter(b,a,x1);
y2 = filter(b,a,x2);

figure(5)
subplot(2,1,1)
stem(n(10:20),x2(10:20),'-.','linewidth',2)
hold on
stem(n(10:20),y2(10:20),'rd','linewidth',2)
plot(n(10:20),x2(10:20),'-.','linewidth',1)
plot(n(10:20),y2(10:20),'r-.','linewidth',1)
axis tight
grid on
ylabel('Amplitud');
xlabel('Tiempo discreto');
title('Respuesta del sistema a la frecuencia f_2 - Retardo 2 muestras');
legend('Entrada de frecuencia f_2','Salida del sistema')

subplot(2,1,2)
stem(n(10:60),x1(10:60),'-.','linewidth',2)
hold on
stem(n(10:60),y1(10:60),'rd','linewidth',2)
plot(n(10:60),x1(10:60),'-.','linewidth',1)
plot(n(10:60),y1(10:60),'r-.','linewidth',1)
axis tight
grid on
ylabel('Amplitud');
xlabel('Tiempo discreto');
title('Respuesta del sistema a la frecuencia f_1 - Retardo 2.59 muestras');
legend('Entrada de frecuencia f_1','Salida del sistema')

%% Upsample de reconstrucción
upsampfact = 10; %% tengo fs * 10 muestras por segundo
nceros = 7; % cantidad de ceros del filtro sinc
hrec = sinc(linspace(-nceros,nceros,2*nceros*upsampfact+1)); % filtro de reconstruccion
fdelay = nceros*upsampfact+1 % retardo del filtro de salida 

% upsampling de la señal de salida
ydups = upsample(yd,upsampfact); % señal de salida con upsampling (agrega ceros)
yrec = filter(hrec,1,ydups); % señal que va al conversor D/A interpolador

% upsampling de la señal de entrada discretizada (para probar la
% reconstruccion)
xdups = upsample(xd,upsampfact);
xdrec = filter(hrec,1,xdups); % señal que va al conversor D/A interpolador


figure(6)
subplot(2,1,1)
plot(t/1000,xc,'linewidth',2) %% 1ms de la señal continua de entrada
hold on
plot(linspace(0,2,2*fsamp/1000*upsampfact),xdrec(fdelay:fdelay+2*fsamp/1000*upsampfact-1),'r','linewidth',2)
title('Señal de entrada continua y su reconstruccion (se eliminó el retardo del filtro de upsampling)')
xlabel('t (ms)')
ylabel('Amplitud')
legend('Señal continua de entrada', 'Señal reconstruida');
grid on
ylim([-1.5,2.1])
subplot(2,1,2)
plot(linspace(0,2,2*fsamp/1000*upsampfact),yrec(fdelay:fdelay+2*fsamp/1000*upsampfact-1),'r','linewidth',2)
title('Señal de salida reconstruida por el conversor DA (se eliminó el retardo del filtro de upsampling)')
grid on
xlabel('t (ms)')
ylabel('Amplitud')
