clear all
close all


nvars = 8;

options = gaoptimset(@ga);
options = gaoptimset(options,...
    'PlotFcn',{@gaplotbestf,@gaplotdistance,@gaplotgenealogy,@gaplotscorediversity,@gaplotscores},...
    'Display','diagnose',...
    ...%'SelectionFcn',@selectionfun,...
    'PopulationSize',10);

LB = - ones(8,1);
UB = ones(8,1);

LB(1) = 0.1;
UB(nvars/2+1) = -0.1;


A = [- eye(nvars/2) , eye(nvars/2);
    zeros(nvars/2,nvars)];

b = zeros(nvars,1);


[x,fval] = ga(@fitnessfun,nvars,[],[],[],[],[],[]);
