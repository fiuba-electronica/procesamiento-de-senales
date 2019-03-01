clear all
close all
clc

%% Parametros
N = 400;        % Largo del filtro
D = 22;         % Delay       
lmsMU = 0.003;  % LMS mu
nlmsMU = 0.05;  % NLMS mu
f = 50;         % Frecuencia de la interferencia [Hz]
A = 1.25;       % Amplitud de la interferencia
epsilon = 0.01; % Parametro del NLMS para evitar divergencias

%% Vectores
w = zeros(N,1);
[data, fs] = audioread('./audio/audio001.mp3');
data = data(:,1);
error = zeros(1,length(data));
n = 1:length(data);
interference = A*sin(2*pi*f*n/fs)';

input = data + interference;

%% Procesamiento
[output1, w] = 1.1*lms(N, D, input, input, w, lmsMU, error);
[output2, w] = nlms(N, D, input, input, w, nlmsMU, error, epsilon);

audiowrite('./audio/audio002.wav', input, fs);
audiowrite('./audio/apnc_audio001.wav', output1, fs);
audiowrite('./audio/apnc_audio002.wav', output2, fs);