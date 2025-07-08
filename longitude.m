function LON=longitude(bit,CPR,lon_ref,lat,Nb,position)
    %Fonction pour calculer la longitude cf algo annexe
    %Convertir bits en valeurs dec
    rlon_de = conversion_signed_int(bit,0);
    %Changement angle pour rendre compatible avec position au sol
    if position == "airborne"
        angle = 360;
    elseif position == "ground"
        angle = 90;
    else
        fprintf("Lis la fonction\n");
    end

    %Calcul Dlon
    Nlat_test=cprNL(lat)-CPR;
    if Nlat_test == 0
        Dlon = angle;
    elseif Nlat_test > 0
        Dlon = angle/Nlat_test;
    else
        fprintf("Problème sur calcul cprNL\n");
        return;
    end

    %Calcul de m
    MOD= @(x,y) x-y*floor(x/y);
    m=floor(lon_ref/Dlon)+floor(0.5+MOD(lon_ref,Dlon)/Dlon-rlon_de/(2^Nb));

    %Calcul de LON
    LON=Dlon*(m+(rlon_de/(2^Nb)));
    