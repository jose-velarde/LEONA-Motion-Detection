%This works perfectly and is fast!

%Calculate the area of cloud cover with Tir <= -32oC 
%and Tir <= -52oC
%First need to calculate for each pixel dlat and dlon 
%then the correspondent distance and multiply to get the area. 
%Use dlat= ( (lat- lat(k-1)) + (lat(k+1)-lat) )/2

%Momentarly redifine outlat and outlon to include:
%1 row before first row and 1 after last row
% outlat=latarray(frow-1:lrow+1,fcol:lcol);
% [nr nc]=size(outlat);
% for kc=1:nc
%     k=1;
%     for kr=2:nr-1
%         dlat(k,kc)=( abs(outlat(kr,kc)-outlat(kr-1,kc)) + abs(outlat(kr+1,kc)-outlat(kr,kc)) )/2;
%         ddistlat(k,kc) = dlat(k,kc)*6378*(pi/180); %convert dlat in degrees into 
%         k=k+1;                    %dist. in km on the great cicle path
%     end
% end
% %Return to original definition
% outlat=latarray(frow:lrow,fcol:lcol);
% 
% %calculate dlon= ( (lon- lon(k-1)) + (lon(k+1)-lon) )/2
% %include 1 col before first col and 1 after last
% outlon=lonarray(frow:lrow,fcol-1:lcol+1);
% [nr nc]=size(outlon);
% for kr=1:nr
%     k=1;
%     for kc=2:nc-1
%         dlon(kr,k)=( abs(outlon(kr,kc)-outlon(kr,kc-1)) + abs(outlon(kr,kc+1)-outlon(kr,kc)) )/2;
%         ddistlon(kr,k)= dlon(kr,k)*6378*(pi/180)*cos(outlat(kr,kc-1)*(pi/180));%convert dlon 
%         k=k+1 ;      %in degrees into dist. in km on the latitude cicle
%     end
% end
% %Return to original definition
% outlon=lonarray(frow:lrow,fcol:lcol);
% [nr nc]=size(outlon);
% 
% %(differential) area (dA) of each pixel
% dA=ddistlat.*ddistlon; 
% 
% %Now calculate the area of pixels within T range of interest
% 
% %Test the temperature of pixel at center of region of interest
% %And then for adjacent pixels
% centerrow= round(nr/2);
% centercol= round(nc/2);


%%%% Hardcoded

outtemp = plottedTemp;
centerrow= y;
centercol= x;

%%%%%
sr=centerrow;
sc=centercol;
pixarea=zeros(1,2);
k=1; inc=1; r=0;
ukneigh = []; un=1;
flg=0;
oldjump=zeros(1,2);
oj=1;

%Check all neighboors around 1st pixel
v= [sr sc];
% [pixarea k ukneigh un]=oldneighboors2(pixarea, k, ukneigh, un, outtemp, v, T, flg);
[pixarea k ukneigh un]=oldneighboors2(pixarea, k, ukneigh, un, outtemp, v, T, flg, 'down');

sc=sc+ inc;

s=2;
% figure(90) %debuguing
% imagesc(outtemp)
% hold on


while flg ~= 1
    v= [sr sc];
    if outtemp(sr,sc) <= T & isempty(intersect2(pixarea, v, 'rows'))
        pixarea(k,:)=v;
        k=k+1;
        [pixarea k ukneigh un]=neighboors(pixarea, k, ukneigh, un, outtemp, v, T, inc, flg);
        sc=sc+ inc;
        
    elseif outtemp(sr,sc) <= T & ~isempty(intersect2(pixarea, v, 'rows'))
        [pixarea k ukneigh un]=neighboors(pixarea, k, ukneigh, un, outtemp, v, T, inc, flg, 'up');
        sc=sc+ inc;
        
    elseif outtemp(sr,sc) > T
        [ukneigh un]=ukneighboors(ukneigh, pixarea, outtemp, v, un, T);
        
        %Achieved the boundary, have to jump to a new row
        next=[];
        if sr==centerrow  & flg == 0 %very first time -> go down
            next=pixarea(find(pixarea(:,1)==max(pixarea(:,1))),:);
        elseif sr==centerrow & flg > 0  %first time up -> go up
            next=pixarea(find(pixarea(:,1)==min(pixarea(:,1))),:);
        elseif sr-centerrow >0 %going down -> go down
            next=pixarea(find(pixarea(:,1)==max(pixarea(:,1))),:);
        elseif sr-centerrow <0 %going up -> go up
            next=pixarea(find(pixarea(:,1)==min(pixarea(:,1))),:);
        end    
              
        if inc == 1 %going to the right
            jump= next(find( next(:,2)==max((next(:,2))) ),:);
            inc = -1 ;       %reverse direction
        else %going to the right
            jump = next(find( next(:,2)==min((next(:,2))) ),:);
            inc = 1;         %reverse direction
        end
        if jump(1) ~= sr & isempty(intersect2(oldjump, jump, 'rows')) %going down
            sr =jump(1)  
            sc=jump(2)
            oldjump(oj,:)=jump;
            oj=oj+1;
        else    %got to a corner
            %Check wich unkown neighboors have been included
            %and remove them from the list
            while ~isempty(r)
                values=[]; r=[];
                [values r rb]=intersect(ukneigh, pixarea, 'rows');
                ukneigh(r,:)=[];
                un=size(ukneigh,1)+1;
            end
            r=0;
            if ~isempty(ukneigh)  %go to uknown neighboors 
                if sr>centerrow %going down -> go down
                    next=ukneigh(find(ukneigh(:,1)==max(ukneigh(:,1))),:);
                else    %going up -> go up
                    next=ukneigh(find(ukneigh(:,1)==min(ukneigh(:,1))),:);
                end    
                if inc == -1 
                    jump= next(find( next(:,2)==max((next(:,2))) ),:);
                else
                    jump = next(find( next(:,2)==min((next(:,2))) ),:);
                end
                plot (pixarea(:,2),pixarea(:,1),'.k');
                if sr>centerrow & jump(1)<centerrow
                    flg=2    %start checking upper image
                    sr=centerrow
                    sc=centercol
                elseif isempty(intersect2(oldjump, jump, 'rows'))
                    sr =jump(1)      
                    sc=jump(2)
                    oldjump(oj,:)=jump;
                    oj=oj+1;
                end    
                %sr=ukneigh(size(ukneigh,1),1)  %(go to last element of list) 
                %sc=ukneigh(size(ukneigh,1),2) 
                %ukneigh(size(ukneigh,1),:)=[];
                %un=size(ukneigh,1)+1;
            %Check if all unkown neighboors have been included    
            elseif flg==0 & isempty(jump)
                flg=2    %start checking upper image
                sr=centerrow
                sc=centercol
            elseif flg > 0 %checked all unkown neighboors
                flg=1   %stop
            end
        end %if jump   

        %If not eof, after jump -> check all neighboors
        if flg~=1 
            v= [sr sc];
            [pixarea k ukneigh un]=oldneighboors2(pixarea, k, ukneigh, un, outtemp, v, T, flg, 'up');
            sc=sc+ inc;
        end
        
    end %if outtemp
        
         
end  %while  

hold off %debuguing
% stormarea=sum(sum( dA(pixarea(:,1),pixarea(:,2)) ));