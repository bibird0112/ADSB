function [LAT0,LAT1]=latitude_global(bit0,bit1,CPR0,CPR1)
    %Fonction pour calculer la latitude cf algo annexe
    %Convertir bits en valeurs dec
    
    if CPR0 == 0
        YZ0 = conversion_signed_int(bit0,0);
        YZ1 = conversion_signed_int(bit1,0);
        i_0 = CPR0;
        i_1 = CPR1;
    else
        YZ0 = conversion_signed_int(bit1,0); %On échange les valeurs pour être en cohérence avec la valeur du CPR
        YZ1 = conversion_signed_int(bit0,0);
        i_0 = CPR1;
        i_1 = CPR0;
    end
   
    
    %Calcul de Dlat
    Dlat0=360/(4*15-i_0);
    Dlat1=360/(4*15-i_1);

    %Calcul de j
    MOD= @(x,y) x-y*floor(x/y);
    j=floor(0.5+(59*YZ0-60*YZ1)/(2^17));

    %Calcul LAT
    LAT0=Dlat0*(MOD(j,60-i_0)+(YZ0)/2^17);
    LAT1=Dlat1*(MOD(j,60-i_1)+(YZ1)/2^17);


    if CPR0 == 1
        temp=LAT0;
        LAT0=LAT1;
        LAT1=temp;
    end