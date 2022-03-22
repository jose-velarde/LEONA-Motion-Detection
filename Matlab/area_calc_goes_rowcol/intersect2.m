
function [c,ia,ib] = intersect2(a,b,flag) % ia ib ?? 

    % Matrix 'a' contains on the first column the indice of the row 
    % where the min. value is found in each column of matrix 'latarray'.
    % Idem for matrix 'b' (except 'lonarray').
    
c = sortrows([a;b]);
d = c(1:end-1,:)==c(2:end,:);
d = all(d,2); 
c = c(d,:);         % give the indices of the row and column 
