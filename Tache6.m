%% Tâche 6/7

clear 
clc
close all

load("adsb_msgs.mat");

fe = 20e6;
Te = 1/fe;

Ts = 1e-6;
fs = 1/Ts;

Fse = Ts/Te;

lat_ref = 44.806884;
lon_ref = -0.606629; %Coordonnées géographiques d'une position de ref (prise avec le graph de l'exemple)

polynome = [1 1 1 1 1 1 1 1 1 1 1 1 1 0 1 0 0 0 0 0 0 1 0 0 1];
crc_detector = comm.CRCDetector(polynome);

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
