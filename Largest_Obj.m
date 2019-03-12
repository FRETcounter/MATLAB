%**************************************************************************
%**************************************************************************
%**************************************************************************
%                  Developed by Mustafa Sami, RIKEN BDR
%**************************************************************************
%**************************************************************************
%**************************************************************************

% This function will find the largest object inthe binary image

function Output = Largest_Obj (BW)

Labeled_BW = bwlabel(BW,8); %must use 8-connectivity
Area = regionprops(Labeled_BW,'Area');
maxArea = max([Area.Area]);
    
for i=1:size(Area,1)
    if maxArea==Area(i).Area
       max_num = i;
        break
    end
end

Largest_Obj = (Labeled_BW == max_num);

Output = Largest_Obj;
end

