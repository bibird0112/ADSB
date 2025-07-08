%% Tâche 3 : détecteur CRC

clear 
clc
close all

fe = 20e6;
Te = 1/fe;

Ts = 1e-6;
fs = 1/Ts;

Fse = Ts/Te;

bits_emis = randi([0 1],88,1); % Test avec nombre de bits d'une trame ADS-B sans CRC et préambule
polynome = [1 1 1 1 1 1 1 1 1 1 1 1 1 0 1 0 0 0 0 0 0 1 0 0 1];

crc_generator = comm.CRCGenerator(polynome); 
crc_detector = comm.CRCDetector(polynome);

bits_CRC = codageCRC(bits_emis,crc_generator);

%sans bruit
[bits_recus,err1]=m_decodageCRC(bits_CRC,crc_detector);

if err1 == 0
    fprintf("Tâche 3 : Le message envoyé sans bruit est intègre \n");
end

%avec bruit

bits_CRC_bruit = mod_PPM(transpose(bits_CRC),Fse);

sigma2 = 3; %Valeur de la variance
nl_t = randn(size(bits_CRC_bruit)) * sqrt(sigma2);

yl_t = bits_CRC_bruit + nl_t;

% Convolution par p1(-t)
porte = ones(1,Fse/2);
rl_t = conv(yl_t,porte, "full"); %On prend toutes les valeurs pour avoir la valeur en 0
rlt_sliced = rl_t(Fse/2:end); % On enlève les parties avant t=0, on décale de Fse/4 valeurs pour compenser le filtre


bits_CRC_decision = cplxdecision(rlt_sliced);

[bits_recus_bruit,err2]=m_decodageCRC(transpose(bits_CRC_decision),crc_detector);

if err2 == 1
    fprintf("Tâche 3 : Le message envoyé avec bruit n'est pas intègre \n");
else
    fprintf("Tâche 3 : Le message envoyé avec bruit est intègre \n");
end