function [A_new,Phi_new,nh_max] = vtinterp(A,Phi,F0,F0_new,BWh)
%[A_new,Phi_new,nh_max] = vtinterp(A,Phi,F0,F0_new,BWh)
%
% This function interpolates vocal tract represented by harmonic serie of
% amplitudes and phases (A,Phi) with pitch frequency F0, to the new pitch
% frequency F0new. Interpolation is performed with complex representation
% for the phases, while with logarithmic amplitudes for the amplitudes. In
% this case, interpolation for the 1st harmonic when F0mew<F0 is performed
% assuming that logarithmic amplitude envelope attains the amplitude of the
% 1st harmonic at the frequency 0. Only harmonics located within the
% harmonic bandwidth [0,BWh] are returned. It also returns the new number
% of harmonics in nh_max.
%
% Joan Claudi Socoró, NOvember 2018
% Enginyeria La Salle

% Number of harmonics
nh = length(A);
%% Phases interpolation
% Complex amplitudes
C = A.*exp(j*Phi);
% Interpolation
nh_max = floor(BWh/F0_new);
C_new = interp1(F0*(1:nh),C,F0_new*(1:nh_max),'linear','extrap');
Phi_new = angle(C_new);

%% Amplitudes interpolation
A_new = 10.^(interp1(F0*(0:nh),[log10(A(1));log10(A)],F0_new*(1:nh_max),'linear','extrap'));
end

