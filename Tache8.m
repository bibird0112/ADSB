%% Tâche 8

clear
close all
load('buffers.mat')

polynome = [1 1 1 1 1 1 1 1 1 1 1 1 1 0 1 0 0 0 0 0 0 1 0 0 1];
crc_detector = comm.CRCDetector(polynome);
lat_ref = 44.806884;
lon_ref = -0.606629; 

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
Tp=8*Ts;  % Définition préambule

seuil = 0.75;
Nb_buffers = 3;
idx_debut_trame = synchronisationT8(buffers(:,Nb_buffers),spt,Tp,seuil); %Renvoit les premiers indices des différentes trames

figure,
plot(abs(buffers(:,Nb_buffers)))
hold on,
for i = 1:length(idx_debut_trame)
    xline(idx_debut_trame(i), '--r', 'LineWidth', 1);  
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

% Test avec fonction de référence donnée, fonction pas dans le zip

% [structu, corrc] = process_buffer(buffers,lon_ref, lat_ref, seuil,Fse_8);