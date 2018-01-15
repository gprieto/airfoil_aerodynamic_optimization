function polars = runXfoil(file)

%% Create a new instance of the XFOIL class, and set some properties
xf = XFOIL('/usr/bin/xfoil');
xf.KeepFiles = false; % Set it to true to keep all intermediate files created (Airfoil, Polars, ...)
xf.Visible = true;    % Set it to false to hide XFOIL plotting window

%% Create a NACA 5-series airfoil
if (nargin>0)
    xf.Airfoil =  Airfoil(file);
else
    xf.Airfoil =  Airfoil.createNACA5('23012',150);
end
% To create a NACA 4-series, use   >> xf.Airfoil =  Airfoil.createNACA4('0012');
% To load an existing airfoil, use >> xf.Airfoil =  Airfoil('naca0012.dat');

%% Setup the action list


%Add five filtering steps to smooth the airfoil coordinates and help convergence
%xf.addFiltering(5);

%Switch to OPER mode, and set Reynolds = 3E7, Mach = 0.1
xf.addOperation(3E7,0.1,4);

%Set maximum number of iterations
xf.addIter(100)

%Initializate the calculations
xf.addAlpha(0,true);

%Create a new polar
xf.addPolarFile('Polar.txt');

%Calculate a sequence of angle of attack, from 0 to 25 degrees, step size of 0.1 degrees
xf.addAlpha(0:0.1:20);

%Close the polar file
xf.addClosePolarFile;

%And finally add the action to quit XFOIL
xf.addQuit;

%% Now we're ready to run XFOIL
xf.run
disp('Running XFOIL, please wait...')

%% Wait up to 100 seconds for it to finish... 
%It is possible to run more than one XFOIL instance at the same time
finished = xf.wait(2); 
polars = [];
%% If successfull, read and plot the polar
if finished
    disp('XFOIL analysis finished.')
    xf.readPolars;
    polars = xf.Polars{1};
    %figure
    %xf.plotPolar(1);
else
    xf.kill;
end
