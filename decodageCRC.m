function [bit_decoded err] = decodageCRC(bits_recus,crc_detector)
    %Enlève le CRC de la fin et détecte si il y a au minimum une erreur
    
    [bit_decoded err] = crc_detector(bits_recus);
    bit_decoded = transpose(bit_decoded);
end