function LON=longitude_global(bit0,bit1,CPR0,CPR1,lat0,lat1)
    %Fonction pour calculer la longitude cf algo annexe
    %Convertir bits en valeurs dec
    %Ajouter condition si les deux Nlat de sont pas bonnes -> il faut
    %rajouter LON non défini et faire condition apres
    if CPR0 == 0
        XZ0 = conversion_signed_int(bit0,0);
        XZ1 = conversion_signed_int(bit1,0);
        i_0 = CPR0;
        i_1 = CPR1;
    else
        XZ0 = conversion_signed_int(bit1,0); %On échange les valeurs pour être en cohérence avec la valeur du CPR
        XZ1 = conversion_signed_int(bit0,0);
        i_0 = CPR1;
        i_1 = CPR0;
    end

    %Calcul Dlon
    Nlat_test0=cprNL(lat0);
    Nlat_test1=cprNL(lat1);
    if Nlat_test0 ~= Nlat_test1
        fprintf("Pas le même Nlat donc pas possible d'avoir longitude\n");
        LON = inf;
        return;
    end
    
    if Nlat_test0 - i_0 == 0
        Dlon0 = 360;
    elseif Nlat_test0 - i_0 > 0
        Dlon0 = 360/(Nlat_test0-i_0);
    else
        fprintf("Problème sur calcul cprNL\n");
        return;
    end

    if Nlat_test1 - i_1 == 0
        Dlon1 = 360;
    elseif Nlat_test1 - i_1 > 0
        Dlon1 = 360/(Nlat_test1 - i_1);
    else
        fprintf("Problème sur calcul cprNL\n");
        return;
    end
    
    MOD = @(x,y) x-y*floor(x/y);
    %Calcul de m avec le Dlon correspondant au message le plus récent 
    if CPR0 == 1 %Dans ce cas les valeurs ont été inversé et donc Nlat_test1
        m=floor(0.5 + (XZ0*(Nlat_test1)-XZ1*(Nlat_test1+1))/2^17);
        LON= Dlon1*(MOD(m,Nlat_test1+i_1)+XZ1/2^17);
    else 
        m=floor(0.5 + (XZ0*(Nlat_test0)-XZ1*(Nlat_test0+1))/2^17);
        LON= Dlon0*(MOD(m,Nlat_test0+i_0)+XZ0/2^17);
    end

    