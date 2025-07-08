function identifiant = identification(bits)

    %Tableau de correspondance pour l'identification
  
    tab_carac(1:26) = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    tab_carac(32) = ' '; %SP = ESPACE ?
    tab_carac(48:57) = '0123456789';
    
    % Identification : 8 caractères de 6 bits
    for i=1:8
        tab_6_bits = bits((i-1)*6+1:i*6); 
        num = bi2de(tab_6_bits,'left-msb'); 
        identifiant(i) = tab_carac(num);
    end
    