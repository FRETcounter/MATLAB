
function Output = Memb_Segment(ROI_Memb_Gray,   BW_Mask, SEG_Method,...
    Current_Seed, BlockProcessingHight, BlockProcessingWidth, ...
    Current_Minimum_Seed, Manually_Corrected_Membrane, Multithresh_Num_of_Clusters, ...
    Mask_Dilation, Memb_Constuct_Cluster)



switch SEG_Method
    
    
    
    case{5}  % Block based
        
        
        % 1- Apply 4-levels multithresholding and get the 3 and 4 in small
        % block processing bases.
        
        
        %**************************************************************************
        %%**************Level: Wide Segmentation *********************************
        %**************************************************************************
        % Apply 15x15 block processing Multhithresholding  first 2 levels
        
        % BlockProcessingHight = 15;
        % BlockProcessingWidth = 15;
        
        I = ROI_Memb_Gray;
        %Comp_I = imcomplement(I);
        Num_Clust = 4; % Four clusters
        %3rd Cluster
        fun = @(block_struct) Memb_Block_proc_Multithresh(Num_Clust, block_struct.data);
        block_multithresh = blockproc(I, [BlockProcessingHight, BlockProcessingWidth],fun, ...  %block hight then width
            'BorderSize', [0 0]); %pad each block with BorderSize to avoid straight line artifacts that occurs when using blockprocessing
        %imshow(block_multithresh);
        block_otsu = block_multithresh;
        bw = ~block_otsu;  %membrane in black
        
        %Watershed set
        level = 1;
        D = -bwdist(~bw);
        mask = imextendedmin(D,level);
        
        D2 = imimposemin(D,mask);
        
        Ld2 = watershed(D2);
        II = Ld2;
        II(II > 0) = 1;
        
        %Now smooth the segmented membrane generated from watershed by:
        % 1- Dilation of 3x3
        % 2- put the minimum seed. Because small cell might close when applying
        % step 1
        % 3- apply thinning inf
        
        
        % Binarize the membrane because it is not logical yet
        thr = graythresh(II);
        II = imbinarize(II,thr);
        II = ~II;
        Smooth_Dilation_Size = 3;
        SE_Wide = strel('rectangle', [Smooth_Dilation_Size   Smooth_Dilation_Size]);
        I_Dilate = imdilate(II, SE_Wide);
        
        % now put the minimum seed
        put_seed = immultiply(I_Dilate, ~Current_Minimum_Seed);
        put_seed = im2bw(put_seed);
        
        Output = bwmorph(put_seed, 'thin', Inf);   %Final Output
        
        
        
        
        
    case{6}   %Trace based
        
        Manually_Corrected_Membrane = Manually_Corrected_Membrane;  %Manually_Corrected_Membrane of the previous frame
        ROI_Memb_Gray = ROI_Memb_Gray;
        [rows,cols] = size(Manually_Corrected_Membrane);
        Memb_Significant_Pixels = zeros(size(Manually_Corrected_Membrane));
        Sum_Significant_Pixels = im2bw(zeros(size(Manually_Corrected_Membrane)));
        for row = 1 : rows
            for col = 1 : cols
                Int_Val = Manually_Corrected_Membrane (row, col);
                if Int_Val ==1
                    try
                        Memb_Significant_Pixels(row, col) = 1;
                        BW_Significant = im2bw(Memb_Significant_Pixels);
                        
                        SE = strel('rectangle',[Mask_Dilation Mask_Dilation]);     %Thickness level of the mask input
                        BW_Significant_Block = imdilate(BW_Significant, SE);
                        Gray_Significant_Block = immultiply(BW_Significant_Block, ROI_Memb_Gray);
                        
                        %Get the highest 2 clusters of four
                        
                        Num_Clust = Multithresh_Num_of_Clusters;
                        thresh = multithresh(Gray_Significant_Block, Num_Clust-1);
                        seg_I = imquantize(Gray_Significant_Block, thresh);
                        RGB = label2rgb(seg_I);
                        ind = [];
                        Cluster_array = [];
                        
                        for c = 1:Num_Clust
                            Obj = seg_I==c;
                            ind(c, 1) = nnz(Obj);
                            %figure, imshow(Obj);
                            
                            Cluster_array{c, 1} = Obj;
                        end
                        
                        Last_Cluster =(Cluster_array{Num_Clust,1});
                        Second_Last_Cluster =(Cluster_array{(Num_Clust-1),1});
                        
                        if Memb_Constuct_Cluster ==1
                            Both_Clust = imadd(Last_Cluster, Last_Cluster);
                        elseif Memb_Constuct_Cluster ==2
                            Both_Clust = imadd(Last_Cluster, Second_Last_Cluster);
                        end
                        
                        out = im2bw(Both_Clust);
                        
                        
                        %****************************
                        % Added December 28 2018
                        
                        out = bwmorph(out, 'thin', inf);  %skel
                        %*****************************
                        
                        Sum_Significant_Pixels = imadd(out, Sum_Significant_Pixels);  % Cummulative sum
                        Sum_Significant_Pixels = im2bw(Sum_Significant_Pixels);
                        Memb_Significant_Pixels = zeros(size(Manually_Corrected_Membrane));
                        
                    catch
                        break   %in case if fail due to empty clusters
                        
                    end
                end
            end
        end
        bw = ~Sum_Significant_Pixels;  %membrane in black
        
        %Watershed set
        level = 1;
        D = -bwdist(~bw);
        mask = imextendedmin(D,level);
        D2 = imimposemin(D,mask);
        Ld2 = watershed(D2);
        II = Ld2;
        II(II > 0) = 1;
        
        %Now smooth the segmented membrane generated from watershed by:
        % 1- Dilation of 3x3
        % 2- put the minimum seed. Because small cell might close when applying step 1
        % 3- apply thinning inf
        
        % Binarize the membrane because it is not logical yet
        thr = graythresh(II);
        II = imbinarize(II,thr);
        II = ~II;
        Smooth_Dilation_Size = 3;
        SE_Wide = strel('rectangle', [Smooth_Dilation_Size   Smooth_Dilation_Size]);
        I_Dilate = imdilate(II, SE_Wide);
        
        % now put the minimum seed
        put_seed = immultiply(I_Dilate, ~Current_Minimum_Seed);
        put_seed = im2bw(put_seed);
        
        Output = bwmorph(put_seed, 'thin', Inf);   %Final Output result image
        
        
end

end

