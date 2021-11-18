%This works perfectly!


function [pixarea, k, ukneigh, un] = neighboors(pixarea, k, ukneigh, un, outtemp, rc, T, flg, updown)

r=rc(1);
c=rc(2);

if strcmp(updown,'down')==1 %going down, 
    ad=1;   %unknown neighboor is next row down
    krst=r-2+ad;
    krend=r+1+ad;
    kinc=1;
else       %going up,
    ad=0;   %unknown neighboor is next row up
    krst=r+1+ad;
    krend=r-2+ad;
    kinc=-1;
end
for kr=krst:kinc:krend
    for kc=c-1:c+1
        rc= [kr kc];
        outtemp (kr,kc);
        if kr~=r+2 & kr~=r-2
            if outtemp(kr,kc) <= T & isempty(intersect2(pixarea, rc, 'rows')) 
                pixarea(k,:)=[kr kc];
                k=k+1;
            end
        elseif outtemp(kr,kc) <= T & isempty(intersect2(pixarea, rc, 'rows'))...
         & isempty(intersect2(ukneigh, rc, 'rows'))
                if flg~=2 
                    if ~isempty(intersect(pixarea, [kr-1 kc], 'rows'))    
                        ukneigh(un,:)=[kr kc];
                        un=un+1;
                    end
                elseif ~isempty(intersect(pixarea, [kr+1 kc], 'rows'))
                    ukneigh(un,:)=[kr kc];
                    un=un+1;
                end    
        end     
    end    
end 

