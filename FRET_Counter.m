
%**************************************************************************
%**************************************************************************
%**************************************************************************
%                  Developed by Mustafa Sami, RIKEN BDR
%**************************************************************************
%**************************************************************************
%**************************************************************************


function varargout = FRET_Counter(varargin)
% FRET_COUNTER MATLAB code for FRET_Counter.fig
%      FRET_COUNTER, by itself, creates a new FRET_COUNTER or raises the existing
%      singleton*.
%
%      H = FRET_COUNTER returns the handle to a new FRET_COUNTER or the handle to
%      the existing singleton*.
%
%      FRET_COUNTER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FRET_COUNTER.M with the given input arguments.
%
%      FRET_COUNTER('Property','Value',...) creates a new FRET_COUNTER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before FRET_Counter_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to FRET_Counter_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help FRET_Counter

% Last Modified by GUIDE v2.5 18-Jan-2019 15:25:07

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @FRET_Counter_OpeningFcn, ...
    'gui_OutputFcn',  @FRET_Counter_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before FRET_Counter is made visible.
function FRET_Counter_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to FRET_Counter (see VARARGIN)

% Choose default command line output for FRET_Counter
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes FRET_Counter wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = FRET_Counter_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

I = getimage;
figure, imshow(I, []);


% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

pathName = {};

fileNames = handles.fileNames;
num_frames = handles.num_frames;
pathName = handles.pathName;

set(handles.slider1, 'SliderStep', [1/num_frames 10/num_frames],'Min', 1,'Max', num_frames);

t2 = get(handles.slider1,'Value');
t2 = round(t2);
set(handles.text3,'String',num2str(t2));   %this will include the decimal
set(handles.slider1, 'Value', t2);

set(handles.edit31,'String',fileNames{t2}); % update the edit2 with file name

if t2 <= num_frames
    g = imread([pathName,fileNames{t2}]);
    imshow(g, []);
    
else
    Z = ([pathName,imread(fileNames{num_frames})]);
    imshow(Z, []);
    set(handles.text1,'String',num2str(num_frames));
    title('Reached Last Frame', 'Color','r',...
        'FontSize',10,'FontWeight','bold');
    set(handles.slider1,'value', num_frames);
    
end



% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double


% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit10_Callback(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit10 as text
%        str2double(get(hObject,'String')) returns contents of edit10 as a double


% --- Executes during object creation, after setting all properties.
function edit10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





function edit12_Callback(hObject, eventdata, handles)
% hObject    handle to edit12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit12 as text
%        str2double(get(hObject,'String')) returns contents of edit12 as a double


% --- Executes during object creation, after setting all properties.
function edit12_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





% --- Executes on button press in pushbutton15.
function pushbutton15_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    
    pathName = {};
    
    try
        pathName = handles.pathName;
        filelist = handles.filelist;
        
    catch
        if isempty(pathName)
            msgbox({'No images found!';...
                'Please load your images first by clicking';...
                '"Load Stack" button'})
        end
    end
    
    
    
    
    edit3_val_string = get(handles.edit3, 'String');
    Start_Frame =  str2num(edit3_val_string);
    
    
    edit4_val_string = get(handles.edit4, 'String');
    End_Frame = str2num(edit4_val_string);
    
    edit12_val_string = get(handles.edit12, 'String');
    Option = str2num(edit12_val_string);
    
    edit13_val_string = get(handles.edit13, 'String');
    Mask_Dilation = str2num(edit13_val_string);
    
    edit14_val_string = get(handles.edit14, 'String');
    Multithresh_Num_of_Clusters = str2num(edit14_val_string);
    
    
    SeedSize = 2;   %fix
    
    
    edit16_val_string = get(handles.edit16, 'String');
    BlockProcessingHight = str2num(edit16_val_string);
    
    edit17_val_string = get(handles.edit17, 'String');
    BlockProcessingWidth = str2num(edit17_val_string);
    
    
    edit13_val_string = get(handles.edit13, 'String');
    membrane_shift = str2num(edit13_val_string);      
    
    
    checkboxStatus1 = get(handles.checkbox1,'Value');  
    if(checkboxStatus1)
        Start_Reference_Mask = 1; 
    else
        Start_Reference_Mask = 0;  
    end
    
    
    checkboxStatus2 = get(handles.checkbox2,'Value');  
    if(checkboxStatus2)
        Inverese_Reading = 1; 
    else
        Inverese_Reading = 0;  
    end
    
    
    checkboxStatus3 = get(handles.checkbox3,'Value');  
    if(checkboxStatus3)
        Invert_Raw_Image = 1; 
    else
        Invert_Raw_Image = 0;  
    end
    
    
    checkboxStatus4 = get(handles.checkbox4,'Value');  
    if(checkboxStatus4)
        Previous_Segmentation_Window = 1; 
    else
        Previous_Segmentation_Window = 0;  
    end
    
    
    
    
    checkboxStatus8 = get(handles.checkbox8,'Value');  
    
    if(checkboxStatus8)
        Scape_Manual_Correction = 1; 
    else
        Scape_Manual_Correction = 0; 
    end
    
    
    
    
    switch get(get(handles.uibuttongroup1,'SelectedObject'),'Tag')
        
        %     case 'radiobutton1',  SEG_Method = 1;
        %case 'radiobutton2',  SEG_Method = 2;
        %case 'radiobutton3',  SEG_Method = 3;
        %case 'radiobutton4',  SEG_Method = 4;
        case 'radiobutton5',  SEG_Method = 5;
        case 'radiobutton6',  SEG_Method = 6;
            %case 'radiobutton7',  SEG_Method = 7;
        case 'radiobutton18', SEG_Method = 18;
        case 'radiobutton19', SEG_Method = 19;
    end
    
    
    
    
    switch get(get(handles.uibuttongroup3,'SelectedObject'),'Tag')
        
        case 'radiobutton16',  Memb_Constuct_Cluster = 1;
        case 'radiobutton17',  Memb_Constuct_Cluster = 2;
    end
    
    
    
    
    
    
    if SEG_Method == 18   % apply the segmentation method without masking or seeding
        

        pathName_MembRaw = pathName;
        filelist_MembRaw = filelist;
        
        
        fileNames_MembRaw = {filelist_MembRaw.name}';
        fileNames_MembRaw = fileNames_MembRaw (Start_Frame:End_Frame);  % targeted frames
        
        if Inverese_Reading ==1
            fileNames_MembRaw = flipud(fileNames_MembRaw);
        end
        
        num_frames = (numel(filelist_MembRaw));
        MembRaw = imread(fullfile(pathName_MembRaw, fileNames_MembRaw{1}));
        
        Memb_Array = [];
        
        End = (numel(fileNames_MembRaw));
        for k = 1:End
            
            Memb_Array{k} = imread(fullfile(pathName_MembRaw, fileNames_MembRaw{k}));
            
        end
        
        %**************************************************************************
        % Apply segmentation to the first frame *****************
        %**************************************************************************
        
        for z = 1: End
            I_Gray = Memb_Array{z};
            Comp_I = imcomplement(I_Gray);
            %**********************************************************
            Window_H  =  100;                     %BlockProcessingHight; %100;
            Window_W  =  100;                     %BlockProcessingWidth; %100;
            Smallest_Obj_remove  = 1;
            
            fun = @(block_struct) thresher(block_struct.data);
            block_otsu = blockproc(Comp_I,[Window_H, Window_W],fun); %block hight then width
            block_otsu = bwareaopen(block_otsu,Smallest_Obj_remove);
            bw = block_otsu;

            level = 1;
            D = -bwdist(~bw);
            mask = imextendedmin(D,level);
            D2 = imimposemin(D,mask);
            Ld2 = watershed(D2); % sometime works better than Ld2 = watershed(D2, 4); 
            
            
            II = Ld2;
            II(II > 0) = 1;
            % Binarize the membrane because it is not logical yet
            thr = graythresh(II);
            I = imbinarize(II,thr);
            
            
            % Apply skeletonization procedure
            I = ~I;
            SE_Wide = strel('rectangle', [3   3]);
            I_Dilate = imdilate(I, SE_Wide);
            I_Erode = imerode(I_Dilate, SE_Wide);
            
            
            Thin_I = bwmorph(I_Erode,'thin', inf);
            % final spur removal
            I = bwmorph(Thin_I,'spur', inf); 
            
            
            [H W] = size(I);
            I_Pad = padarray(I, [10 10], 'both');
            I_Spr = bwmorph(I_Pad, 'spur', Inf);  
            I = imcrop(I_Spr, [11 11 (W-1) (H-1)]);
            I = Largest_Obj(I);
            
            %**************************************************************
            % *********Manually correct the first frame *******************
            %**************************************************************
            
            ground_truth = Memb_Array{z};
            FileName_ground_truth = fileNames_MembRaw{z};
            
            
            if Previous_Segmentation_Window == 0
                if Scape_Manual_Correction == 1 %  in case of if the checkbox is selected
                    I = I;
                    
                elseif Scape_Manual_Correction == 0 %  in case of if the checkbox is not selected
                    I = Manual_Correction_Tool2 (I, ground_truth, Memb_Array, FileName_ground_truth, Invert_Raw_Image, pathName);
                end
                
            elseif Previous_Segmentation_Window == 1
                
                Previous_ground_truth = Memb_Array{z};  % during initialization only
                Previous_FileName_ground_truth = fileNames_MembRaw{z};  % during initialization only
                
                if  Scape_Manual_Correction == 1 %  in case of if the checkbox is not selected
                    I = I;
                elseif    Scape_Manual_Correction == 0
                    I = Manual_Correction_Tool2_TwoWindow (I, ground_truth,...
                        Memb_Array, FileName_ground_truth, Invert_Raw_Image, ...
                        Previous_ground_truth, Previous_FileName_ground_truth, pathName);
                end
                
            end
            
            
            Mask_I = I;
            Mask_Array {z} = Mask_I;  % save the mask
            
%             Pre_Seed =   ~Mask_I;
%             Seed_Obj = imclearborder(Pre_Seed, 4);
%             BW_Seed = FindSeeds (Seed_Obj, SeedSize);
%             Seed_Array {z} =  BW_Seed;
%             
%             SE_FullSeed = strel('rectangle', [Mask_Dilation  Mask_Dilation]);  %or use same Dilation_Size
%             Full_Seed = imerode(Seed_Obj, SE_FullSeed);
%             Both_Seeds = imadd(Full_Seed, BW_Seed);
%             Both_Seeds = im2bw(Both_Seeds);
%             Both_Seeds_Array{1} = Both_Seeds;
            
           
            Subfolder_path_and_name = [pathName 'Segmented_Membrane_Result'];
            mkdir(Subfolder_path_and_name) %where to save results
            
            N_memb = fileNames_MembRaw{z};
            
            imwrite(Mask_I, [Subfolder_path_and_name,'\Memb_', N_memb], 'tif', 'Compression','none')
            
        end
        
        
        
    elseif SEG_Method == 19   % apply the segmentation method to a single cell without masking or seeding
        

        
        pathName_MembRaw = pathName;
        filelist_MembRaw = filelist;
        
        fileNames_MembRaw = {filelist_MembRaw.name}';
        fileNames_MembRaw = fileNames_MembRaw (Start_Frame:End_Frame);  % targeted frames
        
        %Inverese reading checkbox
        if Inverese_Reading ==1
            fileNames_MembRaw = flipud(fileNames_MembRaw);
        end
        
        num_frames = (numel(filelist_MembRaw));
        MembRaw = imread(fullfile(pathName_MembRaw, fileNames_MembRaw{1}));
        
        Memb_Array = [];
        
        End = (numel(fileNames_MembRaw));
        for k = 1:End
            
            Memb_Array{k} = imread(fullfile(pathName_MembRaw, fileNames_MembRaw{k}));
            
        end
        
        %******************************************************************
        % ********* Apply segmentation to the first frame *****************
        %******************************************************************
        
        
        for z = 1:1       % first frame
            I_Gray = Memb_Array{z};
            Comp_I = imcomplement(I_Gray);
            
            %**********************************************************
            
            Window_H  =  100;                     %BlockProcessingHight; %100;
            Window_W  =  100;                     %BlockProcessingWidth; %100;
            Smallest_Obj_remove  = 1;
            
            fun = @(block_struct) thresher(block_struct.data);
            block_otsu = blockproc(Comp_I,[Window_H, Window_W],fun); 
            block_otsu = bwareaopen(block_otsu,Smallest_Obj_remove);

            bw = block_otsu;
            
            level = 1;
            D = -bwdist(~bw);
            mask = imextendedmin(D,level);
            D2 = imimposemin(D,mask);
            Ld2 = watershed(D2);
            
            
            II = Ld2;
            II(II > 0) = 1;

            thr = graythresh(II);
            I = imbinarize(II,thr);

            I = ~I;
            SE_Wide = strel('rectangle', [3   3]);
            I_Dilate = imdilate(I, SE_Wide);
            I_Erode = imerode(I_Dilate, SE_Wide);
            Thin_I = bwmorph(I_Erode,'thin', inf);
            I = bwmorph(Thin_I,'spur', inf);  
            
            [H W] = size(I);
            I_Pad = padarray(I, [10 10], 'both');
            I_Spr = bwmorph(I_Pad, 'spur', Inf); 
            I = imcrop(I_Spr, [11 11 (W-1) (H-1)]);
            I = Largest_Obj(I);

            %**************************************************************
            % **********  Manually correct the first frame ****************
            %**************************************************************
            
            ground_truth = Memb_Array{z};
            FileName_ground_truth = fileNames_MembRaw{z};
            
            
            if Previous_Segmentation_Window == 0
                I = Manual_Correction_Tool2 (I, ground_truth, Memb_Array, FileName_ground_truth, Invert_Raw_Image, pathName);
                
            elseif Previous_Segmentation_Window == 1
                
                Previous_ground_truth = Memb_Array{z};  
                Previous_FileName_ground_truth = fileNames_MembRaw{z};  
                I = Manual_Correction_Tool2_TwoWindow (I, ground_truth,...
                    Memb_Array, FileName_ground_truth, Invert_Raw_Image, ...
                    Previous_ground_truth, Previous_FileName_ground_truth, pathName);
            
            end
            
            
            Mask_I = I;
            Mask_Array {z} = Mask_I;  % save the mask
            
%             Pre_Seed =   ~Mask_I;
%             Seed_Obj = imclearborder(Pre_Seed, 4);
%             BW_Seed = FindSeeds (Seed_Obj, SeedSize);
%             Seed_Array {z} =  BW_Seed;
%             
%             SE_FullSeed = strel('rectangle', [Mask_Dilation  Mask_Dilation]);  %or use same Dilation_Size
%             Full_Seed = imerode(Seed_Obj, SE_FullSeed);
%             Both_Seeds = imadd(Full_Seed, BW_Seed);
%             Both_Seeds = im2bw(Both_Seeds);
%             Both_Seeds_Array{1} = Both_Seeds;
            
            
            %Save the first corrected membrane
            Subfolder_path_and_name = [pathName 'Segmented_Membrane_Result'];
            mkdir(Subfolder_path_and_name) %where to save results

            N_memb = fileNames_MembRaw{z};

            imwrite(Mask_I, [Subfolder_path_and_name,'\Memb_', N_memb], 'tif', 'Compression','none')
            
            Previous_as_Reference = Mask_I;
            
            
            %*************   Initialization ends  ****************
            %*****************************************************
            
            for z = 2:End
                I_Gray = Memb_Array{z};
                
                %I_Gray = uint8(I_Gray);
                
                Comp_I = imcomplement(I_Gray);
                %**********************************************************
                Window_H  =  100;                     %BlockProcessingHight; %100;
                Window_W  =  100;                     %BlockProcessingWidth; %100;
                Smallest_Obj_remove  = 1;
                
                fun = @(block_struct) thresher(block_struct.data);
                block_otsu = blockproc(Comp_I,[Window_H, Window_W],fun); %block hight then width
                block_otsu = bwareaopen(block_otsu,Smallest_Obj_remove);
                %imshow(block_otsu);
                bw = block_otsu;
                
                level = 1;
                D = -bwdist(~bw);
                mask = imextendedmin(D,level);
                D2 = imimposemin(D,mask);
                Ld2 = watershed(D2);
                
                
                II = Ld2;
                II(II > 0) = 1;
                thr = graythresh(II);
                I = imbinarize(II,thr);
                
                % Apply skeletonization procedure
                I = ~I;
                SE_Wide = strel('rectangle', [3   3]);
                I_Dilate = imdilate(I, SE_Wide);
                I_Erode = imerode(I_Dilate, SE_Wide);
                
                Thin_I = bwmorph(I_Erode,'thin', inf);
                I = bwmorph(Thin_I,'spur', inf);   
                
                [H W] = size(I);
                I_Pad = padarray(I, [10 10], 'both');
                I_Spr = bwmorph(I_Pad, 'spur', Inf);  
                I = imcrop(I_Spr, [11 11 (W-1) (H-1)]);
                I = Largest_Obj(I);
                
                %**********************************************************
                %************ Clean Before Manual Correction **************
                
                Clean_Area = imfill(Previous_as_Reference,'holes');
                SEE = strel('disk', membrane_shift );
                Clean_Outside = imdilate(Clean_Area, SEE);
                Clean_Outside = immultiply(I, Clean_Outside);
                Clean_Outside = bwmorph(Clean_Outside, 'spur', Inf);
                Clean_Inside = imerode(Clean_Area, SEE);
                Clean_Inside = immultiply(~Clean_Inside, Clean_Outside);
                Clean_Inside = bwmorph(Clean_Inside, 'spur', Inf);
                
                Clean_Inside =  bwmorph(Clean_Inside, 'clean');
                
                I = Clean_Inside;

                %**********************************************************
                % *********** Manually correct the frame ************
                %**********************************************************
                
                ground_truth = Memb_Array{z};
                FileName_ground_truth = fileNames_MembRaw{z};
                
                
                if Previous_Segmentation_Window == 0
                    I = Manual_Correction_Tool2 (I, ground_truth, Memb_Array, FileName_ground_truth, Invert_Raw_Image, pathName);
                    
                elseif Previous_Segmentation_Window == 1
                    
                    Previous_ground_truth = Memb_Array{z};  
                    Previous_FileName_ground_truth = fileNames_MembRaw{z}; 
                    I = Manual_Correction_Tool2_TwoWindow (I, ground_truth, ...
                        Memb_Array, FileName_ground_truth, Invert_Raw_Image, ...
                        Previous_ground_truth, Previous_FileName_ground_truth, pathName);
                end
                
                
                Mask_I = I;
                Mask_Array {z} = Mask_I;  % save the mask
                
%                 Pre_Seed =   ~Mask_I;
%                 Seed_Obj = imclearborder(Pre_Seed, 4);
%                 BW_Seed = FindSeeds (Seed_Obj, SeedSize);
%                 Seed_Array {z} =  BW_Seed;
%                 
%                 SE_FullSeed = strel('rectangle', [Mask_Dilation  Mask_Dilation]); 
%                 Full_Seed = imerode(Seed_Obj, SE_FullSeed);
%                 Both_Seeds = imadd(Full_Seed, BW_Seed);
%                 Both_Seeds = im2bw(Both_Seeds);
%                 Both_Seeds_Array{1} = Both_Seeds;
                

                N_memb = fileNames_MembRaw{z};
 
                imwrite(Mask_I, [Subfolder_path_and_name,'\Memb_', N_memb], 'tif', 'Compression','none')
                Previous_as_Reference = Mask_I;

            end
            
        end
        
        
        %**********************************************************************
        
        
    else
        
        Epith_Memb_Segmentation_Track_and_Correct (     ...
            Start_Frame, End_Frame, Option, Mask_Dilation, Start_Reference_Mask,  SEG_Method, ...
            Inverese_Reading, BlockProcessingHight, BlockProcessingWidth, Invert_Raw_Image, ...
            Previous_Segmentation_Window, Multithresh_Num_of_Clusters, pathName, filelist, Memb_Constuct_Cluster)
        
    end
end



function edit13_Callback(hObject, eventdata, handles)
% hObject    handle to edit13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit13 as text
%        str2double(get(hObject,'String')) returns contents of edit13 as a double


% --- Executes during object creation, after setting all properties.
function edit13_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1



function edit14_Callback(hObject, eventdata, handles)
% hObject    handle to edit14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit14 as text
%        str2double(get(hObject,'String')) returns contents of edit14 as a double


% --- Executes during object creation, after setting all properties.
function edit14_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox2


% --- Executes during object creation, after setting all properties.
function pushbutton15_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



function edit16_Callback(hObject, eventdata, handles)
% hObject    handle to edit16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit16 as text
%        str2double(get(hObject,'String')) returns contents of edit16 as a double


% --- Executes during object creation, after setting all properties.
function edit16_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit17_Callback(hObject, eventdata, handles)
% hObject    handle to edit17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit17 as text
%        str2double(get(hObject,'String')) returns contents of edit17 as a double


% --- Executes during object creation, after setting all properties.
function edit17_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox3.
function checkbox3_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox3


% --- Executes on button press in checkbox4.
function checkbox4_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox4


% --- Executes on button press in pushbutton19.
function pushbutton19_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


msgbox({'This will show the previous segmented membrane in a separate window.' ...
    'Be sure not to have segmented images from before inside the ' ...
    '"Segmented_Reference_Mask folder" when using this option.'});




function edit18_Callback(hObject, eventdata, handles)
% hObject    handle to edit18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit18 as text
%        str2double(get(hObject,'String')) returns contents of edit18 as a double


% --- Executes during object creation, after setting all properties.
function edit18_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit19_Callback(hObject, eventdata, handles)
% hObject    handle to edit19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit19 as text
%        str2double(get(hObject,'String')) returns contents of edit19 as a double


% --- Executes during object creation, after setting all properties.
function edit19_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox5.
function checkbox5_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox5



function edit20_Callback(hObject, eventdata, handles)
% hObject    handle to edit20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit20 as text
%        str2double(get(hObject,'String')) returns contents of edit20 as a double


% --- Executes during object creation, after setting all properties.
function edit20_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit21_Callback(hObject, eventdata, handles)
% hObject    handle to edit21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit21 as text
%        str2double(get(hObject,'String')) returns contents of edit21 as a double


% --- Executes during object creation, after setting all properties.
function edit21_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox6.
function checkbox6_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox6



function edit22_Callback(hObject, eventdata, handles)
% hObject    handle to edit22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit22 as text
%        str2double(get(hObject,'String')) returns contents of edit22 as a double


% --- Executes during object creation, after setting all properties.
function edit22_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit23_Callback(hObject, eventdata, handles)
% hObject    handle to edit23 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit23 as text
%        str2double(get(hObject,'String')) returns contents of edit23 as a double


% --- Executes during object creation, after setting all properties.
function edit23_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit23 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in radiobutton9.
function radiobutton9_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton9


% --- Executes on button press in radiobutton10.
function radiobutton10_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton10





% --- Executes on button press in radiobutton11.
function radiobutton11_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton11


% --- Executes on button press in radiobutton12.
function radiobutton12_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton12


% --- Executes during object creation, after setting all properties.
function uibuttongroup1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uibuttongroup1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in radiobutton1.
function radiobutton1_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton1


% --- Executes on button press in checkbox7.
function checkbox7_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox7



function edit24_Callback(hObject, eventdata, handles)
% hObject    handle to edit24 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit24 as text
%        str2double(get(hObject,'String')) returns contents of edit24 as a double


% --- Executes during object creation, after setting all properties.
function edit24_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit24 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit25_Callback(hObject, eventdata, handles)
% hObject    handle to edit25 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit25 as text
%        str2double(get(hObject,'String')) returns contents of edit25 as a double


% --- Executes during object creation, after setting all properties.
function edit25_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit25 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in togglebutton1.
function togglebutton1_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of togglebutton1



function edit26_Callback(hObject, eventdata, handles)
% hObject    handle to edit26 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit26 as text
%        str2double(get(hObject,'String')) returns contents of edit26 as a double


% --- Executes during object creation, after setting all properties.
function edit26_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit26 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit27_Callback(hObject, eventdata, handles)
% hObject    handle to edit27 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit27 as text
%        str2double(get(hObject,'String')) returns contents of edit27 as a double


% --- Executes during object creation, after setting all properties.
function edit27_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit27 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton24.
function pushbutton24_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton24 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    pathName = {};
    
    try
        pathName = handles.pathName;
        filelist = handles.filelist;
        
    catch
        if isempty(pathName)
            msgbox({'No images found!';...
                'Please load your images first by clicking';...
                '"Load Stack" button'})
        end
    end

    
    edit3_val_string = get(handles.edit3, 'String');
    Start_Frame =  str2num(edit3_val_string);
    
    edit4_val_string = get(handles.edit4, 'String');
    End_Frame = str2num(edit4_val_string);
    
    edit12_val_string = get(handles.edit12, 'String');
    Min_Nucl_Size = str2num(edit12_val_string);
    
    edit13_val_string = get(handles.edit13, 'String');
    Mask_Dilation = str2num(edit13_val_string);
    
    
    
    edit14_val_string = get(handles.edit14, 'String');
    Multithresh_Num_of_Clusters = str2num(edit14_val_string);
    
    edit16_val_string = get(handles.edit16, 'String');
    BlockProcessingHight = str2num(edit16_val_string);
    
    edit17_val_string = get(handles.edit17, 'String');
    BlockProcessingWidth = str2num(edit17_val_string);
    
    checkboxStatus1 = get(handles.checkbox1,'Value');  % in case of if the checkbox is ON
    if(checkboxStatus1)
        Start_Reference_Mask = 1; %  in case of if the checkbox is selected
    else
        Start_Reference_Mask = 0;  %  in case of if the checkbox is not selected
    end
    
    
    checkboxStatus2 = get(handles.checkbox2,'Value');  % in case of if the checkbox os ON
    if(checkboxStatus2)
        Inverese_Reading = 1; %  in case of if the checkbox is selected
    else
        Inverese_Reading = 0;  %  in case of if the checkbox is not selected
    end
    
    
    
    
    checkboxStatus3 = get(handles.checkbox3,'Value');  % in case of if the checkbox os ON
    if(checkboxStatus3)
        Invert_Raw_Image = 1; %  in case of if the checkbox is selected
    else
        Invert_Raw_Image = 0;  %  in case of if the checkbox is not selected
    end
    
    
   
    
    checkboxStatus9 = get(handles.checkbox9,'Value');  % in case of if the checkbox os ON
    if(checkboxStatus9)
        Previous_Segmentation_Window = 1; %  in case of if the checkbox is selected
    else
        Previous_Segmentation_Window = 0;  %  in case of if the checkbox is not selected
    end
    
    
    %Previous_Segmentation_Window = 0; % Always show one correction window for nuclei correction in FRET Counter
    
    
    switch get(get(handles.uibuttongroup1,'SelectedObject'),'Tag')
        
        %     case 'radiobutton1',  SEG_Method = 1;
        %     case 'radiobutton2',  SEG_Method = 2;
        %     case 'radiobutton3',  SEG_Method = 3;
        %     case 'radiobutton4',  SEG_Method = 4;
        case 'radiobutton5',  SEG_Method = 5;
        case 'radiobutton6',  SEG_Method = 6;
            %     case 'radiobutton7',  SEG_Method = 7;
        case 'radiobutton18', SEG_Method = 18;
    end
    
    
    
    
    switch get(get(handles.uibuttongroup3,'SelectedObject'),'Tag')
        
        case 'radiobutton16',  Memb_Constuct_Cluster = 1;
        case 'radiobutton17',  Memb_Constuct_Cluster = 2;
    end
    
    
    
    switch get(get(handles.uibuttongroup4,'SelectedObject'),'Tag')
        
        case 'radiobutton20',  Nuclei_SEG_Method = 1;
        case 'radiobutton21',  Nuclei_SEG_Method = 2;
        case 'radiobutton22',  Nuclei_SEG_Method = 3;
    end
    
    
    %**************************************************************************
    %************ Confirm that input stack images are gray ********************
    
    fileNames = handles.fileNames;
    
    g = imread([pathName,fileNames{1}]);
    
    [~, ~, Ss] = size(g);
    if Ss > 1
        msgbox('Input stack is RGB. This method works only with gray images.', 'Error','error');
        %**************************************************************************
    else
        
        Nuclei_Segmentation_Track_and_Correct ( ...
            Start_Frame, End_Frame, Min_Nucl_Size, Mask_Dilation, Start_Reference_Mask, Multithresh_Num_of_Clusters, SEG_Method, ...
            Inverese_Reading, BlockProcessingHight, BlockProcessingWidth, Invert_Raw_Image, Previous_Segmentation_Window,...
            Nuclei_SEG_Method, pathName, filelist)
    end
    
end


function edit28_Callback(hObject, eventdata, handles)
% hObject    handle to edit28 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit28 as text
%        str2double(get(hObject,'String')) returns contents of edit28 as a double


% --- Executes during object creation, after setting all properties.
function edit28_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit28 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit29_Callback(hObject, eventdata, handles)
% hObject    handle to edit29 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit29 as text
%        str2double(get(hObject,'String')) returns contents of edit29 as a double


% --- Executes during object creation, after setting all properties.
function edit29_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit29 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit30_Callback(hObject, eventdata, handles)
% hObject    handle to edit30 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit30 as text
%        str2double(get(hObject,'String')) returns contents of edit30 as a double


% --- Executes during object creation, after setting all properties.
function edit30_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit30 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox8.
function checkbox8_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox8


% --- Executes during object creation, after setting all properties.
function text5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in radiobutton18.
function radiobutton18_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton18


checkStatusradio18 = get(handles.radiobutton18,'Value');  % in case of if the checkbox os ON
if(checkStatusradio18)
    set(handles.checkbox4,'Value', 0)
else
    set(handles.checkbox4,'Value', 1)
end


% --- Executes during object deletion, before destroying properties.
function pushbutton26_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton26 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object deletion, before destroying properties.
function pushbutton14_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton28.
function pushbutton28_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton28 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    
    [fileName,pathName] = uigetfile('*.tif' );
    dname       = fullfile(pathName,fileName);
    filelist = dir([fileparts(dname) filesep '*.tif']);
    fileNames = {filelist.name}';
    num_frames = (numel(filelist));
    I = imread(fullfile(pathName, fileNames{1}));
    imshow(I,[]);

    set(handles.edit4,'String',num_frames);
    set(handles.text5,'String',num_frames);
    
    set(handles.edit31,'String',fileName);
    
    handles.filelist = filelist;
    handles.fileNames = fileNames;
    handles.num_frames = num_frames;
    handles.fileName = fileName;
    handles.pathName = pathName;
    
    guidata(hObject,handles);

    if num_frames > 1
        set(handles.slider1,'enable','on')
    else
        set(handles.slider1,'enable','off')
    end

end


function edit31_Callback(hObject, eventdata, handles)
% hObject    handle to edit31 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit31 as text
%        str2double(get(hObject,'String')) returns contents of edit31 as a double


% --- Executes during object creation, after setting all properties.
function edit31_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit31 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit32_Callback(hObject, eventdata, handles)
% hObject    handle to edit32 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit32 as text
%        str2double(get(hObject,'String')) returns contents of edit32 as a double


% --- Executes during object creation, after setting all properties.
function edit32_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit32 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit33_Callback(hObject, eventdata, handles)
% hObject    handle to edit33 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit33 as text
%        str2double(get(hObject,'String')) returns contents of edit33 as a double


% --- Executes during object creation, after setting all properties.
function edit33_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit33 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit34_Callback(hObject, eventdata, handles)
% hObject    handle to edit34 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit34 as text
%        str2double(get(hObject,'String')) returns contents of edit34 as a double


% --- Executes during object creation, after setting all properties.
function edit34_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit34 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton29.
function pushbutton29_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton29 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


%**************************************************************************
edit32_val_string = get(handles.edit32, 'String');
rotdeg = str2num(edit32_val_string);    % Rotation degree -ve is rotation to the left
%                 +ve is rotation to the right

%Example: rotdeg = -6.36;     %-ve is rotation to left

%**************************************************************************


Y=[];

[fileName,pathName] = uigetfile('*.tif' );
dname       = fullfile(pathName,fileName);
filelist = dir([fileparts(dname) filesep '*.tif']);
fileNames = {filelist.name};
num_frames = (numel(filelist));
for i = 1: num_frames
    Y{i} = single(imread(fullfile(pathName, fileNames{i})));
    Y{i} = imrotate(Y{i},-rotdeg);
end

handles.Y = Y;
    
guidata(hObject,handles);


% --- Executes on button press in pushbutton30.
function pushbutton30_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton30 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



%**************************************************************************
edit32_val_string = get(handles.edit32, 'String');
rotdeg = str2num(edit32_val_string);    % Rotation degree -ve is rotation to the left
%                 +ve is rotation to the right

%Example: rotdeg = -6.36;     %-ve is rotation to left

%**************************************************************************

Z=[];

[fileName,pathName] = uigetfile('*.tif' );
dname       = fullfile(pathName,fileName);
filelist = dir([fileparts(dname) filesep '*.tif']);
fileNames = {filelist.name};
num_frames = (numel(filelist));
for i = 1: num_frames
    Z{i} = single(imread(fullfile(pathName, fileNames{i})));
    Z{i} = imrotate(Z{i},-rotdeg);
end

handles.Z = Z;
    
guidata(hObject,handles);



% --- Executes on button press in pushbutton31.
function pushbutton31_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton31 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%**************************************************************************
edit32_val_string = get(handles.edit32, 'String');
rotdeg = str2num(edit32_val_string);    % Rotation degree -ve is rotation to the left
%                 +ve is rotation to the right

%Example: rotdeg = -6.36;     %-ve is rotation to left

%**************************************************************************


X=[];

[fileName,pathName] = uigetfile('*.tif' );
dname       = fullfile(pathName,fileName);
filelist = dir([fileparts(dname) filesep '*.tif']);
fileNames = {filelist.name};
num_frames = (numel(filelist));
for i = 1:num_frames
    X{i} = single(imread(fullfile(pathName, fileNames{i})));
    X{i} = imrotate(X{i},-rotdeg);
end


set(handles.edit36,'String',num_frames);


handles.X = X;


parts = strsplit(pathName, filesep);
parent_path = strjoin(parts(1:end-1), filesep);


handles.parent_path = parent_path;

guidata(hObject,handles);


function edit35_Callback(hObject, eventdata, handles)
% hObject    handle to edit35 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit35 as text
%        str2double(get(hObject,'String')) returns contents of edit35 as a double


% --- Executes during object creation, after setting all properties.
function edit35_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit35 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit36_Callback(hObject, eventdata, handles)
% hObject    handle to edit36 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit36 as text
%        str2double(get(hObject,'String')) returns contents of edit36 as a double


% --- Executes during object creation, after setting all properties.
function edit36_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit36 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton32.
function pushbutton32_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton32 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

X = handles.X;
Y = handles.Y;
Z = handles.Z;
parent_path = handles.parent_path;

%*******************************************************************
%**************************************************************************
edit32_val_string = get(handles.edit32, 'String');
rotdeg = str2num(edit32_val_string);    % Rotation degree -ve is rotation to the left
%                 +ve is rotation to the right

%Example: rotdeg = -6.36;     %-ve is rotation to left

%**************************************************************************

edit33_val_string = get(handles.edit33, 'String');
MicPerPix = str2num(edit33_val_string);   %  microscope micron per pixel

%Example: 0.803/3 micron/pixel
%**************************************************************************

edit34_val_string = get(handles.edit34, 'String');
TimeInterv = str2num(edit34_val_string);   %  time interval in minutes

%Example:  5 (minutes)
%**************************************************************************

edit35_val_string = get(handles.edit35, 'String');
StartFrame = str2num(edit35_val_string);   %  Starting frame

%Example:  1 (start from frame number 1)
%**************************************************************************

edit36_val_string = get(handles.edit36, 'String');
EndFrame = str2num(edit36_val_string);   %  Starting frame

%Example:  11 (Stop at frame number 11)
%**************************************************************************

edit37_val_string = get(handles.edit37, 'String');
Max_Hist = str2num(edit37_val_string);   %  Starting frame

%**************************************************************************

edit38_val_string = get(handles.edit38, 'String');
Min_Hist = str2num(edit38_val_string);   %  Starting frame


FRET_Visualize(X, Y, Z, MicPerPix, TimeInterv, StartFrame, EndFrame, Max_Hist, Min_Hist, parent_path);


% --- Executes on button press in pushbutton33.
function pushbutton33_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton33 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


closeGUI = handles.figure1; %handles.figure1 is the GUI figure
 
guiPosition = get(handles.figure1,'Position'); %get the position of the GUI
guiName = get(handles.figure1,'Name'); %get the name of the GUI
close(closeGUI); %close the old GUI
close all
eval(guiName) %call the GUI again
set(gcf,'Position',guiPosition); %set the position for the new GUI
clc


% --- Executes on button press in checkbox9.
function checkbox9_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox9



function edit37_Callback(hObject, eventdata, handles)
% hObject    handle to edit37 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit37 as text
%        str2double(get(hObject,'String')) returns contents of edit37 as a double


% --- Executes during object creation, after setting all properties.
function edit37_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit37 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit38_Callback(hObject, eventdata, handles)
% hObject    handle to edit38 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit38 as text
%        str2double(get(hObject,'String')) returns contents of edit38 as a double


% --- Executes during object creation, after setting all properties.
function edit38_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit38 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
