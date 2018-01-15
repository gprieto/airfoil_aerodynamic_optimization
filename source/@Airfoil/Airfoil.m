classdef Airfoil < handle
    properties
       filename
       UpperX
       UpperY
       LowerX
       LowerY
       Name
    end
    
    methods (Static)
        AF = createNACA4(Designation, NumPoints)
        AF = createNACA5(Designation, NumPoints)
    end
    
    methods
        function this = Airfoil(filename)
            if nargin == 0
                %Empty airfoil...
                return
            end
            this.filename = filename;
             %Load airfoil from file, using the standard Eppler format
             fid = fopen(filename);
             Header = fgetl(fid);
             tmp=textscan(Header, '%f%f','MultipleDelimsAsOne',true);
             if isempty(tmp{1})
                 HasHeader=true;
                 this.Name = strtrim(Header);
             else
                 HasHeader=false;
                 [~,f,~]=fileparts(filename);
                 this.Name = f;
             end
             frewind(fid);
%             Coordinates = textscan(fid, '%f%f','HeaderLines',HasHeader,'MultipleDelimsAsOne',true);
             fclose(fid);
%             
%             %Separate upper and lower coordinates
%             X=Coordinates{1};
%             Y=Coordinates{2};
%             
%             %Normalize data to 0..1
%             minX=min(X);
%             maxX=max(X);
%             scale = 1/(maxX-minX);
%             X=(X-minX) .* scale;
%             Y=       Y .* scale;
% 
%             %FIXME: Derotate airfoil, if necessary
%             
%             %Find leading edge (X=0)
%             iLE = find(X==0,1,'first');
%             this.UpperX = X(iLE:-1:1);
%             this.UpperY = Y(iLE:-1:1);
%             
%             this.LowerX = X(iLE:end);
%             this.LowerY = Y(iLE:end);
        end
        
        function save (this,filename)
            fid=fopen(filename,'w+');
            fprintf(fid,'%s\n',this.Name);
            fprintf(fid,' %f %f \n',[flipud(this.UpperX) flipud(this.UpperY)].');
            fprintf(fid,' %f %f \n',[this.LowerX(2:end) this.LowerY(2:end)].');
            fclose(fid);
        end
            
        function plot(this,ViewPoints)
            plot(this.UpperX,this.UpperY,'-g');
            hold on
            plot(this.LowerX,this.LowerY,'-r');
            if nargin == 2 && ViewPoints
                plot(this.UpperX,this.UpperY,'og');
                plot(this.LowerX,this.LowerY,'or');
            end
            axis equal
        end

        function [X,Y] = Coordinates(this)
            X=[flipud(this.UpperX); this.LowerX(2:end)];
            Y=[flipud(this.UpperY); this.LowerY(2:end)];
        end
        
        function T=ThicknessAt(this,X)
            UY = interp1(this.UpperX,this.UpperY,X);
            LY = interp1(this.LowerX,this.LowerY,X);
            T = UY-LY;
        end
        
        function T=Thickness(this)
            X=[this.UpperX;this.LowerX];
            T=max(this.ThicknessAt(X));
        end
        
        function T=CamberAt(this,X)
            UY = interp1(this.UpperX,this.UpperY,X);
            LY = interp1(this.LowerX,this.LowerY,X);
            T = (UY+LY)./2;
        end
        
        function T=Camber(this)
            X=[this.UpperX;this.LowerX];
            T=max(this.CamberAt(X));
        end
        
    end
end
