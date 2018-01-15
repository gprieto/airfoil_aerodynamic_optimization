# Aerodynamic optimization of an airfoil 
Aerodynamic optimization of an airfoil using an evolutionary algorithm.

## Motivation
This project was done in May 2016 for the final evaluation of the Visquous Aerodynamics course of second year at ISAE-SUPAERO Graduate School.

## Method
The objective is to find a glider airfoil that maximizes a given performance criteria under visquous flow conditions. The Class Shape Transformation (CST) was chosen to mathematically model the airfoil geometry for its low number of parameters needed and its great modelisation power. CST also allows to easily ensure coherent leading and trailing edge geometries. Two different optimisation algorithms were used:
* A **Genetic algorithm** was first implemented, where the CST parameters were acting as "chromosomes" and an airfoil as an "individual".
* Then a **Hybrid genetic algorithm** was implemented, consisting in two steps. The first step identical to the genetic algorithm, where the second step performs a constrainted optimization to further exploit the local attraction zone found earlier.

Only the Genetic algorithm has been uploaded to date.

## Prerequisites
This project is written in MATLAB, therefore a copy of MATLAB is needed. It also uses several functions of MATLAB's Global Optimization Toolbox. 

Aerodynamic calculations are performed with the [Xfoil](http://web.mit.edu/drela/Public/web/xfoil/) software developped by MIT.

This project was developped in a Unix environment and hasn't been tested in Windows systems.

## Deployment
Simply run with MATLAB the file `GA.m`.

## Results
The following are the optimized airfoil geometries obtained with both algorithms.
![Optimized airfoils](https://github.com/gprieto/airfoil_aerodynamic_optimization/blob/master/airfoils.png)

Results are more extensively shown and discussed (in french) in the PDF file.

## Contributors
* **Guillermo Prieto** - developped the optimization algorithms
* **Charlie Naudy** - worked on the manual optimization on the graphical version of Xfoil
* *Rafael Oliveira* - His [XFOILinterface](https://fr.mathworks.com/matlabcentral/fileexchange/30478-rafael-aero-xfoilinterface)  was used to interface Xfoil with MATLAB. Several improvements were made for it to work on Unix systems (which wasn't implemented in the original software)  
