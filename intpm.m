function [pitch_marks_f,uv] = intpm(x,pitch_marks,fs)
% [pitch_marks_f,uv] = intpm(x,pitch_marks,fs)
%
% Interpolates pitch marks of a speech signal x sampled at fs Hz when 
% distance between consecutive pitch marks are greater that the inverse of 
% the minimum pitch period (defined as f0min), obtaining pitch marks also 
% during unvoiced or silence regions of the speech signal.  Also the 
% function returns the uv vector of the same size of the returned pitch marks
% vector, with binary values indicating the voiced frames with 1 and
% unvoiced frames with 0.
%
% Joan Claudi Socoró, December 2018
% Enginyeria La Salle

f0min = 70;
Tmax = (fs/f0min);
pitch_periods = diff(pitch_marks);
decis = (pitch_periods>Tmax);

% figure(1);clf;
% hndl(1) = subplot(311);plot(x);hold on;
% for n = 1:length(pitch_marks)
%     line([pitch_marks(n) pitch_marks(n)],[0 x(pitch_marks(n))],'Color','r');
% end
% plot(pitch_marks,x(pitch_marks),'ro')
% axis tight;
% hndl(2) = subplot(312);plot(pitch_marks(1:end-1),pitch_periods,'r.');
% hndl(3) = subplot(313);plot(pitch_marks(1:end-1),decis,'r.');
% linkaxes(hndl,'x');

Ti = 0;
n = 1;
pitch_marks_f = [];
uv = [];
if (pitch_marks(1)>Tmax)
    marki = pitch_marks(1);
    % Primera marca massa lluny --> cal crear noves marques abans, amb el
    % mateix període primer vàlid (zero order hold)
    % (1) Busquem el següent període útil per interpolar (periode que
    % compleix la condició)
    while ((pitch_marks(n+1)-pitch_marks(n))>Tmax)&&(n<(length(pitch_marks)-1))
        n = n + 1;
    end
    T = pitch_marks(n+1)-pitch_marks(n);
    % Coloquem les marques inicials
    newmarks = [marki];
    newmark = marki-T;
    while (newmark>=1)
        newmarks = [newmark newmarks];
        newmark = newmarks(1)-T;
    end
    pitch_marks_f = newmarks;
    uv = zeros(size(newmarks));
end
while n<length(pitch_marks)
    T = pitch_marks(n+1)-pitch_marks(n);
    if (T>Tmax)
        % Cal interpolar
        % (1) Busquem el següent període útil per interpolar (periode que
        % compleix la condició)
        n = n + 1;
        while ((pitch_marks(n+1)-pitch_marks(n))>Tmax)&&(n<(length(pitch_marks)-1))
            n = n + 1;
        end
        Tf = pitch_marks(n+1)-pitch_marks(n);
        markf = pitch_marks(n);
        if (Tf<=Tmax)
            % Interpolem períodes Ti i Tf entre les marques marki i markf 
            % --> Creem un nou vector de marques interpolades en la variable newmarks
            newmarks = [marki];
            newperiods = [marki];
            Tnew = Ti*(((marki+Ti)-markf)/(marki-markf)) + Tf*(((marki+Ti)-marki)/(markf-marki));
            markn = marki;
            markn = round(markn + Tnew);
            while (markn<markf)
                newmarks = [newmarks markn];
                newperiods = [newperiods Tnew];
                Tnew = Ti*((markn - markf)/(marki-markf)) + Tf*((markn-marki)/(markf-marki));
                markn = round(markn + Tnew);
            end
            % Mirem si la darrer període és massa petit i en aquest cas
            % anem restant 1 mostra a cada període fins que l'espai és
            % suficient
            while ((markf - newmarks(end))<(0.5*0.7*(Tf+(newmarks(end)-newmarks(end-1)))))
                newperiods(2:end) = newperiods(2:end) - 1;
                newmarks = round(cumsum(newperiods));
            end
            %Incorporem les noves marques
            pitch_marks_f = [pitch_marks_f newmarks(2:end) markf];
            uv = [uv zeros(size([newmarks(2:end) markf]))];
        else
            % Últims períodes calculables no compleixen la condició, pel
            % que repetim el darrer període útil fins al final (zero order
            % hold)
            while ((pitch_marks_f(end)+Ti)<=length(x))
                pitch_marks_f = [pitch_marks_f;pitch_marks_f(end)+Ti];
                uv = [uv zeros(size([pitch_marks_f(end)+Ti]))];
            end
        end
    else
        % Període de pitch correcte --> Incorporem la marca de pitch a
        % l'array final: pitch_marks_f
        pitch_marks_f = [pitch_marks_f pitch_marks(n+1)];
        uv = [uv ones(size([pitch_marks(n+1)]))];
        Ti = T;
        marki = pitch_marks(n+1);
        n = n + 1;
    end
end

if ((length(x) - pitch_marks_f(end))>Tmax)
    % Darrera marca massa allunyada del final del senyal --> Afegim marques
    % fins al final separades exactament la separació entre les dues
    % darreres marques posades en pitch_marks_f
    T = pitch_marks_f(end) - pitch_marks_f(end-1);
    marki = pitch_marks_f(end);
    markn = marki + T;
    while (markn<=length(x))
        pitch_marks_f = [pitch_marks_f markn];
        uv = [uv zeros(size([markn]))];
        markn = markn + T;
    end
end

end

