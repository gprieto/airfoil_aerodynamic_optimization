function filename = coordinates2file( data )
%COORDINATES2FILE Summary of this function goes here
%   Detailed explanation goes here

filename = 'airfoil.txt';

fileID = fopen(filename,'wt');
name = 'Test-Profile \n';
fprintf(fileID,name);
for n=1:length(data)
    fprintf(fileID,'%1.5f %12.5f \n',data(n,1),data(n,2));
end

fclose(fileID);
end

