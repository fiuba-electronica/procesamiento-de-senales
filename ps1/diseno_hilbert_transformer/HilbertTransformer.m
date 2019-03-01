close all;
clear all;

%El transformador de Hilbert deberá ser implementado como un filtro
%tipo 3 o 4, para poder desplazar a la fase en pi/2.
%Debido a que para el filtro completo es necesario un retardo de N/2 = Tau_G
%se decide utilizar el tipo 3 (N par), para de esa forma no requerir un retardo fraccionario.
%Al ser de tipo 3, también se logra que la mitad de los coeficientes valgan cero (reduciendo un posible costo de implementación)
%La desventaja es que aparece un cero en pi, por lo que atenuaría un poco a las frecuencias altas de la señal. En este caso
%influye poco por ser el ancho de banda de las señales aproximadamente 4KHz.
ripple = 0.01;

%Para elegir la frecuencia de transición inferior, se observó que casi todos los archivos de audio tienen poco o nulo contenido
%por debajo de esa frecuencia.
omega_inf = 200/8e3; %Normalizado (1 es PI)

%Para la frecuencia superior, se eligió la opuesta (pi-omega_inf). Si se desea hacer un filtro muy asimétrico (por ejemplo omega_sup=7/8), el algoritmo
%de Parks-McClellan hace cosas extrañas: no converge o converge a una solución 
%cuya respuesta en frecuencia toma valores muy grandes en la banda de transición superior.
omega_sup = 1-omega_inf;

%------------Equiripple-------------

idx = 0;
%Debido a la construcción con tipo 3, aumentar el orden en dos no siempre lleva a un filtro distinto.
%Esto es porque la respuesta al impulso tiene ceros en la mitad de las posiciones, por lo que aumentar N en dos
%solamente agrega esos ceros en el borde, siendo un filtro con misma respuesta en frecuencia (pero peor retardo de grupo)
for N = 90:4:98;
	%Calculamos coeficientes del filtro usando el algoritmo de Parks-McClellan.
	%El argumento 'hilbert' hace que cree filtros antisimétricos (Tipo 3 y 4)
	%La banda de paso tiene módulo 1, mientras que el resto queda como transición
	%Siendo una única banda, el peso elegido no influye en el filtro.
	h = firpm(N,[omega_inf omega_sup],[1 1],[1],'hilbert');
	
	figure(1)
	subplot(2,1,1);
	hold on
	stem(0:N,h); %Graficamos la respuesta al impulso

	N_FFT = 2048;
	h_f = fft(h, N_FFT); %Calculamos la respuesta en frecuencia (muestreada en N_FFT puntos)
	h_f = h_f(1:N_FFT/2+1); %Nos quedamos con la parte baja: 0-PI de la respuesta (incluyendo el PI)
	i=0:length(h_f)-1; %Indices para graficar

	figure(2)
	subplot(2,1,1);
	hold on
	plot(i/length(h_f),abs(h_f(i+1))); %Graficamos la respuesta en frecuencia (se le suma 1 al indice para acceder a la posición correcta)

	figure(3)
	subplot(2,1,1);
	hold on
	plot(i/length(h_f),abs(h_f(i+1)));
	
	figure(4)		%Graficamos la fase
	subplot(2,1,1);
	hold on
	plot(i/length(h_f),unwrap(angle(h_f(i+1)))/pi);

	idx = idx + 1;
	leyenda{1}{idx}=['Equiripple N=', num2str(N)];
end

%------------Least-squares-------------

idx = 0;
%Nuevamente, aumentar el orden en dos no siempre lleva a un filtro distinto.
%En este caso la mitad de las posiciones no valen exactamente cero (~<1e-6), posiblemente por trabajar con precisión finita.
for N = 90:4:98;
	%Calculamos coeficientes del filtro usando el método de Cuadrados mínimos.
	%El argumento 'hilbert' hace que cree filtros antisimétricos (Tipo 3 y 4)
	%La banda de paso tiene módulo 1, mientras que el resto queda como transición
	%Siendo una única banda, el peso elegido no influye en el filtro.
	h = firls(N,[omega_inf omega_sup],[1 1],[1],'hilbert');
	
	figure(1)
	subplot(2,1,2);
	hold on
	stem(0:N,h); %Graficamos la respuesta al impulso

	N_FFT = 2048;
	h_f = fft(h, N_FFT); %Calculamos la respuesta en frecuencia (muestreada en N_FFT puntos)
	h_f = h_f(1:N_FFT/2+1); %Nos quedamos con la parte baja: 0-PI de la respuesta (incluyendo el PI)
	i=0:length(h_f)-1; %Indices para graficar

	figure(2)
	subplot(2,1,2);
	hold on
	plot(i/length(h_f),abs(h_f(i+1))); %Graficamos la respuesta en frecuencia (se le suma 1 al indice para acceder a la posición correcta)

	figure(3)
	subplot(2,1,2);
	hold on
	plot(i/length(h_f),abs(h_f(i+1)));
	
	figure(4)		%Graficamos la fase
	subplot(2,1,2);
	hold on
	plot(i/length(h_f),unwrap(angle(h_f(i+1)))/pi);

	idx = idx + 1;
	leyenda{2}{idx}=['Least-squares N=', num2str(N)];
end

%------------Formatos de gráficos-------------

