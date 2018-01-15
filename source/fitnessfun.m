function [F,elapsedTime] = fitnessfun(x)

    tic;
    airfoil = coordinates2file(cst2coordinates(x));
    polars = runXfoil(airfoil);
    
    if ~isempty(polars) && ~isempty(polars.CD)
        F = min(polars.CD);
        elapsedTime = toc;
    else
        F = 1;
    end

    %F=mean(x);
end

