%% Initialisation valeurs

clear 
clc
close all

load("adsb_msgs.mat");
load("buffers.mat");
load("trames.mat")

lat_ref = 44.806884;
lon_ref = -0.606629; %Coordonnées géographiques d'une position de ref (prise avec le graph de l'exemple)

fe = 20e6;
Te = 1/fe;

Ts = 1e-6;
fs = 1/Ts;

Fse = Ts/Te;

%% Tâche 1 
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
%% Tâche 2 : Densité Spectrale de Puissance

Nfft =256;
Nb = 1000;
fe = 20e6;

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


%% Tâche 3 : détecteur CRC
 

bits_emis = randi([0 1],88,1); % Test avec nombre de bits d'une trame ADS-B sans CRC et préambule
polynome = [1 1 1 1 1 1 1 1 1 1 1 1 1 0 1 0 0 0 0 0 0 1 0 0 1];

crc_generator = comm.CRCGenerator(polynome); 
crc_detector = comm.CRCDetector(polynome);

bits_CRC = codageCRC(bits_emis,crc_generator);

%sans bruit
[bits_recus,err1]=m_decodageCRC(bits_CRC,crc_detector);

if err1 == 0
    fprintf("Tâche 3 : Le message envoyé sans bruit est intègre \n");
end

%avec bruit

bits_CRC_bruit = mod_PPM(transpose(bits_CRC),Fse);

sigma2 = 3; %Valeur de la variance
nl_t = randn(size(bits_CRC_bruit)) * sqrt(sigma2);

yl_t = bits_CRC_bruit + nl_t;

% Convolution par p1(-t)
porte = ones(1,Fse/2);
rl_t = conv(yl_t,porte, "full"); %On prend toutes les valeurs pour avoir la valeur en 0
rlt_sliced = rl_t(Fse/2:end); % On enlève les parties avant t=0, on décale de Fse/4 valeurs pour compenser le filtre


bits_CRC_decision = cplxdecision(rlt_sliced);

[bits_recus_bruit,err2]=m_decodageCRC(transpose(bits_CRC_decision),crc_detector);

if err2 == 1
    fprintf("Tâche 3 : Le message envoyé avec bruit n'est pas intègre \n");
else
    fprintf("Tâche 3 : Le message envoyé avec bruit est intègre \n");
end

%% Tâche 4 : Synchronisation temporelle


simulate_teb_ppmT4_complex(Ts, Te); 


%% Tâche 6/7 : Couche MAC ADS-B

for i=1:size(adsb_msgs,2)
    ech=transpose(adsb_msgs(:,i));
    registre(i)=m_bit2registre(ech,crc_detector,lat_ref,lon_ref);
end

registre_global = bit2registre_global(adsb_msgs,crc_detector,lat_ref,lon_ref); % Tâche 7, valeurs étranges pour 1 latitude

affiche_carte(lon_ref,lat_ref);
lat = [];
lon = [];
lat_global = [];
lon_global = [];
for i=1:size(registre,2)
    if ~(isempty(registre(i).latitude)) %Vérifie si la ligne correspond à la position
        lat = cat(2,lat,registre(i).latitude);
        lon = cat(2,lon,registre(i).longitude);
    end
end
for i=1:size(registre_global,2)
    if ~(isempty(registre_global(i).latitude)) %Vérifie si la ligne correspond à la position
        lat_global = cat(2,lat_global,registre_global(i).latitude);
        lon_global = cat(2,lon_global,registre_global(i).longitude);
    end
end

hold on,
plot(lon, lat, '-b', 'LineWidth', 2);
plot(lon_global, lat_global, '--g', 'LineWidth', 2);
hold off,

%% Tache 8
clear
close all
polynome = [1 1 1 1 1 1 1 1 1 1 1 1 1 0 1 0 0 0 0 0 0 1 0 0 1];
crc_detector = comm.CRCDetector(polynome);
lat_ref = 44.806884;
lon_ref = -0.606629;
%synchronisationT8 renvoit les
%premiers indices des différentes trames puis on fait CRC 
load('buffers.mat')
Ts = 1e-6;
fe_8 = 4e6; % La fréquence d'échantillonage change pour la tâche 8
Te_8 = 1/fe_8;
Fse_8 = Ts/Te_8;

size_spt=8*Fse_8;
spt=zeros(1,size_spt);
spt(1:Fse_8/2)=1;
spt(Fse_8+1:Fse_8+Fse_8/2)=1;
spt(3*Fse_8+1+Fse_8/2:4*Fse_8)=1;
spt(4*Fse_8+1+Fse_8/2:5*Fse_8)=1;
Tp=8*Ts;

seuil = 0.75;
Nb_buffers = 3;
idx_debut_trame = synchronisationT8(buffers(:,Nb_buffers),spt,Tp,seuil);

figure,
plot(abs(buffers(:,Nb_buffers)))
hold on,
for i = 1:length(idx_debut_trame)
    xline(idx_debut_trame(i), '--r', 'LineWidth', 1);  % '--r' pour une ligne pointillée rouge
end
hold off,

structure = struct('adresse',[],'format',[],'type',[],'nom',[], 'altitude',[],'timeFlag',[],'cprFlag',[],'latitude',[],'longitude',[],'velocity',[]); %Initialisation registre
idx_ok = 1;
porte = ones(1,Fse_8/2);

for i=1:size(idx_debut_trame,2)
    trame = buffers(idx_debut_trame(i)+size_spt+1:idx_debut_trame(i)+size_spt+112*Fse_8,Nb_buffers);
    bits = demod_PPMcplx(transpose(trame),Fse_8,porte);
    structure = m_bit2registre(bits,crc_detector,lat_ref,lon_ref);
    if ~isequal(structure.adresse,[]) % Vérifie que bit2registre a bien fonctionné (CRC,format,...) 
        registre_correct(idx_ok) = structure;
        idx_ok = idx_ok + 1;
    end
end


rm=transpose(buffer_sliced(1:Fse/2:end)); %Echantillonage a Ts/2
% Synchronisation

X_axis = 0:Ts/2:(size(rm,2)/2)*Ts-Te;
% figure,
% plot(X_axis,rm,Linestyle="none",Marker="+")
% xlim([-3*Te (size(rm,2)/2)*Ts+3*Te])
% ylim([min(rm)-0.4 max(rm)+0.4])
% title("module de rm");
% figure,
% plot(rm,Linestyle="none",Marker="+")

bk_decision = decision(rm,v0);

R=bit2registre(bk_decision,crc_detector,lat_ref,lon_ref);
figure,
plot(bk_decision)


