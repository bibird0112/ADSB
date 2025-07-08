function [y,z] = Mon_Welch(x,NFFT,Fe)
    % x est le vecteur contenant les échantillons du signal pour lequel il faut calculer la DSP
    % NFFT représente le nombre de points sur lequel les FFT doivent être calculées
    % y est l’estimation de la DSP de x, Fe est la fréquence d’échantillonnage
    
    k =  round(size(x,2)/NFFT);
    ech = zeros(NFFT,k);
    for i=1:k
        ech(1:NFFT,i)=x((i-1)*NFFT+1:i*NFFT);
    end
    ech_fft = (abs(fftshift(fft(ech))).^2)/(Fe*NFFT);
   
    y = mean(ech_fft, 2);
    z = (-NFFT/2 : NFFT/2-1) * (Fe / NFFT); %frequency axis

end