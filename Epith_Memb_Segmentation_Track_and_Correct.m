%This software is to segment and track the cell membrane over time-laps confocal images.


% Developed by Mustafa Sami, RIKEN CDB, 2016


%**************************************************************************
%**************************************************************************

function  Epith_Memb_Segmentation_Track_and_Correct (     ...
        Start_Frame, End_Frame, Option, Mask_Dilation, Start_Reference_Mask,  SEG_Method, ...
        Inverese_Reading, BlockProcessingHight, BlockProcessingWidth, Invert_Raw_Image, ...
        Previous_Segmentation_Window, Multithresh_Num_of_Clusters, pathName, filelist, Memb_Constuct_Cluster)

%XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
%XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

if Start_Reference_Mask == 1 %Checkbox is on. Having a starting reference mask
    
    %XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
    %XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
    
    
    
    %STEP-1 (A) ***************************************************************
    %************************** Raw Images *********************************
%     waitfor(msgbox('Please upload your membrane marker raw stack images'));
%     
%     [fileName,pathName_MembRaw] = uigetfile('*.tif')
%     dname       = fullfile(pathName_MembRaw,fileName)
%     filelist_MembRaw = dir([fileparts(dname) filesep '*.tif']);
    
    pathName_MembRaw = pathName;
    filelist_MembRaw = filelist;
    
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
        
        I = Manual_Correction_Tool2 (I, ground_truth, Memb_Array, FileName_ground_truth, Invert_Raw_Image, pathName);
        
    elseif Previous_Segmentation_Window == 1
        
        Previous_ground_truth = Memb_Array{1};  % during initialization only. Added 24 March 2017
        Previous_FileName_ground_truth = fileNames_MembRaw{1};  % during initialization only. Added 24 March 2017
        
        I = Manual_Correction_Tool2_TwoWindow (I, ground_truth, Memb_Array, FileName_ground_truth, Invert_Raw_Image, Previous_ground_truth, Previous_FileName_ground_truth, pathName);
    end
    
    I = bwmorph(I, 'spur', Inf);  %Added 17 Nov. 2016.
    Mask_I = I;
    Mask_Array {1} = Mask_I;  % save the mask
    Pre_Seed =  ~Mask_I;
    Seed_Obj = imclearborder(Pre_Seed, 4);
    
    min_seed_size = 2;
    
    BW_Seed = FindSeeds (Seed_Obj, min_seed_size);  % main central seed
    Seed_Array {1} =  BW_Seed;
    
    SE_FullSeed = strel('rectangle', [Mask_Dilation  Mask_Dilation]);  %or use same Dilation_Size
    Full_Seed = imerode(Seed_Obj, SE_FullSeed);
    Both_Seeds = imadd(Full_Seed, BW_Seed);
    Both_Seeds = im2bw(Both_Seeds);
    
    %***********************************************************
    %remove any small projections from the seed because they cause wrong
    %segmentation using the watershed     added 8 May, 2017
    
    SSE = strel('rectangle', [3 3]);
    Both_Seeds = imopen(Both_Seeds,SSE);
    %***********************************************************
    
    Both_Seeds_Array{1} = Both_Seeds;
    %Save the first corrected membrane
    %mkdir('Segmented_Membrane_Result') %where to save results
    
    Subfolder_path_and_name = [pathName 'Segmented_Membrane_Result'];
    mkdir(Subfolder_path_and_name) %where to save results
    
    N_memb = fileNames_MembRaw{1};
    
    Mask_I = ~Mask_I;
    Mask_I = imclearborder(Mask_I, 4);
    
    imwrite(Mask_I, [Subfolder_path_and_name,['\Memb_', N_memb]], 'tif', 'Compression','none')
    
    
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
        %segmentation using the watershed     added 8 May, 2017
        
        SSE = strel('rectangle', [3 3]);
        Current_Seed = imopen(Current_Seed,SSE);
        %***********************************************************
        
        
        
        BW_Mask_Seed = imsubtract(BW_Mask, Current_Seed);
        BW_Mask = im2bw(BW_Mask_Seed);
        
        ROI_Memb_I = immultiply(Memb_I, BW_Mask);
        
        % This step found to have no reason to apply  20 April 2017
        %ROI_Memb_I = uint8( (double(ROI_Memb_I) - double(min(ROI_Memb_I(:)))) /(double(max(ROI_Memb_I(:))) - double(min(ROI_Memb_I(:)))) * 255 );
        
        %ROI_Memb_I = uint8 (ROI_Memb_I);  %found to be best one
        
        %****************************
        
        
        %Now apply segmentation
        Manually_Corrected_Membrane = Mask_Array {k-1};
        ROI_Memb_Gray = ROI_Memb_I;
        
        
        I_Memb_Segment = Memb_Segment(ROI_Memb_Gray, BW_Mask, SEG_Method,...
            Current_Seed, BlockProcessingHight, BlockProcessingWidth, ...
            Current_Minimum_Seed, Manually_Corrected_Membrane, Multithresh_Num_of_Clusters);
        
        %Clean the image from spurs and any seperated objects
        I = I_Memb_Segment;
        [H W] = size(I);
        I_Pad = padarray(I, [10 10], 'both');
        I_Spr = bwmorph(I_Pad, 'spur', Inf);  %Added 17 Nov. 2016.
        I = imcrop(I_Spr, [11 11 (W-1) (H-1)]);
        I = Largest_Obj(I);
        
        
        %Manually correct the current frame
        ground_truth = Memb_Array{k};
        FileName_ground_truth = fileNames_MembRaw{k};
        
        
        if Previous_Segmentation_Window == 0
            I = Manual_Correction_Tool2 (I, ground_truth, Memb_Array, FileName_ground_truth, Invert_Raw_Image, pathName);
            
        elseif Previous_Segmentation_Window == 1
            
            Previous_ground_truth = Memb_Array{k-1};  % during initialization only. Added 24 March 2017
            Previous_FileName_ground_truth = fileNames_MembRaw{k-1};  % during initialization only. Added 24 March 2017
            I = Manual_Correction_Tool2_TwoWindow (I, ground_truth, Memb_Array, FileName_ground_truth, Invert_Raw_Image, Previous_ground_truth, Previous_FileName_ground_truth, pathName);
        end
        
        
        I = bwmorph(I, 'spur', Inf);  %Added 17 Nov. 2016.
        
        Mask_I = I;
        Mask_Array {k} = Mask_I;  % save the mask
        Pre_Seed =  ~Mask_I;
        Seed_Obj = imclearborder(Pre_Seed, 4);
        
        min_seed_size = 2;
        
        BW_Seed = FindSeeds (Seed_Obj, min_seed_size);
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
           
        imwrite(Mask_I, [Subfolder_path_and_name,['\Memb_', N_memb]], 'tif', 'Compression','none')
    end
    
    
    
    
    %XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
    %XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
    
