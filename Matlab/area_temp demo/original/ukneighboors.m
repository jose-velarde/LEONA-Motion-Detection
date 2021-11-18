%This works perfectly and is fast!
function [ukneigh, un]= ukneighboors(ukneigh, pixarea, outtemp, rc, un, T)

r=rc(1);
c=rc(2);
jj=1;
for kr=r-1:r+1
    for kc=c-1:c+1
        rc= [kr kc];
        if outtemp(kr,kc) <= T & isempty(intersect2(pixarea, rc, 'rows'))...
         & isempty(intersect2(ukneigh, rc, 'rows'))
                    ukneigh(un,:)=[kr kc];
                    un=un+1;
      end    
    end    
end 

