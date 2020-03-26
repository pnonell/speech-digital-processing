function [frame_h, frame_n, polin] = mhe_frame(frame, fs, P1, P2, P3, uv)

    window = hamming(length(frame));

    frame_w = frame .* window;

    mP1P2 = P2 - P1;
    mP2P3 = P3 - P2;

    fP1P2 = fs / mP1P2;
    fP2P3 = fs / mP2P3;

    f0 = round(mean([fP1P2 fP2P3]));

    L = floor(5000 / f0);

    frame_h = zeros(size(frame));
    frame_n = zeros(size(frame));

    if uv == 1
        %Calculem la matriu de finestra
        W = diag(window);

        w0 = (2 * pi * f0) / fs;

        n = (P1:P3)' - P2;
        l = -L:L;
        nl = n * l;

        %Calculem la matriu de Fourier
        B = exp(1j * w0 * nl);
        c = pinv((B') * (W') * W * B) * (B') * (W') * W * frame_w;

        %Calculem les amplituds i fases
        A = 2 *abs(c);
        Phi = angle(c);

        w0 = 2 * pi * (f0/fs);
        %Modelem la part harmonica del frame
        for k = 1:L
            frame_h = frame_h + (A(k+L+1) * cos(w0 * n * k + Phi(k+L+1)));
        end
    end

    %we calculate stochastic part
    error = (frame - frame_h) .* window;
    [LPC, E] = lpc(error);
    gaussian = sqrt(E) .* randn(1, size(frame, 1));
    frame_n = transpose(filter(1, LPC, gaussian));


    %Calculem Polin
    middle = P2 - P1 + 1;
    p12 = linspace(0, 1, middle);
    p23 = linspace(1, 0, length(frame) - middle);
    polin = transpose(cat(2, p12, p23(1: length(p23))));
end
