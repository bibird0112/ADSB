function pb = simulate_teb_ppmT4_complex_2(Ts, Te, v0)
    % Paramètres
    fe = 1/Te;
    Fse = Ts / Te;
    EbN0_dB = 0:1:10; 
    D_max = 250;
    Nb = 256;
    Tp = 8e-6;
    % Nombre minimum d'erreurs pour valider TEB
    num_errors_threshold = 100;
    EbN0_valeurs = 10.^(EbN0_dB / 10);

    % Initialisation du TEB pour la première simulation
    teb1 = zeros(size(EbN0_dB));
    porte = ones(1, Fse / 2);

    % Définition Fse et spt pour la première partie
    Fse = 20;
    size_spt = 8 * Fse;
    spt = zeros(1, size_spt);
    spt(1:Fse / 2) = 1;
    spt(Fse + 1:Fse + Fse / 2) = 1;
    spt(3 * Fse + 1 + Fse / 2:4 * Fse) = 1;
    spt(4 * Fse + 1 + Fse / 2:5 * Fse) = 1;

    % Boucle de simulation pour la première partie (avec synchronisation temporelle)
    for idx = 1:length(EbN0_dB)
        num_errors = 0;
        num_bits = 0;
        num_pckt = 0;
        while num_errors < num_errors_threshold || num_pckt < 1000
            num_pckt = num_pckt + 1;

            % Génération aléatoire des bits
            bits = randi([0, 1], 1, Nb);
            
            % Modulation PPM
            signal = mod_PPM(bits, Fse);
            size_trame = size(signal, 2);
            
            % Ajout au signal de la trame spt et décalage en fréquence
            deltaT_reel = randi([1, 100]);
            deltaF = randi([-1000, 1000]);
            phi0 = 2 * pi * rand();
           
            D = zeros(1, D_max);
            D(deltaT_reel) = 1;
            A = [spt, signal];
            signalSPT = conv(D, A);
            Ps = mean(abs(signalSPT).^2);
            N0 = Ps * Fse / EbN0_valeurs(idx);

            % Ajout du bruit gaussien
            signalSPT_length = length(signalSPT);
            bruit = sqrt(N0 / 2) * randn(1, signalSPT_length);
            signal_bruite = signalSPT .* exp(-1j * (2 * pi * deltaF * signalSPT + phi0)) + bruit;
            
            % Synchronisation temps
            [signal_synchroT, ~] = synchronisation(signal_bruite, spt, Tp, Te, Ts, size_trame);
            
            % Convolution et échantillonnage
            rl_t = conv(signal_synchroT, porte, 'full');
            rlt_sliced = rl_t(Fse / 2:end);
            rm = rlt_sliced(1:Fse / 2:end);

            % Décision sur les bits reçus
            bits_recus = cplxdecision(rm);

            % Calcul du nombre d'erreurs
            num_errors = num_errors + sum(bits ~= bits_recus(1:length(bits)));
            num_bits = num_bits + Nb;
        end
        
        % Calcul du TEB pour ce Eb/N0
        teb1(idx) = num_errors / num_bits;
    end

    % Boucle de simulation pour la seconde partie (sans synchronisation temporelle)
    teb2 = zeros(size(EbN0_dB));
    for idx = 1:length(EbN0_dB)
        num_errors = 0;
        num_bits = 0;
        
        while num_errors < num_errors_threshold
            % Génération des bits
            bits = randi([0, 1], 1, Nb);
            
            % Modulation PPM
            signal = mod_PPM(bits, Fse);
            Ps = mean(abs(signal).^2);
            N0 = Ps * Fse / EbN0_valeurs(idx);
            
            % Ajout du bruit gaussien
            bruit = sqrt(N0 / 2) * randn(1, length(signal));
            signal_bruite = signal + bruit;
            
            % Démodulation et décision
            rl_t = conv(signal_bruite, porte, 'full');
            rlt_sliced = rl_t(Fse / 2:end);
            rm = rlt_sliced(1:Fse / 2:end);

            % Décision sur les bits reçus
            bits_recus = decision(rm, v0);

            % Calcul du nombre d'erreurs
            num_errors = num_errors + sum(bits ~= bits_recus);
            num_bits = num_bits + Nb;
        end
        
        % Calcul du TEB pour ce Eb/N0
        teb2(idx) = num_errors / num_bits;
        % Calcul Pb
        pb = 0.5 * erfc(sqrt(EbN0_valeurs));
    end

    % Tracé des résultats sur une même figure
    figure;
    semilogy(EbN0_dB, teb1, 'r.-', 'DisplayName', 'Avec synchronisation temporelle');
    hold on;
    semilogy(EbN0_dB, teb2, 'b.-', 'DisplayName', 'Sans synchronisation temporelle');
    semilogy(EbN0_dB, pb, 'g', 'DisplayName', 'Pb théorique');
    grid on;
    xlabel('Eb/N0 (dB)');
    ylabel('TEB');
    title('Taux d''erreur binaire en fonction du rapport Eb/N0');
    legend('show');
    hold off;
end
