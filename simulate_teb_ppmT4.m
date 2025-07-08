function pb = simulate_teb_ppmT4(Ts, Te, v0)
    % Paramètres
    fe=1/Te;
    Fse = Ts / Te;
    EbN0_dB = 0:1:10; 
    D_max = 250;
    Nb=120;

    Tp = 8e-6;
    % Nombre minimum d'erreurs pour valider TEB
    num_errors_threshold = 100;
    EbN0_valeurs = 10.^(EbN0_dB/10);

    teb = zeros(size(EbN0_dB));
    porte = ones(1, Fse / 2);
    

    % Initialisation pour stocker les MSE (Mean Squared Error)

    % mse_per_ebno = zeros(size(EbN0_dB));

    % Définition Fse et spt
    
    Fse = 20;
    size_spt=8*Fse;
    spt=zeros(1,size_spt);
    spt(1:Fse/2)=1;
    spt(Fse+1:Fse+Fse/2)=1;
    spt(3*Fse+1+Fse/2:4*Fse)=1;
    spt(4*Fse+1+Fse/2:5*Fse)=1;

    for idx = 1:length(EbN0_dB)
        num_errors = 0;
        num_bits = 0;
        num_pckt = 0;
        while num_errors < num_errors_threshold || num_pckt < 1000
            num_pckt = num_pckt + 1;

            %mse_accumulator=0;
            % Génération aléatoire des bits
            bits = randi([0, 1], 1, Nb);
            
            % Modulation PPM
            signal = mod_PPM(bits, Fse);
            size_trame = size(signal,2);
            
            % Ajout au signal de la trame spt et décalage en fréquence
            
            deltaT_reel = randi([1, 100],1,1);

            D = zeros(1, D_max);

            D(deltaT_reel)=1;
            A=[spt,signal];
            signalSPT = conv(D,A);
            
            Ps = mean(abs(signalSPT).^2);

            N0 = Ps*Fse/EbN0_valeurs(idx);

            % Ajout du bruit gaussien

            signalSPT_length = length(signalSPT);

            bruit = sqrt(N0/2) * randn(1, signalSPT_length);

            signal_bruite = signalSPT + bruit;
            
            %Synchronisation temps
            [signal_synchroT,~] = synchronisation(signal_bruite,spt,Tp, Te, Ts, size_trame);

            rl_t = conv(signal_synchroT , porte, 'full');

            % Échantillonnage
            rlt_sliced = rl_t(Fse / 2:end);

            % Échantillonage à Ts/2
            rm = rlt_sliced(1:Fse / 2:end);
            
            bits_recus = decision(rm, v0);

            % Calcul du nombre d'erreurs
            num_errors = num_errors + sum(bits ~= bits_recus(1:length(bits)));
            num_bits = num_bits + Nb;
        end
        
        % Calcul du TEB pour ce Eb/N0
        teb(idx) = num_errors / num_bits;
        %Calcul Pb
        pb = 0.5*erfc(sqrt(EbN0_valeurs)); % Calcul du pb une fois pour tous les Eb/N0
    end
    
    % Tracé des résultats*
    figure;
    semilogy(EbN0_dB, teb, 'r.-');
    hold on;
    semilogy(EbN0_dB, pb, 'g');
    grid on;
    xlabel('Eb/N0 (dB)');
    ylabel('TEB');
    title('Taux d''erreur binaire en fonction du rapport Eb/N0');
end
