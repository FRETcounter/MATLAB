%Seed from membrane function

function Output = FindSeeds (I, SeedSize)
CC = bwconncomp(I, 4);
L = bwlabel(I, 4);
NumberOfObjects = CC.NumObjects;
cumulativeBinaryImage = false(size(I));
for k = 1:NumberOfObjects
    Obj = L ==k;
    Cent = regionprops(Obj, 'Centroid');
    
    X_Cent = floor(Cent.Centroid(1));
    Y_Cent = floor(Cent.Centroid(2));
    cumulativeBinaryImage(Y_Cent, X_Cent) = 1;
    
end
%
se = strel('square',SeedSize);
SeedImage = imdilate(cumulativeBinaryImage, se);

Output = SeedImage;
end
 
