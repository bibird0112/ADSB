%% Tâche 1 : Prise en main de la chaîne de communications ADS-B

clear 
clc
close all

fe = 20e6;
Te = 1/fe;

Ts = 1e-6;
fs = 1/Ts;

Fse = Ts/Te;

b = [1,0,0,1,0]; % Bits de l'exemple
sl_t = mod_PPM(b,Fse);

%Ajout bruit
sigma2 = 3; %Valeur de la variance
nl_t = randn(size(sl_t)) * sqrt(sigma2);

yl_t = sl_t + nl_t;

% Convolution par p1(-t)
porte = ones(1,Fse/2);
rl_t = conv(yl_t,porte, "full"); %On prend toutes les valeurs pour avoir la valeur en 0
rlt_sliced = rl_t(Fse/2:end); % On enlève les parties avant t=0, on décale de Fse/4 valeurs pour compenser le filtre

%Echantillonage 

rm=rlt_sliced(1:Fse/2:end); %Echantillonage a Ts/2

%Décision
p1 = mod_PPM(1,Fse);
p1_top = p1(1:Fse/2);
t=0:1:(Fse/2)-1;
v0 = trapz(t, abs(p1_top).^2);

bk_decision = decision(rm,v0); 

%calcul TEB

N = 1000; %Paquet d'information binaire
pb = simulate_teb_ppm(N,Ts,Te,v0); %Tracé de la courbe TEB en fonction de Eb/N0 

% Afficher figures
T_axis = 0:Te:size(b,2)*Ts-Te; % 100 valeurs et on exclu la dernière valeur puisqu'on veut la valeur en 0
figure,
subplot(3,1,1)
plot(T_axis,sl_t)
ylim([-0.05 1.05])
title("Signal modulé envoyé en entrée sans bruit") 
xlabel('Temps en secondes')
ylabel('Amplitude')

X_axis = 0:Ts/2:size(b,2)*Ts-Te;
subplot(3,1,2)
plot(T_axis,rlt_sliced) 
title("Signal reçu par le récepteur avec bruit") 
xlabel('Temps en secondes')
ylabel('Amplitude')

subplot(3,1,3)
plot(X_axis,rm,Linestyle="none",Marker="+")
xlim([-3*Te size(b,2)*Ts+3*Te])
ylim([min(rm)-0.4 max(rm)+0.4])
title("Signal après échantillonage, avant décision"); 
xlabel('Temps en secondes')
ylabel('Amplitude')