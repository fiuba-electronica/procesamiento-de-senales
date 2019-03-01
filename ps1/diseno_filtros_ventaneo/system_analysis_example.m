


close all
h = 1-(0:5)/5;
%h = [-2.3539   -1.0618    0.5868   -1.5788    1.2345   -0.1211   -0.0222    0.0311   -1.1218   -1.6889]
nffth = 1024;
H = fft(h,nffth);  % Fft con mas puntos para mas resolucion
Hdb = 20 * log10(abs(H));
% frecuencia normalizada de 0 a 2*(N-1)/N;
nfrecs = linspace(0,2*(nffth-1)/nffth,nffth); 

% Respuesta impulsiva y modulo de la respuesta en frecuencia
figure(1)
subplot(2,1,1) % respuesta impulsiva
stem(0:length(h)-1,h,'markerfacecolor','b','markersize',8)
xlabel('Tiempo (discreto)');
ylabel('Amplitud');
subplot(2,1,2) % modulo de la transferencia
plot(nfrecs(1:nffth/2+1),Hdb(1:nffth/2+1),'linewidth',2)
grid on
ylabel('Magnitud (dB)');
xlabel('Frecuencia normalizada (\times\pi rad/muestra)')
xlim([0,1])


%%
% Fase y retardo de grupo
phvec = angle(H);
temp = diff(phvec);
vector = cumsum([0 2*pi *( (temp < -pi) - (temp>pi))]);
unwrappedphase =  phvec + vector;

figure(2)
subplot(3,1,1) % fase de la transferencia
plot(nfrecs(1:(nffth/2+1)),phvec(1:(nffth/2+1)),'linewidth',2)
grid on
ylabel('Fase (radianes)')
xlabel('Frecuencia normalizada (\times\pi rad/muestra)')

xlim([0,1])
subplot(3,1,2) % fase de la transferencia
plot(nfrecs(1:(nffth/2+1)),unwrappedphase(1:(nffth/2+1)),'r','linewidth',2)
grid on
ylabel('Fase extendida (radianes)')
xlabel('Frecuencia normalizada (\times\pi rad/muestra)')
xlim([0,1])

subplot(3,1,3) % retardo de grupo
%calculo por diferencia directa de la fase
gdelay = -diff(unwrappedphase)/(nfrecs(2)-nfrecs(1))/pi;
plot(nfrecs(1:(nffth/2+1)) +nfrecs(2)/2,gdelay(1:(nffth/2+1)))
grid on
hold on
% calculo por relacion con la fft
nffth2 = 128;
nfrecs2 = linspace(0,2,nffth2); % frecuencia normalizada
gdelay2 = real(fft(h.*(0:length(h)-1),nffth2) ./ fft(h,nffth2));
plot(nfrecs2(1:(nffth2/2+1)) ,gdelay2(1:(nffth2/2+1)) ,'dr')
xlim([0,1])
ylabel('Retardo de grupo (en muestras)')
xlabel('Frecuencia normalizada (\times\pi rad/muestra)')
legend('Estimación por derivada de la fase','Estimación por FFT')