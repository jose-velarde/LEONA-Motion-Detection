function [list_pix, border_pix] = floodFillScanlineStack(x, y , temp, thresholdTemp, tempData, preallocate, fig, writerObj)
if thresholdTemp == temp
    return;
end

h = size(tempData,1);
w = size(tempData,2);
stack = zeros(1,2);
list_pix = zeros(preallocate,2);
border_pix = zeros(10000,2);
% stack = zeros(20000,2);

stack(1,:) = [x y];
i = 1;
% j = 1;
k = 1;
while ~isempty(stack)
    x = stack(end,1);
    y = stack(end,2);
    stack(end,:) = [];
%     x = stack(j,1);
%     y = stack(j,2);
%     stack(j,:) = [];
%     j = j - 1;
    x1 = x;
    while x1 >= 1 && tempData(y, x1) <= thresholdTemp
        x1 = x1 - 1;
    end
    
    x1 = x1 + 1;
    spanAbove = false;
    spanBelow = false;

    border = true;
    while x1 <= w && tempData(y, x1) <= thresholdTemp
        if border
%             border_pix(j,:) = [x1, y]; %Modificar esto
            border_pix(k,:) = [y, x1];
            k = k + 1;
            border = false;
        end
        list_pix(i,:) = [y x1]; %y: lon pixel coordinate position, x: lat pixel coordinate position
%           list_pix(i,:) = [x1 y]; %Modificar esto
          
%         plot(plottedLons(x1),plottedLats(y),'.k', 'color', 'white');
%         pause(0.00001)
%         frame = getframe(fig);
%         writeVideo(writerObj,frame);
        
        tempData(y, x1) = 0;
        %% Check top left pixel
        if ~spanAbove && y > 1 && x1 > 1 && tempData((y - 1),(x1-1)) <= thresholdTemp
            stack(end+1,:) = [(x1-1) (y - 1)];
%             j = j +1 ;
%             stack(j,:) = [(x1-1) (y - 1)];
            spanAbove = true;
        else
            if spanAbove && y > 1 && x1 > 1 && tempData((y - 1), (x1-1))  >= thresholdTemp
                spanAbove = false;
            end
        end
        %% Check top pixel
        if ~spanAbove && y > 1 && tempData((y - 1), x1) <= thresholdTemp
            stack(end+1,:) = [x1 (y - 1)];
%             j = j +1 ;
%             stack(j,:) = [x1 (y - 1)];
            spanAbove = true;
        else
            if spanAbove && y > 1 && tempData((y - 1), x1)  >= thresholdTemp
                spanAbove = false;
            end
        end
        %% Check top right pixel
        if ~spanAbove && y > 1 &&  x1 < w && tempData((y - 1), (x1+1)) <= thresholdTemp
            stack(end+1,:) = [(x1+1) (y - 1)];
%             j = j +1 ;
%             stack(j,:) = [(x1+1) (y - 1)];
            spanAbove = true;
        else
            if spanAbove && y > 1 && x1 < w && tempData((y - 1), (x1+1))  >= thresholdTemp
                spanAbove = false;
            end
        end
        %% Check bottom left pixel
        if ~spanBelow && (y < (h)) && x1 > 1  && tempData((y + 1), (x1-1)) <= thresholdTemp
            stack(end+1,:) = [(x1-1) (y + 1)];
%             j = j +1 ;
%             stack(j,:) = [(x1-1) (y + 1)];
            spanBelow = true;
        else
            if spanBelow && (y < (h))&& x1 > 1  && tempData((y + 1), (x1-1)) >= thresholdTemp
                spanBelow = false;
            end
        end
        %% Check bottom pixel
        if ~spanBelow && (y < (h)) && tempData((y + 1), x1) <= thresholdTemp
            stack(end+1,:) = [x1 (y + 1)];
%             j = j +1 ;
%             stack(j,:) = [x1 (y + 1)];
            spanBelow = true;
        else
            if spanBelow && (y < (h)) && tempData((y + 1), x1) >= thresholdTemp
                spanBelow = false;
            end
        end
        %% Check bottom right pixel
        if ~spanBelow && (y < (h))  && x1 < w && tempData((y + 1), (x1+1)) <= thresholdTemp
            stack(end+1,:) = [(x1+1) (y + 1)];
%             j = j +1 ;
%             stack(j,:) = [(x1+1) (y + 1)];
            spanBelow = true;
        else
            if spanBelow && (y < (h)) && x1 < w && tempData((y + 1), (x1+1)) >= thresholdTemp
                spanBelow = false;
            end
        end
        
        i = i + 1;
        x1 = x1 + 1;
        
    end
    
    if tempData(y, (x1-1)) == 0
        border_pix(k,:) = [y, (x1-1)];
        k = k + 1;
    end
end
list_pix( ~any(list_pix,2), : ) = [];
border_pix( ~any(border_pix,2), : ) = [];

end