elseif Start_Reference_Mask == 0  %Checkbox is off. No starting reference mask
    
    %XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
    %XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
    
    %     waitfor(msgbox('Please upload your membrane marker raw stack images'));
    %
    %     [fileName,pathName_MembRaw] = uigetfile('*.tif');
    %     dname       = fullfile(pathName_MembRaw,fileName);
    %     filelist_MembRaw = dir([fileparts(dname) filesep '*.tif']);
    
    pathName_MembRaw = pathName;
    filelist_MembRaw = filelist;
    
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
    ROI_Memb_Gray = Memb_Gray;
    
    BW_Mask = true(size(ROI_Memb_Gray));
    Current_Seed = false(size(ROI_Memb_Gray));
    I = Memb_Segment_Initialization(ROI_Memb_Gray,  Mask_Dilation,  ...
        BW_Mask, SEG_Method, Current_Seed, BlockProcessingHight, BlockProcessingWidth);
    %Clean the image from spurs and any seperated objects
    [H W] = size(I);
    I_Pad = padarray(I, [10 10], 'both');
    I_Spr = bwmorph(I_Pad, 'spur', Inf);  %Added 17 Nov. 2016.
    I = imcrop(I_Spr, [11 11 (W-1) (H-1)]);
    I = Largest_Obj(I);
    
    %**************************************************************************
    % Manually correct the first frame **************************************
    %**************************************************************************
    ground_truth = Memb_Array{1};
    FileName_ground_truth = fileNames_MembRaw{1};
    
    
    if Previous_Segmentation_Window == 0
        I = Manual_Correction_Tool2 (I, ground_truth, Memb_Array, FileName_ground_truth, Invert_Raw_Image, pathName);
        
    elseif Previous_Segmentation_Window == 1
        
        Previous_ground_truth = Memb_Array{1};  % during initialization only. Added 24 March 2017
        Previous_FileName_ground_truth = fileNames_MembRaw{1};  % during initialization only. Added 24 March 2017
        I = Manual_Correction_Tool2_TwoWindow (I, ground_truth, Memb_Array, FileName_ground_truth, Invert_Raw_Image, Previous_ground_truth, Previous_FileName_ground_truth, pathName);
    end
    
    
    Mask_I = I;
    Mask_Array {1} = Mask_I;  % save the mask
    
    Pre_Seed =  ~Mask_I;
    Seed_Obj = imclearborder(Pre_Seed, 4);
    min_seed_size = 2;
    
    BW_Seed = FindSeeds (Seed_Obj, min_seed_size);
    Seed_Array {1} =  BW_Seed;
    
    SE_FullSeed = strel('rectangle', [Mask_Dilation  Mask_Dilation]);  %or use same Dilation_Size
    Full_Seed = imerode(Seed_Obj, SE_FullSeed);
    Both_Seeds = imadd(Full_Seed, BW_Seed);
    Both_Seeds = im2bw(Both_Seeds);
    
    
    %remove any small projections from the seed because they cause wrong
    %segmentation using the watershed     added 8 May, 2017
    
    % Cancelled Dec. 2018
