%**************************************************************************
%**************************************************************************
%**************************************************************************
%                  Developed by Mustafa Sami, RIKEN BDR
%**************************************************************************
%**************************************************************************
%**************************************************************************



function Output = Memb_Segment(Memb_I, ROI_Memb_Gray, BW_Mask, SEG_Method,...
            Previous_Seed, BlockProcessingHight, BlockProcessingWidth, ...
            Previous_Minimum_Seed, Manually_Corrected_Membrane, Multithresh_Num_of_Clusters, ...
            Mask_Dilation, Memb_Constuct_Cluster)



switch SEG_Method
    
    
    
    case{5}  % Block based
        
        
        % 1- Apply 4-levels multithresholding and get the 3 and 4 in small
        % block processing bases.
        
        
        %**************************************************************************
        %%**************Level: Wide Segmentation *********************************
        %**************************************************************************
        % Apply 15x15 block processing Multhithresholding  first 2 levels
        
        
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
        
        Ld2 = watershed(D2, 4);
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
        put_seed = immultiply(I_Dilate, ~Previous_Minimum_Seed);
        put_seed = im2bw(put_seed);
        
        Output = bwmorph(put_seed, 'thin', Inf);   %Final Output
        

    case{6}   %Trace based
        
        Manually_Corrected_Membrane = Manually_Corrected_Membrane;  %Manually_Corrected_Membrane of the previous frame
        ROI_Memb_Gray = ROI_Memb_Gray;
        
       %imwrite(ROI_Memb_Gray, [Subfolder_path_and_name,['\Memb_', N_memb]], 'tif', 'Compression','none');   %XXXXXX
        
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
                        
                        SE = strel('rectangle',[Mask_Dilation   Mask_Dilation]);     %Thickness level of the mask input
                        BW_Significant_Block = imdilate(BW_Significant, SE);
                        Gray_Significant_Block = immultiply(BW_Significant_Block, Memb_I);     %XXX
                        
                        
                        if Mask_Dilation>=3  % in case we have a block contains more than three pixels
                            
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
                            
                            out = imbinarize(Both_Clust);
                            
                            
                        elseif Mask_Dilation <3 % in case we have a block contains less than three pixels
                            
                            
                            out = imbinarize(Gray_Significant_Block);
                            
                        end
                        
                        
                        %****************************
                        % Added December 28 2018
                        
                        out = bwmorph(out, 'thin', inf);  %skel
                        %*****************************
                        
                        Sum_Significant_Pixels = imadd(out, Sum_Significant_Pixels);  % Cummulative sum
                        Sum_Significant_Pixels = imbinarize(Sum_Significant_Pixels);
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
        Ld2 = watershed(D2, 4);
        II = Ld2;
        II(II > 0) = 1;
        thr = graythresh(II);
        II = imbinarize(II,thr);
        II = ~II;
        %Now smooth the segmented membrane generated from watershed by:
        % 0- thinning to inf remove the sharpness caused by watershed
        % 1- Dilation of 3x3
        % 2- put the minimum seed. Because small cell might disappear when applying step 1
        % 3- apply thinning to inf
        
        % Binarize the membrane because it is not logical yet
        
        %Thin_II = bwmorph(II, 'thin', Inf);
        
        %first thinning
        s = [10,10];  %pad the image
        I = padarray(II,s,0,'both');
        I_thin = bwmorph(I, 'thin', Inf); %Thin
        I_Spur = bwmorph(I_thin, 'spur', Inf);  %4-spur removal
        I_Clean = bwmorph(I_Spur, 'clean'); % 5-clean the image from isolated single pixels
        I_Remove_Pad = I_Clean(1+s(1):end-s(1),1+s(2):end-s(2)); % remove the padding
        
        First_I_Thin = RemoveSingelPixelObject(I_Remove_Pad);
        
        
        Smooth_Dilation_Size = 3;
        SE_Wide = strel('rectangle', [Smooth_Dilation_Size   Smooth_Dilation_Size]);
        I_Dilate = imdilate(First_I_Thin, SE_Wide);
        
        
        % now put the minimum seed
        put_seed = immultiply(I_Dilate, ~Previous_Minimum_Seed);
        put_seed = im2bw(put_seed);

        %Second thinning after putting the seed
        s = [10,10];  %pad the image
        I = padarray(put_seed,s,0,'both');
        I_thin = bwmorph(I, 'thin', Inf); %Thin
        I_Spur = bwmorph(I_thin, 'spur', Inf);  %4-spur removal
        I_Clean = bwmorph(I_Spur, 'clean'); % 5-clean the image from isolated single pixels
        I_Remove_Pad = I_Clean(1+s(1):end-s(1),1+s(2):end-s(2)); % remove the padding
        
        Second_I_Thin = RemoveSingelPixelObject(I_Remove_Pad);
        Output = Second_I_Thin;
        
end

end

