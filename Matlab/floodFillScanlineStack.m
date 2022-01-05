function [list_pix] = floodFillScanlineStack(x, y, temp, tresholdTemp, tempData, plottedLons, plottedLats, fig, writerObj)
if tresholdTemp == temp
    return;
end

h = size(tempData,1);
w = size(tempData,2);
stack = zeros(1,2);
list_pix = zeros(floor(h*w/3),2);

stack(1,:) = [x y];
i = 1;
while ~isempty(stack)

    x = stack(end,1);
    y = stack(end,2);
    stack(end,:) = [];
    
    x1 = x;
    while x1 >= 1 && tempData(y, x1) <= tresholdTemp
        x1 = x1 - 1;
    end
    
    x1 = x1 + 1;
    spanAbove = false;
    spanBelow = false;
    
    while x1 <= w && tempData(y, x1) <= tresholdTemp
        list_pix(i,:) = [y x1];

%         plot(plottedLons(x1),plottedLats(y),'.k', 'color', 'blue');
%         pause(0.00001)
%         frame = getframe(fig);
%         writeVideo(writerObj,frame);

        tempData(y, x1) = 20;
        %% Check top left pixel
        if ~spanAbove && y > 1 && x1 > 1 && tempData((y - 1), (x1-1)) <= tresholdTemp
            stack(end+1,:) = [(x1-1) (y - 1)];
            
            spanAbove = true;
        else
            if spanAbove && y > 1 && x1 > 1 && tempData((y - 1), (x1-1))  >= tresholdTemp
                spanAbove = false;
            end
        end
        %% Check top pixel
        if ~spanAbove && y > 1 && tempData((y - 1), x1) <= tresholdTemp
            stack(end+1,:) = [x1 (y - 1)];
            
            spanAbove = true;
        else
            if spanAbove && y > 1 && tempData((y - 1), x1)  >= tresholdTemp
                spanAbove = false;
            end
        end
        %% Check right pixel
        if ~spanAbove && y > 1 &&  x1 < w && tempData((y - 1), (x1+1)) <= tresholdTemp
            stack(end+1,:) = [(x1+1) (y - 1)];
            
            spanAbove = true;
        else
            if spanAbove && y > 1 && x1 < w && tempData((y - 1), (x1+1))  >= tresholdTemp
                spanAbove = false;
            end
        end
        %% Check bottom left pixel
        if ~spanBelow && (y < (h)) && x1 > 1  && tempData((y + 1), (x1-1)) <= tresholdTemp
            stack(end+1,:) = [(x1-1) (y + 1)];
            
            spanBelow = true;
        else
            if spanBelow && (y < (h))&& x1 > 1  && tempData((y + 1), (x1-1)) >= tresholdTemp
                spanBelow = false;
            end
        end
        
        if ~spanBelow && (y < (h)) && tempData((y + 1), x1) <= tresholdTemp
            stack(end+1,:) = [x1 (y + 1)];
            
            spanBelow = true;
        else
            if spanBelow && (y < (h)) && tempData((y + 1), x1) >= tresholdTemp
                spanBelow = false;
            end
        end
        
        if ~spanBelow && (y < (h))  && x1 < w && tempData((y + 1), (x1+1)) <= tresholdTemp
            stack(end+1,:) = [(x1+1) (y + 1)];
            
            spanBelow = true;
        else
            if spanBelow && (y < (h)) && x1 < w && tempData((y + 1), (x1+1)) >= tresholdTemp
                spanBelow = false;
            end
        end
        
        i = i + 1;
        x1 = x1 + 1;
        
    end

end
list_pix( ~any(list_pix,2), : ) = [];
end



% Processing...
% 1930 pixels in 3.490725 
% 1930 pixels in 0.038957 
% 
% Processing...
% 740 pixels in 1.195686 
% 740 pixels in 0.028829 
% 
% Processing...
% 1189 pixels in 2.232916 
% 1189 pixels in 0.033592
