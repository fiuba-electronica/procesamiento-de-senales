function PM_LP

clc
clear
close all
% Diseniar un pasabajos por el algoritmo de PM y por la ventana de Kaiser y
% compararlos, con las siguientes especificaciones:

ws = pi/2;
wp = pi/3;
deltap = 0.01;
deltas = 0.005;

deltaw = abs(ws-wp);

Mapp = (-10*log10(deltap*deltas)-13)/(2.324 * deltaw)

vec = round(Mapp):round(Mapp)+2;

cols = {'r','m','b'};
    texto = {};
for n0 = 1:length(vec)
    
    
M = vec(n0);

%%
F = [0, wp/pi, ws/pi, 1];
A = [1, 1, 0, 0];

    
K = deltap/deltas;

h = firpm(M,F,A,[1, deltap/deltas]);

nfft = 1024;
H = fft(h, nfft);
H = H(1:nfft/2+1);
HdB = 20*log10(H);

omegan = 0:2/nfft:2*(nfft-1)/nfft;
omegan = omegan(1:nfft/2+1);


[nc, n1] = min(abs(wp-omegan));
delta1 = max(abs(H(1:n1)))-1;

[nc, n2] = min(abs(ws-omegan));
delta2 = max(abs(H(n2:end)));

figure(1)
subplot(2,1,1)
dBplotter(omegan,H,0,wp/pi,cols{n0})
hold on

subplot(2,1,2)
dBplotter(omegan,H,ws/pi,1,cols{n0})
hold on

figure(2)
hold on
dBplotter(omegan,H,0,1,cols{n0})    

texto = [texto, ['M = ' num2str(length(h)-1)]];
end

figure(1)
subplot(2,1,1)
title('Respuesta en la banda de paso')
plot([0, wp/pi], [20*log10(1+deltap), 20*log10(1+deltap)],'k--','linewidth',2)
plot([0, wp/pi], [20*log10(1-deltap), 20*log10(1-deltap)],'k--','linewidth',2)
legend(texto);

subplot(2,1,2)
title('Respuesta en la banda de rechazo')
plot([ws/pi,1], [20*log10(deltas), 20*log10(deltas)],'k--','linewidth',2)
% ylim([-80, -40])
legend(texto);

figure(2)
title('Respuesta de los filtros')
% ylim([-60, 1])
legend(texto)
end


function dBplotter(omegan,H,w1,w2,col)
[nc, n1] = min(abs(w1-omegan));
[nc, n2] = min(abs(w2-omegan));

HdB = 20*log10(abs(H));
plot(omegan(n1:n2),HdB(n1:n2),'linewidth',2,'color',col)

grid on
xlim([w1, w2])
xlabel('Frecuencia normalizada')
ylabel('Amplitud (dB)')
end

