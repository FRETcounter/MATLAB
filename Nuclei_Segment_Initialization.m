function Output = Nuclei_Segment_Initialization(ROI_Nucl_Gray,   ...
        BW_Mask, SEG_Method, Current_Seed, BlockProcessingHight, BlockProcessingWidth, Nuclei_SEG_Method, Min_Nucl_Size)
    
switch Nuclei_SEG_Method
    
    case{1}    % Morita-san images

        BW = imbinarize(ROI_Nucl_Gray, 'adaptive');
        %BW = bwmorph(BW, 'clean');
        X = Min_Nucl_Size;
        BW = bwareaopen(BW, X);
        SE = strel('disk', 2, 4);
        BW = imopen(BW, SE);
        BW = imfill(BW,'holes');
        BW =  imclearborder(BW);
        
        level = 1;
        D = -bwdist(~BW);
        mask = imextendedmin(D,level);
        D2 = imimposemin(D,mask);
        Ld2 = watershed(D2);
        bw3 = BW;
        bw3(Ld2 == 0) = 0;
        Output = bw3;

        
    case{2}   % Future use
        
        
        
    case{3}    % Future use
        
        
end

end


