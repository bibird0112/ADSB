function signed_value=conversion_signed_int(bits,MSB)
    %MSB=0 : MSB à gauche
    %MSB=1 : MSB à droite
    n=size(bits,2);
    if MSB == 0
        unsigned_value = bi2de(bits,'left-msb');
        if bits(1) == 1
            signed_value = unsigned_value - 2^n; % Règle du complément à 2
        else
            signed_value = unsigned_value;
        end
    else
        unsigned_value = bi2de(bits,'right-msb');
        if bits(end) == 1
            signed_value = unsigned_value - 2^n;
        else
            signed_value = unsigned_value;
        end
    end


