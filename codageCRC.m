function bits_CRC = codageCRC(bits_emis,crc_generator)
    %Rajoute les bits de CRC à la fin du tableau de bits
    
    bits_CRC = crc_generator(bits_emis); 
end