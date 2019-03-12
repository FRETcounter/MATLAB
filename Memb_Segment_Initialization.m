%**************************************************************************
%**************************************************************************
%**************************************************************************
%                  Developed by Mustafa Sami, RIKEN BDR
%**************************************************************************
%**************************************************************************
%**************************************************************************


function Output = Memb_Segment_Initialization(ROI_Memb_Gray,  Mask_Dilation,  ...
    BW_Mask, SEG_Method, Previous_Seed, BlockProcessingHight, BlockProcessingWidth)


switch SEG_Method
    
    case{2}
        level = 1;
        
        I = ROI_Memb_Gray;
        Comp_I = imcomplement(I);
        bw = im2bw(Comp_I);
        D = -bwdist(~bw);
        %Ld = watershed(D, 4);
        mask = imextendedmin(D,level);
        %imshowpair(bw,mask,'blend')
        D2 = imimposemin(D,mask);
        Ld2 = watershed(D2, 4);
        bw3 = bw;
        bw3(Ld2 == 0) = 0;
        
        Out_I = bw3;%*************** First Output
        
        I = ~Out_I;
        
        % Thinning
        I = bwmorph(I,'thin', inf);
        % Dilation
        SE1 = strel('rectangle',[Mask_Dilation Mask_Dilation]);%Never use 4x4. It will couse unequal increasing. Use 3x3 or 5x5
        
        I = imdilate(I,SE1); %******************************************************* Need seeding after the Dilation
        
        I = imsubtract(I, Previous_Seed);   
        I = im2bw(I);
        
        % 2nd thinning to remove flying bobles
        I = bwmorph(I,'thin', inf);
        % Frame 4 sides size X
        I = Four_Sides_Frame (I, Frame_Val);
        % Spur
        I = bwmorph(I,'spur', inf);
        % Largest
        I = Largest_Obj (I);
        %14 2nd dilation followed by thinning to smooth the contours
        I = imdilate(I,SE1); %******************************************************* Need seeding after the Dilation
        
        I = imsubtract(I, Previous_Seed);   
        I = im2bw(I);
        
        % Thinning
        I = bwmorph(I,'thin', inf);
        % final spur removal
        Output = bwmorph(I,'spur', inf);   %Final Output
        
        
        
    case{3}  % Multi-Thresholding
        
        Clus = ROI_Memb_Gray;
        
        k = 4;
        
        thresh = multithresh(Clus,k-1);
        seg_I = imquantize(Clus,thresh);
        ind = [];
        Cluster_array = [];
        
        for c = 1:k
            Obj = seg_I==c;
            ind(c, 1) = nnz(Obj);
            %figure, imshow(Obj);
            Cluster_array{c, 1} = Obj;
        end
        
        % Get the third cluster
        
        Third_Clust = (Cluster_array{3,1}); %third cluster
        
        %Advanced Watershed
        level = 3;
        bw = ~Third_Clust;
        D = -bwdist(~bw);
        mask = imextendedmin(D,level);
        %imshowpair(bw,mask,'blend')
        D2 = imimposemin(D,mask);
        Ld2 = watershed(D2, 4);
        bw3 = bw;
        bw3(Ld2 == 0) = 0;
        
        Memb_bw3 = ~bw3;
        
        
        % Thinning
        I = bwmorph(Memb_bw3,'thin', inf);
        % Dilation
        SE1 = strel('rectangle',[Mask_Dilation Mask_Dilation]);%Never use 4x4. It will couse unequal increasing. Use 3x3 or 5x5
        
        I = imdilate(I,SE1); %******************************************************* Need seeding after the Dilation
        
        I = imsubtract(I, Previous_Seed);   
        I = im2bw(I);
        
        % 2nd thinning to remove flying bobles
        I = bwmorph(I,'thin', inf);
        % Frame 4 sides size X
        I = Four_Sides_Frame (I, Frame_Val);
        % Spur
        I = bwmorph(I,'spur', inf);
        % Largest
        I = Largest_Obj (I);
        %14 2nd dilation followed by thinning to smooth the contours
        I = imdilate(I,SE1); %******************************************************* Need seeding after the Dilation
        
        I = imsubtract(I, Previous_Seed);   
        I = im2bw(I);
        
        % Thinning
        I = bwmorph(I,'thin', inf);
        % final spur removal
        Output = bwmorph(I,'spur', inf);   %Final Output
        
        
        
        
    case{4}  % Extended Minima+Watershed+BlockProcessing
        
        
        level = 1;
        
        I = ROI_Memb_Gray;
        Comp_I = imcomplement(I);
        
        %**********************************************************
        %bw = im2bw(Comp_I);  % Old in case {2}
        %apply block processing Otsu segmentation
        
        Window_H  = BlockProcessingHight; %100;
        Window_W  = BlockProcessingWidth; %100;
        Smallest_Obj_remove  = 1;
        
        fun = @(block_struct) thresher(block_struct.data);
        block_otsu = blockproc(Comp_I,[Window_H, Window_W],fun); %block hight then width
        block_otsu = bwareaopen(block_otsu,Smallest_Obj_remove);
        %imshow(block_otsu);
        
        bw = block_otsu;
        
        %**********************************************************
        D = -bwdist(~bw);
        mask = imextendedmin(D,level);
        %imshowpair(bw,mask,'blend')
        D2 = imimposemin(D,mask);
        Ld2 = watershed(D2, 4);
        bw3 = bw;
        bw3(Ld2 == 0) = 0;
        
        Out_I = bw3;%*************** First Output
        
        I = ~Out_I;
        
        % Thinning
        I = bwmorph(I,'thin', inf);
        % Dilation
        SE1 = strel('rectangle',[Mask_Dilation Mask_Dilation]);%Never use 4x4. It will couse unequal increasing. Use 3x3 or 5x5
        
        I = imdilate(I,SE1); %******************************************************* Need seeding after the Dilation
        
        I = imsubtract(I, Previous_Seed);   
        I = im2bw(I);
        
        % 2nd thinning to remove flying bobles
        I = bwmorph(I,'thin', inf);
        % Frame 4 sides size X
        I = Four_Sides_Frame (I, Frame_Val);
        % Spur
        I = bwmorph(I,'spur', inf);
        % Largest
        I = Largest_Obj (I);
        %14 2nd dilation followed by thinning to smooth the contours
        I = imdilate(I,SE1); %******************************************************* Need seeding after the Dilation
        
        I = imsubtract(I, Previous_Seed);   
        I = im2bw(I);
        
        % Thinning
        I = bwmorph(I,'thin', inf);
        % final spur removal
        Output = bwmorph(I,'spur', inf);   %Final Output
        
        
        
    case{5,6,7}
        
        
        
        %**************************************************************************
        %%**************Level: Wide Segmentation *********************************
        %**************************************************************************
        % Apply block processing Otsu segmentation
        
        I_Gray = ROI_Memb_Gray;
        Comp_I = imcomplement(I_Gray);
        %**********************************************************
        Window_H  =  100;                     %Default BlockProcessing Hight = 100;
        Window_W  =  100;                     %Default BlockProcessing Width = 100;
        Smallest_Obj_remove  = 1;
        
        fun = @(block_struct) thresher(block_struct.data);
        block_otsu = blockproc(Comp_I,[Window_H, Window_W],fun); %block hight then width
        block_otsu = bwareaopen(block_otsu,Smallest_Obj_remove);
        %imshow(block_otsu);
        bw = block_otsu;
        
        level = 1;
        D = -bwdist(~bw); % same as D = imcomplement(bwdist(~bw));
        mask = imextendedmin(D,level);
        D2 = imimposemin(D,mask);
        Ld2 = watershed(D2, 4);
        
        II = Ld2;
        II(II > 0) = 1;
        % Binarize the membrane because it is not logical yet
        thr = graythresh(II);
        I = imbinarize(II,thr);
        
        
        % Apply skeletonization procedure
        I = ~I;
        
        Smoothing_Dilation = 3;   % used only to smooth membrane after the watershed
        
        SE_Wide = strel('rectangle', [Smoothing_Dilation   Smoothing_Dilation]);
        I_Dilate = imdilate(I, SE_Wide);
        I_Erode = imerode(I_Dilate, SE_Wide);
        
        %***********************************************************************
        
        s = [10,10];  %pad the image
        Pad_I_Erode = padarray(I_Erode,s,0,'both');
        
        Thin_I = bwmorph(Pad_I_Erode,'thin', inf);
        Spur_I = bwmorph(Thin_I,'spur', inf);
        I_Remove_Pad = Spur_I(1+s(1):end-s(1),1+s(2):end-s(2)); % remove the padding
        
        Output = I_Remove_Pad;
        % **************************************************************************
        
        
        
end



end

