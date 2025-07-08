function bk_decision = decision(rm,v0)
    bk_decision = zeros(1,size(rm,2)/2);

    for i= 1:(size(rm,2))/2
        rk1 = rm(2*i-1:2*i);
        rk2=rk1;
        rk1(1)=rk1(1)-v0;
        rk2(2)=rk2(2)-v0;
        bk_0=norm(rk2)^2; % Calcul des normes pour déterminer bit le plus proche
        bk_1=norm(rk1)^2;
        if bk_0 <= bk_1 % On détermine le bit le plus proche
            bk_decision(1,i)=0;
        else
            bk_decision(1,i)=1;
        end
    end