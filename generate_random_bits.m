function bits = generate_random_bits(N)
    % Fonction pour générer N bits aléatoires
    % N : nombre de bits à générer
    % bits : vecteur de bits générés (0 ou 1)

    % Générer un vecteur de N bits aléatoires (0 ou 1) suivant une loi uniforme
    bits = randi([0, 1], 1, N);
end
