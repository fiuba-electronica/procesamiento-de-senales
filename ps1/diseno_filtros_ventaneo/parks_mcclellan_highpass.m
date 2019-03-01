function PM_HP

clc
clear
close all
% Diseniar un pasabajos por el algoritmo de PM y por la ventana de Kaiser y
% compararlos, con las siguientes especificaciones:

ws = pi*0.7;
wp = pi*0.8;
deltap = 0.01;
deltas = 0.005;

deltaw = abs(ws-wp);

Mapp = (-10*log10(deltap*deltas)-13)/(2.324 * deltaw)+1

vec = [floor(Mapp),floor(Mapp)+1];

cols = {'r','m','b'};
texto = {};    
for n0 = 1:length(vec)
    
    
M = vec(n0);

%%
F = [0, ws/pi, wp/pi, 1];
A = [0,0, 1, 1];
   

h = firpm(M,F,A,[1, deltas/deltap]);

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
subplot(2,1,1) % banda de paso
dBplotter(omegan,H,wp/pi,1,cols{n0})
hold on

subplot(2,1,2) % banda de rechazo
dBplotter(omegan,H,0,ws/pi,cols{n0})
hold on

figure(2)
hold on
dBplotter(omegan,H,0,1,cols{n0})

figure(3)
hold on
stem(0:length(h)-1,h,'color',cols{n0})
xlabel('Tiempo discreto')
ylabel('Amplitud')

% Leyenda del grafico
texto = [texto, ['M = ' num2str(length(h)-1)]];
end



figure(1)
subplot(2,1,1)
title('Respuesta en la banda de paso')
plot([wp/pi,1], [20*log10(1+deltap), 20*log10(1+deltap)],'k--','linewidth',2)
plot([wp/pi,1], [20*log10(1-deltap), 20*log10(1-deltap)],'k--','linewidth',2)
legend(texto);

subplot(2,1,2)
title('Respuesta en la banda de rechazo')
plot([0,ws/pi], [20*log10(deltas), 20*log10(deltas)],'k--','linewidth',2)
ylim([-80, -40])
legend(texto);

figure(2)
title('Respuesta de los filtros')
ylim([-60, 1])
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

