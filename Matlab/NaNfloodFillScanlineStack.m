function [list_pix, border_pix] = NaNfloodFillScanlineStack(x, y , temp, ~, tempData, plottedLons, plottedLats, fig, writerObj)
if ~isnan(temp)
    return;
end

h = size(tempData,1);
w = size(tempData,2);
stack = zeros(1,2);

list_pix = zeros(h*w,2);
border_pix = zeros(50000,2);

stack(1,:) = [x y];
i = 1;

k = 1;
while ~isempty(stack)
    x = stack(end,1);
    y = stack(end,2);
    stack(end,:) = [];

    x1 = x;
    while x1 >= 1 && isnan(tempData(y, x1))
        x1 = x1 - 1;
    end
    
    x1 = x1 + 1;
    spanAbove = false;
    spanBelow = false;
    
    
    border_pix(k,:) = [y, x1];
    k = k + 1;
%     border_pix(j,:) = [x1, y]; %Modificar esto

    while x1 <= w && isnan(tempData(y, x1))
        list_pix(i,:) = [y x1]; %y: lon pixel coordinate position, x: lat pixel coordinate position
%           list_pix(i,:) = [x1 y]; %Modificar esto
          
%         plot(fig, plottedLons(x1),plottedLats(y),'.k', 'color', 'black');
%         pause(0.00001)
%         frame = getframe(fig);
%         writeVideo(writerObj,frame);
        
        tempData(y, x1) = 255;
        %% Check top left pixel
%         if ~spanAbove && y > 1 && x1 > 1 && isnan(tempData((y - 1),(x1-1)))
%             stack(end+1,:) = [(x1-1) (y - 1)];
%             
%             spanAbove = true;
%         else
%             if spanAbove && y > 1 && x1 > 1 && isnan(tempData((y - 1), (x1-1)))
%                 spanAbove = false;
%             end
%         end
        %% Check top pixel
        if ~spanAbove && y > 1 && isnan(tempData((y - 1), x1))
            stack(end+1,:) = [x1 (y - 1)];
            
            spanAbove = true;
        else
            if spanAbove && y > 1 && ~isnan(tempData((y - 1), x1))
                spanAbove = false;
            end
        end
        %% Check top right pixel
%         if ~spanAbove && y > 1 &&  x1 < w && isnan(tempData((y - 1), (x1+1)))
%             stack(end+1,:) = [(x1+1) (y - 1)];
%             
%             spanAbove = true;
%         else
%             if spanAbove && y > 1 && x1 < w && ~isnan(tempData((y - 1), (x1+1)))
%                 spanAbove = false;
%             end
%         end
        %% Check bottom left pixel
%         if ~spanBelow && (y < (h)) && x1 > 1  && isnan(tempData((y + 1), (x1-1)))
%             stack(end+1,:) = [(x1-1) (y + 1)];
%             
%             spanBelow = true;
%         else
%             if spanBelow && (y < (h))&& x1 > 1  && ~isnan(tempData((y + 1), (x1-1)))
%                 spanBelow = false;
%             end
%         end
        %% Check bottom pixel
        if ~spanBelow && (y < (h)) && isnan(tempData((y + 1), x1))
            stack(end+1,:) = [x1 (y + 1)];

            spanBelow = true;
        else
            if spanBelow && (y < (h)) && ~isnan(tempData((y + 1), x1))
                spanBelow = false;
            end
        end
        %% Check bottom right pixel
%         if ~spanBelow && (y < (h))  && x1 < w && isnan(tempData((y + 1), (x1+1)))
%             stack(end+1,:) = [(x1+1) (y + 1)];
%             
%             spanBelow = true;
%         else
%             if spanBelow && (y < (h)) && x1 < w && ~isnan(tempData((y + 1), (x1+1)))
%                 spanBelow = false;
%             end
%         end
        
        i = i + 1;
        x1 = x1 + 1;
        
    end
    border_pix(k,:) = [y, x1-1];
    k = k + 1;

end
list_pix( ~any(list_pix,2), : ) = [];
border_pix( ~any(border_pix,2), : ) = [];
% list_pix = nonzeros(list_pix');
% list_pix = reshape(v, , )
end
