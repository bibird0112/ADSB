function [yl_t_synchron,delta_t] = synchronisation(yl_t,spt,Tp, Te, Ts, size_trame)
    
    %voir si gestion du bruit dans la fonction
    Fse=Ts/Te;
    size_spt = size(spt,2);
    
    X_axis = 0:Tp/size_spt:Tp-Tp/size_spt;

    %Calcul estimateur
    estimateur = zeros(1,size_spt);

    for i=0:99 

        yl_t_sliced = yl_t(i+1:i+size_spt); % Pour faire l'intégrale entre delta et delta+Tp

        num = trapz(X_axis,yl_t_sliced.*spt);

        den1 = sqrt(trapz(X_axis,abs(spt).^2));

        den2 = sqrt(trapz(X_axis,abs(yl_t_sliced).^2));

        estimateur(i+1) = num/(den1*den2); %Calcul de l'estimateur comme montré dans le sujet

    end

    %Déterminer delta

    [~,idx] = max(abs(estimateur));
    delta_t = idx; 

    yl_t_synchron = yl_t(delta_t+size_spt:delta_t+size_spt+size_trame-1);




    
 