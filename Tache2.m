%%Tâche 2 : Densité Spectrale de Puissance

clear 
clc
close all

fe = 20e6;
Te = 1/fe;

Ts = 1e-6;
fs = 1/Ts;

Fse = Ts/Te;

Nfft =256;
Nb = 1000;

% Modulation: PPM
x = mod_PPM(randi([0, 1], 1, Nb), Fse);  

% Estimation de la DSP en utilisant la méthode Welch
[Y, freq] = Mon_Welch(x, Nfft, fe); 

% DSP théorique
DSPtheorique = @(f) ((1/4)*(f==0)+((1./Ts)*(sin(Ts*pi*f./2).^4)./((pi*f).^2)));

figure;
semilogy(freq, Y, 'b', 'DisplayName', 'DSP Estimée (Welch)');
hold on;
semilogy(freq, DSPtheorique(freq), 'r', 'DisplayName', 'DSP théorique');
ylim([1e-20, 1])
xlabel('Frequences (Hz)');
ylabel('DSP');
title('DSP théoriques et DSP estimée');
legend('show');
grid on;
hold off;