%     SSE = strel('rectangle', [2 2]);
%     Both_Seeds = imopen(Both_Seeds,SSE);
    
    
    Both_Seeds_Array{1} = Both_Seeds;
    
    
    %Save the first corrected membrane
    %mkdir('Segmented_Membrane_Result') %where to save results
    Subfolder_path_and_name = [pathName 'Segmented_Membrane_Result'];
    mkdir(Subfolder_path_and_name) %where to save results
    
    
    
    N_memb = fileNames_MembRaw{1};
    
    Mask_I = ~Mask_I;
    Mask_I = imclearborder(Mask_I, 4);
    
    %imwrite(Mask_I, ['Segmented_Membrane_Result\memb_', N_memb], 'tif')
    imwrite(Mask_I, [Subfolder_path_and_name,['\Memb_', N_memb]], 'tif', 'Compression','none')
 
    
    %****************** Initialization Ends ***********************************
    %**************************************************************************
    
    %**************************************************************************
    % Use the manually corrected membrane as a mask to segment the following frame
    %**************************************************************************
    
    
    for k = 2:End
        Memb_I = Memb_Array{k}; %gray cropped raw image
        
        SE_Mask = strel('rectangle',[Mask_Dilation Mask_Dilation]);     %Thickness level of the mask input
        BW_Mask = imdilate(Mask_Array {k-1}, SE_Mask);
        
        
        %put the seed
        Current_Seed = Both_Seeds_Array {k-1};  % was Seed_Array
        Current_Minimum_Seed = Seed_Array {k-1} ;
        
        
        %***********************************************************
        %remove any small projections from the seed because they cause wrong
        %segmentation using the watershed     added 8 May, 2017
        
        % Cancelled Dec. 2018
        
