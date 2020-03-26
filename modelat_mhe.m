[x, fs] = audioread('audio_original.wav');

%Extrayem les marques de pitch a traves del fitxer previament generat
pitch_marks = readtable('audio_original_marques.pitch.txt','ReadVariableNames',false,'ReadRowNames',false,'Delimiter','\t');
pitch_marks = round(table2array(pitch_marks)*fs)+1;

[pitch_marks_f,uv] = intpm(x,pitch_marks,fs);

%Mostrem les marques de pitch originals vs les processades
figure
subplot(2, 1, 1)
plot(x);
hold on;
scatter(pitch_marks, x(pitch_marks));
title('Original pitch marks')
legend('speech signal', 'signal pitch marks')
hold off

subplot(2, 1, 2)
plot(x);
hold on;
scatter(pitch_marks_f, x(pitch_marks_f));
plot(pitch_marks_f, uv);
title('Processed pitch marks');
legend('speech signal', 'signal pitch marks', 'UV decision');
hold off;

x_h = zeros(size(x));
x_n = zeros(size(x));

%Per tota la senyal, calculem les parts harmoinques i estocastiques de cada frame
for i = 3:length(pitch_marks_f)
    P3 = pitch_marks_f(i);
    P2 = pitch_marks_f(i-1);
    P1 = pitch_marks_f(i-2);

    [frame_h, frame_n, polin] = mhe_frame(x(P1:P3), fs, P1, P2, P3, uv(i-1));

    %Sumem cada frame harmonic i estocastic als senyals harmonics i estocastics
    x_h(P1:P3) = x_h(P1:P3) + (frame_h .* polin);
    x_n(P1:P3) = x_n(P1:P3) + (frame_n .* polin);
end

%Sumem ambdues senyals per reconstruir el senyal original
x_mhe = x_h + x_n;

%Mostrem el senyal i espectrograma del senyal reconstruit i els seus components
figure
subplot(2, 3, 1)
plot(x_mhe);
title('Rebuilt Signal');

subplot(2, 3, 2)
plot(x_h);
title('Harmonic part');

subplot(2, 3, 3)
plot(x_n);
title('Stochastic part');

nw = round(fs* 0.08);
na = round(fs * 0.005);

[Se,Fe,Te] = spectrogram(x_mhe, nw, nw-na, nw, fs);
[Se_h,Fe_h,Te_h] = spectrogram(x_h, nw, nw-na, nw, fs);
[Se_n,Fe_n,Te_n] = spectrogram(x_n, nw, nw-na, nw, fs);

subplot(2, 3, 4)
imagesc(Te, Fe, 20*log10(abs(Se)));
set(gca,'ydir', 'normal');
xlabel('time(s)');
ylabel('frequency(Hz)');

subplot(2, 3, 5)
imagesc(Te_h, Fe_h, 20*log10(abs(Se_h)));
set(gca,'ydir', 'normal');
xlabel('time(s)');
ylabel('frequency(Hz)');

subplot(2, 3, 6)
imagesc(Te_n, Fe_n, 20*log10(abs(Se_n)));
set(gca,'ydir', 'normal');
xlabel('time(s)');
ylabel('frequency(Hz)');

%Reproduim les senyals
disp('Now playing harmonic part');
sound(x_h, fs);
pause(5.0);
disp('Now playing stochastic part');
sound(x_n, fs);
pause(5.0);
disp('Now playing rebuilt signal');
sound(x_mhe, fs);

%Exportem els senyals com a arxius de audio
audiowrite('audio_h.wav', x_h, fs);
audiowrite('audio_n.wav', x_n, fs);
audiowrite('audio_hn.wav', x_mhe, fs);
