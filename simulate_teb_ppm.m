function pb = simulate_teb_ppm(Nb, Ts, Te, v0)
    % Paramètres
    Fse = Ts / Te;
    EbN0_dB = 0:1:10; 
    num_errors_threshold = 100; % Nombre minimum d'erreurs pour valider TEB
    EbN0_valeurs = 10.^(EbN0_dB/10);

    teb = zeros(size(EbN0_dB));
    porte = ones(1, Fse / 2);

    for idx = 1:length(EbN0_dB)
        num_errors = 0;
        num_bits = 0;
        
        while num_errors < num_errors_threshold
            bits = randi([0, 1], 1, Nb);
            
            % Modulation PPM
            signal = mod_PPM(bits, Fse);
            Ps = mean(abs(signal).^2);
            N0 = Ps*Fse/EbN0_valeurs(idx); %Pondérer le bruit par la pss du signal et le nombre d'échantillon par bits
            % Ajout du bruit gaussien
            bruit = sqrt(N0/2) * randn(1, length(signal));
            signal_bruite = signal + bruit;
            
            % Démodulation et décision
            
            rl_t = conv(signal_bruite, porte, 'full'); % Convolution
            rlt_sliced = rl_t(Fse / 2:end); % Échantillonsize_tramenage
            rm = rlt_sliced(1:Fse / 2:end); % Échantillonage à Ts/2
            
            bits_recus = decision(rm, v0);

            % Calcul du nombre d'erreurs
            num_errors = num_errors + sum(bits ~= bits_recus);
            num_bits = num_bits + Nb;
        end
        
        % Calcul du TEB pour ce Eb/N0
        teb(idx) = num_errors / num_bits;
        %Calcul Pb
        pb = 0.5*erfc(sqrt(EbN0_valeurs)); % Calcul du pb une fois pour tous les Eb/N0
    end
    
    % Tracé des résultats
    figure;
    semilogy(EbN0_dB, teb, 'r.-');
    hold on;
    semilogy(EbN0_dB, pb, 'g');
    grid on;
    xlabel('Eb/N0 (dB)');
    ylabel('TEB');
    title('Taux d''erreur binaire en fonction du rapport Eb/N0 sans synchronisation temporelle');
end
