function delta = synchronisationT8(yl_t,spt,Tp,seuil)

    % Initialisation des variables
    size_spt = size(spt,2);
    len_yl_t = length(yl_t);
    num_segments = len_yl_t - size_spt; % Nombre de segments de taille Tp dans yl_t
    yl_t = transpose(yl_t);
    X_axis = 0:Tp/size_spt:Tp-Tp/size_spt; 
    corr = zeros(1,num_segments);

    den1 = sqrt(trapz(X_axis, abs(spt).^2)); % ne change pas dans toute la boucle
    
    % Calcul de la corrélation pour chaque segment de taille Tp
    for i = 1:num_segments
        yl_t_sliced = yl_t(i+ 1:i+size_spt);

        num = trapz(X_axis, yl_t_sliced .* spt);
        
        den2 = sqrt(trapz(X_axis, abs(yl_t_sliced).^2));
        
        corr(i) = num / (den1 * den2); % Calcul de l'estimateur de corrélation
    end

    [~, delta] = findpeaks(abs(corr), 'MinPeakHeight', seuil);
end
