function VEL=velocity(bits,CAP)
    %Besoin du heading ?

    %Velocity E/W
    if CAP == 1 %Vitesse par rapport au sol (pas supersonique)
        DIR_EW = bits(1); % 0:East 1:West
        if(bi2de(bits(2:11),'left-msb') == 0)
            vel_EW =null(1); % Pas d'info
        else
            vel_EW = bi2de(bits(2:11),'left-msb') - 1; %Vitesse en noeuds
        end % Si valeur max de bits(2,11) : valeur indeterminé...
        
        DIR_NS = bits(12); % 0:North 1:South
        if(bi2de(bits(13:22),'left-msb') == 0)
            vel_NS =null(1); % Pas d'info
        else
            vel_NS = bi2de(bits(13:22),'left-msb') - 1; %Vitesse en noeuds
        end % Si valeur max de bits(12,21) : valeur indeterminé...
    
        DIR_UD = bits(24); % 0:Up 1:Down
        if(bi2de(bits(25:33),'left-msb') == 0)
            vel_UD =null(1); % Pas d'info
        else
            vel_UD = (bi2de(bits(25:33),'left-msb')-1)*64; %Vitesse en pieds par minute
        end
        
        vel_UD = vel_UD/101; %Vitesse en noeuds
        
        VEL = norm([vel_EW,vel_UD,vel_NS]);
    
    elseif CAP == 3 %Vitesse aérienne
        % 11ers bits : pour la direction
        airspe_type = bits(12);
        if(bi2de(bits(13:22),'left-msb') == 0)
            airspe =null(1); % Pas d'info
        else
            airspe = bi2de(bits(13:22),'left-msb') - 1; %Vitesse en noeuds
        end % Si valeur max de bits(13,22) : valeur indeterminé...  
        
        DIR_UD = bits(24); % 0:Up 1:Down
        if(bi2de(bits(25:33),'left-msb') == 0)
            vel_UD =null(1); % Pas d'info
        else
            vel_UD = (bi2de(bits(25:33),'left-msb')-1)*64; %Vitesse en pieds par minute
        end
        %Valeur d'altitude barométrique après 

        VEL = norm([airspe,vel_UD]);
    else 
        VEL = Inf;
    end
end