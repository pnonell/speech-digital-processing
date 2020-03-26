close all;

%factors de transformació de temps i pitch
T_fact = 0.7;
F_fact = 2.5;

%llegim l'àudio
[x, fs] = audioread('audio_original.wav');

%llegim les marques de pitch
pitch_marks = readtable('audio_original_marques.pitch.txt','ReadVariableNames',false,'ReadRowNames',false,'Delimiter','\t');
pitch_marks = round(table2array(pitch_marks)*fs)+1;

[pitch_marks_f,uv] = intpm(x,pitch_marks,fs);

%inicialitzem la part harmònica i estocàstica
x_h = zeros(ceil(size(x,1) * T_fact), size(x, 2));
x_n = zeros(ceil(size(x,1) * T_fact), size(x, 2));

%inicialitzem la fase acumulada a 0 i la primera marca P0
Linear_Phase_Acum = 0;
P0 = 0;

%bucle d'anàlisi i modificació per trames
for i = 3:length(pitch_marks_f)
    %obtenim les 3 marques de pitch de la trama
    P3 = pitch_marks_f(i);
    P2 = pitch_marks_f(i-1);
    P1 = pitch_marks_f(i-2);

    %apliquem la funció de transformació de trama
    [frame_h, frame_n, polin, Linear_Phase_Acum, P1, P3] = mhet_frame(x(P1:P3), fs, P0, P1, P2, P3, F_fact, T_fact, Linear_Phase_Acum, uv(i-1));
    
    %assignem la pròxima P0
    P0 = pitch_marks_f(i-2);
    
    %apliquem el polin
    frame_h2 = (frame_h .* polin);
    frame_n2 = (frame_n .* polin);
    
    %guardem la nova trama al senyal total
    x_h(P1:P3) = x_h(P1:P3) + frame_h2;
    x_n(P1:P3) = x_n(P1:P3) + frame_n2;
end

%sumem la part harmònica i la estocàstica
x_mhe = x_h + x_n;

%reproduim l'original
disp('Now playing original');
audioplayer1 = audioplayer(x, fs);
playblocking(audioplayer1);

%reproduim la part harmònica
disp('Now playing harmonic part');
audioplayer2 = audioplayer(x_h, fs);
playblocking(audioplayer2);

%reproduim la part estocàstica
disp('Now playing stochastic part');
audioplayer3 = audioplayer(x_n, fs);
playblocking(audioplayer3);

%reproduim la reconstrucció
disp('Now playing rebuilt signal');
audioplayer4 = audioplayer(x_mhe, fs);
playblocking(audioplayer4);

%guardem el nou audio
audiowrite('audio_hn_T07F25.wav', x_mhe, fs);