function floodFill(x, y, newColor, oldColor,screenBuffer, w, h)
  if oldColor == newColor
    return
  end
  
[delta_x,x] = min(abs(plottedLons - x));
[delta_y,y] = min(abs(plottedLats - y));

%   push(stack, x, y);
  stack = [];
  stack = [stack, [x y];

  while(pop(stack, x, y))
    x1 = x;
    while(x1 >= 0 && screenBuffer[y * w + x1] == oldColor) 
        x1--;
    end
    x1++;
    spanAbove = spanBelow = 0;
    while(x1 < w && screenBuffer[y * w + x1] == oldColor)
      screenBuffer[y * w + x1] = newColor;
      if (!spanAbove && y > 0 && screenBuffer[(y - 1) * w + x1] == oldColor)
        stack = [stack, [x1 y-1]
        spanAbove = true;
      elseif (spanAbove && y > 0 && screenBuffer[(y - 1) * w + x1] ~= oldColor)
        spanAbove = false;
      end
      if(!spanBelow && y < h - 1 && screenBuffer[(y + 1) * w + x1] == oldColor)
        stack = [stack, [x1 y+1]
        spanBelow = true;
      elseif(spanBelow && y < h - 1 && screenBuffer[(y + 1) * w + x1] ~= oldColor)
        spanBelow = false;
      end
      x1++;
    end
  end
end