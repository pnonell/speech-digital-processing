function [frame_h, frame_n, polin, Linear_Phase_Acum, P1, P3] = mhet_frame(frame, fs, P0, P1, P2, P3, F_fact, T_fact, Linear_Phase_Acum, uv)
    %enfinestrem la trama
    window = hamming(length(frame));
    frame_w = frame .* window; 
    
    %càlcul de les marques de pitch modificades
    P1_new = ceil(P1 * T_fact);
    P2_new = ceil(P2 * T_fact);
    P3_new = ceil(P3 * T_fact);
    
    %càlcul de la f0
    mP1P2 = P2 - P1;
    mP2P3 = P3 - P2;
    fP1P2 = fs / mP1P2;
    fP2P3 = fs / mP2P3;
    f0 = round(mean([fP1P2 fP2P3]));
    %f0 modificada
    f0_new = F_fact * f0;
    %càlcul L
    L = floor(5000 / f0);
    L_new = floor(5000 / f0_new);
    
    n2 = (P1_new:P3_new)' - P2_new;

    %inicialització de les trames harmòniques (modificada i normal) i
    %l'estocàstica (modificada)
    frame_h = zeros(size(frame));
    frame_n = zeros(ceil(size(n2)));
    frame_h_new = zeros(ceil(size(n2)));

    %si la trama és harmònica
    if uv == 1
        %calcul part harmonica
        W = diag(window);
        
        w0 = (2 * pi * f0) / fs;
        
        %calcul f.fon. de la trama anterior
        mP1P2_ant = P1 - P0;
        mP2P3_ant = P2 - P1;
        fP1P2_ant = fs / mP1P2_ant;
        fP2P3_ant = fs / mP2P3_ant;
        f0_ant = round(mean([fP1P2_ant fP2P3_ant]));
        w0_ant = 2 * pi * (f0_ant/fs); 
        
        T = (P1 - P0);
        
        %calculem l'increment de fase i la sumem a l'acumulada
        Linear_Phase_Acum = Linear_Phase_Acum + T/2 * (w0*(T_fact*F_fact - 1) + w0_ant * (F_fact * T_fact - 1));        
        
        n = (P1:P3)' - P2;
        l = -L:L;
        nl = n * l;
        
        B = exp(1j * w0 * nl);
        
        c = pinv((B') * (W') * W * B) * (B') * (W') * W * frame_w;
        %càlcul amplituds i fases
        A = 2 *abs(c);
        Phi = angle(c);
        
        A_new = A;
        Phi_new = Phi;
        
        %si modifiquem el pitch, busquem les noves amplituds i fases
        if F_fact ~= 1
            BWh = 5000;
            [A_new,Phi_new,nh_max] = vtinterp(A(L+2:2*L+1),Phi(L+2:2*L+1),f0,f0_new,BWh);
            
            L_new = nh_max;
        end    
        
        %càlcul de la trama harmònica modificada
        w0 = 2 * pi * (f0_new/fs); 
        for k = 1:L_new
            %si modifiquem el pitch, utilitzem les noves amplituds i fases
            if F_fact ~= 1
                frame_h_new = frame_h_new + (A_new(k) * cos(w0 * n2 * k + Phi_new(k) + (Linear_Phase_Acum * k)));
            else
                %si no modifiquem el pitch, utilitzem les mateixes fases i
                %amplituds
                frame_h_new = frame_h_new + (A(k+L+1) * cos(w0 * n2 * k + Phi(k+L+1) + (Linear_Phase_Acum * k)));
            end
        end
        
        %càlcul de la trama harmònica sense modificar
        w0 = 2 * pi * (f0/fs); 
        for k = 1:L
            frame_h = frame_h + (A(k+L+1) * cos(w0 * n * k + Phi(k+L+1)));
        end
         
    end

    %we calculate stochastic part
    error = (frame - frame_h) .* window;
    
    [LPC, E] = lpc(error);
    gaussian = sqrt(E) .* randn(1, size(frame_h_new, 1));
    frame_n = transpose(filter(1, LPC, gaussian));

    %we calculate polin
    middle = P2_new - P1_new + 1;
    p12 = linspace(0, 1, middle);
    p23 = linspace(1, 0, (length(frame_h_new)) - middle);
    polin = transpose(cat(2, p12, p23(1: length(p23))));

    %assignem els nous valors modificats
    P1 = P1_new;
    P3 = P3_new;
    frame_h = frame_h_new;
end