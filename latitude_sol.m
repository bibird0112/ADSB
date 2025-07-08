function LAT = latitude_sol(bit,CPR,lat_ref,Nb)
     %Fonction pour calculer la latitude cf A.2.6.6
    %Convertir bits en valeurs dec
    rlat_de = conversion_signed_int(bit,0);
    
    %Calcul de Dlat
    Dlat=90/(4*15-CPR);

    %Calcul de j
    MOD= @(x,y) x-y*floor(x/y);
    j=floor(lat_ref/Dlat)+floor(0.5+MOD(lat_ref,Dlat)/Dlat-rlat_de/(2^Nb));

    %Calcul LAT
    LAT=Dlat*(j+(rlat_de/(2^Nb)));