function LAT=latitude(bit,CPR,lat_ref,Nb,position)
    %Fonction pour calculer la latitude cf algo annexe
    %Convertir bits en valeurs dec
    rlat_de = conversion_signed_int(bit,0);
    %Changement angle pour rendre compatible avec position au sol
    if position == "airborne"
        angle = 360;
    elseif position == "ground"
        angle = 90;
    else
        fprintf("Lis la fonction\n");
    end
    %Calcul de Dlat
    Dlat=angle/(4*15-CPR);

    %Calcul de j
    MOD= @(x,y) x-y*floor(x/y);
    j=floor(lat_ref/Dlat)+floor(0.5+MOD(lat_ref,Dlat)/Dlat-rlat_de/(2^Nb));

    %Calcul LAT
    LAT=Dlat*(j+(rlat_de/(2^Nb)));


