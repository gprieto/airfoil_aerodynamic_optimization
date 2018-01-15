classdef XFOIL < handle
    properties
        Airfoil
        Actions    = {}
        Polars
        PolarFiles = {};
        PressureFiles = {};
        Visible = true
        Process
        XFOILExecutable = 'xfoil.exe'; %/usr/bin/xfoil for Linux
        KeepFiles = false;
        KeepAirfoilFile = true;
        ID
    end
    
    properties (SetAccess = private)
        AirfoilFile = ''
    end
    
    
    methods (Static, Hidden)
        function ID = NewID()
            persistent LastID
            if isempty(LastID)
                LastID=0;
            end
            ID=LastID+1;
            LastID=ID;
        end
    end
    
    methods (Hidden)
        function CreateActionsFile(this)
            fid = fopen(this.ActionsFile,'wt+');
            if ~this.Visible
                fprintf(fid,'PLOP\nG\n\n');
            end
            fprintf(fid,'LOAD %s\n',this.AirfoilFile);
            fprintf(fid,'%s\n',this.Actions{:});
            fclose(fid);
        end       
    end
    
    methods (Static)
        function DownloadXFOIL
            h = waitbar(0,'Please wait, downloading XFOIL...');
            URL = 'http://web.mit.edu/drela/Public/web/xfoil/xfoil6.96.zip';
            [f, status] = urlwrite(URL, 'xfoil.zip');
            if status == 0
                warning('XFOIL:NotFound','XFOIL executable was not found in current MATLAB path, and I failed to download it. Please get it at http://web.mit.edu/drela/Public/web/xfoil/');
            end
            ClassPath = mfilename('fullpath');
            ClassPath = fileparts(fileparts(ClassPath)); %Get the directory above the class
            TargetPath = fullfile(ClassPath,'XFOIL');
            unzip(f,TargetPath);
            delete(f);
            addpath(genpath(TargetPath));
            delete(h);            
        end
    end
    
    methods
        function this = XFOIL(XFOILExecutable)
            if nargin == 1 && ~isempty(XFOILExecutable)
                this.XFOILExecutable = XFOILExecutable;
            end
            this.ID=this.NewID;
            
            if this.ID == 1
                disp(repmat('-',1,70));
                disp(' XFOIL - MATLAB interface v1.0');
                disp(' Copyright (c) 2011 by Rafael Oliveira - Contact: rafael@rafael.aero')
                disp(repmat('-',1,70));
                disp(' Thanks for Prof. Mark Drela and all involved on XFOIL development')
                disp(' for making available this amazing tool for all of us.')
                disp(repmat('-',1,70));
            end
            
            if isempty(which(this.XFOILExecutable))
                if ispc
                    ButtonName = questdlg('XFOIL executable not found, should I download it?', 'XFOIL','Yes','No','Yes');
                    if strcmp(ButtonName,'Yes')
                        XFOIL.DownloadXFOIL;
                    else
                        warning('XFOIL:NotFound','XFOIL executable was not found in current MATLAB path, Please get it at http://web.mit.edu/drela/Public/web/xfoil/');
                    end
                else
                    
                    %error('Unix version not yet implemented!')
                end
            end
        end
        
        function AF = ActionsFile(this)
            AF = sprintf('actions_%i.txt',this.ID);
        end     
        
        function run(this)
            
            if ~isa(this.Airfoil,'char')
                if isa(this.Airfoil,'Airfoil')
                    %[d, AirfoilFile] = fileparts(tempname(pwd));
                    %this.AirfoilFile = [AirfoilFile '.dat'];
                    this.AirfoilFile = this.Airfoil.filename;
                    %this.Airfoil.save(this.AirfoilFile);
                else
                    error('Invalid airfoil')
                end
            else
                this.AirfoilFile = this.Airfoil;
            end
            
            if ~exist(this.AirfoilFile,'file')
                error('Airfoil file not found: %s', this.AirfoilFile)
            end
            
            this.CreateActionsFile;
                
            warning('off','MATLAB:DELETE:FileNotFound')
            for i=1:length(this.PolarFiles)
                delete(this.PolarFiles{1})
            end
            warning('on','MATLAB:DELETE:FileNotFound')
            
            if ispc
                if ~exist(fullfile(pwd,this.XFOILExecutable),'file')
                    xfEXE = which(this.XFOILExecutable);
                    [success,msg,msgid] = copyfile(xfEXE,fullfile(pwd,this.XFOILExecutable),'f');
                    if ~success
                        error('Error when copying XFOIL to current directory: %s',msg)
                    end
                end                
                arg = {'cmd', '/c',sprintf('"%s < %s"',this.XFOILExecutable,this.ActionsFile), '>','nul'};
            else
                fid = fopen('script','wt+');
                fprintf(fid,'#!/bin/bash \n\n');
                fprintf(fid,'%s < %s > output 2> outputerr;\n',this.XFOILExecutable,this.ActionsFile);
                fclose(fid);
                
                arg = {'/bin/bash','./script'};
                setenv('GFORTRAN_STDIN_UNIT', '5')
                setenv('GFORTRAN_STDOUT_UNIT', '6')
                setenv('GFORTRAN_STDOUT_ERR', '7')
                %error('Unix version not yet implemented!')
            end
           
            PB = java.lang.ProcessBuilder(arg);
            this.Process = PB.start;
            %delete('./script')
        end
        
        function finished = wait(this,timeout)
            tStart = tic;
            finished=false;
            if nargin<2
                timeout=inf;
            end
            while toc(tStart)<timeout && finished==false
                try %#ok<TRYNC>
                    ev = this.Process.exitValue(); %#ok<NASGU>
                    this.Process=[];
                    finished=true;
                end
                pause(0.01)
            end
        end
        
        function kill (this)
            if ~isempty(this.Process)
                this.Process.destroy;
                this.Process.waitFor();
                disp(this.Process.exitValue());
                pause(3);
                this.Process =[];
            end
        end
        
        function addActions (this, NewActions)
            if ~iscell(NewActions)
                NewActions={NewActions};
            end
            
            this.Actions = cat(1,this.Actions, NewActions);
        end
        
        function addFiltering (this,Steps)
            NewActions = {''; ''; ''; '';'' ;''; ''; ''; ...
                'PANE'; 'MDES'; 'FILT 1.00'};
            FiltActions = repmat({'EXEC'},Steps,1);
            
            NewActions = cat(1,NewActions,FiltActions);
            NewActions{end+1} = '';
            NewActions{end+1} = 'PANE';
            this.addActions (NewActions);
        end
        
        function changePaneling (this,NumberOfNodes)%, TeLeDensity, RefinedArea)
            NewActions = {''; ''; ''; '';'' ;''; ''; ''; ...
                'PPAR'; ['n ' num2str(NumberOfNodes)]; ''; '';...
                'GDES'; 'CADD'; ''; ''; ''; '';};
            this.addActions (NewActions);
        end
        
        function addOperation (this, Reynolds, Mach, N, Vacc, XTrTop, XTrBottom)
            if nargin<2
                Reynolds=0;
                NewActions = {'OPER'};
            else
                if nargin<3
                    Mach=0;
                end
                if nargin<4
                    N=9;
                end
                if nargin<5
                    Vacc=0.01;
                end
                if nargin<6
                    XTrTop=1;
                end
                if nargin<7
                    XTrBottom=1;
                end

                NewActions = {'OPER'; 'VPAR'; ...
                    sprintf('N %1.2f',N); ...
                    sprintf('VACC %1.4f',Vacc); ...
                    'XTR'; sprintf('%1.4f',XTrTop); ...
                    sprintf('%1.4f',XTrBottom); ''; ...
                    sprintf('VISC %1.4f',Reynolds); ...
                    sprintf('MACH %1.6f',Mach)};
            end
            this.addActions (NewActions);
        end
        
        function addIter(this,Iter)
            this.addActions(sprintf('ITER %i',Iter))
        end
        
        function addAlpha(this, Alpha,Init)
            if nargin==2 || ~Init
                if numel(Alpha) == 1
                    this.addActions(sprintf('ALFA %2.4f',Alpha))
                else
                    for i = 1:numel(Alpha)
                        this.addActions(sprintf('ALFA %2.4f',Alpha(i)))
                    end
                end
            else
                this.addActions({sprintf('ALFA %2.4f',Alpha);'INIT'})
            end
        end
        
        function addCL(this, CL, Init)
            if nargin==2 || ~Init
                this.addActions(sprintf('CL %2.4f',CL))
            else
                this.addActions({sprintf('CL %2.4f',CL);'INIT'})
            end
        end        
        
        function addPolarFile(this,PolarFile)
            this.addActions({'PACC'; PolarFile; ''});
            this.PolarFiles{end+1} = PolarFile;
        end
        
        function addPressureFile(this,PressureFile)
            this.addActions(sprintf('CPWR %s', PressureFile));
            this.PressureFiles{end+1} = PressureFile;
        end
        
        function addClosePolarFile(this)
            this.addActions({'PACC';''});
        end
        
        function addQuit(this)
            this.addActions({'';'';'';'';'';'';'';'QUIT';''});
        end
        
        function plotPolar(this,Index)
            p1=this.Polars{Index};
            subplot(2,4,1:4)
            if isa(this.Airfoil,'Airfoil')
                this.Airfoil.plot;
                set(gcf,'Name',this.Airfoil.Name);
            else
                af = Airfoil(this.Airfoil);
                af.plot;
                set(gcf,'Name',af.Name);
            end
            xlabel('x/c')
            ylabel('y/c')

            ax = subplot(2,4,[5 6]);
            plot(p1.CD,p1.CL)
            xlabel('CD')
            ylabel('CL')
            
            subplot(2,4,7);
            axCLCM = plotyy(p1.Alpha,p1.CL,p1.Alpha,p1.CM);
            ax(2) = axCLCM(1);
            set(axCLCM(1),'YTick', get(ax(1),'YTick'));
            xlabel('Alpha [deg]')
            ylabel(axCLCM(1),'CL')
            ylabel(axCLCM(2),'CM')
            
            ax(3) = subplot(2,4,8);
            plot(p1.Top_Xtr,p1.CL,'g')
            hold on
            plot(p1.Bot_Xtr,p1.CL,'r')
            xlabel('x_t_r/c')
            ylabel('CL')
            
            linkaxes(ax,'y');
        end
        
    end
end