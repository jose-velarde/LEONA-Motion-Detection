function [array] = removeZeros(array, row)
skip_start_zeros = 0;
skip_end_zeros = 0;
for i = 1:size(array(row,:),2)
    if array(row,i) == 0 && skip_start_zeros == 0;
        array(row,i) = NaN;
    else
        skip_start_zeros = 1;
    end
    j = i;
    j= j -1;
    if array(row,end-j) == 0 && skip_end_zeros == 0;
        array(row,end-j) = NaN;
    else
        skip_end_zeros = 1;
    end
end

end