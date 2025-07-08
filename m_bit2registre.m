function registre = m_bit2registre(bit,crc_detector,lat_ref,lon_ref)
    %Fait un registre contenant les informations que l'avion envoit
    %Pour l'instant : enregistre la position géographique en l'air,
    %l'identification de l'avion et son numéro unique
    %Après : vitesse, position au sol
    
    registre = struct('adresse',[],'format',[],'type',[],'nom',[], 'altitude',[],'timeFlag',[],'cprFlag',[],'latitude',[],'longitude',[],'velocity',[]); %Initialisation registre
    [bit_decoded,err] = m_decodageCRC(transpose(bit),crc_detector);
    
    if err==1
        fprintf("Le CRC détecte une erreur \n");
        return;
    end

    %Format de la trame
    if sum(bit_decoded(1:5) ~= [1 0 0 0 1]) ~= 0 %On veut que les 5 premiers bits soient égaux à 17 pour ADS-B
        fprintf("Le type de trame envoyé n'est pas celui voulu");
        return;
    end
    
    registre.format = 17;

    CAP=bi2de(bit_decoded(6:8),'left-msb'); %Bits de capacité pour la vitesse

    %Adresse OACI de l'appareil
    
    registre.adresse = dec2hex(bi2de(bit_decoded(9:32),'left-msb')); 

    % 1 à 4 : identifications
    %9-22 sans 19 : position en vol
    FTC = bi2de(bit_decoded(33:37),'left-msb'); 
    registre.type = FTC;

    if (0<=FTC) && (FTC<=4) %FTC pour identification appareil
        registre.nom = identification(bit_decoded(41:end));
        
    elseif ((9<=FTC) && (FTC<=18)) || ((20<=FTC) && (FTC<=22)) %FTC pour position au vol appareil
        %Calcul altitude    
        ralt = cat(2,bit_decoded(41:47),bit_decoded(49:52));
        ralt_de = bi2de(ralt,'left-msb');
        ALT = 25*ralt_de -1000;
        registre.altitude = ALT; %altitude en pied
        %Ajout timeFlag
        %registre.timeFlag = bit_decoded(53); %Pas considéré et valeur bizarre...
        %Ajout CPRflag
        CPR=bit_decoded(54);
        registre.cprFlag = CPR;
        %Calcul latitude
        LAT=latitude(bit_decoded(55:71),CPR,lat_ref,17,"airborne");
        registre.latitude = LAT;
        %Calcul longitude
        LON = longitude(bit_decoded(72:88),CPR,lon_ref,LAT,17,"airborne");
        registre.longitude = LON;
    elseif FTC == 19 %FTC pour vitesse de l'avion
        VEL = velocity(bit_decoded(41:end),CAP); %On suppose que l'avion n'est pas supersonique, heading non calculé
        registre.velocity = VEL;
    elseif (5<=FTC) && (FTC<=8) %FTC pour position au sol
        CPR = bit_decoded(54);
        registre.cprFlag = CPR;
        %Altitude au sol
        ALT = 166; %Altitude en pied de l'aéroport de Merignac
        registre.altitude = ALT;
        %Calcul latitude au sol
        LAT=latitude(bit_decoded(55:71),CPR,lat_ref,17,"ground");
        registre.latitude = LAT;
        %Calcul longitude
        LON = longitude(bit_decoded(72:88),CPR,lon_ref,LAT,17,"ground");
        registre.longitude = LON; 
    end
end




             
            