for subgrafico=1:2
	%Formato del gráfico 1 (rta. impulsiva)
	figure(1);
	subplot(2,1,subgrafico);
	grid on;
	xlim([0, N]);
	xlabel('n');
	ylabel('Amplitud');
	title('Respuesta al impulso');
	legend(leyenda{subgrafico},'Location','Southwest');

	%Formato del gráfico 2 (rta. en frecuencia: módulo)
	figure(2);
	subplot(2,1,subgrafico);
	plot([0, 1],[1-ripple, 1-ripple],'k--','linewidth',1);
	plot([0, 1],[1+ripple, 1+ripple],'k--','linewidth',1);
	grid on;
	xlim([0, 1]);
	xlabel('Frecuencia normalizada');
	ylabel('Amplitud');
	title('Respuesta en frecuencia: modulo');
	legend(leyenda{subgrafico},'Location','Southwest');

	%Formato del gráfico 3 (rta. en banda paso)
	figure(3);
	subplot(2,1,subgrafico);
	plot([0, 1],[1-ripple, 1-ripple],'k--','linewidth',1);
	plot([0, 1],[1+ripple, 1+ripple],'k--','linewidth',1);
	grid on;
	xlim([omega_inf, omega_sup]);
	xlabel('Frecuencia normalizada');
	ylabel('Amplitud');
	title('Respuesta en banda de paso');
	legend(leyenda{subgrafico},'Location','Southwest');

	%Formato del gráfico 4 (rta. en frecuencia: fase)
	figure(4);
	subplot(2,1,subgrafico);
	grid on;
	xlim([0, 1]);
	xlabel('Frecuencia normalizada');
	ylabel('Fase normalizada');
	title('Respuesta en frecuencia: fase');
	legend(leyenda{subgrafico},'Location','Southwest');
end

%------------Implementación del filtro completo-------------

%Se observó que el filtro que cumple las especificaciones con menor orden es el Equiripple (con N=94).
%Sin embargo, el filtro siguiente (N=98) de los diseñados con el método de Least-squares tiene un mejor comportamiento en la banda de paso,
%distorsionando menos en amplitud a la señal, aunque requiere dos coeficientes no nulos extra, e impondría un mayor retardo al sistema.

%Filtro elegido:
N_FINAL = 94;
h = firpm(N_FINAL,[omega_inf omega_sup],[1 1],[1],'hilbert');

ARCHIVO_ENTRADA = 'int_wav.wav';

[y,fs] = audioread(ARCHIVO_ENTRADA);
y = y(:,1)'; %Usamos solo el primer canal, transponemos para que quede en forma de columna

n=1:length(y);

%--omega_r = 4100*2*pi/fs; %Frecuencia (discreta) sobre la cual se quiere hacer la reflexión
omega_r = 10000*2*pi/fs; %Frecuencia (discreta) sobre la cual se quiere hacer la reflexión

%En la rama superior, se desplaza en N/2, teniendo cuidado de no indexar un índice menor o igual a cero. Esto se hace con la función max, que
%termina "repitiendo" la primera muestra hasta que se acabe el retardo deseado. Si no es cero, puede introducir alguna distorsion en la primeras N/2 muestras de la salida.
%En la rama inferior, se convoluciona la respuesta al impulso del filtro diseñado con la entrada. 
%En ambos casos se multiplica (término a término) con los términos trigonométricos correspondientes.

%Se verificó que los desplazamientos fueran correctos usando un impulso como entrada (y(n)=0, y(500)=1)
%y graficando dos canales los términos (sin el producto por seno y coseno): https://dl.dropboxusercontent.com/u/2470403/psi_rta.png
y_salida_1 = y(max(1, n-N_FINAL/2)).*cos(omega_r.*n); %Rama superior del filtro
y_salida_2 = conv(h,y(1:length(y)-N_FINAL)).*sin(omega_r.*n); %Rama inferior del filtro

y_salida = y_salida_1 + y_salida_2;

audiowrite('outputs/salida.wav', y_salida, fs);

%------------Gráficos de espectro de la entrada y salida------------

y_f = fft(y); %Calculamos la FFT de la señal de entrada
y_f = y_f(1:length(y_f)/2+1); %Nos quedamos con la parte baja: 0-PI de la respuesta (incluyendo el PI)
i=0:length(y_f)-1; %Indices para graficar
figure(5)
subplot(2,1,1);
plot(i/length(y_f),20*log10(abs(y_f)./length(y_f))); %Graficamos el espectro de la señal de entrada

ys_f = fft(y_salida); %Calculamos la FFT de la señal de salida
ys_f = ys_f(1:length(ys_f)/2+1); %Nos quedamos con la parte baja: 0-PI de la respuesta (incluyendo el PI)
i=0:length(ys_f)-1; %Indices para graficar
figure(5)
subplot(2,1,2);
hold on

nespejo = length(ys_f) * omega_r/pi;
plot((nespejo-i)/length(y_f),20*log10(abs(y_f)./length(y_f))); %Graficamos el valor esperado del espectro (omega' = wc - omega)

plot(i/length(ys_f),20*log10(abs(ys_f)./length(ys_f))); %Graficamos el espectro de la señal de salida

subplot(2,1,1);
grid on;
xlim([0, 1]);
ylim([-125, 0]); %Las entradas son de 16 bits pero tienen componentes espectrales con amplitudes menores a 96 dB.
%Usando dithering se pueden representar tonos con amplitudes menores a un bit.
xlabel('Frecuencia normalizada');
ylabel('Amplitud relativa [dB]');
title('Espectro de entrada');

subplot(2,1,2);
grid on;
xlim([0, 1]);
ylim([-125, 0]); 
xlabel('Frecuencia normalizada');
ylabel('Amplitud relativa [dB]');
title('Espectro de salida');
legend('Esperado','Calculado','Location','Northeast');