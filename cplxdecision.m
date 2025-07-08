function bk_decision=cplxdecision(rm)
    %Décision si signal complexe
    bk_decision = zeros(1,size(rm,2)/2);

    for i= 1:(size(rm,2))/2
        rk= rm(2*i-1:2*i);
        if abs(rk(1)) >= abs(rk(2))
            bk_decision(1,i)=1;
        else
            bk_decision(1,i)=0;
        end
    end
end