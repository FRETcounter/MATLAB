%**************************************************************************
%**************************************************************************
%**************************************************************************
%                  Developed by Mustafa Sami, RIKEN BDR
%**************************************************************************
%**************************************************************************
%**************************************************************************


%This software is to track and correct the cell nuclei over time-laps confocal images.


%**************************************************************************
%**************************************************************************

function Nuclei_Segmentation_Track_and_Correct ( ...
    Start_Frame, End_Frame, Min_Nucl_Size, Mask_Dilation, Start_Reference_Mask, Multithresh_Num_of_Clusters, SEG_Method, ...
    Inverese_Reading, BlockProcessingHight, BlockProcessingWidth, Invert_Raw_Image, Previous_Segmentation_Window,...
    Nuclei_SEG_Method, pathName, filelist)


try
    
    filelist_MembRaw = filelist;
    pathName_MembRaw = pathName;
    
    %XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
    %XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
    
    if Start_Reference_Mask == 1 %Checkbox is on. Having a starting reference mask
        
        %XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
        %XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

        %STEP-1 (A) ***************************************************************
        %************************** Raw Images *********************************
        waitfor(msgbox('Please upload your membrane marker raw stack images'));
        
        [fileName,pathName_MembRaw] = uigetfile('*.tif')
        dname       = fullfile(pathName_MembRaw,fileName)
        filelist_MembRaw = dir([fileparts(dname) filesep '*.tif']);
        
        fileNames_MembRaw = {filelist_MembRaw.name}';
        
        fileNames_MembRaw = fileNames_MembRaw (Start_Frame:End_Frame);  % targeted frames
        
        %Inverese reading checkbox
        if Inverese_Reading ==1;
            fileNames_MembRaw = flipud(fileNames_MembRaw);
        end
        
        num_frames = (numel(filelist_MembRaw));
        % MembRaw = imread(fullfile(pathName_MembRaw, fileNames_MembRaw{Start_Frame}));
        MembRaw = imread(fullfile(pathName_MembRaw, fileNames_MembRaw{1}));
        %imshow(MembRaw, []);
        
        Memb_Array = []
        
        End = (numel(fileNames_MembRaw));
        for k = 1:End
            
            Memb_Array{k} = imread(fullfile(pathName_MembRaw, fileNames_MembRaw{k}));
        end
        
        
        %STEP-1 (B) ***************************************************************
        %************************** Starting Mask *********************************
        
        waitfor(msgbox('Please upload your starting mask binary image'));
        
        [fileNames_Start_BW,pathName_Start_BW] = uigetfile({...
            '*.jpg;*.tif;*.gif;*.bmp;*.png', 'All image files(*.jpg,*.tif,*.gif,*.bmp,*.png)';
            '*.jpg;*.jpeg', 'JPEG files(*.jpg)';
            '*.gif', 'GIF files(*.gif)';
            '*.tif;*.tiff', 'TIFF files(*.tif)';
            '*.bmp', 'BMP files(*.bmp)';
            '*.png', 'PNG files(*.png)';
            '*.*', 'All Files (*.*)'}, 'Open an image');
        
        fileNames_Start_BW       = fullfile(pathName_Start_BW,fileNames_Start_BW);
        
        filelist_Start_BW = dir([fileparts(fileNames_Start_BW) filesep '*.tif']);
        
        I_Start_BW                   = imread(fileNames_Start_BW);
        
        %**************************************************************************
        %Step-2  ******************************************************************
        %**************************************************************************
        Start_Frame = Start_Frame;
        End_Frame = End_Frame;
        %**************************************************************************
        %Step-3  ******************************************************************
        %**************************************************************************
        I = ~I_Start_BW;
        ground_truth = Memb_Array{1};
        FileName_ground_truth = fileNames_MembRaw{1};
        
        if Previous_Segmentation_Window == 0
            
            I = Nuclei_Manual_Correction_Tool2 (I, ground_truth, Memb_Array, FileName_ground_truth, Invert_Raw_Image, pathName);
            
        elseif Previous_Segmentation_Window == 1
            
            Previous_ground_truth = Memb_Array{1};  % during initialization only. 
            Previous_FileName_ground_truth = fileNames_MembRaw{1};  % during initialization only. 
            
            I = Nuclei_Manual_Correction_Tool2_TwoWindow (I, ground_truth, Memb_Array, FileName_ground_truth, Invert_Raw_Image, Previous_ground_truth, Previous_FileName_ground_truth, pathName);
        end
        
        I = bwmorph(I, 'spur', Inf);  
        Mask_I = I;
        Mask_Array {1} = Mask_I;  % save the mask

        N_memb = fileNames_MembRaw{1};
        
        Mask_I = ~Mask_I;
        Mask_I = imclearborder(Mask_I, 4);
        
        %imwrite(Mask_I, ['Segmented_Membrane_Result\memb_', N_memb], 'tif')
        
        
        %****************** Initialization Ends ***********************************
        %**************************************************************************
        
        %**************************************************************************
        % Use the manually corrected membrane as a mask to segment the following frame
        %**************************************************************************
        
        
        for k = 2:End
            Memb_I = Memb_Array{k}; %gray raw image
            SE_Mask = strel('rectangle',[Mask_Dilation Mask_Dilation]);     %Thickness level of the mask input
            BW_Mask = imdilate(Mask_Array {k-1}, SE_Mask);
            %put the seed
            Current_Seed = Both_Seeds_Array {k-1};  % was Seed_Array
            
            Current_Minimum_Seed = Seed_Array {k-1} ;
            
            %***********************************************************
            %remove any small projections from the seed because they cause wrong
            %segmentation using the watershed     
            
            SSE = strel('rectangle', [3 3]);
            Current_Seed = imopen(Current_Seed,SSE);
            %***********************************************************
            
            BW_Mask_Seed = imsubtract(BW_Mask, Current_Seed);
            BW_Mask = im2bw(BW_Mask_Seed);
            
            ROI_Nucl_I = immultiply(Memb_I, BW_Mask);
            
            %****************************
            %Now apply segmentation
            Manually_Corrected_Membrane = Mask_Array {k-1};
            ROI_Nucl_Gray = ROI_Nucl_I;
            
            
            I_Nucl_Segment = Memb_Segment(ROI_Nucl_Gray, num_iter, delta_t,...
                kappa, High_Pass_Filter, Dilation_Size, Frame_Val, BW_Mask, ...
                SEG_Method, Current_Seed, BlockProcessingHight, BlockProcessingWidth,...
                Current_Minimum_Seed, Manually_Corrected_Membrane, Multithresh_Num_of_Clusters);
            
            %Clean the image from spurs and any seperated objects
            I = I_Nucl_Segment;
            [H W] = size(I);
            I_Pad = padarray(I, [10 10], 'both');
            I_Spr = bwmorph(I_Pad, 'spur', Inf);  
            I = imcrop(I_Spr, [11 11 (W-1) (H-1)]);
            I = Largest_Obj(I);
            
            
            %Manually correct the current frame
            ground_truth = Memb_Array{k};
            FileName_ground_truth = fileNames_MembRaw{k};
            
            
            if Previous_Segmentation_Window == 0
                I = Nuclei_Manual_Correction_Tool2 (I, ground_truth, Memb_Array, FileName_ground_truth, Invert_Raw_Image, pathName);
                
            elseif Previous_Segmentation_Window == 1
                
                Previous_ground_truth = Memb_Array{k-1};  % during initialization only. 
                Previous_FileName_ground_truth = fileNames_MembRaw{k-1};  % during initialization only. 
                I = Nuclei_Manual_Correction_Tool2_TwoWindow (I, ground_truth, Memb_Array, FileName_ground_truth, Invert_Raw_Image, Previous_ground_truth, Previous_FileName_ground_truth, pathName);
            end
            
            
            I = bwmorph(I, 'spur', Inf);  
            
            Mask_I = I;
            Mask_Array {k} = Mask_I;  % save the mask
            Pre_Seed =  ~Mask_I;
            Seed_Obj = imclearborder(Pre_Seed, 4);
            BW_Seed = FindSeeds (Seed_Obj, SeedSize);
            Seed_Array {k} =  BW_Seed;   % update the seed array
            
            
            SE_FullSeed = strel('rectangle', [Mask_Dilation  Mask_Dilation]);  %or use same Dilation_Size
            Full_Seed = imerode(Seed_Obj, SE_FullSeed);
            Both_Seeds = imadd(Full_Seed, BW_Seed);
            Both_Seeds = im2bw(Both_Seeds);
            Both_Seeds_Array{k} = Both_Seeds;
            
            %Save the segmented membrane result
            N_memb = fileNames_MembRaw{k};
            
            Mask_I = ~Mask_I;
            Mask_I = imclearborder(Mask_I, 4);
            
            %imwrite(Mask_I, ['Segmented_Membrane_Result\memb_', N_memb], 'tif')
            
        end
        
        %XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
        %XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
        
    elseif Start_Reference_Mask == 0  %Checkbox is off. No starting reference mask
        
        %XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
        %XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

        fileNames_MembRaw = {filelist_MembRaw.name}';
        fileNames_MembRaw = fileNames_MembRaw (Start_Frame:End_Frame);  % targeted frames
        
        %Inverese reading checkbox
        if Inverese_Reading ==1
            fileNames_MembRaw = flipud(fileNames_MembRaw);
        end
        
        num_frames = (numel(filelist_MembRaw));
        % MembRaw = imread(fullfile(pathName_MembRaw, fileNames_MembRaw{Start_Frame}));
        MembRaw = imread(fullfile(pathName_MembRaw, fileNames_MembRaw{1}));
        %imshow(MembRaw, []);
        
        Memb_Array = []
        
        End = (numel(fileNames_MembRaw));
        for k = 1:End
            
            Memb_Array{k} = imread(fullfile(pathName_MembRaw, fileNames_MembRaw{k}));
            
        end
        
        %**************************************************************************
        % Apply segmentation to the first frame *****************
        %**************************************************************************
        Memb_Gray = Memb_Array{1};
        
        
        
        % Segmentation filter
        ROI_Nucl_Gray = Memb_Gray;
        
        BW_Mask = true(size(ROI_Nucl_Gray));
        Current_Seed = false(size(ROI_Nucl_Gray));
        %I = Nuclei_Segment_Initialization(ROI_Memb_Gray, num_iter, delta_t, kappa, High_Pass_Filter, Dilation_Size, Frame_Val, BW_Mask, SEG_Method, Current_Seed, BlockProcessingHight, BlockProcessingWidth);
        I = Nuclei_Segment_Initialization(ROI_Nucl_Gray,   ...
            BW_Mask, SEG_Method, Current_Seed, BlockProcessingHight, BlockProcessingWidth, Nuclei_SEG_Method, Min_Nucl_Size);
        
        
        %**************************************************************************
        % Manually correct the first frame **************************************
        %**************************************************************************
        ground_truth = Memb_Array{1};
        FileName_ground_truth = fileNames_MembRaw{1};
        
        
        if Previous_Segmentation_Window == 0
            I = Nuclei_Manual_Correction_Tool2 (I, ground_truth, Memb_Array, FileName_ground_truth, Invert_Raw_Image, pathName);
            Intensity_Label_Image = zeros(size(I));
            s_Cumm = 1;
            s_C = 1;
        elseif Previous_Segmentation_Window == 1
            
            Previous_ground_truth = Memb_Array{1};  % during initialization only.
            Previous_FileName_ground_truth = fileNames_MembRaw{1};  % during initialization only. 
            
            s_Cumm = 1;
            [I, s_Cumm, Intensity_Label_Image] = Nuclei_Manual_Correction_Tool2_TwoWindow (I, s_Cumm, ground_truth, Memb_Array, FileName_ground_truth, Invert_Raw_Image, Previous_ground_truth, Previous_FileName_ground_truth, pathName);
        end

        Intensity_Label_Image = uint16(Intensity_Label_Image);

        Mask_I = I;
        Mask_Array {1} = Mask_I;  % save the mask

        %Save the first corrected membrane
        %mkdir('Segmented_Membrane_Result') %where to save results
        N_memb = fileNames_MembRaw{1};
        
        Mask_I = ~Mask_I;
        Mask_I = imclearborder(Mask_I, 4);
        
        %imwrite(Mask_I, ['Segmented_Membrane_Result\memb_', N_memb], 'tif')

        if Previous_Segmentation_Window == 1   % in case of two window segmentation only
        Subfolder_path_and_name = [pathName 'Intensity_Label_Result'];

        mkdir(Subfolder_path_and_name)
        imwrite(Intensity_Label_Image, [Subfolder_path_and_name,['\Intensity_Label_Image_', N_memb]], 'tif');
        end
        
        %****************** Initialization Ends ***********************************
        %**************************************************************************
        
        %**************************************************************************
        % Use the manually corrected membrane as a mask to segment the following frame
        %**************************************************************************
        
        
        for k = 2:End
            Memb_I = Memb_Array{k}; %gray cropped raw image
            
            
            Manually_Corrected_Membrane = Mask_Array {k-1};
            
            
            
            %Now apply segmentation
            ROI_Nucl_Gray = Memb_I;
            
            I_Nucl_Segment = Nucl_Segment(ROI_Nucl_Gray, Nuclei_SEG_Method, Manually_Corrected_Membrane, Min_Nucl_Size);
            
            %Clean the image from spurs and any seperated objects
            I = I_Nucl_Segment;
           
            
            %Manually correct the current frame
            ground_truth = Memb_Array{k};
            FileName_ground_truth = fileNames_MembRaw{k};
            
            
            if Previous_Segmentation_Window == 0
                I = Nuclei_Manual_Correction_Tool2 (I, ground_truth, Memb_Array, FileName_ground_truth, Invert_Raw_Image, pathName);
                
            elseif Previous_Segmentation_Window == 1
                Previous_ground_truth = Memb_Array{k-1};  % during initialization only. 
                Previous_FileName_ground_truth = fileNames_MembRaw{k-1};  % during initialization only. 
                
                [I, s_C, Intensity_Label_Image] = Nuclei_Manual_Correction_Tool2_TwoWindow (I, s_Cumm, ground_truth, Memb_Array, FileName_ground_truth, Invert_Raw_Image, Previous_ground_truth, Previous_FileName_ground_truth, pathName);
            end
            
            
            Intensity_Label_Image = uint16(Intensity_Label_Image);
            
            s_Cumm = s_C;
            
            I = bwmorph(I, 'spur', Inf);  
            Mask_I = I;
            Mask_Array {k} = Mask_I;  % save the mask
            
            
            
            %Save the segmented membrane result
            N_memb = fileNames_MembRaw{k};
            
            Mask_I = ~Mask_I;
            Mask_I = imclearborder(Mask_I, 4);
            
            %imwrite(Mask_I, ['Segmented_Membrane_Result\memb_', N_memb], 'tif')
            
            if Previous_Segmentation_Window == 1
            imwrite(Intensity_Label_Image, [Subfolder_path_and_name,['\Intensity_Label_Image_', N_memb]], 'tif');
            end
            
        end
        
        
        
    end
    
    %****************************** END ***************************************
    
end





