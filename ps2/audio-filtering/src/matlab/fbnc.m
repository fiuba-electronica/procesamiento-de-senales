clear all
close all
clc

%% Parametros
N = 400;        % Largo del filtro
D = 70;         % Delay       
lmsMU = 0.005;   % LMS mu
nlmsMU = 0.04;   % NLMS mu
f = 50;         % Frecuencia de la interferencia [Hz]
A = 1.25;       % Amplitud de la interferencia
epsilon = 0.01; % Parametro del NLMS para evitar divergencias

%% Vectores
w = zeros(N,1);
[data, fs] = audioread('./audio/audio001.mp3');
data = data(:,1);
error = zeros(1,length(data))';
n = 1:length(data);
interference = A*sin(2*pi*f*n/fs)';

input = data + interference;

%% Procesamiento
output1 = lms(N, D, error, input, w, lmsMU, error);
output2 = nlms(N, D, error, input, w, nlmsMU, error, epsilon);

audiowrite('./audio/audio.wav', input, fs);
audiowrite('./audio/fbnc_lms.wav', output1, fs);
audiowrite('./audio/fbnc_nlms.wav', output2, fs);