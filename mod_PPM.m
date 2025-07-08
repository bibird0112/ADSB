function [sl]=mod_PPM(b, Fse)
    
    % b : tableau de bits
    sl=zeros(1,size(b,2)*Fse);
    for k = 1:size(b,2)
        i=k-1;
        if b(k) == 1
            sl(i*Fse+1:i*Fse+Fse/2) = 1;
            sl(i*Fse+1+ Fse/2:(i+1)*Fse) = 0;
        else
            sl(i*Fse +1:i*Fse +Fse/2) = 0;
            sl(i*Fse+1+ Fse/2:(i+1)*Fse) = 1;
        end
    end
