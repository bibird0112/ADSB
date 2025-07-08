function bk_decision = demod_PPMcplx(sl_t,Ts,Te,porte)
    
    Fse = Ts/Te;    

    % Convolution par p1(-t)
    rl_t = conv(yl_t,porte, "full"); %On prend toutes les valeurs pour avoir la valeur en 0
    rlt_sliced = rl_t(Fse/2:end); % On enlève les parties avant t=0, on décale de Fse/4 valeurs pour compenser le filtre
    
    %Echantillonage 

    rm=rlt_sliced(1:Fse/2:end); %Echantillonage a Ts/2

    %Décision
    bk_decision = cplxdecision(rm);
    