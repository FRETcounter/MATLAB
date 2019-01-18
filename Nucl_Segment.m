
%

function Output = Nucl_Segment(ROI_Nucl_Gray, Nuclei_SEG_Method, Manually_Corrected_Membrane, Min_Nucl_Size)

switch Nuclei_SEG_Method
    
    case{1}   
        
        
        BW = imbinarize(ROI_Nucl_Gray, 'adaptive');
        %BW = bwmorph(BW, 'clean');
        X = Min_Nucl_Size;
        BW = bwareaopen(BW, X);
        SE = strel('disk', 2, 4);  % 4 is the default number for periodic line structuring elements used to approximate shape
        BW = imopen(BW, SE);
        BW =  imclearborder(BW);
        BW = imfill(BW,'holes');
        level = 1;
        D = -bwdist(~BW);
        mask = imextendedmin(D,level);
        D2 = imimposemin(D,mask);
        Ld2 = watershed(D2);
        bw3 = BW;
        bw3(Ld2 == 0) = 0;
        Sum_Obj = bw3;
        
        
    case{2}   % Future use
        
        
        
        
        
    case{3}   % Future use
        
        
        
end
Output = Sum_Obj;

end

