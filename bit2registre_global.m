function registre = bit2registre_global(trames,crc_detector,lat_ref,lon_ref)
    %Fait un registre contenant les informations que l'avion envoit
    %Pour l'instant : enregistre la position géographique en l'air,
    %l'identification de l'avion et son numéro unique
    %Après : vitesse, position au sol
    for i=1:size(trames,2)-1
        bit1 = trames(:,i);
        bit2 = trames(:,i+1); 
    
        [bit_decoded1,err] = m_decodageCRC(bit1,crc_detector);
        if err==1
            fprintf("Le CRC détecte une erreur \n");
            return;
        end
    
        [bit_decoded2,err] = m_decodageCRC(bit2,crc_detector);
        if err==1
            fprintf("Le CRC détecte une erreur \n");
            return;
        end
    
        FTC1 = bi2de(bit_decoded1(33:37),'left-msb');
        FTC2 = bi2de(bit_decoded2(33:37),'left-msb');
    
        CPR1=bit_decoded1(54);
        CPR2=bit_decoded2(54);
    
        if (FTC1 == FTC2) && (((9<=FTC1) && (FTC1<=18)) || ((20<=FTC1) && (FTC1<=22))) && (CPR1 ~= CPR2) %On veut un CPR différent pour les 2 et un FTC désignant la position en vol
            registre(i) = struct('adresse',[],'format',[],'type',[],'nom',[], 'altitude',[],'timeFlag',[],'cprFlag',[],'latitude',[],'longitude',[],'velocity',[]); %Initialisation registre
            if sum(bit_decoded1(1:5) ~= [1 0 0 0 1]) ~= 0 %On veut que les 5 premiers bits soient égaux à 17 pour ADS-B
                fprintf("Le type de trame envoyé n'est pas celui voulu");
                return;
            end
            if sum(bit_decoded2(1:5) ~= [1 0 0 0 1]) ~= 0 %On veut que les 5 premiers bits soient égaux à 17 pour ADS-B
                fprintf("Le type de trame envoyé n'est pas celui voulu");
                return;
            end
        
            registre(i).format = 17;
            %Adresse OACI de l'appareil
            registre(i).adresse = dec2hex(bi2de(bit_decoded1(9:32),'left-msb')); 
            %Calcul altitude    
            ralt = cat(2,bit_decoded1(41:47),bit_decoded1(49:52));
            ralt_de = bi2de(ralt,'left-msb');
            ALT = 25*ralt_de -1000;
            registre(i).altitude = ALT; %altitude en pied
            registre(i).cprFlag = CPR1;
            %Calcul latitude
            [LAT1,LAT2]=latitude_global(bit_decoded1(55:71),bit_decoded2(55:71),CPR1,CPR2);
            registre(i).latitude = LAT1;
            %Calcul longitude
            LON = longitude_global(bit_decoded1(72:88),bit_decoded2(72:88),CPR1,CPR2,LAT1,LAT2);
            registre(i).longitude = LON;
            registre(i).type = FTC1;
        else
            registre(i) = m_bit2registre(transpose(bit1),crc_detector,lat_ref,lon_ref);
        end
    end
    bit = trames(:,end);
    registre(size(trames,2)) = m_bit2registre(transpose(bit),crc_detector,lat_ref,lon_ref);
    
end




             
            

