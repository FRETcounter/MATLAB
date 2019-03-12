%**************************************************************************
%**************************************************************************
%**************************************************************************
%                  Developed by Mustafa Sami, RIKEN BDR
%**************************************************************************
%**************************************************************************
%**************************************************************************


function Output = RemoveSingelPixelObject(I)  %membrane should be in white

burnedImage = ~I; %convert it

Cum_Obj = zeros(size(burnedImage));
Cum_Obj = im2bw(Cum_Obj);
%
[L, num_Obj] = bwlabel(burnedImage,4);


for R = 1:num_Obj
    Obj = L ==R;
    Area_obj = nnz(Obj);
    if Area_obj == 1          % Size of the object
        
        Cum_Obj = imadd(Obj, Cum_Obj);
        Cum_Obj = im2bw(Cum_Obj );
    else
    Cum_Obj = Cum_Obj;
    end
end

XX = imabsdiff(Cum_Obj, burnedImage);
XX = ~XX;
burned_I = bwmorph(XX, 'thin', Inf);

Output = burned_I;

end