%         SSE = strel('rectangle', [3 3]);
%         Current_Seed = imopen(Current_Seed,SSE);
        %***********************************************************
        
        
        
        BW_Mask_Seed = imsubtract(BW_Mask, Current_Seed);
        BW_Mask = im2bw(BW_Mask_Seed);
        
        ROI_Memb_I = immultiply(Memb_I, BW_Mask);
        
        %*******************************************
        % This step found to have no reason to apply  20 April 2017
        %ROI_Memb_I = uint8( (double(ROI_Memb_I) - double(min(ROI_Memb_I(:)))) /(double(max(ROI_Memb_I(:))) - double(min(ROI_Memb_I(:)))) * 255 );
        
        %ROI_Memb_I = uint8 (ROI_Memb_I);
        %*********************************************
        
        Manually_Corrected_Membrane = Mask_Array {k-1};
        
        
        
        %Now apply segmentation
        ROI_Memb_Gray = ROI_Memb_I;
        
        I_Memb_Segment = Memb_Segment(ROI_Memb_Gray,   BW_Mask, SEG_Method,...
            Current_Seed, BlockProcessingHight, BlockProcessingWidth, ...
            Current_Minimum_Seed, Manually_Corrected_Membrane, Multithresh_Num_of_Clusters, ...
            Mask_Dilation, Memb_Constuct_Cluster);
        
        %Clean the image from spurs and any seperated objects
        I = I_Memb_Segment;
        [H W] = size(I);
        I_Pad = padarray(I, [10 10], 'both');
        I_Spr = bwmorph(I_Pad, 'spur', Inf);  %Added 17 Nov. 2016.
        I = imcrop(I_Spr, [11 11 (W-1) (H-1)]);
        I = Largest_Obj(I);
        
        
        %Manually correct the current frame
        ground_truth = Memb_Array{k};
        FileName_ground_truth = fileNames_MembRaw{k};
        
        
        if Previous_Segmentation_Window == 0
            I = Manual_Correction_Tool2 (I, ground_truth, Memb_Array, FileName_ground_truth, Invert_Raw_Image, pathName);
            
        elseif Previous_Segmentation_Window == 1
            Previous_ground_truth = Memb_Array{k-1};  % during initialization only. Added 24 March 2017
            Previous_FileName_ground_truth = fileNames_MembRaw{k-1};  % during initialization only. Added 24 March 2017
            
            I = Manual_Correction_Tool2_TwoWindow (I, ground_truth, Memb_Array, FileName_ground_truth, Invert_Raw_Image, Previous_ground_truth, Previous_FileName_ground_truth, pathName);
        end
        
        
        I = bwmorph(I, 'spur', Inf);  %Added 17 Nov. 2016.
        Mask_I = I;
        Mask_Array {k} = Mask_I;  % save the mask
        Pre_Seed =  ~Mask_I;
        Seed_Obj = imclearborder(Pre_Seed, 4);
        
        min_seed_size = 2;
        
        BW_Seed = FindSeeds (Seed_Obj, min_seed_size);
        Seed_Array {k} =  BW_Seed;
        
        SE_FullSeed = strel('rectangle', [Mask_Dilation  Mask_Dilation]);  %or use same Dilation_Size
        Full_Seed = imerode(Seed_Obj, SE_FullSeed);
        Both_Seeds = imadd(Full_Seed, BW_Seed);
        Both_Seeds = im2bw(Both_Seeds);
        Both_Seeds_Array{k} = Both_Seeds;
        
        
        %Save the segmented membrane result
        N_memb = fileNames_MembRaw{k};
        
        Mask_I = ~Mask_I;
        Mask_I = imclearborder(Mask_I, 4);
        
        
        imwrite(Mask_I, [Subfolder_path_and_name,['\Memb_', N_memb]], 'tif', 'Compression','none')
    
        
    end
    
    
    
end

%****************************** END ***************************************



